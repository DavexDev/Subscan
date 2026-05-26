// keyword (lowercase) → URL de cancelación del proveedor
const Map<String, String> _kCancelUrls = {
  'netflix': 'https://www.netflix.com/cancelplan',
  'spotify': 'https://www.spotify.com/account/subscription/',
  'amazon prime': 'https://www.amazon.com/gp/primecentral',
  'amazon': 'https://www.amazon.com/gp/primecentral',
  'disney': 'https://www.disneyplus.com/account',
  'hulu': 'https://secure.hulu.com/account',
  'hbo': 'https://www.max.com/settings/subscription',
  'max': 'https://www.max.com/settings/subscription',
  'paramount': 'https://www.paramountplus.com/account/subscription/',
  'apple tv': 'https://appleid.apple.com/account/manage',
  'apple music': 'https://appleid.apple.com/account/manage',
  'apple': 'https://appleid.apple.com/account/manage',
  'youtube': 'https://myaccount.google.com/payments-and-subscriptions',
  'adobe': 'https://account.adobe.com/plans',
  'microsoft': 'https://account.microsoft.com/services',
  'office': 'https://account.microsoft.com/services',
  'github': 'https://github.com/settings/billing',
  'notion': 'https://www.notion.com/settings/billing',
  'dropbox': 'https://www.dropbox.com/account/plan',
  'duolingo': 'https://www.duolingo.com/settings/subscription',
  'canva': 'https://www.canva.com/settings/purchase-history',
  'chatgpt': 'https://chat.openai.com/settings',
  'openai': 'https://chat.openai.com/settings',
  'figma': 'https://www.figma.com/settings/billing',
  'slack': 'https://app.slack.com/plans',
  'zoom': 'https://zoom.us/billing/my-plans',
  'twitch': 'https://www.twitch.tv/settings/prime',
  'xbox': 'https://account.microsoft.com/services',
  'playstation': 'https://www.playstation.com/en-us/my-playstation/subscription/',
  'nintendo': 'https://accounts.nintendo.com/profile/about',
};

/// Devuelve la URL de cancelación para [nombre], o null si no hay una conocida.
String? findCancelUrl(String nombre) {
  final lower = nombre.toLowerCase();
  for (final entry in _kCancelUrls.entries) {
    if (lower.contains(entry.key)) return entry.value;
  }
  return null;
}
