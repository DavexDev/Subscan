# SubScan - Sistema de Gestión de Suscripciones

## Descripción General

SubScan es una aplicación Flutter para gestionar suscripciones digitales con análisis inteligente mediante 6 estructuras de datos académicas. Implementa **Clean Architecture** con capas de Domain, Data y Presentation, integrado con **Riverpod** para state management.

**Estado del Proyecto**: Desarrollo colaborativo con equipo especializado

---

## Equipo y Estructura de Trabajo

### Miembros del Equipo (4)

| Rol | Responsable | Rama | Área |
|-----|------------|------|------|
| **Designer** | Pablo | - | Figma: Mockups, Design Tokens, Componentes |
| **Backend Core** | Dave | `dave` | Data Structures, Domain Layer, Architecture |
| **Backend Core (Supabase)** | Dave | `supabase-integration` | Firebase Auth, Supabase DB, SupabaseDatasource, Edge Functions |
| **Frontend** | Brandon | `brandonnn` | UI Pages, Widgets, Riverpod State, Animations |
| **Backend Integration** | Jeferson | `Jeferson` | Gmail API Integration, GmailDatasource, Email Parsing |

### Ramas Principales

```
main (protegida)
 ├─ dave                    [feat(core):, feat(datasource):]
 ├─ brandonnn               [feat(ui):, style:, refactor(ui):]
 ├─ supabase-integration    [feat(auth):, feat(db):, feat(datasource):]
 └─ Jeferson               [feat(gmail):, feat(email-sync):]
```

### Convenciones de Commits por Rama

**Branch `dave` (Dave - Backend Core)**:
- `feat(core): implement {feature}`
- `feat(datasource): implement {interface}`
- `feat(providers): add {provider}`
- `test(core): add {tests}`

**Branch `brandonnn` (Brandon - Frontend)**:
- `feat(ui): implement {page/widget}`
- `style: {styling changes}`
- `refactor(ui): {component improvements}`
- `test(widget): add {tests}`

**Branch `supabase-integration` (Dave - Supabase Setup)**:
- `feat(auth): implement firebase authentication`
- `feat(db): create subscriptions table with RLS`
- `feat(datasource): implement SupabaseDatasource`
- `feat(edge-functions): add subscription sync logic`

**Branch `Jeferson` (Jeferson - Gmail API)**:
- `feat(gmail): integrate Gmail API client`
- `feat(datasource): implement GmailDatasource`
- `feat(email-sync): add email parsing and detection`

### Auto-merge Workflow

Todas las ramas tienen auto-merge habilitado:
- Trigger: PR abierto en cualquier rama
- Validación: `flutter analyze` + `flutter test`
- Merge type: Squash merge
- Target: `main`

Para crear nueva rama:
```bash
git checkout main
git pull origin main
git checkout -b {branch-name}
# Hacer cambios
git commit -m "tipo(área): mensaje"
git push origin {branch-name}
# Crear PR en GitHub → auto-merge en ~30 segundos
```

---

## Ciclo de Desarrollo

1. **Design** → Pablo crea mockups y design tokens en Figma
2. **Backend Core** → Dave implementa estructuras y contratos (rama `dave`)
3. **Frontend** → Brandon implementa UI basada en Figma (rama `brandonnn`)
4. **Backend Supabase** → Dave implementa autenticación y BD (rama `supabase-integration`)
5. **Backend Gmail** → Jeferson implementa integración de emails (rama `Jeferson`)
6. **Integration** → Todo se mergeea a `main` automáticamente

---

## Tecnología Stack

- **Framework**: Flutter + Dart
- **State Management**: Riverpod 2.4.0
- **Backend**: Supabase + Firebase
- **Auth**: Google Sign-In
- **API**: Gmail API (via Supabase Edge Functions)

---

## 1. Estructuras de Datos Implementadas

### 1.1 Stack (Pila) - LIFO
**Ubicación**: `lib/core/services/data_structures/stack.dart`

**Tipo**: Genérico `Stack<T>`

**Descripción**: Estructura de datos de tipo LIFO (Last In, First Out). El último elemento insertado es el primero en salir.

**Operaciones Implementadas**:
- `push(T value)` - Inserta elemento al final
- `pop() -> T?` - Extrae y retorna el último elemento
- `peek() -> T?` - Visualiza el último elemento sin remover
- `size` - Obtiene cantidad de elementos
- `isEmpty` - Verifica si está vacía
- `clear()` - Limpia la estructura
- `toList() -> List<T>` - Convierte a lista

**Propósito en SubScan**:
- Almacena **suscripciones urgentes** (<=3 días para renovar)
- Acceso LIFO: las más urgentes se procesan primero
- Permite `popUrgente()` para obtener la siguiente urgente

**Tests**: 6 tests unitarios validando operaciones LIFO, peek sin modificación, empty state

---

### 1.2 Queue (Cola) - FIFO
**Ubicación**: `lib/core/services/data_structures/queue.dart`

**Tipo**: Genérico `Queue<T>`

**Descripción**: Estructura de datos de tipo FIFO (First In, First Out). El primer elemento insertado es el primero en salir.

**Operaciones Implementadas**:
- `enqueue(T value)` - Inserta elemento al final
- `dequeue() -> T?` - Extrae y retorna el primer elemento
- `peek() -> T?` - Visualiza el primer elemento sin remover
- `size` - Obtiene cantidad de elementos
- `isEmpty` - Verifica si está vacía
- `clear()` - Limpia la estructura
- `toList() -> List<T>` - Convierte a lista
- `items` getter - Acceso a elementos para state management

**Propósito en SubScan**:
- Almacena **suscripciones próximas a renovarse** (4-7 días)
- Acceso FIFO: mantiene orden cronológico de renovaciones
- Permite `dequeueProxima()` para procesar en orden

**Tests**: 6 tests unitarios validando operaciones FIFO, peek sin modificación, empty state

---

### 1.3 LinkedList (Lista Enlazada)
**Ubicación**: `lib/core/services/data_structures/linked_list.dart`

**Tipo**: Genérico `LinkedList<T>` con clase interna `Node<T>`

**Descripción**: Estructura encadenada donde cada nodo apunta al siguiente. Permite inserción/eliminación eficiente sin reorganización de memoria.

**Operaciones Implementadas**:
- `insert(T value)` - Inserta elemento ordenado alfabéticamente
- `delete(T value) -> bool` - Elimina elemento, retorna si fue exitoso
- `search(T value) -> bool` - Busca elemento
- `traverse() -> List<T>` - Retorna todos los elementos en orden
- `size` - Cantidad de elementos
- `isEmpty` - Verifica si está vacía
- `clear()` - Limpia la estructura

**Nodo Interno**:
```dart
class Node<T> {
  final T value;
  Node<T>? next;
  
  Node(this.value);
}
```

**Propósito en SubScan**:
- Almacena **todas las suscripciones** ordenadas por nombre
- Permite recorrido secuencial eficiente
- Facilita inserción/eliminación sin reorganización

**Tests**: 6 tests unitarios para insert/delete/search/traverse, empty state, traversal order

---

### 1.4 BinaryTree (Árbol Binario de Búsqueda)
**Ubicación**: `lib/core/services/data_structures/binary_tree.dart`

**Tipo**: Genérico `BinaryTree<T>` con clase interna `TreeNode<T>`

**Descripción**: Árbol de búsqueda binario con soporte para comparadores personalizados. Mantiene elementos ordenados para búsqueda rápida O(log n).

**Operaciones Implementadas**:
- `insert(T value)` - Inserta manteniendo orden BST
- `search(T value) -> bool` - Busca elemento (O(log n) en promedio)
- `traverseInOrder() -> List<T>` - Recorrido en orden (Left-Root-Right)
- `traversePreOrder() -> List<T>` - Recorrido pre-orden (Root-Left-Right)
- `traversePostOrder() -> List<T>` - Recorrido post-orden (Left-Right-Root)
- `size` - Cantidad de elementos
- `isEmpty` - Verifica si está vacía
- `clear()` - Limpia la estructura

**Nodo Interno**:
```dart
class TreeNode<T> {
  final T value;
  TreeNode<T>? left;
  TreeNode<T>? right;
  
  TreeNode(this.value);
}
```

**Comparador Personalizado**:
- Constructor acepta `int Function(T a, T b) comparator`
- Valor por defecto: requiere que T implemente `Comparable`
- En SubScan: usa comparador de fecha de renovación

**Propósito en SubScan**:
- Almacena **suscripciones ordenadas por fecha de renovación**
- Búsqueda rápida O(log n) para consultas
- Tres recorridos disponibles para diferentes análisis

**Tests**: 6 tests unitarios para insert/search/traverse (3 órdenes), custom comparator, empty state

---

### 1.5 HashTable (Tabla Hash)
**Ubicación**: `lib/core/services/data_structures/hash_table.dart`

**Tipo**: Genérico `HashTable<K, V>`

**Descripción**: Tabla hash con resolución de colisiones mediante encadenamiento (buckets). Ofrece búsqueda O(1) promedio.

**Operaciones Implementadas**:
- `insert(K key, V value)` - Inserta o actualiza par clave-valor
- `search(K key) -> V?` - Busca valor por clave (O(1) promedio)
- `delete(K key) -> bool` - Elimina por clave, retorna si existía
- `keys() -> List<K>` - Retorna todas las claves
- `values() -> List<V>` - Retorna todos los valores
- `size` - Cantidad de pares clave-valor
- `clear()` - Limpia la tabla

**Función Hash**:
```dart
int _hash(K key) => key.hashCode % _capacity;
```

**Resolución de Colisiones**:
- Encadenamiento: cada bucket es una `List<MapEntry<K, V>>`
- Manejo automático de múltiples valores con misma clave hash

**Propósito en SubScan**:
- Búsqueda **O(1) de suscripciones por ID**
- Reemplazo de diccionario Map para demostración de estructura de datos
- Acceso ultra-rápido en operaciones de sincronización

**Tests**: 6 tests unitarios para insert/search/delete, hash collisions, bucket handling, empty state

---

### 1.6 Graph (Grafo)
**Ubicación**: `lib/core/services/data_structures/graph.dart`

**Tipo**: Genérico `Graph<T>` con lista de adyacencia

**Descripción**: Grafo no dirigido con soporte para búsqueda en profundidad (DFS) y búsqueda en anchura (BFS).

**Operaciones Implementadas**:
- `addNode(T node)` - Agrega nodo al grafo
- `addEdge(T from, T to, {bool directed = false})` - Agrega arista entre nodos
- `bfs(T start) -> List<T>` - Búsqueda en anchura (BFS) retorna nodos visitados
- `dfs(T start) -> List<T>` - Búsqueda en profundidad (DFS) retorna nodos visitados
- `hasNode(T node) -> bool` - Verifica si existe nodo
- `hasEdge(T from, T to) -> bool` - Verifica si existe arista
- `nodeCount` - Cantidad de nodos
- `clear()` - Limpia el grafo

**Estructura Interna**:
```dart
Map<T, Set<T>> _adjacencyList; // Cada nodo apunta a sus vecinos
```

**Propósito en SubScan**:
- Modela **relaciones entre servicios de suscripción**
- Ej: Netflix ↔ Disney+ ↔ HBO (servicios de streaming)
- BFS/DFS para encontrar servicios relacionados
- Análisis de clusters de gastos por categoría

**Tests**: 7 tests unitarios para addNode/addEdge, BFS/DFS order, connectivity, empty state

---

## 2. Integración: SubscriptionDataStructureService

**Ubicación**: `lib/core/services/subscription_service.dart`

**Responsabilidad**: Distribuir inteligentemente datos de suscripciones en las 6 estructuras según criterios de urgencia.

**Método Principal**:
```dart
static void loadSubscriptionsIntoStructures({
  required List<Subscription> subscriptions,
  required Stack<Subscription> stackUrgentes,
  required Queue<Subscription> queueProximas,
  required LinkedList<Subscription> linkedListTodas,
  required BinaryTree<Subscription> treeOrdenadas,
  required HashTable<String, Subscription> hashTableBusqueda,
  required Graph<String> graphServicios,
})
```

**Distribución de Datos**:
| Estructura | Datos | Criterio | Propósito |
|-----------|-------|----------|-----------|
| **Stack** | Urgentes | `isUrgent` (<=3 días) | Acceso LIFO a críticos |
| **Queue** | Próximas | `isNearRenewal` (4-7 días) | FIFO por fecha |
| **LinkedList** | Todas | Ninguno | Iteración completa |
| **BinaryTree** | Todas | Ordenadas por fecha | Búsqueda rápida |
| **HashTable** | Todas | Por ID | Lookup O(1) |
| **Graph** | Servicios | Relaciones por categoría | Análisis de clusters |

**Métodos de Acceso**:
- `peekUrgente(stack)` - Ve siguiente urgente sin remover
- `popUrgente(stack)` - Extrae siguiente urgente
- `peekProxima(queue)` - Ve siguiente próxima sin remover
- `dequeueProxima(queue)` - Extrae siguiente próxima
- `createSubscriptionBinaryTree()` - Factory con comparador de fecha

---

## 3. Arquitectura Clean Architecture

### 3.1 Domain Layer (Lógica de Negocio)
- `domain/repositories/subscription_repository.dart` - Interfaz de contrato

### 3.2 Data Layer (Acceso a Datos)
- `data/datasources/subscription_datasource.dart` - Interfaz abstracta para implementadores
- `data/datasources/supabase_datasource.dart` - Implementación Supabase (rama `supabase-integration`)
- `data/datasources/gmail_datasource.dart` - Implementación Gmail (rama `gmail-integration`)
- `data/repositories/subscription_repository_impl.dart` - Implementación que usa datasource

### 3.3 Models
- `models/subscription.dart` - Entidad Subscription con propiedades computadas:
  - `diasRestantes` - Cálculo dinámico
  - `isUrgent` - Urgencia (<=3 días)
  - `isNearRenewal` - Próxima (<=7 días)

### 3.4 Providers (Riverpod)
- `providers/data_structures_providers.dart` - Providers para cada estructura
- `providers/subscription_providers.dart` - Providers para repositorio y servicio

---

## 4. Unit Tests

**Total**: 42 tests [OK]

| Componente | Tests | Estado |
|-----------|-------|--------|
| Stack | 6 | PASSING |
| Queue | 6 | PASSING |
| LinkedList | 6 | PASSING |
| BinaryTree | 6 | PASSING |
| HashTable | 6 | PASSING |
| Graph | 7 | PASSING |
| SubscriptionService | 5 | PASSING |
| **TOTAL** | **42** | **[OK]** |

**Ejecutar tests**:
```bash
flutter test test/data_structures_test.dart test/subscription_service_test.dart
```

---

## 5. Estado de Implementación por Rama

### ✅ Rama `dave` - Backend Core (Dave)
- [OK] 6 Estructuras de datos con operaciones completas
- [OK] 42 Unit tests (todos pasando)
- [OK] Subscription entity con propiedades computadas
- [OK] SubscriptionDataStructureService con distribución inteligente
- [OK] Clean Architecture (Domain + Data layers)
- [OK] Repositorio y Datasource interfaces
- [OK] Riverpod Providers (structures y subscription)
- [OK] Documentación completa

### ✅ Rama `brandonnn` - Frontend UI (Brandon)
- [OK] 5 Pages: Splash, Onboarding, Login, Dashboard, Detail
- [OK] Widgets reutilizables: Card, Banner
- [OK] Design Tokens y AppTheme
- [OK] Riverpod state management (SubscriptionNotifier)
- [OK] Animaciones y transiciones
- [OK] Mock datasource para desarrollo
- [OK] 43 tests pasando (42 + widget test)

### ⏳ Rama `supabase-integration` - Backend Supabase (Dave)
- [ ] Firebase Auth setup
- [ ] Supabase database + RLS
- [ ] SupabaseDatasource implementation
- [ ] Edge Functions
- [ ] .env configuration

### ⏳ Rama `Jeferson` - Email Integration (Jeferson)
- [ ] Gmail API integration
- [ ] GmailDatasource implementation
- [ ] Email parsing y detection
- [ ] OAuth2 configuration

---

## 6. Dependencias

### pubspec.yaml
```yaml
dependencies:
  flutter_riverpod: ^2.4.0      # State management
  riverpod: ^2.4.0              # Core riverpod
  supabase_flutter: ^1.8.0      # Backend
  google_sign_in: ^6.2.0        # Auth
  googleapis: ^12.0.0           # Gmail API
  dio: ^5.3.0                   # HTTP
```

---

## 7. Cómo Usar (Para Todas las Ramas)

### Cargar datos en estructuras
```dart
final subscriptions = await ref.watch(subscriptionRepositoryProvider).getSubscriptions();

SubscriptionDataStructureService.loadSubscriptionsIntoStructures(
  subscriptions: subscriptions,
  stackUrgentes: ref.watch(stackProvider),
  queueProximas: ref.watch(queueProvider),
  linkedListTodas: ref.watch(linkedListProvider),
  treeOrdenadas: ref.watch(binaryTreeProvider),
  hashTableBusqueda: ref.watch(hashTableProvider),
  graphServicios: ref.watch(graphProvider),
);
```

### Acceder a urgentes
```dart
final urgente = SubscriptionDataStructureService.peekUrgente(stack);
final proximaAUrgente = SubscriptionDataStructureService.popUrgente(stack);
```

### Búsqueda rápida por ID
```dart
final sub = hashTable.search('sub-id-123');
```

### Análisis de relaciones
```dart
final relacionados = graph.bfs('Netflix');
```

---

## 8. Notas Académicas

Proyecto implementa los 6 requisitos de estructuras de datos obligatorias:

1. **Stack** - LIFO structure ✓
2. **Queue** - FIFO structure ✓
3. **LinkedList** - Encadenada con Node ✓
4. **BinaryTree** - BST con 3 traversals ✓
5. **HashTable** - Con resolución de colisiones ✓
6. **Graph** - Con BFS/DFS algorithms ✓

Control de versiones mediante Git con feature/* branching.

---

## 9. Cómo Empezar

### Instalación
```bash
flutter pub get
flutter test
```

### Ejecutar app
```bash
flutter run
```

---

**Estructura del Proyecto**:
- **Rama `dave`** (Dave - Backend Core): Estructuras de datos, Domain layer
- **Rama `brandonnn`** (Brandon - Frontend): UI pages, widgets, state management
- **Rama `supabase-integration`** (Dave - Supabase): Firebase Auth, database setup
- **Rama `Jeferson`** (Jeferson - Email): Gmail API integration
- **Setup Guides**: Ver archivos privados `PERSONA3A_BACKEND.md`, `PERSONA3B_GMAIL.md`, `AI_AGENT_INSTRUCTIONS.md`
- **Estado del Repo**: Ramas `dave` + `brandonnn` completas. `supabase-integration` + `gmail-integration` en desarrollo paralelo

**Última actualización**: 2026-05-12


