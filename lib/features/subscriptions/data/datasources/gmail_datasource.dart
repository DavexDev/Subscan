import 'dart:convert';

import 'package:googleapis/gmail/v1.dart' as gmail;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:subscan/features/subscriptions/data/datasources/subscription_datasource.dart';
import 'package:subscan/features/subscriptions/models/subscription.dart';

/// Cliente HTTP que inyecta los headers de autenticación de Google.
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
class GmailDatasource implements SubscriptionDatasource {
  static const _scopes = [
    'https://www.googleapis.com/auth/gmail.readonly',
    'https://www.googleapis.com/auth/userinfo.email',
  ];

  final GoogleSignIn _googleSignIn = GoogleSignIn(scopes: _scopes);

  // Servicios conocidos: keyword → nombre para mostrar
  static const _knownServices = {
    'netflix': 'Netflix',
    'spotify': 'Spotify',
    'amazon prime': 'Amazon Prime',
    'amazon': 'Amazon',
    'disney': 'Disney+',
    'hulu': 'Hulu',
    'adobe': 'Adobe Creative Cloud',
    'microsoft': 'Microsoft 365',
    'github': 'GitHub',
    'notion': 'Notion',
    'youtube': 'YouTube Premium',
    'apple': 'Apple One',
    'dropbox': 'Dropbox',
    'duolingo': 'Duolingo Plus',
    'canva': 'Canva Pro',
    'chatgpt': 'ChatGPT Plus',
    'openai': 'ChatGPT Plus',
    'figma': 'Figma',
    'slack': 'Slack',
    'zoom': 'Zoom',
  };

  @override
  Future<List<Subscription>> getSubscriptions() async {
    final account =
        await _googleSignIn.signInSilently() ?? await _googleSignIn.signIn();

    if (account == null) throw Exception('Gmail no autenticado');

    final headers = await account.authHeaders;
    final authClient = _GoogleAuthClient(headers);
    final gmailApi = gmail.GmailApi(authClient);

    final results = await gmailApi.users.messages.list(
      'me',
      q:
          'subject:(renovación OR renewal OR suscripción OR subscription OR billing OR invoice)',
      maxResults: 20,
    );

    if (results.messages == null || results.messages!.isEmpty) return [];

    final subscriptions = <Subscription>[];

    for (final ref in results.messages!) {
      try {
        final msg = await gmailApi.users.messages.get(
          'me',
          ref.id!,
          format: 'full',
        );
        final sub = _parse(msg);
        if (sub != null) subscriptions.add(sub);
      } catch (_) {
        // Ignorar mensajes que no se puedan parsear
      }
    }

    authClient._client.close();
    return subscriptions;
  }

  Subscription? _parse(gmail.Message message) {
    final headers = message.payload?.headers ?? [];
    final subject = _header(headers, 'Subject') ?? '';
    final from = _header(headers, 'From') ?? '';
    final date = _header(headers, 'Date') ?? '';

    final body = _decodeBody(message.payload);
    final fullText = '$subject $from $body'.toLowerCase();

    final nombre = _detectService(fullText, subject);
    if (nombre == null) return null;

    final precio = _extractPrice(body ?? subject);
    if (precio == null || precio <= 0) return null;

    return Subscription(
      id: message.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      nombre: nombre,
      precioActual: precio,
      precioOriginal: precio,
      fechaRenovacion: _extractDate(body ?? '', date),
      fuente: 'gmail',
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

    // Multipart: buscar text/plain
    if (part.parts != null) {
      for (final p in part.parts!) {
        if (p.mimeType == 'text/plain') {
          return _decodeBase64(p.body?.data);
        }
      }
      // Fallback: cualquier parte
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
    for (final entry in _knownServices.entries) {
      if (fullText.contains(entry.key)) return entry.value;
    }

    // Fallback: limpiar el subject de palabras de renovación
    final cleaned = subject
        .replaceAll(
          RegExp(
            r'\b(renewal|renovaci[oó]n|billing|invoice|suscripci[oó]n|subscription|receipt|recibo)\b',
            caseSensitive: false,
          ),
          '',
        )
        .trim();

    return cleaned.isNotEmpty ? cleaned : null;
  }

  double? _extractPrice(String text) {
    final regex = RegExp(r'[\$€£]\s*(\d{1,4}[.,]\d{2})');
    final match = regex.firstMatch(text);
    if (match != null) {
      return double.tryParse(match.group(1)!.replaceAll(',', '.'));
    }
    return null;
  }

  DateTime _extractDate(String body, String dateHeader) {
    // Buscar patrones de fecha en el body
    final patterns = [
      RegExp(r'(\d{4}-\d{2}-\d{2})'), // ISO 8601
      RegExp(r'(\d{2}/\d{2}/\d{4})'), // DD/MM/YYYY
      RegExp(r'(\d{2}-\d{2}-\d{4})'), // DD-MM-YYYY
    ];

    for (final regex in patterns) {
      final match = regex.firstMatch(body);
      if (match != null) {
        final parsed = DateTime.tryParse(match.group(1)!);
        if (parsed != null && parsed.isAfter(DateTime.now())) return parsed;
      }
    }

    // Fallback: fecha del email + 30 días
    final emailDate = DateTime.tryParse(dateHeader);
    return (emailDate ?? DateTime.now()).add(const Duration(days: 30));
  }

  // READ-ONLY: las siguientes operaciones no aplican a Gmail

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
