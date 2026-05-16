/// BinaryTree data structure implementation
/// Operaciones: Insert, Delete, Traverse (InOrder, PreOrder, PostOrder)
class BinaryTree<T> {
  TreeNode<T>? _root;
  int _size = 0;
  final int Function(T a, T b) _comparator;

  BinaryTree({int Function(T a, T b)? comparator})
    : _comparator = comparator ?? _defaultComparator;

  static int _defaultComparator(dynamic a, dynamic b) {
    if (a is Comparable && b is Comparable) {
      return a.compareTo(b as Comparable);
    }
    throw UnsupportedError('Type must implement Comparable');
  }

  /// Insert: agregar elemento
  void insert(T value) {
    if (_root == null) {
      _root = TreeNode(value);
      _size++;
    } else {
      _insertRecursive(_root!, value);
    }
  }

  void _insertRecursive(TreeNode<T> node, T value) {
    final comparison = _comparator(value, node.value);
    if (comparison < 0) {
      if (node.left == null) {
        node.left = TreeNode(value);
        _size++;
      } else {
        _insertRecursive(node.left!, value);
      }
    } else {
      if (node.right == null) {
        node.right = TreeNode(value);
        _size++;
      } else {
        _insertRecursive(node.right!, value);
      }
    }
  }

  /// Search: buscar elemento
  bool search(T value) {
    return _searchRecursive(_root, value);
  }

  bool _searchRecursive(TreeNode<T>? node, T value) {
    if (node == null) return false;
    final comparison = _comparator(value, node.value);
    if (comparison == 0) return true;
    if (comparison < 0) {
      return _searchRecursive(node.left, value);
    } else {
      return _searchRecursive(node.right, value);
    }
  }

  /// Traverse InOrder: Left, Root, Right
  List<T> traverseInOrder() {
    final result = <T>[];
    _inOrderRecursive(_root, result);
    return result;
  }

  void _inOrderRecursive(TreeNode<T>? node, List<T> result) {
    if (node == null) return;
    _inOrderRecursive(node.left, result);
    result.add(node.value);
    _inOrderRecursive(node.right, result);
  }

  /// Traverse PreOrder: Root, Left, Right
  List<T> traversePreOrder() {
    final result = <T>[];
    _preOrderRecursive(_root, result);
    return result;
  }

  void _preOrderRecursive(TreeNode<T>? node, List<T> result) {
    if (node == null) return;
    result.add(node.value);
    _preOrderRecursive(node.left, result);
    _preOrderRecursive(node.right, result);
  }

  /// Traverse PostOrder: Left, Right, Root
  List<T> traversePostOrder() {
    final result = <T>[];
    _postOrderRecursive(_root, result);
    return result;
  }

  void _postOrderRecursive(TreeNode<T>? node, List<T> result) {
    if (node == null) return;
    _postOrderRecursive(node.left, result);
    _postOrderRecursive(node.right, result);
    result.add(node.value);
  }

  int get size => _size;
  bool get isEmpty => _size == 0;

  void clear() {
    _root = null;
    _size = 0;
  }
}

class TreeNode<T> {
  T value;
  TreeNode<T>? left;
  TreeNode<T>? right;

  TreeNode(this.value);
}
