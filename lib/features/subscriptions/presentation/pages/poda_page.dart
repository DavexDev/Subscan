import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:subscan/core/theme/design_tokens.dart';
import 'package:subscan/features/subscriptions/presentation/pages/subscription_detail_page.dart';
import 'package:subscan/features/subscriptions/providers/subscription_notifier_provider.dart';
import 'package:subscan/features/subscriptions/presentation/widgets/subscription_card.dart';

const Color _kBg = Color(0xFF030B3F);

/// Pantalla PODA — lista completa de suscripciones con acceso a detalle/edición.
class PodaPage extends ConsumerWidget {
  const PodaPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(subscriptionNotifierProvider);
    final notifier = ref.read(subscriptionNotifierProvider.notifier);

    return Scaffold(
      backgroundColor: _kBg,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(
                DesignTokens.s24,
                DesignTokens.s20,
                DesignTokens.s24,
                DesignTokens.s8,
              ),
              child: Text(
                'Mis suscripciones',
                style: TextStyle(
                  fontFamily: DesignTokens.fontFamily,
                  fontSize: 22,
                  fontWeight: DesignTokens.wBold,
                  color: Colors.white,
                ),
              ),
            ),
            if (state.isLoading)
              const Expanded(
                child: Center(
                  child: CircularProgressIndicator(color: Colors.white),
                ),
              )
            else if (state.allSubscriptions.isEmpty)
              Expanded(
                child: Center(
                  child: Text(
                    'No tienes suscripciones aún',
                    style: TextStyle(
                      fontFamily: DesignTokens.fontFamily,
                      fontSize: 15,
                      color: Colors.white.withValues(alpha: 0.5),
                    ),
                  ),
                ),
              )
            else
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.only(
                    top: DesignTokens.s8,
                    bottom: DesignTokens.s80,
                  ),
                  itemCount: state.allSubscriptions.length,
                  itemBuilder: (context, i) {
                    final sub = state.allSubscriptions[i];
                    return SubscriptionCard(
                      subscription: sub,
                      onTap: () => Navigator.of(context).push(
                        PageRouteBuilder(
                          pageBuilder: (context, animation, _) =>
                              SubscriptionDetailPage(subscription: sub),
                          transitionsBuilder: (_, anim, _, child) =>
                              FadeTransition(opacity: anim, child: child),
                          transitionDuration: DesignTokens.animNormal,
                        ),
                      ),
                      onRenew: () => notifier.renewSubscription(sub.id),
                      onDelete: () async {
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (_) => AlertDialog(
                            title: const Text('Eliminar suscripción'),
                            content: Text('¿Deseas eliminar "${sub.nombre}"?'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context, false),
                                child: const Text('Cancelar'),
                              ),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: DesignTokens.error,
                                ),
                                onPressed: () => Navigator.pop(context, true),
                                child: const Text(
                                  'Eliminar',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            ],
                          ),
                        );
                        if (confirm == true) {
                          notifier.deleteSubscription(sub.id);
                        }
                      },
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}
