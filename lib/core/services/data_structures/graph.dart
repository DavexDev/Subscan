/// Graph data structure implementation with adjacency list
/// Operaciones: Add Node, Add Edge, BFS, DFS
class Graph<T> {
  final Map<T, Set<T>> _adjacencyList = {};

  /// Add Node: agregar nodo al grafo
  void addNode(T node) {
    _adjacencyList.putIfAbsent(node, () => <T>{});
  }

  /// Add Edge: conectar dos nodos
  void addEdge(T source, T dest, {bool directed = false}) {
    _adjacencyList.putIfAbsent(source, () => <T>{});
    _adjacencyList.putIfAbsent(dest, () => <T>{});
    _adjacencyList[source]!.add(dest);

    if (!directed) {
      _adjacencyList[dest]!.add(source);
    }
  }

  /// BFS: Breadth-First Search
  List<T> bfs(T start) {
    if (!_adjacencyList.containsKey(start)) return [];

    final visited = <T>{};
    final queue = <T>[start];
    final result = <T>[];

    while (queue.isNotEmpty) {
      final node = queue.removeAt(0);
      if (visited.contains(node)) continue;

      visited.add(node);
      result.add(node);
      queue.addAll(_adjacencyList[node] ?? []);
    }
    return result;
  }

  /// DFS: Depth-First Search
  List<T> dfs(T start) {
    if (!_adjacencyList.containsKey(start)) return [];

    final visited = <T>{};
    final result = <T>[];

    void visit(T node) {
      if (visited.contains(node)) return;
      visited.add(node);
      result.add(node);
      final neighbors = _adjacencyList[node];
      if (neighbors != null) {
        for (final neighbor in neighbors) {
          visit(neighbor);
        }
      }
    }

    visit(start);
    return result;
  }

  Set<T> get nodes => _adjacencyList.keys.toSet();
  int get nodeCount => _adjacencyList.length;
  int get edgeCount {
    int count = 0;
    for (final neighbors in _adjacencyList.values) {
      count += neighbors.length;
    }
    return count;
  }

  void clear() {
    _adjacencyList.clear();
  }

  /// Verificar si existe un nodo
  bool hasNode(T node) => _adjacencyList.containsKey(node);

  /// Verificar si existe una arista
  bool hasEdge(T source, T dest) {
    return _adjacencyList[source]?.contains(dest) ?? false;
  }
}
