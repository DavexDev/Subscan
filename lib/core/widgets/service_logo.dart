import 'package:flutter/material.dart';
import 'package:subscan/core/theme/design_tokens.dart';

// Maps keyword (lowercase) → asset filename (without extension)
const Map<String, String> _kLogoAssets = {
  'spotify': 'spotify',
  'netflix': 'netflix',
  'disney': 'disney_plus',
  'youtube': 'youtube',
  'amazon': 'amazon_prime',
  'prime': 'amazon_prime',
  'hbo': 'max',
  ' max': 'max',
  'hulu': 'hulu',
  'paramount': 'paramount_plus',
  'apple tv': 'apple_tv',
  'appletv': 'apple_tv',
  'twitch': 'twitch',
  'crunchyroll': 'crunchyroll',
  'deezer': 'deezer',
  'tidal': 'tidal',
  'apple music': 'apple_music',
  'applemusic': 'apple_music',
  'chatgpt': 'chatgpt',
  'openai': 'chatgpt',
  'microsoft': 'microsoft',
  'office': 'microsoft',
  'adobe': 'adobe',
  'dropbox': 'dropbox',
  'duolingo': 'duolingo',
  'canva': 'canva',
  'figma': 'figma',
  'notion': 'notion',
  'slack': 'slack',
  'zoom': 'zoom',
  'github': 'github',
  'xbox': 'xbox',
  'playstation': 'playstation',
  'nintendo': 'nintendo',
};

Color serviceBrandColor(String name) {
  final n = name.toLowerCase();
  if (n.contains('spotify')) return const Color(0xFF1DB954);
  if (n.contains('netflix')) return const Color(0xFFE50914);
  if (n.contains('disney')) return const Color(0xFF0063E5);
  if (n.contains('youtube')) return const Color(0xFFFF0000);
  if (n.contains('amazon') || n.contains('prime')) return const Color(0xFF00A8E1);
  if (n.contains('hbo') || n.contains('max')) return const Color(0xFF7B2FBE);
  if (n.contains('hulu')) return const Color(0xFF1CE783);
  if (n.contains('paramount')) return const Color(0xFF0064FF);
  if (n.contains('apple')) return const Color(0xFF888888);
  if (n.contains('twitch')) return const Color(0xFF9146FF);
  if (n.contains('crunchyroll')) return const Color(0xFFF47521);
  if (n.contains('deezer')) return const Color(0xFF00C7F2);
  if (n.contains('adobe')) return const Color(0xFFFF0000);
  if (n.contains('microsoft') || n.contains('office')) return const Color(0xFF00A4EF);
  if (n.contains('tidal')) return const Color(0xFF00FFFF);
  if (n.contains('duolingo')) return const Color(0xFF58CC02);
  if (n.contains('dropbox')) return const Color(0xFF0061FF);
  if (n.contains('canva')) return const Color(0xFF00C4CC);
  if (n.contains('figma')) return const Color(0xFFF24E1E);
  if (n.contains('notion')) return const Color(0xFFFFFFFF);
  if (n.contains('slack')) return const Color(0xFF4A154B);
  if (n.contains('zoom')) return const Color(0xFF2D8CFF);
  if (n.contains('github')) return const Color(0xFFFFFFFF);
  if (n.contains('xbox')) return const Color(0xFF107C10);
  if (n.contains('playstation')) return const Color(0xFF003087);
  if (n.contains('nintendo')) return const Color(0xFFE60012);
  if (n.contains('chatgpt') || n.contains('openai')) return const Color(0xFF10A37F);
  return const Color(0xFF4F6BFF);
}

String? _assetForName(String name) {
  final n = name.toLowerCase();
  // Exact-starts-with check first for "max" to avoid false matches
  for (final entry in _kLogoAssets.entries) {
    if (n.contains(entry.key.trim())) return entry.value;
  }
  return null;
}

/// Widget de logo de servicio: muestra el logo real si existe como asset,
/// o una inicial con color de marca como fallback.
class ServiceLogo extends StatelessWidget {
  final String name;
  final double size;

  const ServiceLogo({super.key, required this.name, this.size = 48});

  @override
  Widget build(BuildContext context) {
    final asset = _assetForName(name);
    final color = serviceBrandColor(name);
    final radius = size * 0.26;

    if (asset != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: Image.asset(
          'assets/logos/$asset.png',
          width: size,
          height: size,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _Fallback(
            name: name,
            size: size,
            color: color,
            radius: radius,
          ),
        ),
      );
    }

    return _Fallback(name: name, size: size, color: color, radius: radius);
  }
}

class _Fallback extends StatelessWidget {
  final String name;
  final double size;
  final Color color;
  final double radius;

  const _Fallback({
    required this.name,
    required this.size,
    required this.color,
    required this.radius,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: color.withValues(alpha: 0.45), width: 1.5),
      ),
      child: Center(
        child: Text(
          name.isNotEmpty ? name[0].toUpperCase() : '?',
          style: TextStyle(
            fontFamily: DesignTokens.fontFamily,
            fontSize: size * 0.42,
            fontWeight: DesignTokens.wBold,
            color: color,
          ),
        ),
      ),
    );
  }
}
