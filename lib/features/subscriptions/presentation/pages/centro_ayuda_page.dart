import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:subscan/core/theme/design_tokens.dart';

const Color _kBg = Color(0xFF030B3F);
const Color _kCard = Color(0xFF3B4792);
const Color _kAccent = Color(0xFF4F6BFF);
const Color _kSheet = Color(0xFF0D1854);

// ─── Model ────────────────────────────────────────────────────────────────────

class _FaqItem {
  final String question;
  final String answer;
  final String category;

  const _FaqItem({
    required this.question,
    required this.answer,
    required this.category,
  });
}

const _kCategories = ['Todas', 'Suscripciones', 'Cuenta', 'PODA', 'Privacidad'];

const List<_FaqItem> _faqs = [
  // ── Suscripciones ──────────────────────────────────────────────────────────
  _FaqItem(
    category: 'Suscripciones',
    question: '¿Cómo agrego una suscripción manualmente?',
    answer:
        'Desde la pantalla principal, toca el botón "+" y selecciona el servicio o ingresa el nombre. '
        'Completa el precio, moneda, categoría y fecha de renovación. PODA calculará automáticamente los días restantes.',
  ),
  _FaqItem(
    category: 'Suscripciones',
    question: '¿Cómo sincronizo suscripciones desde Gmail?',
    answer:
        'Ve a "Mi cuenta" → "Correos vinculados" y toca "+ Agregar". '
        'Inicia sesión con tu cuenta de Google y concede los permisos de lectura. '
        'PODA escaneará tu bandeja en busca de correos de confirmación de suscripciones.',
  ),
  _FaqItem(
    category: 'Suscripciones',
    question: '¿Cómo edito o elimino una suscripción?',
    answer:
        'Toca sobre cualquier suscripción para ver su detalle. '
        'Desde ahí encontrarás los botones "Editar" y "Eliminar" en la parte superior derecha.',
  ),
  _FaqItem(
    category: 'Suscripciones',
    question: '¿Por qué no aparece una suscripción en la detección automática?',
    answer:
        'La detección por Gmail depende de que el servicio envíe correos de confirmación o factura a tu bandeja. '
        'Si no aparece, puedes agregarla manualmente. '
        'También asegúrate de que el correo vinculado sea el que recibe las notificaciones del servicio.',
  ),
  _FaqItem(
    category: 'Suscripciones',
    question: '¿En qué monedas puedo registrar mis suscripciones?',
    answer:
        'PODA soporta Quetzal (GTQ), Dólar USD, Euro (EUR), Peso MXN y Libra GBP. '
        'Puedes mezclar monedas libremente; cada suscripción guarda su propia moneda.',
  ),

  // ── Cuenta ─────────────────────────────────────────────────────────────────
  _FaqItem(
    category: 'Cuenta',
    question: '¿Cómo cambio mi contraseña?',
    answer:
        'Ve a "Mi cuenta" → "Seguridad" → "Contraseña". '
        'Ingresa tu contraseña actual y la nueva contraseña. '
        'Esta opción solo está disponible si iniciaste sesión con correo y contraseña.',
  ),
  _FaqItem(
    category: 'Cuenta',
    question: '¿Cómo vinculo otra cuenta de correo?',
    answer:
        'En "Mi cuenta", toca "+ Agregar" en la sección "Correos vinculados". '
        'Puedes vincular múltiples cuentas de Gmail para sincronizar suscripciones de diferentes buzones.',
  ),
  _FaqItem(
    category: 'Cuenta',
    question: '¿Cómo cierro sesión?',
    answer:
        'En la pantalla "Mi cuenta", desplázate hasta el fondo y toca el botón "Cerrar sesión". '
        'Esto cerrará tu sesión en Firebase y Google de forma segura.',
  ),
  _FaqItem(
    category: 'Cuenta',
    question: '¿Puedo usar PODA sin cuenta de Google?',
    answer:
        'Sí. Puedes registrarte con correo electrónico y contraseña. '
        'La sincronización automática desde Gmail requiere vincular al menos una cuenta de Google.',
  ),

  // ── PODA ───────────────────────────────────────────────────────────────────
  _FaqItem(
    category: 'PODA',
    question: '¿Qué es PODA?',
    answer:
        'PODA es la función de optimización de gastos. Analiza tus suscripciones activas '
        'y te sugiere cuáles podrías cancelar o renegociar para reducir tu gasto mensual. '
        'Accede desde la pestaña "PODA" en la barra inferior.',
  ),
  _FaqItem(
    category: 'PODA',
    question: '¿Cómo se calculan las sugerencias de ahorro?',
    answer:
        'PODA compara el precio que pagas con la tarifa regular del servicio. '
        'Si detecta que ya terminó un período de promoción, o que tienes suscripciones similares duplicadas, '
        'te lo notifica como oportunidad de ahorro.',
  ),
  _FaqItem(
    category: 'PODA',
    question: '¿Las alertas se actualizan automáticamente?',
    answer:
        'Sí. Cada vez que abres la pestaña "Alertas", PODA recalcula los días restantes '
        'de cada suscripción y actualiza el estado de urgencia en tiempo real. '
        'Puedes configurar el umbral de aviso en "Notificaciones".',
  ),

  // ── Privacidad ─────────────────────────────────────────────────────────────
  _FaqItem(
    category: 'Privacidad',
    question: '¿Qué datos almacena PODA?',
    answer:
        'PODA almacena el nombre de tus suscripciones, precios, fechas de renovación y la cuenta de correo '
        'asociada a cada suscripción. Los datos se guardan de forma cifrada en nuestros servidores (Supabase). '
        'No almacenamos contraseñas de servicios externos.',
  ),
  _FaqItem(
    category: 'Privacidad',
    question: '¿Es seguro vincular mi Gmail?',
    answer:
        'PODA solo solicita permiso de lectura (gmail.readonly). '
        'Nunca puede leer, enviar ni eliminar correos. '
        'Tu token de acceso se usa exclusivamente para buscar correos de confirmación de suscripciones.',
  ),
  _FaqItem(
    category: 'Privacidad',
    question: '¿Cómo puedo eliminar mis datos?',
    answer:
        'Para eliminar todos tus datos, escríbenos a soporte@piums.io desde el correo asociado a tu cuenta. '
        'Procesaremos tu solicitud en un plazo de 72 horas.',
  ),
];

// ─── Page ─────────────────────────────────────────────────────────────────────

class CentroAyudaPage extends StatefulWidget {
  const CentroAyudaPage({super.key});

  @override
  State<CentroAyudaPage> createState() => _CentroAyudaPageState();
}

class _CentroAyudaPageState extends State<CentroAyudaPage> {
  final _searchCtrl = TextEditingController();
  String _query = '';
  String _selectedCategory = 'Todas';

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  List<_FaqItem> get _filtered {
    return _faqs.where((f) {
      final matchesCat =
          _selectedCategory == 'Todas' || f.category == _selectedCategory;
      final q = _query.toLowerCase();
      final matchesQuery = q.isEmpty ||
          f.question.toLowerCase().contains(q) ||
          f.answer.toLowerCase().contains(q);
      return matchesCat && matchesQuery;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filtered;

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
          'Centro de ayuda',
          style: TextStyle(
            fontFamily: DesignTokens.fontFamily,
            fontSize: 20,
            fontWeight: DesignTokens.wBold,
            color: Colors.white,
          ),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
                DesignTokens.s16, DesignTokens.s8,
                DesignTokens.s16, DesignTokens.s12),
            child: _SearchBar(
              controller: _searchCtrl,
              onChanged: (v) => setState(() => _query = v),
            ),
          ),
          SizedBox(
            height: 36,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(
                  horizontal: DesignTokens.s16),
              scrollDirection: Axis.horizontal,
              itemCount: _kCategories.length,
              separatorBuilder: (ctx, i) =>
                  const SizedBox(width: DesignTokens.s8),
              itemBuilder: (_, i) {
                final cat = _kCategories[i];
                final active = cat == _selectedCategory;
                return GestureDetector(
                  onTap: () =>
                      setState(() => _selectedCategory = cat),
                  child: AnimatedContainer(
                    duration: DesignTokens.animFast,
                    padding: const EdgeInsets.symmetric(
                        horizontal: DesignTokens.s16),
                    decoration: BoxDecoration(
                      color: active
                          ? _kAccent
                          : Colors.white.withValues(alpha: 0.07),
                      borderRadius:
                          BorderRadius.circular(DesignTokens.rFull),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      cat,
                      style: TextStyle(
                        fontFamily: DesignTokens.fontFamily,
                        fontSize: 13,
                        fontWeight: active
                            ? DesignTokens.wSemibold
                            : DesignTokens.wRegular,
                        color: active
                            ? Colors.white
                            : Colors.white.withValues(alpha: 0.6),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: DesignTokens.s12),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(
                  DesignTokens.s16, 0,
                  DesignTokens.s16, DesignTokens.s32),
              children: [
                if (filtered.isEmpty)
                  _EmptySearch(query: _query)
                else ...[
                  _FaqList(items: filtered),
                  const SizedBox(height: DesignTokens.s24),
                ],
                _ContactCard(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Search bar ───────────────────────────────────────────────────────────────

class _SearchBar extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  const _SearchBar(
      {required this.controller, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      style: const TextStyle(
        fontFamily: DesignTokens.fontFamily,
        color: Colors.white,
        fontSize: 15,
      ),
      decoration: InputDecoration(
        hintText: 'Buscar en preguntas frecuentes…',
        hintStyle: TextStyle(
          fontFamily: DesignTokens.fontFamily,
          color: Colors.white.withValues(alpha: 0.35),
          fontSize: 14,
        ),
        prefixIcon: Icon(Icons.search_rounded,
            color: Colors.white.withValues(alpha: 0.4), size: 20),
        suffixIcon: controller.text.isNotEmpty
            ? IconButton(
                icon: Icon(Icons.close_rounded,
                    color: Colors.white.withValues(alpha: 0.4), size: 18),
                onPressed: () {
                  controller.clear();
                  onChanged('');
                },
              )
            : null,
        filled: true,
        fillColor: _kCard.withValues(alpha: 0.7),
        contentPadding: const EdgeInsets.symmetric(
            horizontal: DesignTokens.s16, vertical: DesignTokens.s12),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(DesignTokens.rL),
          borderSide:
              BorderSide(color: Colors.white.withValues(alpha: 0.1)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(DesignTokens.rL),
          borderSide: const BorderSide(color: _kAccent),
        ),
      ),
    );
  }
}

// ─── FAQ list ─────────────────────────────────────────────────────────────────

class _FaqList extends StatelessWidget {
  final List<_FaqItem> items;
  const _FaqList({required this.items});

  // Group by category preserving original order
  Map<String, List<_FaqItem>> _group() {
    final map = <String, List<_FaqItem>>{};
    for (final item in items) {
      map.putIfAbsent(item.category, () => []).add(item);
    }
    return map;
  }

  @override
  Widget build(BuildContext context) {
    final groups = _group();
    final widgets = <Widget>[];
    groups.forEach((cat, catItems) {
      if (groups.length > 1) {
        widgets.add(_SectionLabel(cat));
        widgets.add(const SizedBox(height: DesignTokens.s8));
      }
      widgets.add(_FaqGroup(items: catItems));
      widgets.add(const SizedBox(height: DesignTokens.s16));
    });
    return Column(
        crossAxisAlignment: CrossAxisAlignment.start, children: widgets);
  }
}

class _FaqGroup extends StatelessWidget {
  final List<_FaqItem> items;
  const _FaqGroup({required this.items});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _kCard,
        borderRadius: BorderRadius.circular(DesignTokens.rL),
      ),
      child: Column(
        children: List.generate(items.length, (i) {
          return _FaqTile(
            item: items[i],
            isLast: i == items.length - 1,
          );
        }),
      ),
    );
  }
}

class _FaqTile extends StatefulWidget {
  final _FaqItem item;
  final bool isLast;
  const _FaqTile({required this.item, required this.isLast});

  @override
  State<_FaqTile> createState() => _FaqTileState();
}

class _FaqTileState extends State<_FaqTile> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InkWell(
          onTap: () => setState(() => _expanded = !_expanded),
          borderRadius: BorderRadius.vertical(
            top: const Radius.circular(DesignTokens.rL),
            bottom: widget.isLast && !_expanded
                ? const Radius.circular(DesignTokens.rL)
                : Radius.zero,
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: DesignTokens.s16, vertical: DesignTokens.s16),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    widget.item.question,
                    style: TextStyle(
                      fontFamily: DesignTokens.fontFamily,
                      fontSize: 14,
                      fontWeight: DesignTokens.wMedium,
                      color: _expanded
                          ? Colors.white
                          : Colors.white.withValues(alpha: 0.9),
                      height: 1.4,
                    ),
                  ),
                ),
                const SizedBox(width: DesignTokens.s8),
                AnimatedRotation(
                  turns: _expanded ? 0.5 : 0,
                  duration: DesignTokens.animNormal,
                  child: Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: _expanded
                        ? _kAccent
                        : Colors.white.withValues(alpha: 0.4),
                    size: 22,
                  ),
                ),
              ],
            ),
          ),
        ),
        AnimatedSize(
          duration: DesignTokens.animNormal,
          curve: Curves.easeInOut,
          child: _expanded
              ? Padding(
                  padding: const EdgeInsets.only(
                    left: DesignTokens.s16,
                    right: DesignTokens.s16,
                    bottom: DesignTokens.s16,
                  ),
                  child: Text(
                    widget.item.answer,
                    style: TextStyle(
                      fontFamily: DesignTokens.fontFamily,
                      fontSize: 13,
                      height: 1.6,
                      color: Colors.white.withValues(alpha: 0.65),
                    ),
                  ),
                )
              : const SizedBox.shrink(),
        ),
        if (!widget.isLast)
          Divider(
            height: 1,
            indent: DesignTokens.s16,
            endIndent: DesignTokens.s16,
            color: Colors.white.withValues(alpha: 0.08),
          ),
      ],
    );
  }
}

// ─── Empty search ─────────────────────────────────────────────────────────────

class _EmptySearch extends StatelessWidget {
  final String query;
  const _EmptySearch({required this.query});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Column(
        children: [
          Icon(Icons.search_off_rounded,
              color: Colors.white.withValues(alpha: 0.2), size: 48),
          const SizedBox(height: DesignTokens.s12),
          Text(
            'Sin resultados para "$query"',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: DesignTokens.fontFamily,
              fontSize: 14,
              color: Colors.white.withValues(alpha: 0.45),
            ),
          ),
          const SizedBox(height: DesignTokens.s8),
          Text(
            'Prueba con otras palabras o contáctanos.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: DesignTokens.fontFamily,
              fontSize: 13,
              color: Colors.white.withValues(alpha: 0.3),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Contact card ─────────────────────────────────────────────────────────────

class _ContactCard extends StatelessWidget {
  Future<void> _openEmail(BuildContext context) async {
    final uri = Uri(
      scheme: 'mailto',
      path: 'soporte@piums.io',
      queryParameters: {
        'subject': 'Soporte PODA',
      },
    );
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No se pudo abrir el cliente de correo.'),
          backgroundColor: Color(0xFFEF4444),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(DesignTokens.s20),
      decoration: BoxDecoration(
        color: _kSheet,
        borderRadius: BorderRadius.circular(DesignTokens.rL),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: _kAccent.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.support_agent_rounded,
                    color: _kAccent, size: 20),
              ),
              const SizedBox(width: DesignTokens.s12),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '¿No encontraste lo que buscabas?',
                    style: TextStyle(
                      fontFamily: DesignTokens.fontFamily,
                      fontSize: 14,
                      fontWeight: DesignTokens.wSemibold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    'Nuestro equipo te responde en 24–48 h.',
                    style: TextStyle(
                      fontFamily: DesignTokens.fontFamily,
                      fontSize: 12,
                      color: Color(0xFF9CA3AF),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: DesignTokens.s16),
          SizedBox(
            width: double.infinity,
            height: 44,
            child: ElevatedButton.icon(
              onPressed: () => _openEmail(context),
              icon: const Icon(Icons.email_outlined, size: 18),
              label: const Text(
                'Contactar soporte',
                style: TextStyle(
                  fontFamily: DesignTokens.fontFamily,
                  fontSize: 14,
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
          const SizedBox(height: DesignTokens.s10),
          Center(
            child: Text(
              'soporte@piums.io',
              style: TextStyle(
                fontFamily: DesignTokens.fontFamily,
                fontSize: 12,
                color: Colors.white.withValues(alpha: 0.35),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Section label ────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          const EdgeInsets.only(left: DesignTokens.s4, bottom: DesignTokens.s4),
      child: Text(
        text.toUpperCase(),
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
