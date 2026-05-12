import 'package:flutter_test/flutter_test.dart';
import 'package:subscan/core/services/data_structures/stack.dart';
import 'package:subscan/core/services/data_structures/queue.dart';
import 'package:subscan/core/services/data_structures/linked_list.dart';
import 'package:subscan/core/services/data_structures/binary_tree.dart';
import 'package:subscan/core/services/data_structures/hash_table.dart';
import 'package:subscan/core/services/data_structures/graph.dart';

void main() {
  group('Stack Tests', () {
    late Stack<int> stack;

    setUp(() {
      stack = Stack<int>();
    });

    test('push y pop funcionan correctamente (LIFO)', () {
      stack.push(1);
      stack.push(2);
      stack.push(3);

      expect(stack.pop(), equals(3));
      expect(stack.pop(), equals(2));
      expect(stack.pop(), equals(1));
      expect(stack.isEmpty, equals(true));
    });

    test('peek retorna el tope sin remover', () {
      stack.push(1);
      stack.push(2);
      stack.push(3);

      expect(stack.peek(), equals(3));
      expect(stack.size, equals(3));
    });

    test('pop en stack vacío retorna null', () {
      expect(stack.pop(), equals(null));
      expect(stack.isEmpty, equals(true));
    });

    test('size retorna cantidad correcta', () {
      stack.push(1);
      stack.push(2);

      expect(stack.size, equals(2));
    });

    test('clear limpia el stack', () {
      stack.push(1);
      stack.push(2);
      stack.clear();

      expect(stack.isEmpty, equals(true));
      expect(stack.size, equals(0));
    });

    test('toList retorna lista de elementos', () {
      stack.push(1);
      stack.push(2);
      stack.push(3);

      expect(stack.toList(), equals([1, 2, 3]));
    });
  });

  group('Queue Tests', () {
    late Queue<int> queue;

    setUp(() {
      queue = Queue<int>();
    });

    test('enqueue y dequeue funcionan correctamente (FIFO)', () {
      queue.enqueue(1);
      queue.enqueue(2);
      queue.enqueue(3);

      expect(queue.dequeue(), equals(1));
      expect(queue.dequeue(), equals(2));
      expect(queue.dequeue(), equals(3));
      expect(queue.isEmpty, equals(true));
    });

    test('peek retorna el primero sin remover', () {
      queue.enqueue(1);
      queue.enqueue(2);
      queue.enqueue(3);

      expect(queue.peek(), equals(1));
      expect(queue.size, equals(3));
    });

    test('dequeue en queue vacío retorna null', () {
      expect(queue.dequeue(), equals(null));
      expect(queue.isEmpty, equals(true));
    });

    test('size retorna cantidad correcta', () {
      queue.enqueue(1);
      queue.enqueue(2);

      expect(queue.size, equals(2));
    });

    test('clear limpia la queue', () {
      queue.enqueue(1);
      queue.enqueue(2);
      queue.clear();

      expect(queue.isEmpty, equals(true));
      expect(queue.size, equals(0));
    });

    test('toList retorna lista de elementos en orden FIFO', () {
      queue.enqueue(1);
      queue.enqueue(2);
      queue.enqueue(3);

      expect(queue.toList(), equals([1, 2, 3]));
    });
  });

  group('LinkedList Tests', () {
    late LinkedList<int> linkedList;

    setUp(() {
      linkedList = LinkedList<int>();
    });

    test('insert agrega elementos a la lista', () {
      linkedList.insert(1);
      linkedList.insert(2);
      linkedList.insert(3);

      expect(linkedList.size, equals(3));
      expect(linkedList.traverse(), equals([1, 2, 3]));
    });

    test('search encuentra elemento existente', () {
      linkedList.insert(1);
      linkedList.insert(2);
      linkedList.insert(3);

      expect(linkedList.search(2), equals(true));
      expect(linkedList.search(5), equals(false));
    });

    test('delete remueve elemento correctamente', () {
      linkedList.insert(1);
      linkedList.insert(2);
      linkedList.insert(3);

      final result = linkedList.delete(2);
      expect(result, equals(true));
      expect(linkedList.traverse(), equals([1, 3]));
      expect(linkedList.size, equals(2));
    });

    test('delete primer elemento', () {
      linkedList.insert(1);
      linkedList.insert(2);

      final result = linkedList.delete(1);
      expect(result, equals(true));
      expect(linkedList.traverse(), equals([2]));
    });

    test('delete en lista vacía retorna false', () {
      expect(linkedList.delete(1), equals(false));
    });

    test('clear limpia la lista', () {
      linkedList.insert(1);
      linkedList.insert(2);
      linkedList.clear();

      expect(linkedList.isEmpty, equals(true));
      expect(linkedList.size, equals(0));
    });
  });

  group('BinaryTree Tests', () {
    late BinaryTree<int> tree;

    setUp(() {
      tree = BinaryTree<int>();
    });

    test('insert agrega elementos al árbol', () {
      tree.insert(5);
      tree.insert(3);
      tree.insert(7);
      tree.insert(1);
      tree.insert(9);

      expect(tree.size, equals(5));
    });

    test('search encuentra elemento existente', () {
      tree.insert(5);
      tree.insert(3);
      tree.insert(7);

      expect(tree.search(3), equals(true));
      expect(tree.search(7), equals(true));
      expect(tree.search(10), equals(false));
    });

    test('traverseInOrder retorna elementos en orden', () {
      tree.insert(5);
      tree.insert(3);
      tree.insert(7);
      tree.insert(1);
      tree.insert(9);

      expect(tree.traverseInOrder(), equals([1, 3, 5, 7, 9]));
    });

    test('traversePreOrder retorna root primero', () {
      tree.insert(5);
      tree.insert(3);
      tree.insert(7);

      final result = tree.traversePreOrder();
      expect(result[0], equals(5));
    });

    test('traversePostOrder retorna root último', () {
      tree.insert(5);
      tree.insert(3);
      tree.insert(7);

      final result = tree.traversePostOrder();
      expect(result.last, equals(5));
    });

    test('clear limpia el árbol', () {
      tree.insert(5);
      tree.insert(3);
      tree.clear();

      expect(tree.isEmpty, equals(true));
      expect(tree.size, equals(0));
    });
  });

  group('HashTable Tests', () {
    late HashTable<String, int> hashTable;

    setUp(() {
      hashTable = HashTable<String, int>();
    });

    test('insert y search funcionan', () {
      hashTable.insert('a', 1);
      hashTable.insert('b', 2);
      hashTable.insert('c', 3);

      expect(hashTable.search('a'), equals(1));
      expect(hashTable.search('b'), equals(2));
      expect(hashTable.search('z'), equals(null));
    });

    test('insert actualiza valor existente', () {
      hashTable.insert('a', 1);
      hashTable.insert('a', 10);

      expect(hashTable.search('a'), equals(10));
      expect(hashTable.size, equals(1));
    });

    test('delete remueve elemento', () {
      hashTable.insert('a', 1);
      hashTable.insert('b', 2);

      final result = hashTable.delete('a');
      expect(result, equals(true));
      expect(hashTable.search('a'), equals(null));
      expect(hashTable.size, equals(1));
    });

    test('delete elemento inexistente retorna false', () {
      expect(hashTable.delete('z'), equals(false));
    });

    test('keys y values retornan listas correctas', () {
      hashTable.insert('a', 1);
      hashTable.insert('b', 2);

      expect(hashTable.keys().length, equals(2));
      expect(hashTable.values().length, equals(2));
    });

    test('clear limpia la tabla hash', () {
      hashTable.insert('a', 1);
      hashTable.insert('b', 2);
      hashTable.clear();

      expect(hashTable.isEmpty, equals(true));
      expect(hashTable.size, equals(0));
    });
  });

  group('Graph Tests', () {
    late Graph<String> graph;

    setUp(() {
      graph = Graph<String>();
    });

    test('addNode agrega nodo', () {
      graph.addNode('A');
      graph.addNode('B');

      expect(graph.hasNode('A'), equals(true));
      expect(graph.nodeCount, equals(2));
    });

    test('addEdge conecta dos nodos (directed)', () {
      graph.addNode('A');
      graph.addNode('B');
      graph.addEdge('A', 'B', directed: true);

      expect(graph.hasEdge('A', 'B'), equals(true));
      expect(graph.hasEdge('B', 'A'), equals(false));
    });

    test('addEdge conecta dos nodos (undirected)', () {
      graph.addNode('A');
      graph.addNode('B');
      graph.addEdge('A', 'B', directed: false);

      expect(graph.hasEdge('A', 'B'), equals(true));
      expect(graph.hasEdge('B', 'A'), equals(true));
    });

    test('bfs recorre nodos en orden breadth-first', () {
      graph.addNode('A');
      graph.addNode('B');
      graph.addNode('C');
      graph.addEdge('A', 'B', directed: true);
      graph.addEdge('A', 'C', directed: true);

      final result = graph.bfs('A');
      expect(result.first, equals('A'));
      expect(result.length, equals(3));
    });

    test('dfs recorre nodos en orden depth-first', () {
      graph.addNode('A');
      graph.addNode('B');
      graph.addNode('C');
      graph.addEdge('A', 'B', directed: true);
      graph.addEdge('B', 'C', directed: true);

      final result = graph.dfs('A');
      expect(result.first, equals('A'));
      expect(result.length, equals(3));
    });

    test('bfs retorna lista vacía si nodo no existe', () {
      graph.addNode('A');
      expect(graph.bfs('Z'), equals([]));
    });

    test('clear limpia el grafo', () {
      graph.addNode('A');
      graph.addNode('B');
      graph.clear();

      expect(graph.nodeCount, equals(0));
    });
  });
}
