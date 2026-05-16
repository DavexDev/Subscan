/// Queue data structure implementation (FIFO - First In First Out)
/// Generic Queue for any type of data
class Queue<T> {
  final List<T> _items = [];

  /// Getter para acceder a los items
  List<T> get items => List.from(_items);

  /// Enqueue: agregar al final
  void enqueue(T element) {
    _items.add(element);
  }

  /// Dequeue: remover del inicio
  T? dequeue() {
    return _items.isEmpty ? null : _items.removeAt(0);
  }

  /// Peek: ver el primero sin remover
  T? peek() => _items.isEmpty ? null : _items.first;

  /// Verificar si está vacía
  bool get isEmpty => _items.isEmpty;

  /// Tamaño
  int get size => _items.length;

  /// Lista de todos
  List<T> toList() => List.from(_items);

  /// Limpiar
  void clear() => _items.clear();

  @override
  String toString() => _items.toString();
}
