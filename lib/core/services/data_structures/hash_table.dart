/// HashTable data structure implementation with collision handling
/// Usa bucket-based approach (List of Lists)
class HashTable<K, V> {
  final List<List<MapEntry<K, V>>> _buckets;
  int _size = 0;

  HashTable({int capacity = 16}) : _buckets = List.generate(capacity, (_) => []);

  /// Hash function
  int _hash(K key) => key.hashCode % _buckets.length;

  /// Insert: agregar o actualizar key-value
  void insert(K key, V value) {
    final index = _hash(key);
    
    // Buscar si la key ya existe
    for (int i = 0; i < _buckets[index].length; i++) {
      if (_buckets[index][i].key == key) {
        _buckets[index][i] = MapEntry(key, value);
        return;
      }
    }
    
    // Si no existe, agregarlo
    _buckets[index].add(MapEntry(key, value));
    _size++;
  }

  /// Search: buscar por key
  V? search(K key) {
    final index = _hash(key);
    for (final entry in _buckets[index]) {
      if (entry.key == key) return entry.value;
    }
    return null;
  }

  /// Delete: remover por key
  bool delete(K key) {
    final index = _hash(key);
    for (int i = 0; i < _buckets[index].length; i++) {
      if (_buckets[index][i].key == key) {
        _buckets[index].removeAt(i);
        _size--;
        return true;
      }
    }
    return false;
  }

  int get size => _size;
  bool get isEmpty => _size == 0;

  void clear() {
    for (final bucket in _buckets) {
      bucket.clear();
    }
    _size = 0;
  }

  /// Retorna todas las keys
  List<K> keys() {
    final result = <K>[];
    for (final bucket in _buckets) {
      for (final entry in bucket) {
        result.add(entry.key);
      }
    }
    return result;
  }

  /// Retorna todos los valores
  List<V> values() {
    final result = <V>[];
    for (final bucket in _buckets) {
      for (final entry in bucket) {
        result.add(entry.value);
      }
    }
    return result;
  }
}
