import 'package:subscan/core/services/data_structures/stack.dart';
import 'package:subscan/core/services/data_structures/queue.dart';
import 'package:subscan/core/services/data_structures/linked_list.dart';
import 'package:subscan/core/services/data_structures/binary_tree.dart';
import 'package:subscan/core/services/data_structures/hash_table.dart';
import 'package:subscan/core/services/data_structures/graph.dart';
import 'package:subscan/features/subscriptions/models/subscription.dart';

/// Servicio para cargar datos de suscripciones EN las estructuras de datos
/// Responsabilidad: Distribución inteligente de datos según urgencia
class SubscriptionDataStructureService {
  /// Carga lista de suscripciones en todas las estructuras
  /// Cada estructura tiene un propósito específico
  static void loadSubscriptionsIntoStructures({
    required List<Subscription> subscriptions,
    required Stack<Subscription> stackUrgentes,
    required Queue<Subscription> queueProximas,
    required LinkedList<Subscription> linkedListTodas,
    required BinaryTree<Subscription> treeOrdenadas,
    required HashTable<String, Subscription> hashTableBusqueda,
    required Graph<String> graphServicios,
  }) {
    // Limpiar estructuras
    stackUrgentes.clear();
    queueProximas.clear();
    linkedListTodas.clear();
    treeOrdenadas.clear();
    hashTableBusqueda.clear();
    graphServicios.clear();

    // Organizar por urgencia
    final urgentes = subscriptions.where((s) => s.isUrgent).toList();
    final proximas = subscriptions
        .where((s) => s.isNearRenewal && !s.isUrgent)
        .toList();
    // resto no se usa en v1, pero se reserva para futuras funcionalidades

    // STACK: Suscripciones urgentes (LIFO - últimas agregadas primero = más urgentes)
    for (final sub in urgentes) {
      stackUrgentes.push(sub);
    }

    // QUEUE: Suscripciones próximas a renovarse (FIFO - por orden de fecha)
    for (final sub in proximas) {
      queueProximas.enqueue(sub);
    }

    // LINKED LIST: Todas las suscripciones (inserción ordenada por nombre)
    for (final sub in subscriptions) {
      linkedListTodas.insert(sub);
    }

    // BINARY TREE: Ordenadas por fecha de renovación (búsqueda rápida)
    for (final sub in subscriptions) {
      treeOrdenadas.insert(sub);
    }

    // HASH TABLE: Búsqueda rápida por ID
    for (final sub in subscriptions) {
      hashTableBusqueda.insert(sub.id, sub);
    }

    // GRAPH: Relaciones entre servicios (ej: Netflix connect a Disney+)
    _buildServiceRelationships(subscriptions, graphServicios);
  }

  /// Construye relaciones entre servicios en el grafo
  /// Ej: Netflix y Disney+ son servicios de streaming
  static void _buildServiceRelationships(
    List<Subscription> subscriptions,
    Graph<String> graph,
  ) {
    // Agregar nodos para cada servicio único
    for (final sub in subscriptions) {
      graph.addNode(sub.nombre);
    }

    // Agregar aristas entre servicios similares (mismo tipo)
    final serviciosPorCategoria = _groupByCategory(subscriptions);

    for (final entry in serviciosPorCategoria.entries) {
      final servicios = entry.value;
      // Conectar servicios de la misma categoría
      for (int i = 0; i < servicios.length; i++) {
        for (int j = i + 1; j < servicios.length; j++) {
          graph.addEdge(
            servicios[i].nombre,
            servicios[j].nombre,
            directed: false,
          );
        }
      }
    }
  }

  /// Agrupa suscripciones por categoría (streaming, office, etc)
  static Map<String, List<Subscription>> _groupByCategory(
    List<Subscription> subscriptions,
  ) {
    final grouped = <String, List<Subscription>>{};

    final categories = {
      'Streaming': ['netflix', 'amazon', 'disney', 'hulu', 'hbo'],
      'Música': ['spotify', 'apple music', 'youtube music'],
      'Office': ['microsoft', 'google', 'adobe'],
      'Storage': ['dropbox', 'icloud', 'google drive'],
    };

    for (final sub in subscriptions) {
      final nombreLower = sub.nombre.toLowerCase();
      String? categoria;

      for (final entry in categories.entries) {
        final cat = entry.key;
        final keywords = entry.value;
        if (keywords.any((kw) => nombreLower.contains(kw))) {
          categoria = cat;
          break;
        }
      }

      categoria ??= 'Otros';
      grouped.putIfAbsent(categoria, () => []).add(sub);
    }

    return grouped;
  }

  /// Obtiene la siguiente suscripción urgente sin removerla
  static Subscription? peekUrgente(Stack<Subscription> stackUrgentes) {
    return stackUrgentes.peek();
  }

  /// Obtiene la siguiente suscripción por renovación sin removerla
  static Subscription? peekProxima(Queue<Subscription> queueProximas) {
    return queueProximas.peek();
  }

  /// Extrae la suscripción urgente siguiente (remueve)
  static Subscription? popUrgente(Stack<Subscription> stackUrgentes) {
    return stackUrgentes.pop();
  }

  /// Extrae la suscripción próxima siguiente (remueve)
  static Subscription? dequeueProxima(Queue<Subscription> queueProximas) {
    return queueProximas.dequeue();
  }

  /// Factory para crear BinaryTree con comparador de fecha de renovación
  static BinaryTree<Subscription> createSubscriptionBinaryTree() {
    return BinaryTree<Subscription>(
      comparator: (a, b) => a.fechaRenovacion.compareTo(b.fechaRenovacion),
    );
  }
}
