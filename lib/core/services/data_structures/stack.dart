/// Stack data structure implementation (LIFO - Last In First Out)
/// Generic Stack for any type of data
class Stack<T> {
  final List<T> _items = [];

  /// Getter para acceder a los items
  List<T> get items => List.from(_items);

  /// Push: agregar elemento al tope
  void push(T element) {
    _items.add(element);
  }

  /// Pop: remover y devolver elemento del tope
  T? pop() {
    return _items.isEmpty ? null : _items.removeLast();
  }

  /// Peek: ver elemento del tope sin remover
  T? peek() => _items.isEmpty ? null : _items.last;

  /// Verificar si está vacía
  bool get isEmpty => _items.isEmpty;

  /// Tamaño
  int get size => _items.length;

  /// Lista de todos los elementos
  List<T> toList() => List.from(_items);

  /// Limpiar
  void clear() => _items.clear();

  @override
  String toString() => _items.toString();
}
