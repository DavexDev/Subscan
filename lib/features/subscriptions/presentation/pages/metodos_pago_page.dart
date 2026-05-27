import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:subscan/core/theme/design_tokens.dart';
import 'package:subscan/features/subscriptions/providers/payment_methods_provider.dart';

const Color _kBg = Color(0xFF030B3F);
const Color _kCard = Color(0xFF3B4792);
const Color _kSheet = Color(0xFF0D1854);
const Color _kAccent = Color(0xFF4F6BFF);

// ─── Page ─────────────────────────────────────────────────────────────────────

class MetodosPagoPage extends ConsumerWidget {
  const MetodosPagoPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final methods = ref.watch(paymentMethodsProvider);

    return Scaffold(
      backgroundColor: _kBg,
      appBar: AppBar(
        backgroundColor: _kBg,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Métodos de pago',
          style: TextStyle(
            fontFamily: DesignTokens.fontFamily,
            fontSize: 20,
            fontWeight: DesignTokens.wBold,
            color: Colors.white,
          ),
        ),
        actions: [
          if (methods.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(right: DesignTokens.s8),
              child: IconButton(
                icon: const Icon(Icons.add_rounded,
                    color: Colors.white, size: 26),
                onPressed: () => _showAddSheet(context, ref),
              ),
            ),
        ],
      ),
      body: methods.isEmpty
          ? _EmptyState(onAdd: () => _showAddSheet(context, ref))
          : _MethodsList(
              methods: methods,
              onAdd: () => _showAddSheet(context, ref),
              onDelete: (id) =>
                  ref.read(paymentMethodsProvider.notifier).remove(id),
            ),
    );
  }

  void _showAddSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: _kSheet,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => _AddMethodSheet(
        onAdd: (tipo, alias) {
          ref.read(paymentMethodsProvider.notifier).add(tipo, alias);
          Navigator.of(ctx).pop();
        },
      ),
    );
  }
}

// ─── Empty State ──────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  final VoidCallback onAdd;
  const _EmptyState({required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: _kAccent.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.credit_card_rounded,
                color: _kAccent,
                size: 36,
              ),
            ),
            const SizedBox(height: DesignTokens.s20),
            const Text(
              'Sin métodos guardados',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: DesignTokens.fontFamily,
                fontSize: 18,
                fontWeight: DesignTokens.wBold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: DesignTokens.s10),
            Text(
              'Agrega tus tarjetas y métodos de pago para llevar un mejor control de tus suscripciones.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: DesignTokens.fontFamily,
                fontSize: 14,
                height: 1.5,
                color: Colors.white.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: DesignTokens.s32),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                onPressed: onAdd,
                icon: const Icon(Icons.add_rounded, size: 20),
                label: const Text(
                  'Agregar método',
                  style: TextStyle(
                    fontFamily: DesignTokens.fontFamily,
                    fontSize: 15,
                    fontWeight: DesignTokens.wSemibold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _kAccent,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(DesignTokens.rL),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Methods List ─────────────────────────────────────────────────────────────

class _MethodsList extends StatelessWidget {
  final List<PaymentMethod> methods;
  final VoidCallback onAdd;
  final ValueChanged<String> onDelete;

  const _MethodsList({
    required this.methods,
    required this.onAdd,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(DesignTokens.s16),
      children: [
        Container(
          padding: const EdgeInsets.all(DesignTokens.s12),
          decoration: BoxDecoration(
            color: _kAccent.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(DesignTokens.rM),
            border: Border.all(color: _kAccent.withValues(alpha: 0.2)),
          ),
          child: Row(
            children: [
              Icon(Icons.info_outline_rounded,
                  color: _kAccent.withValues(alpha: 0.8), size: 18),
              const SizedBox(width: DesignTokens.s10),
              Expanded(
                child: Text(
                  'Úsalos al registrar tus suscripciones para mejor seguimiento.',
                  style: TextStyle(
                    fontFamily: DesignTokens.fontFamily,
                    fontSize: 13,
                    height: 1.4,
                    color: Colors.white.withValues(alpha: 0.7),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: DesignTokens.s16),
        Container(
          decoration: BoxDecoration(
            color: _kCard,
            borderRadius: BorderRadius.circular(DesignTokens.rL),
          ),
          child: Column(
            children: List.generate(methods.length, (i) {
              return _MethodRow(
                method: methods[i],
                isLast: i == methods.length - 1,
                onDelete: () => onDelete(methods[i].id),
              );
            }),
          ),
        ),
        const SizedBox(height: DesignTokens.s16),
        SizedBox(
          width: double.infinity,
          height: 48,
          child: OutlinedButton.icon(
            onPressed: onAdd,
            icon: const Icon(Icons.add_rounded, size: 18),
            label: const Text(
              'Agregar método',
              style: TextStyle(
                fontFamily: DesignTokens.fontFamily,
                fontSize: 15,
                fontWeight: DesignTokens.wSemibold,
              ),
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.white,
              side: BorderSide(color: Colors.white.withValues(alpha: 0.3)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(DesignTokens.rL),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Method Row ───────────────────────────────────────────────────────────────

class _MethodRow extends StatelessWidget {
  final PaymentMethod method;
  final bool isLast;
  final VoidCallback onDelete;

  const _MethodRow({
    required this.method,
    required this.isLast,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final (icon, color) = _iconAndColor(method.tipo);
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(
              horizontal: DesignTokens.s16, vertical: 14),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(DesignTokens.rM),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      method.displayName,
                      style: const TextStyle(
                        fontFamily: DesignTokens.fontFamily,
                        fontSize: 15,
                        fontWeight: DesignTokens.wSemibold,
                        color: Colors.white,
                      ),
                    ),
                    if (method.alias != null && method.alias!.isNotEmpty)
                      Text(
                        method.tipo,
                        style: TextStyle(
                          fontFamily: DesignTokens.fontFamily,
                          fontSize: 12,
                          color: Colors.white.withValues(alpha: 0.5),
                        ),
                      ),
                  ],
                ),
              ),
              IconButton(
                icon: Icon(
                  Icons.delete_outline_rounded,
                  color: Colors.white.withValues(alpha: 0.4),
                  size: 20,
                ),
                onPressed: () => _confirmDelete(context),
              ),
            ],
          ),
        ),
        if (!isLast)
          Divider(
            height: 1,
            indent: 72,
            endIndent: DesignTokens.s16,
            color: Colors.white.withValues(alpha: 0.08),
          ),
      ],
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF0D1854),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(DesignTokens.rL)),
        title: const Text(
          '¿Eliminar método?',
          style: TextStyle(
            fontFamily: DesignTokens.fontFamily,
            fontWeight: DesignTokens.wBold,
            color: Colors.white,
          ),
        ),
        content: Text(
          'Se eliminará "${method.displayName}" de tus métodos guardados.',
          style: TextStyle(
            fontFamily: DesignTokens.fontFamily,
            color: Colors.white.withValues(alpha: 0.7),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Cancelar',
              style: TextStyle(
                fontFamily: DesignTokens.fontFamily,
                color: Colors.white.withValues(alpha: 0.6),
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              onDelete();
            },
            child: const Text(
              'Eliminar',
              style: TextStyle(
                fontFamily: DesignTokens.fontFamily,
                color: Color(0xFFEF4444),
                fontWeight: DesignTokens.wSemibold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Add Sheet ────────────────────────────────────────────────────────────────

class _AddMethodSheet extends StatefulWidget {
  final void Function(String tipo, String? alias) onAdd;
  const _AddMethodSheet({required this.onAdd});

  @override
  State<_AddMethodSheet> createState() => _AddMethodSheetState();
}

class _AddMethodSheetState extends State<_AddMethodSheet> {
  static const List<String> _types = [
    'Tarjeta de crédito',
    'Tarjeta de débito',
    'PayPal',
    'Google Pay',
    'Apple Pay',
    'Transferencia bancaria',
    'Otro',
  ];

  String? _selected;
  final _aliasCtrl = TextEditingController();

  @override
  void dispose() {
    _aliasCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: DesignTokens.s24,
        right: DesignTokens.s24,
        top: DesignTokens.s16,
        bottom: MediaQuery.of(context).viewInsets.bottom + DesignTokens.s32,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: DesignTokens.s20),
          const Text(
            'Agregar método de pago',
            style: TextStyle(
              fontFamily: DesignTokens.fontFamily,
              fontSize: 18,
              fontWeight: DesignTokens.wBold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: DesignTokens.s16),
          Wrap(
            spacing: DesignTokens.s8,
            runSpacing: DesignTokens.s8,
            children: _types.map((t) {
              final (icon, color) = _iconAndColor(t);
              final isSelected = _selected == t;
              return GestureDetector(
                onTap: () => setState(() => _selected = t),
                child: AnimatedContainer(
                  duration: DesignTokens.animFast,
                  padding: const EdgeInsets.symmetric(
                      horizontal: DesignTokens.s12, vertical: DesignTokens.s10),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? _kAccent.withValues(alpha: 0.18)
                        : Colors.white.withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(DesignTokens.rM),
                    border: Border.all(
                      color: isSelected
                          ? _kAccent
                          : Colors.white.withValues(alpha: 0.12),
                      width: isSelected ? 1.5 : 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        icon,
                        color: isSelected
                            ? color
                            : Colors.white.withValues(alpha: 0.6),
                        size: 16,
                      ),
                      const SizedBox(width: DesignTokens.s6),
                      Text(
                        t,
                        style: TextStyle(
                          fontFamily: DesignTokens.fontFamily,
                          fontSize: 13,
                          fontWeight: isSelected
                              ? DesignTokens.wSemibold
                              : DesignTokens.wRegular,
                          color: isSelected
                              ? Colors.white
                              : Colors.white.withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: DesignTokens.s20),
          TextField(
            controller: _aliasCtrl,
            style: const TextStyle(
              fontFamily: DesignTokens.fontFamily,
              color: Colors.white,
              fontSize: 15,
            ),
            decoration: InputDecoration(
              labelText: 'Alias (opcional)',
              hintText: 'Ej. Visa Banco Industrial',
              labelStyle: TextStyle(
                fontFamily: DesignTokens.fontFamily,
                color: Colors.white.withValues(alpha: 0.6),
              ),
              hintStyle: TextStyle(
                fontFamily: DesignTokens.fontFamily,
                color: Colors.white.withValues(alpha: 0.3),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(DesignTokens.rM),
                borderSide:
                    BorderSide(color: Colors.white.withValues(alpha: 0.2)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(DesignTokens.rM),
                borderSide: const BorderSide(color: _kAccent),
              ),
              filled: true,
              fillColor: Colors.white.withValues(alpha: 0.05),
            ),
          ),
          const SizedBox(height: DesignTokens.s24),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: _selected == null
                  ? null
                  : () => widget.onAdd(_selected!, _aliasCtrl.text),
              style: ElevatedButton.styleFrom(
                backgroundColor: _kAccent,
                disabledBackgroundColor: _kAccent.withValues(alpha: 0.3),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(DesignTokens.rL),
                ),
              ),
              child: const Text(
                'Agregar',
                style: TextStyle(
                  fontFamily: DesignTokens.fontFamily,
                  fontSize: 15,
                  fontWeight: DesignTokens.wSemibold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Helpers ──────────────────────────────────────────────────────────────────

(IconData, Color) _iconAndColor(String tipo) {
  switch (tipo) {
    case 'Tarjeta de crédito':
      return (Icons.credit_card_rounded, const Color(0xFF6366F1));
    case 'Tarjeta de débito':
      return (Icons.credit_card_outlined, const Color(0xFF10B981));
    case 'PayPal':
      return (Icons.account_balance_wallet_rounded, const Color(0xFF009CDE));
    case 'Google Pay':
      return (Icons.g_mobiledata_rounded, const Color(0xFF4285F4));
    case 'Apple Pay':
      return (Icons.phone_iphone_rounded, const Color(0xFFE2E8F0));
    case 'Transferencia bancaria':
      return (Icons.account_balance_rounded, const Color(0xFFF59E0B));
    default:
      return (Icons.payment_rounded, const Color(0xFF8B5CF6));
  }
}
