import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:subscan/core/theme/design_tokens.dart';
import 'package:subscan/features/auth/auth_provider.dart';

const Color _kBg = Color(0xFF030B3F);
const Color _kCard = Color(0xFF3B4792);
const Color _kAccent = Color(0xFF4F6BFF);
const Color _kSuccess = Color(0xFF10B981);
const Color _kError = Color(0xFFEF4444);

class SeguridadPage extends ConsumerStatefulWidget {
  const SeguridadPage({super.key});

  @override
  ConsumerState<SeguridadPage> createState() => _SeguridadPageState();
}

class _SeguridadPageState extends ConsumerState<SeguridadPage> {
  final _currentCtrl = TextEditingController();
  final _newCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();

  bool _showCurrent = false;
  bool _showNew = false;
  bool _showConfirm = false;
  bool _saving = false;
  String? _errorMsg;
  bool _success = false;
  String _newPassValue = '';

  @override
  void dispose() {
    _currentCtrl.dispose();
    _newCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  bool _isEmailProvider(User user) =>
      user.providerData.any((p) => p.providerId == 'password');

  String _formatLastSignIn(DateTime? dt) {
    if (dt == null) return 'Desconocido';
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inDays == 0) return 'Hoy';
    if (diff.inDays == 1) return 'Ayer';
    if (diff.inDays < 7) return 'Hace ${diff.inDays} días';
    return '${dt.day}/${dt.month}/${dt.year}';
  }

  // 0 = débil, 1 = media, 2 = fuerte
  int _strength(String p) {
    if (p.length < 6) return 0;
    if (p.length < 10) return 1;
    return 2;
  }

  Future<void> _changePassword() async {
    setState(() {
      _errorMsg = null;
      _success = false;
    });

    final current = _currentCtrl.text.trim();
    final newPass = _newCtrl.text.trim();
    final confirm = _confirmCtrl.text.trim();

    if (current.isEmpty || newPass.isEmpty || confirm.isEmpty) {
      setState(() => _errorMsg = 'Completa todos los campos.');
      return;
    }
    if (newPass != confirm) {
      setState(() => _errorMsg = 'Las contraseñas nuevas no coinciden.');
      return;
    }
    if (newPass.length < 6) {
      setState(() =>
          _errorMsg = 'La nueva contraseña debe tener al menos 6 caracteres.');
      return;
    }

    setState(() => _saving = true);
    try {
      await ref.read(authServiceProvider).changePassword(current, newPass);
      if (!mounted) return;
      setState(() {
        _success = true;
        _newPassValue = '';
      });
      _currentCtrl.clear();
      _newCtrl.clear();
      _confirmCtrl.clear();
    } on FirebaseAuthException catch (e) {
      setState(() => _errorMsg = _friendlyError(e.code));
    } catch (_) {
      setState(() => _errorMsg = 'Ocurrió un error. Intenta de nuevo.');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  String _friendlyError(String code) {
    switch (code) {
      case 'wrong-password':
      case 'invalid-credential':
        return 'La contraseña actual es incorrecta.';
      case 'weak-password':
        return 'La nueva contraseña es muy débil (mínimo 6 caracteres).';
      case 'requires-recent-login':
        return 'Por seguridad, cierra sesión e inicia de nuevo antes de cambiar tu contraseña.';
      default:
        return 'Error al actualizar la contraseña. Intenta de nuevo.';
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);
    if (user == null) return const SizedBox.shrink();

    final isEmail = _isEmailProvider(user);

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
          'Seguridad',
          style: TextStyle(
            fontFamily: DesignTokens.fontFamily,
            fontSize: 20,
            fontWeight: DesignTokens.wBold,
            color: Colors.white,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(DesignTokens.s16),
        children: [
          _SectionLabel('SESIÓN ACTIVA'),
          const SizedBox(height: DesignTokens.s8),
          _buildSessionCard(user, isEmail),
          const SizedBox(height: DesignTokens.s24),
          _SectionLabel('CONTRASEÑA'),
          const SizedBox(height: DesignTokens.s8),
          isEmail ? _buildPasswordForm() : _buildGooglePasswordCard(),
          const SizedBox(height: DesignTokens.s24),
          _buildTwoFACard(),
          const SizedBox(height: DesignTokens.s32),
        ],
      ),
    );
  }

  // ─── Session card ────────────────────────────────────────────────────────────

  Widget _buildSessionCard(User user, bool isEmail) {
    final providerLabel = isEmail ? 'Correo electrónico' : 'Google';
    final providerIcon =
        isEmail ? Icons.email_outlined : Icons.g_mobiledata_rounded;
    final providerColor =
        isEmail ? const Color(0xFF6366F1) : const Color(0xFF4285F4);
    final lastSignIn = _formatLastSignIn(user.metadata.lastSignInTime);

    return Container(
      decoration: BoxDecoration(
        color: _kCard,
        borderRadius: BorderRadius.circular(DesignTokens.rL),
      ),
      child: Column(
        children: [
          _InfoRow(
            icon: providerIcon,
            iconColor: providerColor,
            label: 'Proveedor',
            value: providerLabel,
          ),
          Divider(
              height: 1,
              indent: DesignTokens.s16,
              endIndent: DesignTokens.s16,
              color: Colors.white.withValues(alpha: 0.08)),
          _InfoRow(
            icon: Icons.alternate_email_rounded,
            iconColor: const Color(0xFF8B5CF6),
            label: 'Correo',
            value: user.email ?? '—',
          ),
          Divider(
              height: 1,
              indent: DesignTokens.s16,
              endIndent: DesignTokens.s16,
              color: Colors.white.withValues(alpha: 0.08)),
          _InfoRow(
            icon: Icons.access_time_rounded,
            iconColor: const Color(0xFF10B981),
            label: 'Último acceso',
            value: lastSignIn,
            isLast: true,
          ),
        ],
      ),
    );
  }

  // ─── Password form ────────────────────────────────────────────────────────────

  Widget _buildPasswordForm() {
    final level = _strength(_newPassValue);
    final strengthColor = [_kError, const Color(0xFFF59E0B), _kSuccess][level];
    final strengthLabel = ['Débil', 'Media', 'Fuerte'][level];

    return Container(
      padding: const EdgeInsets.all(DesignTokens.s16),
      decoration: BoxDecoration(
        color: _kCard,
        borderRadius: BorderRadius.circular(DesignTokens.rL),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _PassField(
            label: 'Contraseña actual',
            controller: _currentCtrl,
            isVisible: _showCurrent,
            onToggle: () => setState(() => _showCurrent = !_showCurrent),
          ),
          const SizedBox(height: DesignTokens.s12),
          _PassField(
            label: 'Nueva contraseña',
            controller: _newCtrl,
            isVisible: _showNew,
            onToggle: () => setState(() => _showNew = !_showNew),
            onChanged: (v) => setState(() => _newPassValue = v),
          ),
          if (_newPassValue.isNotEmpty) ...[
            const SizedBox(height: DesignTokens.s8),
            _StrengthBar(level: level, color: strengthColor, label: strengthLabel),
          ],
          const SizedBox(height: DesignTokens.s12),
          _PassField(
            label: 'Confirmar nueva contraseña',
            controller: _confirmCtrl,
            isVisible: _showConfirm,
            onToggle: () => setState(() => _showConfirm = !_showConfirm),
          ),
          if (_errorMsg != null) ...[
            const SizedBox(height: DesignTokens.s12),
            _FeedbackBanner(message: _errorMsg!, isError: true),
          ],
          if (_success) ...[
            const SizedBox(height: DesignTokens.s12),
            _FeedbackBanner(
                message: 'Contraseña actualizada correctamente.',
                isError: false),
          ],
          const SizedBox(height: DesignTokens.s16),
          SizedBox(
            width: double.infinity,
            height: 46,
            child: ElevatedButton(
              onPressed: _saving ? null : _changePassword,
              style: ElevatedButton.styleFrom(
                backgroundColor: _kAccent,
                disabledBackgroundColor: _kAccent.withValues(alpha: 0.4),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(DesignTokens.rL),
                ),
              ),
              child: _saving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white),
                    )
                  : const Text(
                      'Actualizar contraseña',
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

  // ─── Google password card ─────────────────────────────────────────────────────

  Widget _buildGooglePasswordCard() {
    return Container(
      padding: const EdgeInsets.all(DesignTokens.s16),
      decoration: BoxDecoration(
        color: _kCard,
        borderRadius: BorderRadius.circular(DesignTokens.rL),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFF4285F4).withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.g_mobiledata_rounded,
                color: Color(0xFF4285F4), size: 22),
          ),
          const SizedBox(width: DesignTokens.s12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Cuenta de Google',
                  style: TextStyle(
                    fontFamily: DesignTokens.fontFamily,
                    fontSize: 15,
                    fontWeight: DesignTokens.wSemibold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Administra tu contraseña desde myaccount.google.com',
                  style: TextStyle(
                    fontFamily: DesignTokens.fontFamily,
                    fontSize: 12,
                    height: 1.4,
                    color: Colors.white.withValues(alpha: 0.55),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── 2FA card ─────────────────────────────────────────────────────────────────

  Widget _buildTwoFACard() {
    return Container(
      padding: const EdgeInsets.all(DesignTokens.s16),
      decoration: BoxDecoration(
        color: _kAccent.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(DesignTokens.rL),
        border: Border.all(color: _kAccent.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: _kAccent.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.shield_rounded, color: _kAccent, size: 20),
          ),
          const SizedBox(width: DesignTokens.s12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text(
                      'Autenticación en dos pasos',
                      style: TextStyle(
                        fontFamily: DesignTokens.fontFamily,
                        fontSize: 14,
                        fontWeight: DesignTokens.wSemibold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: DesignTokens.s8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 7, vertical: 2),
                      decoration: BoxDecoration(
                        color: _kAccent.withValues(alpha: 0.25),
                        borderRadius:
                            BorderRadius.circular(DesignTokens.rFull),
                      ),
                      child: const Text(
                        'Pronto',
                        style: TextStyle(
                          fontFamily: DesignTokens.fontFamily,
                          fontSize: 10,
                          fontWeight: DesignTokens.wSemibold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  'Agrega una capa extra de seguridad a tu cuenta.',
                  style: TextStyle(
                    fontFamily: DesignTokens.fontFamily,
                    fontSize: 12,
                    height: 1.4,
                    color: Colors.white.withValues(alpha: 0.55),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Shared widgets ───────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
          left: DesignTokens.s4, bottom: DesignTokens.s4),
      child: Text(
        text,
        style: TextStyle(
          fontFamily: DesignTokens.fontFamily,
          fontSize: 11,
          fontWeight: DesignTokens.wSemibold,
          letterSpacing: 1.2,
          color: Colors.white.withValues(alpha: 0.4),
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;
  final bool isLast;

  const _InfoRow({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: DesignTokens.s16,
        vertical: isLast ? 14.0 : 14.0,
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(DesignTokens.rS),
            ),
            child: Icon(icon, color: iconColor, size: 17),
          ),
          const SizedBox(width: DesignTokens.s12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontFamily: DesignTokens.fontFamily,
                    fontSize: 11,
                    color: Colors.white.withValues(alpha: 0.5),
                  ),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontFamily: DesignTokens.fontFamily,
                    fontSize: 14,
                    fontWeight: DesignTokens.wMedium,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PassField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final bool isVisible;
  final VoidCallback onToggle;
  final ValueChanged<String>? onChanged;

  const _PassField({
    required this.label,
    required this.controller,
    required this.isVisible,
    required this.onToggle,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: !isVisible,
      onChanged: onChanged,
      style: const TextStyle(
        fontFamily: DesignTokens.fontFamily,
        color: Colors.white,
        fontSize: 15,
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          fontFamily: DesignTokens.fontFamily,
          color: Colors.white.withValues(alpha: 0.55),
          fontSize: 13,
        ),
        suffixIcon: IconButton(
          icon: Icon(
            isVisible ? Icons.visibility_off_rounded : Icons.visibility_rounded,
            color: Colors.white.withValues(alpha: 0.4),
            size: 20,
          ),
          onPressed: onToggle,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(DesignTokens.rM),
          borderSide:
              BorderSide(color: Colors.white.withValues(alpha: 0.18)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(DesignTokens.rM),
          borderSide: const BorderSide(color: _kAccent),
        ),
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.05),
        contentPadding: const EdgeInsets.symmetric(
            horizontal: DesignTokens.s16, vertical: DesignTokens.s12),
      ),
    );
  }
}

class _StrengthBar extends StatelessWidget {
  final int level; // 0,1,2
  final Color color;
  final String label;

  const _StrengthBar(
      {required this.level, required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        ...List.generate(3, (i) {
          return Expanded(
            child: Container(
              height: 3,
              margin: EdgeInsets.only(right: i < 2 ? 4 : 0),
              decoration: BoxDecoration(
                color: i <= level ? color : Colors.white.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          );
        }),
        const SizedBox(width: DesignTokens.s8),
        Text(
          label,
          style: TextStyle(
            fontFamily: DesignTokens.fontFamily,
            fontSize: 12,
            fontWeight: DesignTokens.wMedium,
            color: color,
          ),
        ),
      ],
    );
  }
}

class _FeedbackBanner extends StatelessWidget {
  final String message;
  final bool isError;

  const _FeedbackBanner({required this.message, required this.isError});

  @override
  Widget build(BuildContext context) {
    final color = isError ? _kError : _kSuccess;
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: DesignTokens.s12, vertical: DesignTokens.s10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(DesignTokens.rM),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(
            isError ? Icons.error_outline_rounded : Icons.check_circle_outline_rounded,
            color: color,
            size: 16,
          ),
          const SizedBox(width: DesignTokens.s8),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                fontFamily: DesignTokens.fontFamily,
                fontSize: 13,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
