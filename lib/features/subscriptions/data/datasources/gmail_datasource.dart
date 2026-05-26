import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:googleapis/gmail/v1.dart' as gmail;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:subscan/core/services/known_services.dart';
import 'package:subscan/features/subscriptions/data/datasources/subscription_datasource.dart';
import 'package:subscan/features/subscriptions/models/subscription.dart';

class _GoogleAuthClient extends http.BaseClient {
  final Map<String, String> _headers;
  final http.Client _client = http.Client();

  _GoogleAuthClient(this._headers);

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    request.headers.addAll(_headers);
    return _client.send(request);
  }
}

/// Datasource READ-ONLY que detecta suscripciones desde Gmail.
/// Prioriza [accessToken] (no requiere UI). Si no hay token usa Google Sign-In.
class GmailDatasource implements SubscriptionDatasource {
  final String? accessToken; // token guardado al vincular cuenta
  final String? emailHint;   // email para mostrar en errores/logs

  GmailDatasource({this.accessToken, this.emailHint});

  static const _scopes = [
    'https://www.googleapis.com/auth/gmail.readonly',
    'https://www.googleapis.com/auth/userinfo.email',
  ];

  @override
  Future<List<Subscription>> getSubscriptions() async {
    // 1. Intentar con token guardado
    if (accessToken != null && accessToken!.isNotEmpty) {
      final client = _GoogleAuthClient({
        'Authorization': 'Bearer $accessToken',
        'X-Goog-AuthUser': '0',
      });
      try {
        final result = await _fetchWithClient(client, emailHint ?? 'cuenta vinculada');
        client._client.close();
        return result;
      } catch (e) {
        client._client.close();
        final msg = e.toString();
        if (msg.contains('401') || msg.contains('invalid authentication') ||
            msg.contains('unauthorized') || msg.contains('credentials')) {
          debugPrint('[Gmail] Token expirado para $emailHint — refrescando con sign-in silencioso');
          // Continúa al flujo de refresh abajo
        } else {
          rethrow;
        }
      }
    }

    // 2. Refresh silencioso (sin UI) usando loginHint para la cuenta correcta
    final googleSignIn = GoogleSignIn(scopes: _scopes);
    final account = await googleSignIn.signInSilently() ?? await googleSignIn.signIn();
    if (account == null) throw Exception('Gmail no autenticado');
    final headers = await account.authHeaders;
    final client = _GoogleAuthClient(headers);
    final result = await _fetchWithClient(client, account.email);
    client._client.close();
    return result;
  }

  Future<List<Subscription>> _fetchWithClient(
      _GoogleAuthClient authClient, String accountEmail) async {
    final gmailApi = gmail.GmailApi(authClient);

    final cutoff = DateTime.now().subtract(const Duration(days: 30));
    final after = '${cutoff.year}/${cutoff.month.toString().padLeft(2, '0')}/${cutoff.day.toString().padLeft(2, '0')}';

    final results = await gmailApi.users.messages.list(
      'me',
      q: 'subject:(renovación OR renewal OR suscripción OR subscription OR billing OR invoice OR receipt OR recibo) after:$after',
      maxResults: 30,
    );

    if (results.messages == null || results.messages!.isEmpty) return [];

    final subscriptions = <Subscription>[];
    for (final ref in results.messages!) {
      try {
        final msg = await gmailApi.users.messages.get('me', ref.id!, format: 'full');
        final sub = _parse(msg, accountEmail);
        if (sub != null) subscriptions.add(sub);
      } catch (e) {
        debugPrint('[Gmail] Error procesando mensaje: $e');
      }
    }
    return subscriptions;
  }

  Subscription? _parse(gmail.Message message, String accountEmail) {
    final headers = message.payload?.headers ?? [];
    final subject = _header(headers, 'Subject') ?? '';
    final from = _header(headers, 'From') ?? '';
    final date = _header(headers, 'Date') ?? '';
    final body = _decodeBody(message.payload);
    final fullText = '$subject $from $body'.toLowerCase();

    final nombre = _detectService(fullText, subject);
    if (nombre == null) {
      debugPrint('[Gmail] SKIP (sin servicio): "$subject"');
      return null;
    }

    final priceText = '${body ?? ''} $subject';
    final priceResult = _extractPriceAndCurrency(priceText);
    final precio = priceResult?.$1;
    final currency = priceResult?.$2 ?? 'GTQ';
    debugPrint('[Gmail] OK servicio=$nombre precio=$precio moneda=$currency | "$subject"');
    if (precio == null || precio <= 0) {
      debugPrint('[Gmail] SKIP (sin precio): "$subject"');
      return null;
    }

    return Subscription(
      id: message.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      nombre: nombre,
      precioActual: precio,
      precioOriginal: precio,
      fechaRenovacion: _extractDate(body ?? '', date),
      fuente: 'gmail',
      currency: currency,
      emailCuenta: accountEmail,
      createdAt: DateTime.now(),
    );
  }

  String? _header(List<gmail.MessagePartHeader> headers, String name) {
    for (final h in headers) {
      if (h.name?.toLowerCase() == name.toLowerCase()) return h.value;
    }
    return null;
  }

  String? _decodeBody(gmail.MessagePart? part) {
    if (part == null) return null;
    if (part.parts != null) {
      for (final p in part.parts!) {
        if (p.mimeType == 'text/plain') return _decodeBase64(p.body?.data);
      }
      for (final p in part.parts!) {
        final result = _decodeBody(p);
        if (result != null) return result;
      }
    }
    return _decodeBase64(part.body?.data);
  }

  String? _decodeBase64(String? data) {
    if (data == null || data.isEmpty) return null;
    try {
      final bytes = base64Url.decode(base64Url.normalize(data));
      return utf8.decode(bytes);
    } catch (_) {
      return null;
    }
  }

  String? _detectService(String fullText, String subject) {
    final subjectLower = subject.toLowerCase();
    // First pass: subject only — avoids body noise (footers, payment mentions, etc.)
    for (final entry in kKnownServices.entries) {
      final pattern = RegExp(
        r'(^|[^a-záéíóúüñ])' + RegExp.escape(entry.key) + r'($|[^a-záéíóúüñ])',
        caseSensitive: false,
        unicode: true,
      );
      if (pattern.hasMatch(subjectLower)) return entry.value;
    }
    // Second pass: full text (from + body) — for cases where subject is generic
    for (final entry in kKnownServices.entries) {
      final pattern = RegExp(
        r'(^|[^a-záéíóúüñ])' + RegExp.escape(entry.key) + r'($|[^a-záéíóúüñ])',
        caseSensitive: false,
        unicode: true,
      );
      if (pattern.hasMatch(fullText)) return entry.value;
    }
    return null;
  }

  /// Ordered patterns: (regex, currency). Most specific first to avoid false matches.
  static final _pricePatterns = <(RegExp, String)>[
    (RegExp(r'MX\$\s*(\d{1,4}[.,]\d{2})'), 'MXN'),
    (RegExp(r'(\d{1,4}[.,]\d{2})\s*MXN'), 'MXN'),
    (RegExp(r'MXN\s*(\d{1,4}[.,]\d{2})'), 'MXN'),
    (RegExp(r'MX\$\s*(\d{1,4})(?!\s*[.,]\d)'), 'MXN'),
    (RegExp(r'(\d{1,4})\s*MXN(?!\d)'), 'MXN'),
    (RegExp(r'€\s*(\d{1,4}[.,]\d{2})'), 'EUR'),
    (RegExp(r'(\d{1,4}[.,]\d{2})\s*EUR'), 'EUR'),
    (RegExp(r'EUR\s*(\d{1,4}[.,]\d{2})'), 'EUR'),
    (RegExp(r'(\d{1,4})\s*EUR(?!\d)'), 'EUR'),
    (RegExp(r'£\s*(\d{1,4}[.,]\d{2})'), 'GBP'),
    (RegExp(r'(\d{1,4}[.,]\d{2})\s*GBP'), 'GBP'),
    (RegExp(r'GBP\s*(\d{1,4}[.,]\d{2})'), 'GBP'),
    (RegExp(r'£\s*(\d{1,4})(?!\s*[.,]\d)'), 'GBP'),
    (RegExp(r'Q\.?\s*(\d{1,4}[.,]\d{2})'), 'GTQ'),
    (RegExp(r'(\d{1,4}[.,]\d{2})\s*GTQ'), 'GTQ'),
    (RegExp(r'GTQ\s*(\d{1,4}[.,]\d{2})'), 'GTQ'),
    (RegExp(r'Q\.?\s*(\d{1,4})(?!\s*[.,]\d)'), 'GTQ'),
    (RegExp(r'\$\s*(\d{1,4}[.,]\d{2})'), 'USD'),
    (RegExp(r'(\d{1,4}[.,]\d{2})\s*USD'), 'USD'),
    (RegExp(r'USD\s*(\d{1,4}[.,]\d{2})'), 'USD'),
    (RegExp(r'(\d{1,4}[.,]\d{2})\s*(?:COP|ARS|BRL|CLP|PEN)'), 'USD'),
    (RegExp(r'\$\s*(\d{1,4})(?!\s*[.,]\d)'), 'USD'),
    (RegExp(r'(\d{1,4})\s*USD(?!\d)'), 'USD'),
    (RegExp(r'(\d{1,4})\s*COP(?!\d)'), 'USD'),
  ];

  (double, String)? _extractPriceAndCurrency(String text) {
    for (final (regex, currency) in _pricePatterns) {
      final match = regex.firstMatch(text);
      if (match != null) {
        final raw = match.group(1)!.replaceAll(',', '.');
        final val = double.tryParse(raw);
        if (val != null && val > 0) return (val, currency);
      }
    }
    return null;
  }

  DateTime _extractDate(String body, String dateHeader) {
    final patterns = [
      RegExp(r'(\d{4}-\d{2}-\d{2})'),
      RegExp(r'(\d{2}/\d{2}/\d{4})'),
      RegExp(r'(\d{2}-\d{2}-\d{4})'),
    ];
    for (final regex in patterns) {
      final match = regex.firstMatch(body);
      if (match != null) {
        final parsed = DateTime.tryParse(match.group(1)!);
        if (parsed != null && parsed.isAfter(DateTime.now())) return parsed;
      }
    }
    final emailDate = DateTime.tryParse(dateHeader);
    return (emailDate ?? DateTime.now()).add(const Duration(days: 30));
  }

  @override
  Future<void> saveSubscription(Subscription subscription) =>
      throw UnimplementedError('GmailDatasource es solo lectura');

  @override
  Future<void> updateSubscription(Subscription subscription) =>
      throw UnimplementedError('GmailDatasource es solo lectura');

  @override
  Future<void> deleteSubscription(String id) =>
      throw UnimplementedError('GmailDatasource es solo lectura');
}
