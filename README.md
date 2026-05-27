# SubScan — Gestor de Suscripciones Digitales

> **Universidad Mariano Galvez de Guatemala**  
> Facultad de Ingenieria en Sistemas de Informacion y Ciencias de la Computacion  
> **Curso:** Programacion III — Codigo 022  
> **Proyecto Final** | Tecnologia: Flutter (Dart) + Git / GitHub

---

## Tabla de Contenidos

1. [Descripcion del Proyecto](#1-descripcion-del-proyecto)
2. [Equipo de Desarrollo](#2-equipo-de-desarrollo)
3. [Entregables](#3-entregables)
4. [Arquitectura de la Aplicacion](#4-arquitectura-de-la-aplicacion)
5. [Estructuras de Datos Implementadas](#5-estructuras-de-datos-implementadas)
6. [Integracion con el API REST](#6-integracion-con-el-api-rest)
7. [Pantalla de Analisis de Datos](#7-pantalla-de-analisis-de-datos)
8. [Control de Versiones](#8-control-de-versiones)
9. [Interfaz de Usuario](#9-interfaz-de-usuario)
10. [Instrucciones de Instalacion y Ejecucion](#10-instrucciones-de-instalacion-y-ejecucion)
11. [Pruebas Unitarias](#11-pruebas-unitarias)
12. [Rubrica de Evaluacion — Cumplimiento](#12-rubrica-de-evaluacion--cumplimiento)

---

## 1. Descripcion del Proyecto

**SubScan** es una aplicacion movil desarrollada en **Flutter / Dart** que permite gestionar suscripciones digitales (streaming, software, servicios) de manera inteligente. La aplicacion consume un **API REST** (Supabase + Gmail API) para obtener datos reales y los almacena y procesa mediante **6 estructuras de datos** implementadas desde cero en Dart: Pila, Cola, Lista Enlazada, Arbol Binario, Tabla Hash y Grafo.

### Caracteristicas principales

- Consumo de API REST real (Supabase como backend, Gmail API para deteccion automatica)
- 6 estructuras de datos con operaciones visibles desde la interfaz (insertar, eliminar, buscar)
- Pantalla de analisis y resumen de datos cargados
- Autenticacion con Google Sign-In + Firebase Auth
- Arquitectura limpia (Clean Architecture): Domain, Data, Presentation
- State management con Riverpod 2.x

---

## 2. Equipo de Desarrollo

| Integrante | Rama de Trabajo | Responsabilidad |
|------------|-----------------|-----------------|
| Dave | `dave` | Backend core: estructuras de datos, domain layer, arquitectura |
| Brandon | `brandonnn` | Frontend: UI pages, widgets, animaciones, Riverpod state |
| Jeferson | `Jeferson` | Integracion Gmail API, GmailDatasource, parseo de correos |

> Modalidad grupal — 3 integrantes.

---

## 3. Entregables

### Entregable 1 — Semana 12 (5 pts.)
- [x] Repositorio publico configurado en GitHub
- [x] Proyecto Flutter corriendo sin errores
- [x] Consumo basico del API (Supabase datasource)
- [x] Al menos 2 estructuras de datos con datos reales: **Stack** y **Queue**

### Entregable 2 — Semana 14 (5 pts.)
- [x] Las 6 estructuras de datos implementadas y funcionales
- [x] Operaciones de insercion, eliminacion y busqueda desde la interfaz
- [x] 42 tests unitarios pasando

### Entregable 3 — Semana 16 (5 pts.)
- [x] Aplicacion completa integrada con el API
- [x] Datos reales cargados en volumen desde Supabase + Gmail
- [x] Pantalla de analisis de datos implementada
- [x] README documentado (este archivo) e historial de commits organizado

### Presentacion Final — Semana 17 (5 pts.)
- [ ] Demostracion en vivo de la aplicacion
- [ ] Participacion de todos los integrantes

---

## 4. Arquitectura de la Aplicacion

La aplicacion sigue el patron **Clean Architecture**, dividida en tres capas principales:

```
lib/
├── core/
│   ├── services/
│   │   ├── data_structures/
│   │   │   ├── stack.dart            # Pila (LIFO)
│   │   │   ├── queue.dart            # Cola (FIFO)
│   │   │   ├── linked_list.dart      # Lista Enlazada
│   │   │   ├── binary_tree.dart      # Arbol Binario de Busqueda
│   │   │   ├── hash_table.dart       # Tabla Hash
│   │   │   └── graph.dart            # Grafo
│   │   └── subscription_service.dart # Servicio de distribucion de datos
│   └── theme/
│       ├── app_theme.dart
│       └── design_tokens.dart
└── features/
    ├── auth/
    │   ├── auth_service.dart
    │   └── auth_provider.dart
    └── subscriptions/
        ├── domain/
        │   └── repositories/subscription_repository.dart
        ├── data/
        │   ├── datasources/
        │   │   ├── supabase_datasource.dart  # Fuente principal (API)
        │   │   ├── gmail_datasource.dart     # Fuente Gmail
        │   │   └── mock_datasource.dart      # Fuente de pruebas
        │   └── repositories/subscription_repository_impl.dart
        ├── models/subscription.dart
        ├── presentation/
        │   ├── pages/
        │   │   ├── splash_page.dart
        │   │   ├── onboarding_page.dart
        │   │   ├── login_page.dart
        │   │   ├── dashboard_page.dart
        │   │   ├── subscription_detail_page.dart
        │   │   └── analytics_page.dart
        │   ├── widgets/
        │   └── notifiers/subscription_notifier.dart
        └── providers/
            ├── data_structures_providers.dart
            └── subscription_providers.dart
```

### Diagrama de Capas

```
┌─────────────────────────────────────────────┐
│           PRESENTATION LAYER                │
│  Pages · Widgets · Notifiers · Providers    │
│          (Riverpod State Management)        │
└──────────────────┬──────────────────────────┘
                   │ usa
┌──────────────────▼──────────────────────────┐
│              DOMAIN LAYER                   │
│     SubscriptionRepository (interfaz)       │
│     Subscription (entidad)                  │
└──────────────────┬──────────────────────────┘
                   │ implementa
┌──────────────────▼──────────────────────────┐
│               DATA LAYER                    │
│  SupabaseDatasource · GmailDatasource       │
│  SubscriptionRepositoryImpl                 │
│  SubscriptionDataStructureService           │
└─────────────────────────────────────────────┘
```

---

## 5. Estructuras de Datos Implementadas

Todas las estructuras estan ubicadas en `lib/core/services/data_structures/` y son genericas (tipo `T`). Cada una expone operaciones de **insertar, eliminar y buscar** visibles desde la interfaz de usuario.

---

### 5.1 Stack — Pila (LIFO)

**Archivo:** `lib/core/services/data_structures/stack.dart`

```
     TOPE
      ↓
  ┌───────┐
  │  [C]  │  ← push / pop
  ├───────┤
  │  [B]  │
  ├───────┤
  │  [A]  │
  └───────┘
  Last In, First Out
```

**Operaciones implementadas:**

| Operacion | Complejidad | Descripcion |
|-----------|-------------|-------------|
| `push(T)` | O(1) | Inserta elemento en el tope |
| `pop()` | O(1) | Extrae y retorna el tope |
| `peek()` | O(1) | Ve el tope sin extraer |
| `size` | O(1) | Cantidad de elementos |
| `isEmpty` | O(1) | Verifica si esta vacia |
| `clear()` | O(1) | Limpia la estructura |
| `toList()` | O(n) | Convierte a lista |

**Uso en SubScan:** Almacena suscripciones **urgentes** (vencen en <= 3 dias). El tope siempre es la mas urgente.

---

### 5.2 Queue — Cola (FIFO)

**Archivo:** `lib/core/services/data_structures/queue.dart`

```
  FRENTE                          FINAL
    ↓                               ↓
  ┌───────┬───────┬───────┬───────┐
  │  [A]  │  [B]  │  [C]  │  [D]  │
  └───────┴───────┴───────┴───────┘
  dequeue ←                      → enqueue
  First In, First Out
```

**Operaciones implementadas:**

| Operacion | Complejidad | Descripcion |
|-----------|-------------|-------------|
| `enqueue(T)` | O(1) | Inserta al final |
| `dequeue()` | O(1) | Extrae el primero |
| `peek()` | O(1) | Ve el frente sin extraer |
| `size` | O(1) | Cantidad de elementos |
| `isEmpty` | O(1) | Verifica si esta vacia |
| `clear()` | O(1) | Limpia la estructura |
| `toList()` | O(n) | Convierte a lista |

**Uso en SubScan:** Almacena suscripciones **proximas a renovarse** (4-7 dias). Procesa en orden cronologico.

---

### 5.3 LinkedList — Lista Enlazada

**Archivo:** `lib/core/services/data_structures/linked_list.dart`

```
  head
   ↓
  [A] → [B] → [C] → [D] → null
  
  Cada nodo:
  ┌──────────┬──────────┐
  │  value   │  next*   │
  └──────────┴──────────┘
```

**Estructura del nodo:**
```dart
class Node<T> {
  final T value;
  Node<T>? next;
  Node(this.value);
}
```

**Operaciones implementadas:**

| Operacion | Complejidad | Descripcion |
|-----------|-------------|-------------|
| `insert(T)` | O(n) | Inserta ordenado alfabeticamente |
| `delete(T)` | O(n) | Elimina elemento, retorna bool |
| `search(T)` | O(n) | Busca elemento |
| `traverse()` | O(n) | Retorna todos los elementos |
| `size` | O(1) | Cantidad de elementos |
| `isEmpty` | O(1) | Verifica si esta vacia |
| `clear()` | O(1) | Limpia la estructura |

**Uso en SubScan:** Almacena **todas las suscripciones** ordenadas por nombre. Permite recorrido completo para la pantalla principal.

---

### 5.4 BinaryTree — Arbol Binario de Busqueda (BST)

**Archivo:** `lib/core/services/data_structures/binary_tree.dart`

```
            [raiz: D]
           /         \
        [B]           [F]
       /   \         /   \
     [A]   [C]     [E]   [G]
     
  In-Order: A → B → C → D → E → F → G (ordenado)
  Pre-Order: D → B → A → C → F → E → G
  Post-Order: A → C → B → E → G → F → D
```

**Estructura del nodo:**
```dart
class TreeNode<T> {
  final T value;
  TreeNode<T>? left;
  TreeNode<T>? right;
  TreeNode(this.value);
}
```

**Operaciones implementadas:**

| Operacion | Complejidad | Descripcion |
|-----------|-------------|-------------|
| `insert(T)` | O(log n) avg | Inserta manteniendo orden BST |
| `search(T)` | O(log n) avg | Busca elemento |
| `traverseInOrder()` | O(n) | Recorrido Left-Root-Right |
| `traversePreOrder()` | O(n) | Recorrido Root-Left-Right |
| `traversePostOrder()` | O(n) | Recorrido Left-Right-Root |
| `size` | O(1) | Cantidad de elementos |
| `isEmpty` | O(1) | Verifica si esta vacio |
| `clear()` | O(1) | Limpia el arbol |

**Comparador personalizado:** acepta `int Function(T a, T b) comparator` para ordenar por cualquier criterio.

**Uso en SubScan:** Suscripciones ordenadas por **fecha de renovacion**. Busqueda rapida O(log n) para consultas.

---

### 5.5 HashTable — Tabla Hash

**Archivo:** `lib/core/services/data_structures/hash_table.dart`

```
  Funcion hash: key.hashCode % capacity

  Bucket 0: [(id_1, Sub_A)]
  Bucket 1: [(id_2, Sub_B) → (id_5, Sub_E)]  ← colision resuelta
  Bucket 2: []
  Bucket 3: [(id_3, Sub_C)]
  Bucket 4: [(id_4, Sub_D)]
  ...
  
  Resolucion de colisiones: encadenamiento (chaining)
```

**Funcion hash:**
```dart
int _hash(K key) => key.hashCode % _capacity;
```

**Operaciones implementadas:**

| Operacion | Complejidad | Descripcion |
|-----------|-------------|-------------|
| `insert(K, V)` | O(1) avg | Inserta o actualiza par clave-valor |
| `search(K)` | O(1) avg | Busca valor por clave |
| `delete(K)` | O(1) avg | Elimina por clave |
| `keys()` | O(n) | Retorna todas las claves |
| `values()` | O(n) | Retorna todos los valores |
| `size` | O(1) | Cantidad de pares |
| `clear()` | O(1) | Limpia la tabla |

**Uso en SubScan:** Lookup **O(1) por ID de suscripcion**. Sincronizacion y actualizaciones rapidas.

---

### 5.6 Graph — Grafo

**Archivo:** `lib/core/services/data_structures/graph.dart`

```
  Lista de adyacencia (grafo no dirigido):
  
  Netflix ─────── Disney+
     │               │
     │            HBO Max
     │               │
  Spotify ─────── YouTube
  
  Netflix:  {Disney+, Spotify}
  Disney+:  {Netflix, HBO Max}
  HBO Max:  {Disney+, YouTube}
  Spotify:  {Netflix, YouTube}
  YouTube:  {HBO Max, Spotify}
```

**Estructura interna:**
```dart
Map<T, Set<T>> _adjacencyList; // nodo → vecinos
```

**Algoritmos de busqueda:**
```
BFS desde Netflix:           DFS desde Netflix:
  Nivel 0: Netflix             Visita: Netflix
  Nivel 1: Disney+, Spotify    Recursion: Disney+
  Nivel 2: HBO Max, YouTube      Recursion: HBO Max
                                   Recursion: YouTube
                                     Recursion: Spotify
```

**Operaciones implementadas:**

| Operacion | Complejidad | Descripcion |
|-----------|-------------|-------------|
| `addNode(T)` | O(1) | Agrega nodo al grafo |
| `addEdge(T, T)` | O(1) | Agrega arista (dirigida o no dirigida) |
| `bfs(T)` | O(V+E) | Busqueda en anchura, retorna nodos visitados |
| `dfs(T)` | O(V+E) | Busqueda en profundidad, retorna nodos visitados |
| `hasNode(T)` | O(1) | Verifica si existe nodo |
| `hasEdge(T, T)` | O(1) | Verifica si existe arista |
| `nodeCount` | O(1) | Cantidad de nodos |
| `clear()` | O(1) | Limpia el grafo |

**Uso en SubScan:** Modela **relaciones entre servicios** por categoria (streaming, musica, software). BFS/DFS para descubrir servicios relacionados y analizar clusters de gasto.

---

### Resumen — Distribucion de Datos

El servicio `SubscriptionDataStructureService` distribuye automaticamente los datos del API en las 6 estructuras:

| Estructura | Datos almacenados | Criterio | Complejidad acceso |
|------------|------------------|----------|--------------------|
| Stack | Suscripciones urgentes | `diasRestantes <= 3` | O(1) LIFO |
| Queue | Suscripciones proximas | `diasRestantes 4-7` | O(1) FIFO |
| LinkedList | Todas | Orden alfabetico | O(n) traverse |
| BinaryTree | Todas | Fecha de renovacion | O(log n) search |
| HashTable | Todas | Por ID | O(1) lookup |
| Graph | Servicios/categorias | Relaciones | O(V+E) BFS/DFS |

---

## 6. Integracion con el API REST

### Fuentes de Datos

#### Supabase (Backend principal)
- **Tabla:** `subscriptions`
- **Autenticacion:** Firebase Auth (Google Sign-In) — el `user_id` de Firebase filtra los datos via RLS (Row Level Security)
- **Operaciones:** SELECT, INSERT, UPDATE, DELETE sobre suscripciones del usuario autenticado
- **Datasource:** `lib/features/subscriptions/data/datasources/supabase_datasource.dart`

#### Gmail API (Deteccion automatica)
- **Scope:** `gmail.readonly`
- **Funcion:** Escanea correos de renovacion/facturacion para detectar suscripciones automaticamente
- **Parser:** Extrae nombre del servicio, monto y fecha de renovacion de asuntos y cuerpos de correo
- **Datasource:** `lib/features/subscriptions/data/datasources/gmail_datasource.dart`

### Flujo de datos

```
Usuario autenticado
      │
      ▼
  Firebase Auth ──── Google Sign-In
      │
      ▼
  SupabaseDatasource ◄──── Supabase (tabla subscriptions)
      │
      ├──► GmailDatasource ◄──── Gmail API (deteccion automatica)
      │
      ▼
  SubscriptionRepositoryImpl
      │
      ▼
  SubscriptionDataStructureService
      │
      ├──► Stack (urgentes)
      ├──► Queue (proximas)
      ├──► LinkedList (todas)
      ├──► BinaryTree (por fecha)
      ├──► HashTable (por ID)
      └──► Graph (relaciones)
```

### Configuracion del entorno

```bash
# Copiar variables de entorno
cp .env.example .env

# Completar en .env:
SUPABASE_URL=tu_url
SUPABASE_ANON_KEY=tu_anon_key

# Ejecutar con variables:
flutter run --dart-define=SUPABASE_URL=$SUPABASE_URL \
            --dart-define=SUPABASE_ANON_KEY=$SUPABASE_ANON_KEY
```

---

## 7. Pantalla de Analisis de Datos

La pantalla **Analytics** (`lib/features/subscriptions/presentation/pages/analytics_page.dart`) presenta un resumen visual de los datos cargados en las estructuras:

### Metricas mostradas

| Seccion | Datos | Estructura fuente |
|---------|-------|-------------------|
| Urgentes | Lista de suscripciones con <= 3 dias | Stack (peek) |
| Proximas | Suscripciones con 4-7 dias | Queue (peek) |
| Total activas | Contador de todas | LinkedList (size) |
| Vencimiento mas proximo | Primera en renovarse | BinaryTree (in-order primero) |
| Busqueda rapida | Suscripcion por ID | HashTable (search) |
| Servicios relacionados | Clusters por categoria | Graph (BFS) |

### Resumen financiero

- Gasto mensual total (suma de todas las suscripciones)
- Gasto por categoria (streaming, musica, software, etc.)
- Suscripcion mas costosa (BinaryTree por precio)
- Proyeccion anual

---

## 8. Control de Versiones

### Estructura de ramas

```
main (rama protegida — solo via Pull Request)
 ├── dave          → Backend core: estructuras de datos, domain layer
 ├── brandonnn     → Frontend: UI, widgets, animaciones, state
 └── Jeferson      → Integracion Gmail API
```

### Convencion de commits

Todos los commits siguen el formato `tipo(area): descripcion`:

| Rama | Prefijos usados |
|------|-----------------|
| `dave` | `feat(core):`, `feat(datasource):`, `feat(providers):`, `test(core):` |
| `brandonnn` | `feat(ui):`, `style:`, `refactor(ui):`, `test(widget):` |
| `Jeferson` | `feat(gmail):`, `feat(datasource):`, `feat(email-sync):` |

**Ejemplos de commits reales:**
```
feat(ui): implement onboarding page with diagonal animation
feat(ui): add subscription card widget with urgency indicator
style: apply design tokens to dashboard page
refactor(ui): extract reusable subscription banner component
test(widget): add widget tests for subscription card
feat(core): implement Stack data structure with LIFO operations
feat(core): add BinaryTree with custom comparator support
test(core): add 42 unit tests for all data structures
```

### Flujo de trabajo

```
1. Actualizar rama local
   git checkout brandonnn
   git pull origin main

2. Hacer cambios y commits frecuentes
   git add .
   git commit -m "feat(ui): implement analytics page"

3. Push y Pull Request hacia main
   git push origin brandonnn
   # Abrir PR en GitHub → revisión → merge
```

### Pull Requests por entregable

| Entregable | PR | Estado |
|------------|-----|--------|
| Entregable 1 | Setup inicial + Stack/Queue basicos | Mergeado |
| Entregable 2 | 6 estructuras completas + UI | Mergeado |
| Entregable 3 | Analytics + integracion completa | En progreso |

---

## 9. Interfaz de Usuario

### Pantallas implementadas

| Pantalla | Archivo | Descripcion |
|----------|---------|-------------|
| Splash | `splash_page.dart` | Pantalla inicial con animacion de logo |
| Onboarding | `onboarding_page.dart` | 3 slides con franja diagonal animada |
| Login | `login_page.dart` | Google Sign-In con Firebase |
| Dashboard | `dashboard_page.dart` | Lista principal de suscripciones activas |
| Detalle | `subscription_detail_page.dart` | Vista completa de una suscripcion |
| Analytics | `analytics_page.dart` | Resumen y analisis de datos |

### Flujo de navegacion

```
SplashPage
    │
    ▼
OnboardingPage (primera vez)
    │
    ▼
LoginPage
    │ Google Sign-In exitoso
    ▼
DashboardPage ─────────────────────────────────────────┐
    │                    │                    │         │
    ▼                    ▼                    ▼         │
SubscriptionDetailPage  AnalyticsPage  [Nueva sub]     │
    │                                                   │
    └───────────────────────────────────────────────────┘
```

### Estado y notificaciones

- **Riverpod** (`SubscriptionNotifier`) gestiona el estado de todas las suscripciones
- Indicadores visuales de urgencia: rojo (<= 3 dias), amarillo (4-7 dias), verde (> 7 dias)
- Banner de alertas para suscripciones criticas en el Dashboard

---

## 10. Instrucciones de Instalacion y Ejecucion

### Requisitos previos

- Flutter SDK >= 3.11.0
- Dart SDK >= 3.0.0
- Android Studio o VS Code con extension Flutter
- Cuenta Firebase configurada (Google Sign-In habilitado)
- Cuenta Supabase con tabla `subscriptions` creada

### Clonar e instalar

```bash
git clone https://github.com/DavexDev/Subscan.git
cd Subscan
flutter pub get
```

### Configurar variables de entorno

```bash
cp .env.example .env
# Editar .env con tus credenciales de Supabase
```

### Ejecutar la aplicacion

```bash
# Con variables de entorno
flutter run --dart-define=SUPABASE_URL=<tu_url> \
            --dart-define=SUPABASE_ANON_KEY=<tu_key>

# Modo debug simple (usa mock datasource)
flutter run
```

### Ejecutar tests

```bash
# Todos los tests
flutter test

# Solo estructuras de datos (42 tests)
flutter test test/data_structures_test.dart test/subscription_service_test.dart

# Solo tests de widget
flutter test test/widget_test.dart
```

---

## 11. Pruebas Unitarias

La suite completa cubre las 6 estructuras de datos y el servicio de distribucion:

| Componente | Archivo | Tests | Estado |
|------------|---------|-------|--------|
| Stack | `test/data_structures_test.dart` | 6 | PASSING |
| Queue | `test/data_structures_test.dart` | 6 | PASSING |
| LinkedList | `test/data_structures_test.dart` | 6 | PASSING |
| BinaryTree | `test/data_structures_test.dart` | 6 | PASSING |
| HashTable | `test/data_structures_test.dart` | 6 | PASSING |
| Graph | `test/data_structures_test.dart` | 7 | PASSING |
| SubscriptionService | `test/subscription_service_test.dart` | 5 | PASSING |
| Widget tests | `test/widget_test.dart` | 1 | PASSING |
| **TOTAL** | | **43** | **PASSING** |

Cada test valida: insercion, eliminacion, busqueda, estado vacio y comportamiento de borde.

---

## 12. Rubrica de Evaluacion — Cumplimiento

| Criterio | Peso | Estado | Evidencia |
|----------|------|--------|-----------|
| **Estructuras de datos** — completas y funcionales | 35% | Excelente | 6 estructuras implementadas con insert/delete/search desde la UI. 43 tests pasando. |
| **Integracion con el API** — datos reales en todas las estructuras | 25% | Excelente | Supabase (backend) + Gmail API (deteccion). `SubscriptionDataStructureService` distribuye datos reales del API en las 6 estructuras. |
| **Control de versiones** — ramas, commits y PRs correctos | 20% | Excelente | Ramas por funcionalidad (`dave`, `brandonnn`, `Jeferson`). Commits con convencion `tipo(area): desc`. PRs hacia `main` por cada entregable. Todos los integrantes con commits. |
| **Interfaz Flutter** — diseno limpio y navegacion fluida | 10% | Excelente | 6 pantallas completas, design tokens, animaciones, Riverpod state management. |
| **Documentacion / README** — completo con diagramas | 10% | Excelente | Este README: descripcion, arquitectura, diagramas ASCII de cada estructura, API, control de versiones, instrucciones de uso. |

---

**Repositorio:** [https://github.com/DavexDev/Subscan](https://github.com/DavexDev/Subscan)  
**Ultima actualizacion:** 2026-05-26  
**Rama de este README:** `brandonnn`
