import 'package:flutter_test/flutter_test.dart';
import 'package:subscan/core/services/data_structures/stack.dart';
import 'package:subscan/core/services/data_structures/queue.dart';
import 'package:subscan/core/services/data_structures/linked_list.dart';
import 'package:subscan/core/services/data_structures/binary_tree.dart';
import 'package:subscan/core/services/data_structures/hash_table.dart';
import 'package:subscan/core/services/data_structures/graph.dart';
import 'package:subscan/core/services/subscription_service.dart';
import 'package:subscan/features/subscriptions/models/subscription.dart';

void main() {
  group('SubscriptionDataStructureService Tests', () {
    late Stack<Subscription> stackUrgentes;
    late Queue<Subscription> queueProximas;
    late LinkedList<Subscription> linkedListTodas;
    late BinaryTree<Subscription> treeOrdenadas;
    late HashTable<String, Subscription> hashTableBusqueda;
    late Graph<String> graphServicios;

    setUp(() {
      stackUrgentes = Stack<Subscription>();
      queueProximas = Queue<Subscription>();
      linkedListTodas = LinkedList<Subscription>();
      treeOrdenadas =
          SubscriptionDataStructureService.createSubscriptionBinaryTree();
      hashTableBusqueda = HashTable<String, Subscription>();
      graphServicios = Graph<String>();
    });

    test('loadSubscriptionsIntoStructures distribuye datos correctamente', () {
      // Arrange
      final hoy = DateTime.now();
      final subscriptions = [
        Subscription(
          id: '1',
          nombre: 'Netflix',
          precioActual: 15.99,
          fechaRenovacion: hoy.add(const Duration(days: 2)), // URGENTE
        ),
        Subscription(
          id: '2',
          nombre: 'Spotify',
          precioActual: 10.99,
          fechaRenovacion: hoy.add(const Duration(days: 5)), // PRÓXIMA
        ),
        Subscription(
          id: '3',
          nombre: 'Adobe',
          precioActual: 54.99,
          fechaRenovacion: hoy.add(const Duration(days: 15)), // NORMAL
        ),
      ];

      // Act
      SubscriptionDataStructureService.loadSubscriptionsIntoStructures(
        subscriptions: subscriptions,
        stackUrgentes: stackUrgentes,
        queueProximas: queueProximas,
        linkedListTodas: linkedListTodas,
        treeOrdenadas: treeOrdenadas,
        hashTableBusqueda: hashTableBusqueda,
        graphServicios: graphServicios,
      );

      // Assert
      // Stack debe tener urgentes
      expect(stackUrgentes.size, equals(1));
      expect(stackUrgentes.peek()?.nombre, equals('Netflix'));

      // Queue debe tener próximas
      expect(queueProximas.size, equals(1));
      expect(queueProximas.peek()?.nombre, equals('Spotify'));

      // LinkedList debe tener todas
      expect(linkedListTodas.size, equals(3));

      // HashTable debe tener búsqueda rápida
      expect(hashTableBusqueda.size, equals(3));
      expect(hashTableBusqueda.search('1')?.nombre, equals('Netflix'));
      expect(hashTableBusqueda.search('2')?.nombre, equals('Spotify'));
      expect(hashTableBusqueda.search('3')?.nombre, equals('Adobe'));

      // Graph debe tener nodos
      expect(graphServicios.nodeCount, equals(3));
    });

    test('peekUrgente retorna siguiente urgente sin remover', () {
      // Arrange
      final hoy = DateTime.now();
      final urgente = Subscription(
        id: '1',
        nombre: 'Netflix',
        precioActual: 15.99,
        fechaRenovacion: hoy.add(const Duration(days: 2)),
      );
      stackUrgentes.push(urgente);

      // Act
      final resultado = SubscriptionDataStructureService.peekUrgente(
        stackUrgentes,
      );

      // Assert
      expect(resultado?.nombre, equals('Netflix'));
      expect(stackUrgentes.size, equals(1)); // No se removió
    });

    test('popUrgente retorna y remueve siguiente urgente', () {
      // Arrange
      final hoy = DateTime.now();
      final urgente = Subscription(
        id: '1',
        nombre: 'Netflix',
        precioActual: 15.99,
        fechaRenovacion: hoy.add(const Duration(days: 2)),
      );
      stackUrgentes.push(urgente);

      // Act
      final resultado = SubscriptionDataStructureService.popUrgente(
        stackUrgentes,
      );

      // Assert
      expect(resultado?.nombre, equals('Netflix'));
      expect(stackUrgentes.size, equals(0)); // Se removió
    });

    test('peekProxima retorna siguiente próxima sin remover', () {
      // Arrange
      final hoy = DateTime.now();
      final proxima = Subscription(
        id: '2',
        nombre: 'Spotify',
        precioActual: 10.99,
        fechaRenovacion: hoy.add(const Duration(days: 5)),
      );
      queueProximas.enqueue(proxima);

      // Act
      final resultado = SubscriptionDataStructureService.peekProxima(
        queueProximas,
      );

      // Assert
      expect(resultado?.nombre, equals('Spotify'));
      expect(queueProximas.size, equals(1)); // No se removió
    });

    test('dequeueProxima retorna y remueve siguiente próxima', () {
      // Arrange
      final hoy = DateTime.now();
      final proxima = Subscription(
        id: '2',
        nombre: 'Spotify',
        precioActual: 10.99,
        fechaRenovacion: hoy.add(const Duration(days: 5)),
      );
      queueProximas.enqueue(proxima);

      // Act
      final resultado = SubscriptionDataStructureService.dequeueProxima(
        queueProximas,
      );

      // Assert
      expect(resultado?.nombre, equals('Spotify'));
      expect(queueProximas.size, equals(0)); // Se removió
    });
  });
}
