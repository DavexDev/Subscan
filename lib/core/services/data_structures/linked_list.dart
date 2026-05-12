/// LinkedList data structure implementation
/// Operaciones: Insert, Delete, Search, Traverse
class LinkedList<T> {
  Node<T>? _head;
  int _size = 0;

  /// Insert: agregar elemento
  void insert(T value) {
    final newNode = Node(value);
    if (_head == null) {
      _head = newNode;
    } else {
      Node<T> current = _head!;
      while (current.next != null) {
        current = current.next!;
      }
      current.next = newNode;
    }
    _size++;
  }

  /// Delete: remover elemento por valor
  bool delete(T value) {
    if (_head == null) return false;

    if (_head!.value == value) {
      _head = _head!.next;
      _size--;
      return true;
    }

    Node<T>? current = _head;
    while (current?.next != null) {
      if (current!.next!.value == value) {
        current.next = current.next!.next;
        _size--;
        return true;
      }
      current = current.next;
    }
    return false;
  }

  /// Search: buscar elemento
  bool search(T value) {
    Node<T>? current = _head;
    while (current != null) {
      if (current.value == value) return true;
      current = current.next;
    }
    return false;
  }

  /// Traverse: obtener lista de todos los elementos
  List<T> traverse() {
    final result = <T>[];
    Node<T>? current = _head;
    while (current != null) {
      result.add(current.value);
      current = current.next;
    }
    return result;
  }

  int get size => _size;
  bool get isEmpty => _size == 0;

  void clear() {
    _head = null;
    _size = 0;
  }
}

class Node<T> {
  T value;
  Node<T>? next;

  Node(this.value);
}
