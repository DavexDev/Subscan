import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:subscan/core/theme/design_tokens.dart';
import 'package:subscan/features/auth/models/linked_account.dart';
import 'package:subscan/features/auth/providers/linked_accounts_provider.dart';
import 'package:subscan/features/subscriptions/providers/subscription_notifier_provider.dart';

const Color _kBg = Color(0xFF030B3F);
const Color _kCard = Color(0xFF0D1854);
const Color _kAccent = Color(0xFF4F6BFF);
const Color _kGreen = Color(0xFF07D47B);

/// Pantalla de sincronización Gmail — todas las cuentas en paralelo.
class GmailSyncOverlayPage extends ConsumerStatefulWidget {
  const GmailSyncOverlayPage({super.key});

  @override
  ConsumerState<GmailSyncOverlayPage> createState() =>
      _GmailSyncOverlayPageState();
}

class _GmailSyncOverlayPageState extends ConsumerState<GmailSyncOverlayPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseCtrl;
  late Animation<double> _pulse;

  List<LinkedAccount> _accounts = [];
  // null = pendiente/en progreso, int = resultado (cantidad encontrada)
  final Map<String, int?> _results = {};
  bool _allDone = false;
  int _totalNew = 0;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _pulse = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) => _startSync());
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    super.dispose();
  }

  Future<void> _startSync() async {
    final accounts = ref.read(linkedAccountsProvider);
    final notifier = ref.read(subscriptionNotifierProvider.notifier);

    if (accounts.isEmpty) {
      // Sin cuentas vinculadas: usar cuenta activa de Google Sign-In
      setState(() {
        _accounts = [
          LinkedAccount(
            id: 'default',
            email: 'Cuenta activa',
            userId: '',
            createdAt: DateTime.now(),
          ),
        ];
        _results['default'] = null;
      });

      await notifier.syncGmail();
      setState(() {
        _results['default'] = 0;
        _allDone = true;
      });
      _pulseCtrl.stop();
      return;
    }

    setState(() {
      _accounts = accounts;
      // Todos en null = todos en progreso simultáneamente
      for (final a in accounts) {
        _results[a.email] = null;
      }
    });

    // Lanzar todas las cuentas EN PARALELO
    final futures = accounts.map((account) async {
      final count = await notifier.syncGmailAccount(account);
      if (mounted) {
        setState(() => _results[account.email] = count);
      }
      return count;
    });

    final counts = await Future.wait(futures);
    await notifier.loadSubscriptions();

    if (mounted) {
      setState(() {
        _totalNew = counts.fold(0, (a, b) => a + b);
        _allDone = true;
      });
      _pulseCtrl.stop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final doneCount = _results.values.where((v) => v != null).length;
    final totalCount = _accounts.length;
    final progress = totalCount == 0 ? 0.0 : doneCount / totalCount;

    return Scaffold(
      backgroundColor: _kBg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: DesignTokens.s24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 60),

              // Ícono animado
              ScaleTransition(
                scale: _allDone
                    ? const AlwaysStoppedAnimation(1.0)
                    : _pulse,
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: _kAccent.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: _kAccent.withValues(alpha: 0.4),
                      width: 2,
                    ),
                  ),
                  child: Icon(
                    _allDone ? Icons.check_rounded : Icons.email_outlined,
                    color: _allDone ? _kGreen : _kAccent,
                    size: 38,
                  ),
                ),
              ),
              const SizedBox(height: DesignTokens.s24),

              Text(
                _allDone ? '¡Sincronización completa!' : 'Escaneando correos',
                style: const TextStyle(
                  fontFamily: DesignTokens.fontFamily,
                  fontSize: 22,
                  fontWeight: DesignTokens.wBold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: DesignTokens.s8),
              Text(
                _allDone
                    ? '$_totalNew suscripción${_totalNew == 1 ? '' : 'es'} nueva${_totalNew == 1 ? '' : 's'} encontrada${_totalNew == 1 ? '' : 's'}'
                    : 'Revisando ${_accounts.length} cuenta${_accounts.length == 1 ? '' : 's'} simultáneamente…',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: DesignTokens.fontFamily,
                  fontSize: 14,
                  color: Colors.white.withValues(alpha: 0.65),
                ),
              ),
              const SizedBox(height: DesignTokens.s32),

              // Barra de progreso
              if (_accounts.length > 1) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '$doneCount de $totalCount cuentas',
                      style: TextStyle(
                        fontFamily: DesignTokens.fontFamily,
                        fontSize: 12,
                        color: Colors.white.withValues(alpha: 0.55),
                      ),
                    ),
                    Text(
                      '${(progress * 100).toInt()}%',
                      style: TextStyle(
                        fontFamily: DesignTokens.fontFamily,
                        fontSize: 12,
                        fontWeight: DesignTokens.wSemibold,
                        color: Colors.white.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: DesignTokens.s8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: progress,
                    backgroundColor: Colors.white.withValues(alpha: 0.1),
                    valueColor:
                        const AlwaysStoppedAnimation<Color>(_kAccent),
                    minHeight: 6,
                  ),
                ),
                const SizedBox(height: DesignTokens.s24),
              ],

              // Lista de cuentas (todas con spinner al mismo tiempo)
              Expanded(
                child: ListView.separated(
                  itemCount: _accounts.length,
                  separatorBuilder: (_, __) =>
                      const SizedBox(height: DesignTokens.s12),
                  itemBuilder: (context, i) {
                    final account = _accounts[i];
                    final key = account.id == 'default'
                        ? 'default'
                        : account.email;
                    final result = _results[key];
                    return _AccountRow(account: account, result: result);
                  },
                ),
              ),

              // Botón al terminar
              if (_allDone) ...[
                const SizedBox(height: DesignTokens.s16),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _kAccent,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(DesignTokens.rL),
                      ),
                    ),
                    child: const Text(
                      'Ver mis suscripciones',
                      style: TextStyle(
                        fontFamily: DesignTokens.fontFamily,
                        fontSize: 15,
                        fontWeight: DesignTokens.wSemibold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: DesignTokens.s32),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Fila de cuenta ───────────────────────────────────────────────────────────

class _AccountRow extends StatelessWidget {
  final LinkedAccount account;
  final int? result; // null = en progreso, int ≥ 0 = terminado

  const _AccountRow({required this.account, required this.result});

  @override
  Widget build(BuildContext context) {
    final isDone = result != null;

    return Container(
      padding: const EdgeInsets.all(DesignTokens.s16),
      decoration: BoxDecoration(
        color: _kCard,
        borderRadius: BorderRadius.circular(DesignTokens.rL),
        border: Border.all(
          color: !isDone
              ? _kAccent.withValues(alpha: 0.45)
              : Colors.white.withValues(alpha: 0.08),
          width: !isDone ? 1.5 : 1,
        ),
      ),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: _kAccent.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                account.email.isNotEmpty
                    ? account.email[0].toUpperCase()
                    : 'G',
                style: const TextStyle(
                  fontFamily: DesignTokens.fontFamily,
                  fontSize: 18,
                  fontWeight: DesignTokens.wBold,
                  color: _kAccent,
                ),
              ),
            ),
          ),
          const SizedBox(width: DesignTokens.s12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  account.displayName ?? account.email,
                  style: const TextStyle(
                    fontFamily: DesignTokens.fontFamily,
                    fontSize: 14,
                    fontWeight: DesignTokens.wSemibold,
                    color: Colors.white,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  !isDone
                      ? 'Buscando suscripciones…'
                      : result! > 0
                          ? '$result nueva${result == 1 ? '' : 's'} encontrada${result == 1 ? '' : 's'}'
                          : 'Sin novedades',
                  style: TextStyle(
                    fontFamily: DesignTokens.fontFamily,
                    fontSize: 12,
                    color: !isDone
                        ? _kAccent
                        : isDone && result! > 0
                            ? _kGreen
                            : Colors.white.withValues(alpha: 0.5),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: DesignTokens.s8),
          if (!isDone)
            const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(_kAccent),
              ),
            )
          else
            Icon(
              result! > 0
                  ? Icons.check_circle_rounded
                  : Icons.check_circle_outline_rounded,
              color: result! > 0
                  ? _kGreen
                  : Colors.white.withValues(alpha: 0.35),
              size: 22,
            ),
        ],
      ),
    );
  }
}
