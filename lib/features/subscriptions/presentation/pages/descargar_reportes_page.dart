import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';
import 'package:subscan/core/theme/design_tokens.dart';
import 'package:subscan/features/subscriptions/models/subscription.dart';
import 'package:subscan/features/subscriptions/providers/subscription_notifier_provider.dart';

const Color _kBg = Color(0xFF030B3F);
const Color _kCard = Color(0xFF3B4792);
const Color _kAccent = Color(0xFF4F6BFF);

const List<String> _kMonths = [
  'Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun',
  'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic',
];

String _fmtDate(DateTime d) =>
    '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

String _fmtShort(DateTime d) => '${d.day} ${_kMonths[d.month - 1]}';

String _currencySymbol(String code) {
  switch (code) {
    case 'USD': return '\$';
    case 'EUR': return '€';
    case 'MXN': return 'MX\$';
    case 'GBP': return '£';
    default: return 'Q';
  }
}

const List<Color> _kIconPalette = [
  Color(0xFFE5223A), Color(0xFF1DB954), Color(0xFF0F3FA2),
  Color(0xFFFF5500), Color(0xFF5822CC), Color(0xFF00C4CC),
  Color(0xFFFF0000),
];
Color _colorFor(String name) =>
    _kIconPalette[name.isEmpty ? 0 : name.codeUnitAt(0) % _kIconPalette.length];

// ─── PDF palette ──────────────────────────────────────────────────────────────

final _pdfNavy     = PdfColor.fromHex('#030B3F');
final _pdfMid      = PdfColor.fromHex('#3B4792');
final _pdfAccent   = PdfColor.fromHex('#4F6BFF');
final _pdfSecondary = PdfColor.fromHex('#6B7BB4');
final _pdfRowAlt   = PdfColor.fromHex('#EEF2FF');
final _pdfText     = PdfColor.fromHex('#1E2A6E');
final _pdfBorder   = PdfColor.fromHex('#D1D9F0');

// ─── Page ─────────────────────────────────────────────────────────────────────

class DescargarReportesPage extends ConsumerStatefulWidget {
  const DescargarReportesPage({super.key});

  @override
  ConsumerState<DescargarReportesPage> createState() =>
      _DescargarReportesPageState();
}

class _DescargarReportesPageState
    extends ConsumerState<DescargarReportesPage> {
  bool _exporting = false;
  String _selectedFormat = 'pdf';

  // ─── CSV ─────────────────────────────────────────────────────────────────────

  String _buildCsv(List<Subscription> subs) {
    final now = DateTime.now();
    final buf = StringBuffer();
    buf.write('﻿'); // UTF-8 BOM
    buf.writeln('# PODA — Reporte de suscripciones');
    buf.writeln('# Exportado: ${_fmtDate(now)}');
    buf.writeln('# Total: ${subs.length} suscripciones');
    buf.writeln('#');
    buf.writeln('Nombre,Precio actual,Moneda,Fecha de renovación,Días restantes,Método de pago,Fuente,Cuenta email');
    for (final s in subs) {
      buf.writeln([
        _csvCell(s.nombre),
        s.precioActual.toStringAsFixed(2),
        s.currency,
        _fmtDate(s.fechaRenovacion),
        s.diasRestantes.toString(),
        _csvCell(s.metodoPago ?? ''),
        s.fuente,
        _csvCell(s.emailCuenta ?? ''),
      ].join(','));
    }
    return buf.toString();
  }

  String _csvCell(String v) {
    if (v.contains(',') || v.contains('"') || v.contains('\n')) {
      return '"${v.replaceAll('"', '""')}"';
    }
    return v;
  }

  Future<void> _exportCsv(List<Subscription> subs) async {
    setState(() => _exporting = true);
    try {
      final bytes = Uint8List.fromList(utf8.encode(_buildCsv(subs)));
      final now = DateTime.now();
      final name = 'poda_reporte_${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}.csv';
      await Share.shareXFiles(
        [XFile.fromData(bytes, mimeType: 'text/csv', name: name)],
        subject: 'Reporte de suscripciones PODA',
      );
    } catch (_) {
      _showError('No se pudo exportar el reporte CSV.');
    } finally {
      if (mounted) setState(() => _exporting = false);
    }
  }

  // ─── PDF ─────────────────────────────────────────────────────────────────────

  Future<Uint8List> _buildPdf(List<Subscription> subs) async {
    final pdf = pw.Document(
      title: 'Reporte PODA',
      author: 'PODA',
    );
    final now = DateTime.now();

    final byCurrency = <String, double>{};
    for (final s in subs) {
      byCurrency[s.currency] = (byCurrency[s.currency] ?? 0) + s.precioActual;
    }

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.symmetric(horizontal: 40, vertical: 44),
        header: (ctx) => _pdfHeader(now),
        footer: (ctx) => _pdfFooter(ctx, now),
        build: (ctx) => [
          pw.SizedBox(height: 20),
          _pdfSummaryBox(subs, byCurrency),
          pw.SizedBox(height: 28),
          _pdfTableSection(subs),
        ],
      ),
    );

    return pdf.save();
  }

  pw.Widget _pdfHeader(DateTime now) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          crossAxisAlignment: pw.CrossAxisAlignment.end,
          children: [
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'PODA',
                  style: pw.TextStyle(
                    fontSize: 26,
                    fontWeight: pw.FontWeight.bold,
                    color: _pdfNavy,
                  ),
                ),
                pw.Text(
                  'Gestión de suscripciones',
                  style: pw.TextStyle(fontSize: 9, color: _pdfSecondary),
                ),
              ],
            ),
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.end,
              children: [
                pw.Text(
                  'Reporte de suscripciones',
                  style: pw.TextStyle(
                    fontSize: 11,
                    fontWeight: pw.FontWeight.bold,
                    color: _pdfText,
                  ),
                ),
                pw.Text(
                  'Generado el ${_fmtDate(now)}',
                  style: pw.TextStyle(fontSize: 9, color: _pdfSecondary),
                ),
              ],
            ),
          ],
        ),
        pw.SizedBox(height: 8),
        pw.Divider(color: _pdfAccent, thickness: 2, height: 2),
        pw.SizedBox(height: 4),
      ],
    );
  }

  pw.Widget _pdfFooter(pw.Context ctx, DateTime now) {
    return pw.Column(
      children: [
        pw.Divider(color: _pdfBorder, thickness: 0.5, height: 12),
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text(
              'Generado con PODA · piums.io',
              style: pw.TextStyle(fontSize: 7.5, color: _pdfSecondary),
            ),
            pw.Text(
              'Página ${ctx.pageNumber} de ${ctx.pagesCount}',
              style: pw.TextStyle(fontSize: 7.5, color: _pdfSecondary),
            ),
          ],
        ),
      ],
    );
  }

  pw.Widget _pdfSummaryBox(
      List<Subscription> subs, Map<String, double> byCurrency) {
    final gastoStr = byCurrency.entries
        .map((e) => '${_currencySymbol(e.key)}${e.value.toStringAsFixed(2)}')
        .join('   ');

    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: pw.BoxDecoration(
        color: _pdfNavy,
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
      ),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.center,
        children: [
          pw.Expanded(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  '${subs.length} suscripciones activas',
                  style: pw.TextStyle(
                    fontSize: 13,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.white,
                  ),
                ),
                pw.SizedBox(height: 4),
                pw.Text(
                  'Gasto mensual estimado: $gastoStr',
                  style: pw.TextStyle(fontSize: 9.5, color: _pdfSecondary),
                ),
              ],
            ),
          ),
          pw.Container(
            width: 1,
            height: 36,
            color: PdfColor.fromHex('#3B4792'),
            margin: const pw.EdgeInsets.symmetric(horizontal: 16),
          ),
          pw.Text(
            _fmtDate(DateTime.now()),
            style: pw.TextStyle(fontSize: 9, color: _pdfSecondary),
          ),
        ],
      ),
    );
  }

  pw.Widget _pdfTableSection(List<Subscription> subs) {
    return pw.TableHelper.fromTextArray(
      headers: [
        'Suscripción',
        'Precio',
        'Moneda',
        'Renovación',
        'Días',
        'Método de pago',
      ],
      data: subs.map((s) {
        final dias = s.diasRestantes;
        final diasStr = dias < 0 ? 'Vencida' : '$dias días';
        return [
          s.nombre,
          s.precioActual.toStringAsFixed(2),
          s.currency,
          _fmtDate(s.fechaRenovacion),
          diasStr,
          s.metodoPago ?? '—',
        ];
      }).toList(),
      headerStyle: pw.TextStyle(
        fontSize: 8.5,
        fontWeight: pw.FontWeight.bold,
        color: PdfColors.white,
      ),
      headerDecoration: pw.BoxDecoration(color: _pdfMid),
      cellStyle: pw.TextStyle(fontSize: 8.5, color: _pdfText),
      cellHeight: 22,
      cellPadding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      headerPadding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 7),
      cellAlignments: {
        0: pw.Alignment.centerLeft,
        1: pw.Alignment.centerRight,
        2: pw.Alignment.center,
        3: pw.Alignment.center,
        4: pw.Alignment.center,
        5: pw.Alignment.centerLeft,
      },
      oddRowDecoration: pw.BoxDecoration(color: _pdfRowAlt),
      border: pw.TableBorder.all(color: _pdfBorder, width: 0.5),
      columnWidths: {
        0: const pw.FlexColumnWidth(2.8),
        1: const pw.FlexColumnWidth(1.4),
        2: const pw.FlexColumnWidth(1.0),
        3: const pw.FlexColumnWidth(1.8),
        4: const pw.FlexColumnWidth(1.2),
        5: const pw.FlexColumnWidth(2.0),
      },
    );
  }

  Future<void> _exportPdf(List<Subscription> subs) async {
    setState(() => _exporting = true);
    try {
      final bytes = await _buildPdf(subs);
      final now = DateTime.now();
      final name =
          'poda_reporte_${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}.pdf';
      await Printing.sharePdf(bytes: bytes, filename: name);
    } catch (_) {
      _showError('No se pudo generar el PDF.');
    } finally {
      if (mounted) setState(() => _exporting = false);
    }
  }

  void _showError(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: const Color(0xFFEF4444),
      ),
    );
  }

  // ─── Build ────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(subscriptionNotifierProvider);
    final subs = state.allSubscriptions;

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
          'Descargar reportes',
          style: TextStyle(
            fontFamily: DesignTokens.fontFamily,
            fontSize: 20,
            fontWeight: DesignTokens.wBold,
            color: Colors.white,
          ),
        ),
      ),
      body: state.isLoading
          ? const Center(
              child: CircularProgressIndicator(color: DesignTokens.primary),
            )
          : _buildBody(subs),
    );
  }

  Widget _buildBody(List<Subscription> subs) {
    return ListView(
      padding: const EdgeInsets.all(DesignTokens.s16),
      children: [
        _SummaryCard(subs: subs),
        const SizedBox(height: DesignTokens.s24),
        _SectionLabel('FORMATO'),
        const SizedBox(height: DesignTokens.s8),
        _FormatSelector(
          selected: _selectedFormat,
          onSelect: (fmt) => setState(() => _selectedFormat = fmt),
        ),
        const SizedBox(height: DesignTokens.s24),
        if (subs.isNotEmpty) ...[
          _SectionLabel('VISTA PREVIA  •  ${subs.length} REGISTROS'),
          const SizedBox(height: DesignTokens.s8),
          _PreviewList(subs: subs),
          const SizedBox(height: DesignTokens.s24),
        ],
        _ExportButton(
          format: _selectedFormat,
          empty: subs.isEmpty,
          exporting: _exporting,
          onTap: () => _selectedFormat == 'pdf'
              ? _exportPdf(subs)
              : _exportCsv(subs),
        ),
        const SizedBox(height: DesignTokens.s32),
      ],
    );
  }
}

// ─── Summary card ─────────────────────────────────────────────────────────────

class _SummaryCard extends StatelessWidget {
  final List<Subscription> subs;
  const _SummaryCard({required this.subs});

  Map<String, double> _groupByCurrency() {
    final map = <String, double>{};
    for (final s in subs) {
      map[s.currency] = (map[s.currency] ?? 0) + s.precioActual;
    }
    return map;
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final byCurrency = _groupByCurrency();

    return Container(
      padding: const EdgeInsets.all(DesignTokens.s20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF3B4792), Color(0xFF1E2A6E)],
        ),
        borderRadius: BorderRadius.circular(DesignTokens.rL),
        border: Border.all(color: _kAccent.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.description_rounded,
                  color: Colors.white, size: 20),
              const SizedBox(width: DesignTokens.s8),
              const Text(
                'Reporte de suscripciones',
                style: TextStyle(
                  fontFamily: DesignTokens.fontFamily,
                  fontSize: 15,
                  fontWeight: DesignTokens.wSemibold,
                  color: Colors.white,
                ),
              ),
              const Spacer(),
              Text(
                _fmtShort(now),
                style: TextStyle(
                  fontFamily: DesignTokens.fontFamily,
                  fontSize: 12,
                  color: Colors.white.withValues(alpha: 0.6),
                ),
              ),
            ],
          ),
          const SizedBox(height: DesignTokens.s16),
          Divider(color: Colors.white.withValues(alpha: 0.1), height: 1),
          const SizedBox(height: DesignTokens.s16),
          Row(
            children: [
              _StatChip(
                label: 'Suscripciones',
                value: '${subs.length}',
              ),
              const SizedBox(width: DesignTokens.s12),
              Expanded(
                child: _GastoChips(byCurrency: byCurrency),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final String label;
  final String value;
  const _StatChip({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontFamily: DesignTokens.fontFamily,
            fontSize: 11,
            color: Colors.white.withValues(alpha: 0.55),
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontFamily: DesignTokens.fontFamily,
            fontSize: 22,
            fontWeight: DesignTokens.wBold,
            color: Colors.white,
          ),
        ),
      ],
    );
  }
}

class _GastoChips extends StatelessWidget {
  final Map<String, double> byCurrency;
  const _GastoChips({required this.byCurrency});

  static const Map<String, String> _symbols = {
    'GTQ': 'Q',
    'USD': '\$',
    'EUR': '€',
    'MXN': 'MX\$',
    'GBP': '£',
  };

  @override
  Widget build(BuildContext context) {
    if (byCurrency.isEmpty) return const SizedBox.shrink();
    return Wrap(
      spacing: DesignTokens.s8,
      runSpacing: DesignTokens.s6,
      alignment: WrapAlignment.end,
      children: byCurrency.entries.map((e) {
        final symbol = _symbols[e.key] ?? e.key;
        return Container(
          padding: const EdgeInsets.symmetric(
              horizontal: DesignTokens.s10, vertical: DesignTokens.s4),
          decoration: BoxDecoration(
            color: _kAccent.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(DesignTokens.rFull),
          ),
          child: Text(
            '$symbol${e.value.toStringAsFixed(2)}',
            style: const TextStyle(
              fontFamily: DesignTokens.fontFamily,
              fontSize: 13,
              fontWeight: DesignTokens.wSemibold,
              color: Colors.white,
            ),
          ),
        );
      }).toList(),
    );
  }
}

// ─── Format selector ──────────────────────────────────────────────────────────

class _FormatSelector extends StatelessWidget {
  final String selected;
  final ValueChanged<String> onSelect;

  const _FormatSelector({required this.selected, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () => onSelect('csv'),
            child: _FormatCard(
              icon: Icons.table_chart_rounded,
              iconColor: const Color(0xFF10B981),
              label: 'CSV',
              description: 'Excel, Google Sheets',
              active: selected == 'csv',
            ),
          ),
        ),
        const SizedBox(width: DesignTokens.s12),
        Expanded(
          child: GestureDetector(
            onTap: () => onSelect('pdf'),
            child: _FormatCard(
              icon: Icons.picture_as_pdf_rounded,
              iconColor: const Color(0xFFEF4444),
              label: 'PDF',
              description: 'Documento imprimible',
              active: selected == 'pdf',
            ),
          ),
        ),
      ],
    );
  }
}

class _FormatCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String description;
  final bool active;

  const _FormatCard({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.description,
    required this.active,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: DesignTokens.animFast,
      padding: const EdgeInsets.all(DesignTokens.s16),
      decoration: BoxDecoration(
        color: active
            ? _kAccent.withValues(alpha: 0.12)
            : _kCard.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(DesignTokens.rL),
        border: Border.all(
          color: active ? _kAccent : Colors.white.withValues(alpha: 0.1),
          width: active ? 1.5 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                color: active ? iconColor : iconColor.withValues(alpha: 0.4),
                size: 22,
              ),
              const Spacer(),
              if (active)
                Container(
                  width: 18,
                  height: 18,
                  decoration: const BoxDecoration(
                    color: _kAccent,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.check_rounded,
                      color: Colors.white, size: 12),
                ),
            ],
          ),
          const SizedBox(height: DesignTokens.s10),
          Text(
            label,
            style: TextStyle(
              fontFamily: DesignTokens.fontFamily,
              fontSize: 16,
              fontWeight: DesignTokens.wBold,
              color: active ? Colors.white : Colors.white.withValues(alpha: 0.4),
            ),
          ),
          Text(
            description,
            style: TextStyle(
              fontFamily: DesignTokens.fontFamily,
              fontSize: 11,
              color: Colors.white.withValues(alpha: active ? 0.6 : 0.3),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Preview list ─────────────────────────────────────────────────────────────

class _PreviewList extends StatelessWidget {
  final List<Subscription> subs;
  const _PreviewList({required this.subs});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _kCard,
        borderRadius: BorderRadius.circular(DesignTokens.rL),
      ),
      child: Column(
        children: List.generate(subs.length, (i) {
          return _PreviewRow(sub: subs[i], isLast: i == subs.length - 1);
        }),
      ),
    );
  }
}

class _PreviewRow extends StatelessWidget {
  final Subscription sub;
  final bool isLast;
  const _PreviewRow({required this.sub, required this.isLast});

  @override
  Widget build(BuildContext context) {
    final color = _colorFor(sub.nombre);
    final initial =
        sub.nombre.isNotEmpty ? sub.nombre[0].toUpperCase() : '?';
    final dias = sub.diasRestantes;
    final renewLabel = dias < 0
        ? 'Vencida'
        : dias == 0
            ? 'Hoy'
            : dias == 1
                ? 'Mañana'
                : _fmtShort(sub.fechaRenovacion);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(
              horizontal: DesignTokens.s16, vertical: DesignTokens.s12),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    initial,
                    style: TextStyle(
                      fontFamily: DesignTokens.fontFamily,
                      fontSize: 14,
                      fontWeight: DesignTokens.wBold,
                      color: color,
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
                      sub.nombre,
                      style: const TextStyle(
                        fontFamily: DesignTokens.fontFamily,
                        fontSize: 14,
                        fontWeight: DesignTokens.wMedium,
                        color: Colors.white,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (sub.metodoPago != null)
                      Text(
                        sub.metodoPago!,
                        style: TextStyle(
                          fontFamily: DesignTokens.fontFamily,
                          fontSize: 11,
                          color: Colors.white.withValues(alpha: 0.45),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
              ),
              const SizedBox(width: DesignTokens.s8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    sub.precioFormateado,
                    style: const TextStyle(
                      fontFamily: DesignTokens.fontFamily,
                      fontSize: 14,
                      fontWeight: DesignTokens.wSemibold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    renewLabel,
                    style: TextStyle(
                      fontFamily: DesignTokens.fontFamily,
                      fontSize: 11,
                      color: dias < 0
                          ? const Color(0xFFEF4444).withValues(alpha: 0.8)
                          : Colors.white.withValues(alpha: 0.5),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        if (!isLast)
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

// ─── Export button ────────────────────────────────────────────────────────────

class _ExportButton extends StatelessWidget {
  final String format;
  final bool empty;
  final bool exporting;
  final VoidCallback onTap;

  const _ExportButton({
    required this.format,
    required this.empty,
    required this.exporting,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final label = exporting
        ? 'Generando…'
        : empty
            ? 'Sin datos para exportar'
            : format == 'pdf'
                ? 'Generar PDF'
                : 'Exportar CSV';

    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton.icon(
        onPressed: (empty || exporting) ? null : onTap,
        icon: exporting
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                    strokeWidth: 2, color: Colors.white),
              )
            : Icon(
                format == 'pdf'
                    ? Icons.picture_as_pdf_rounded
                    : Icons.download_rounded,
                size: 20,
              ),
        label: Text(
          label,
          style: const TextStyle(
            fontFamily: DesignTokens.fontFamily,
            fontSize: 15,
            fontWeight: DesignTokens.wSemibold,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: format == 'pdf'
              ? const Color(0xFFEF4444)
              : _kAccent,
          disabledBackgroundColor: _kAccent.withValues(alpha: 0.35),
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(DesignTokens.rL),
          ),
        ),
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
      padding: const EdgeInsets.only(
          left: DesignTokens.s4, bottom: DesignTokens.s4),
      child: Text(
        text,
        style: TextStyle(
          fontFamily: DesignTokens.fontFamily,
          fontSize: 11,
          fontWeight: DesignTokens.wSemibold,
          letterSpacing: 1.1,
          color: Colors.white.withValues(alpha: 0.4),
        ),
      ),
    );
  }
}
