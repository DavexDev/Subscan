import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:subscan/core/theme/design_tokens.dart';
import 'package:subscan/features/subscriptions/models/subscription.dart';
import 'package:subscan/features/subscriptions/providers/subscription_notifier_provider.dart';

/// Pantalla para agregar o editar una suscripción manual.
///
/// - Pasa [subscription] para modo edición (pre-rellena el formulario).
/// - Sin [subscription] → modo creación.
class AddSubscriptionPage extends ConsumerStatefulWidget {
  final Subscription? subscription;

  const AddSubscriptionPage({super.key, this.subscription});

  bool get isEditing => subscription != null;

  @override
  ConsumerState<AddSubscriptionPage> createState() =>
      _AddSubscriptionPageState();
}

class _AddSubscriptionPageState extends ConsumerState<AddSubscriptionPage> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nombreCtrl;
  late final TextEditingController _precioCtrl;
  late final TextEditingController _precioOrigCtrl;
  late DateTime _fechaRenovacion;

  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final s = widget.subscription;
    _nombreCtrl = TextEditingController(text: s?.nombre ?? '');
    _precioCtrl = TextEditingController(
      text: s != null ? s.precioActual.toStringAsFixed(2) : '',
    );
    _precioOrigCtrl = TextEditingController(
      text: s?.precioOriginal != null
          ? s!.precioOriginal!.toStringAsFixed(2)
          : '',
    );
    _fechaRenovacion =
        s?.fechaRenovacion ?? DateTime.now().add(const Duration(days: 30));
  }

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _precioCtrl.dispose();
    _precioOrigCtrl.dispose();
    super.dispose();
  }

  // ─── Acciones ────────────────────────────────────────────────────────────────

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _fechaRenovacion,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 730)),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: ColorScheme.light(
            primary: DesignTokens.primary,
            onPrimary: Colors.white,
            surface: DesignTokens.surface,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() => _fechaRenovacion = picked);
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _saving = true);

    final id = widget.subscription?.id ??
        DateTime.now().millisecondsSinceEpoch.toString();
    final nombre = _nombreCtrl.text.trim();
    final precioActual = double.parse(_precioCtrl.text.replaceAll(',', '.'));
    final precioOriginalRaw = _precioOrigCtrl.text.trim();
    final precioOriginal = precioOriginalRaw.isNotEmpty
        ? double.tryParse(precioOriginalRaw.replaceAll(',', '.'))
        : null;

    final newSub = Subscription(
      id: id,
      nombre: nombre,
      precioActual: precioActual,
      precioOriginal: precioOriginal,
      fechaRenovacion: _fechaRenovacion,
      fuente: widget.subscription?.fuente ?? 'manual',
      createdAt: widget.subscription?.createdAt ?? DateTime.now(),
    );

    try {
      if (widget.isEditing) {
        await ref
            .read(subscriptionNotifierProvider.notifier)
            .editSubscription(newSub);
      } else {
        await ref
            .read(subscriptionNotifierProvider.notifier)
            .addSubscription(newSub);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.isEditing
                  ? '${newSub.nombre} actualizado ✅'
                  : '${newSub.nombre} agregado ✅',
            ),
            backgroundColor: DesignTokens.success,
            behavior: SnackBarBehavior.floating,
          ),
        );
        Navigator.of(context).pop(newSub);
      }
    } catch (_) {
      if (mounted) setState(() => _saving = false);
    }
  }

  // ─── Build ────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final title =
        widget.isEditing ? 'Editar suscripción' : 'Nueva suscripción';

    return Scaffold(
      backgroundColor: DesignTokens.background,
      appBar: AppBar(
        backgroundColor: DesignTokens.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text(
          title,
          style: const TextStyle(
            fontFamily: DesignTokens.fontFamily,
            fontWeight: DesignTokens.wSemibold,
            fontSize: 18,
            color: Colors.white,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(DesignTokens.s20),
          children: [
            // ── Sección: Servicio ─────────────────────────────────────────
            _SectionLabel('Servicio'),
            _FormCard(
              child: Column(
                children: [
                  _FieldRow(
                    icon: Icons.label_outline_rounded,
                    child: TextFormField(
                      controller: _nombreCtrl,
                      textCapitalization: TextCapitalization.words,
                      style: const TextStyle(
                        fontFamily: DesignTokens.fontFamily,
                        fontSize: 15,
                        color: DesignTokens.textPrimary,
                      ),
                      decoration: _inputDecoration('Nombre del servicio',
                          hint: 'ej. Netflix, Spotify…'),
                      validator: (v) => (v == null || v.trim().isEmpty)
                          ? 'Ingresa el nombre'
                          : null,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: DesignTokens.s20),

            // ── Sección: Precios ──────────────────────────────────────────
            _SectionLabel('Precios'),
            _FormCard(
              child: Column(
                children: [
                  _FieldRow(
                    icon: Icons.attach_money_rounded,
                    child: TextFormField(
                      controller: _precioCtrl,
                      keyboardType: const TextInputType.numberWithOptions(
                          decimal: true),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                            RegExp(r'^\d+[.,]?\d{0,2}')),
                      ],
                      style: const TextStyle(
                        fontFamily: DesignTokens.fontFamily,
                        fontSize: 15,
                        color: DesignTokens.textPrimary,
                      ),
                      decoration: _inputDecoration('Precio actual',
                          hint: '0.00', suffix: '/mes'),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) {
                          return 'Ingresa el precio';
                        }
                        final n =
                            double.tryParse(v.replaceAll(',', '.'));
                        if (n == null || n <= 0) {
                          return 'Precio inválido';
                        }
                        return null;
                      },
                    ),
                  ),
                  _Divider(),
                  _FieldRow(
                    icon: Icons.price_change_outlined,
                    child: TextFormField(
                      controller: _precioOrigCtrl,
                      keyboardType: const TextInputType.numberWithOptions(
                          decimal: true),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                            RegExp(r'^\d+[.,]?\d{0,2}')),
                      ],
                      style: const TextStyle(
                        fontFamily: DesignTokens.fontFamily,
                        fontSize: 15,
                        color: DesignTokens.textPrimary,
                      ),
                      decoration: _inputDecoration(
                        'Precio original',
                        hint: '0.00 (opcional)',
                        suffix: '/mes',
                      ),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) return null;
                        final n =
                            double.tryParse(v.replaceAll(',', '.'));
                        if (n == null || n <= 0) {
                          return 'Precio inválido';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: DesignTokens.s20),

            // ── Sección: Renovación ───────────────────────────────────────
            _SectionLabel('Renovación'),
            _FormCard(
              child: _FieldRow(
                icon: Icons.calendar_month_rounded,
                child: InkWell(
                  onTap: _pickDate,
                  borderRadius:
                      BorderRadius.circular(DesignTokens.rS),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: DesignTokens.s12),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Fecha de renovación',
                                style: const TextStyle(
                                  fontFamily: DesignTokens.fontFamily,
                                  fontSize: 12,
                                  color: DesignTokens.textSecondary,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                _formatDate(_fechaRenovacion),
                                style: const TextStyle(
                                  fontFamily: DesignTokens.fontFamily,
                                  fontSize: 15,
                                  fontWeight: DesignTokens.wMedium,
                                  color: DesignTokens.textPrimary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Icon(
                          Icons.chevron_right_rounded,
                          color: DesignTokens.textSecondary,
                          size: 20,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: DesignTokens.s32),

            // ── Botón guardar ─────────────────────────────────────────────
            SizedBox(
              width: double.infinity,
              height: 52,
              child: FilledButton(
                onPressed: _saving ? null : _submit,
                style: FilledButton.styleFrom(
                  backgroundColor: DesignTokens.primary,
                  disabledBackgroundColor:
                      DesignTokens.primary.withValues(alpha: 0.5),
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(DesignTokens.rM),
                  ),
                ),
                child: _saving
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white),
                        ),
                      )
                    : Text(
                        widget.isEditing ? 'Guardar cambios' : 'Agregar suscripción',
                        style: const TextStyle(
                          fontFamily: DesignTokens.fontFamily,
                          fontSize: 15,
                          fontWeight: DesignTokens.wSemibold,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: DesignTokens.s48),
          ],
        ),
      ),
    );
  }

  // ─── Helpers ──────────────────────────────────────────────────────────────────

  InputDecoration _inputDecoration(String label,
      {String? hint, String? suffix}) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      suffixText: suffix,
      labelStyle: const TextStyle(
        fontFamily: DesignTokens.fontFamily,
        fontSize: 13,
        color: DesignTokens.textSecondary,
      ),
      hintStyle: TextStyle(
        fontFamily: DesignTokens.fontFamily,
        fontSize: 14,
        color: DesignTokens.textDisabled,
      ),
      suffixStyle: const TextStyle(
        fontFamily: DesignTokens.fontFamily,
        fontSize: 13,
        color: DesignTokens.textSecondary,
      ),
      border: InputBorder.none,
      contentPadding: const EdgeInsets.symmetric(
        vertical: DesignTokens.s12,
      ),
      errorStyle: const TextStyle(
        fontFamily: DesignTokens.fontFamily,
        fontSize: 11,
        color: DesignTokens.error,
      ),
    );
  }

  String _formatDate(DateTime d) {
    final months = [
      'ene', 'feb', 'mar', 'abr', 'may', 'jun',
      'jul', 'ago', 'sep', 'oct', 'nov', 'dic',
    ];
    return '${d.day} ${months[d.month - 1]} ${d.year}';
  }
}

// ─── Widgets auxiliares ───────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        left: DesignTokens.s4,
        bottom: DesignTokens.s8,
      ),
      child: Text(
        text.toUpperCase(),
        style: const TextStyle(
          fontFamily: DesignTokens.fontFamily,
          fontSize: 10,
          fontWeight: DesignTokens.wBold,
          color: DesignTokens.textSecondary,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}

class _FormCard extends StatelessWidget {
  final Widget child;
  const _FormCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: DesignTokens.surface,
        borderRadius: BorderRadius.circular(DesignTokens.rL),
        boxShadow: [
          BoxShadow(
            color: DesignTokens.primary.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _FieldRow extends StatelessWidget {
  final IconData icon;
  final Widget child;
  const _FieldRow({required this.icon, required this.child});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: DesignTokens.s16,
        vertical: DesignTokens.s4,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(icon, size: 18, color: DesignTokens.primary),
          const SizedBox(width: DesignTokens.s12),
          Expanded(child: child),
        ],
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Divider(
      height: 1,
      indent: DesignTokens.s16 + 18 + DesignTokens.s12,
      color: DesignTokens.divider,
    );
  }
}
