import 'package:riverpod/riverpod.dart';
import 'package:subscan/core/services/data_structures/stack.dart';
import 'package:subscan/core/services/data_structures/queue.dart';
import 'package:subscan/core/services/data_structures/linked_list.dart';
import 'package:subscan/core/services/data_structures/binary_tree.dart';
import 'package:subscan/core/services/data_structures/hash_table.dart';
import 'package:subscan/core/services/data_structures/graph.dart';

/// Simple providers para acceder a las estructuras de datos
final stackProvider = Provider<Stack<int>>((ref) => Stack<int>());

final queueProvider = Provider<Queue<int>>((ref) => Queue<int>());

final linkedListProvider = Provider<LinkedList<int>>(
  (ref) => LinkedList<int>(),
);

final binaryTreeProvider = Provider<BinaryTree<int>>(
  (ref) => BinaryTree<int>(),
);

final hashTableProvider = Provider<HashTable<String, int>>(
  (ref) => HashTable<String, int>(),
);

final graphProvider = Provider<Graph<String>>((ref) => Graph<String>());
