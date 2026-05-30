# Arquitectura del Proyecto — Subscan (PODA)

> **Nombre público:** PODA  
> **Nombre del repositorio:** Subscan  
> **Última actualización:** 2026-05-30  
> **Curso:** Programación III — Universidad Mariano Gálvez de Guatemala

---

## Resumen Ejecutivo

Aplicación móvil multiplataforma en **Flutter/Dart** que gestiona y analiza suscripciones digitales. El motor de análisis usa **6 estructuras de datos** implementadas desde cero como requisito académico. El backend es **Supabase** (PostgreSQL) con autenticación vía **Firebase/Google Sign-In** y detección automática de suscripciones vía **Gmail API**.

---

## 1. Stack Tecnológico

| Capa | Tecnología | Versión |
|------|-----------|---------|
| Framework | Flutter | ^3.11.3 |
| Lenguaje | Dart | ^3.0.0 |
| State Management | Riverpod | ^2.4.0 |
| Backend (BaaS) | Supabase | ^2.0.0 |
| Autenticación | Firebase Auth + Google Sign-In | ^5.0.0 / ^6.2.0 |
| API Externa | Gmail API (googleapis) | ^12.0.0 |
| HTTP Client | Dio + http | ^5.3.0 / ^1.2.0 |
| UI System | Material Design 3 | built-in |
| Notificaciones | flutter_local_notifications | ^18.0.0 |
| Code Generation | Freezed + build_runner | ^2.4.0 |
| Env vars | flutter_dotenv | ^5.1.0 |

---

## 2. Arquitectura General

El proyecto sigue **Clean Architecture** con tres capas estrictas:

```
┌─────────────────────────────────────────┐
│         PRESENTATION LAYER              │
│  Pages · Widgets · Notifiers            │
│  (Riverpod StateNotifier / Consumer)    │
└──────────────┬──────────────────────────┘
               │ depende de
┌──────────────▼──────────────────────────┐
│            DOMAIN LAYER                 │
│  Repository (interfaces abstractas)     │
│  Modelo: Subscription                   │
└──────────────┬──────────────────────────┘
               │ implementado por
┌──────────────▼──────────────────────────┐
│             DATA LAYER                  │
│  Datasources: Supabase · Gmail · Mock   │
│  RepositoryImpl (orquesta datasources)  │
└─────────────────────────────────────────┘
```

La inyección de dependencias se realiza con **Riverpod Providers**, lo que permite cambiar el datasource (Supabase ↔ Mock ↔ Gmail) sin tocar la UI.

---

## 3. Estructura de Directorios

```
subscan/
├── lib/
│   ├── main.dart                          # Punto de entrada
│   ├── core/
│   │   ├── services/
│   │   │   ├── data_structures/           # 6 estructuras de datos
│   │   │   │   ├── stack.dart             # Stack LIFO
│   │   │   │   ├── queue.dart             # Queue FIFO
│   │   │   │   ├── linked_list.dart       # Lista enlazada (ordenada)
│   │   │   │   ├── binary_tree.dart       # Árbol Binario de Búsqueda
│   │   │   │   ├── hash_table.dart        # Tabla Hash
│   │   │   │   └── graph.dart             # Grafo (BFS/DFS)
│   │   │   ├── subscription_service.dart  # Distribuidor a estructuras
│   │   │   ├── notification_service.dart  # Notificaciones locales
│   │   │   ├── known_services.dart        # Catálogo de servicios
│   │   │   └── cancellation_urls.dart     # URLs de cancelación
│   │   ├── theme/
│   │   │   ├── app_theme.dart             # ThemeData Material 3
│   │   │   └── design_tokens.dart         # Colores, espaciado, tipografía
│   │   └── widgets/
│   │       └── service_logo.dart
│   │
│   └── features/
│       ├── auth/                          # Autenticación
│       │   ├── auth_service.dart
│       │   ├── auth_provider.dart
│       │   ├── models/linked_account.dart
│       │   ├── providers/linked_accounts_provider.dart
│       │   └── data/linked_accounts_datasource.dart
│       │
│       ├── subscriptions/                 # Feature principal
│       │   ├── domain/
│       │   │   └── repositories/
│       │   │       └── subscription_repository.dart   # Interfaz abstracta
│       │   ├── data/
│       │   │   ├── datasources/
│       │   │   │   ├── subscription_datasource.dart   # Interfaz abstracta
│       │   │   │   ├── supabase_datasource.dart        # Impl. Supabase
│       │   │   │   ├── gmail_datasource.dart           # Impl. Gmail API
│       │   │   │   └── mock_datasource.dart            # Impl. para tests
│       │   │   └── repositories/
│       │   │       └── subscription_repository_impl.dart
│       │   ├── models/
│       │   │   └── subscription.dart      # Modelo de dominio
│       │   ├── presentation/
│       │   │   ├── pages/                 # 15+ pantallas
│       │   │   ├── widgets/               # Componentes reutilizables
│       │   │   └── notifiers/
│       │   │       └── subscription_notifier.dart
│       │   └── providers/                 # Riverpod DI
│       │       ├── subscription_providers.dart
│       │       ├── data_structures_providers.dart
│       │       └── notification_prefs_provider.dart
│       │
│       ├── onboarding/
│       └── tutorial/
│
├── test/
│   ├── data_structures_test.dart          # 42 tests (6 por estructura)
│   ├── subscription_service_test.dart     # 5 tests del servicio
│   └── widget_test.dart
│
├── assets/
│   ├── images/                            # Onboarding, login, avatars
│   ├── logos/                             # 33 logos de servicios
│   └── videos/splash.mp4
│
├── android/  ios/  macos/  windows/  web/ # Código nativo por plataforma
├── .github/workflows/auto-merge.yml       # CI/CD GitHub Actions
├── pubspec.yaml
└── .env                                   # Secrets (no en repositorio)
```

---

## 4. Motor de Estructuras de Datos

El corazón académico del proyecto. Todas son genéricas (`<T>`) e implementadas desde cero.

| # | Estructura | Complejidad | Uso en la App |
|---|-----------|-------------|---------------|
| 1 | **Stack** (LIFO) | O(1) push/pop | Suscripciones urgentes (≤ 3 días) |
| 2 | **Queue** (FIFO) | O(1) enqueue/dequeue | Próximas renovaciones (4-7 días) |
| 3 | **LinkedList** (ordenada) | O(n) | Todas las suscripciones (alfabético) |
| 4 | **BinaryTree** (BST) | O(log n) avg | Suscripciones por fecha de renovación |
| 5 | **HashTable** | O(1) avg | Búsqueda rápida por ID |
| 6 | **Graph** (BFS/DFS) | O(V+E) | Relaciones entre servicios |

### Servicio Distribuidor

`lib/core/services/subscription_service.dart` clasifica automáticamente cada suscripción en las estructuras correctas según su urgencia:

```
Lista completa →  LinkedList (todas)
                  BinaryTree (ordenadas)
                  HashTable (búsqueda)
                  Graph (relaciones)

Urgentes (≤3d) → Stack

Próximas (4-7d) → Queue
```

---

## 5. Modelo de Dominio

```dart
class Subscription {
  final String id;
  final String nombre;
  final double precioActual;
  final double? precioOriginal;
  final DateTime fechaRenovacion;
  final String fuente;       // 'gmail' | 'manual' | 'supabase'
  final String currency;     // 'GTQ' | 'USD' | 'EUR' | 'MXN' | 'GBP'
  final String? emailCuenta;
  final String? metodoPago;

  // Propiedades calculadas
  int get diasRestantes { ... }
  bool get isVencida     => diasRestantes < 0;
  bool get isUrgent      => diasRestantes >= 0 && diasRestantes <= 3;
  bool get isNearRenewal => diasRestantes >= 0 && diasRestantes <= 7;
  String get precioFormateado => '$currencySymbol${precioActual.toStringAsFixed(2)}';
}
```

---

## 6. Datasources

### Supabase (`supabase_datasource.dart`)
Datasource de producción. Lee/escribe en tabla `subscriptions` filtrando por `user_id`. Usa Row Level Security (RLS) para aislar datos entre usuarios.

### Gmail (`gmail_datasource.dart`)
Detecta suscripciones automáticamente buscando en los últimos 30 días correos con términos como `renewal`, `invoice`, `billing`, `subscription`. Extrae servicio, precio y fecha de renovación.

### Mock (`mock_datasource.dart`)
Datos hardcodeados para desarrollo y testing sin conexión al backend.

---

## 7. Base de Datos — Supabase (PostgreSQL)

**Proyecto:** `poda-83443`

```sql
-- Tabla principal
subscriptions (
  id               UUID PRIMARY KEY,
  user_id          UUID REFERENCES auth.users,
  nombre           TEXT,
  precio_actual    DECIMAL(10,2),
  precio_original  DECIMAL(10,2),
  fecha_renovacion DATE,
  fuente           TEXT,      -- gmail | manual | supabase
  currency         VARCHAR(3),
  email_cuenta     VARCHAR(255),
  metodo_pago      TEXT,
  created_at       TIMESTAMP,
  updated_at       TIMESTAMP
)

-- Historial de precios
subscription_price_history (
  subscription_id UUID REFERENCES subscriptions,
  precio          DECIMAL(10,2),
  recorded_at     TIMESTAMP
)

-- Preferencias de usuario
user_preferences (
  user_id              UUID UNIQUE REFERENCES auth.users,
  gmail_sync_timestamp TIMESTAMP
)
```

Row Level Security habilitado en todas las tablas — cada usuario solo accede a sus propios datos.

---

## 8. Flujo de Navegación

```
SplashPage (video)
  ↓
OnboardingPage (3 slides — solo primera vez)
  ↓
LoginPage (Google Sign-In via Firebase)
  ↓
DashboardPage (hub central)
  ├─→ SubscriptionDetailPage
  ├─→ AddSubscriptionPage / EditSubscriptionPage
  ├─→ EstadisticasPage (analytics con estructuras)
  ├─→ AlertasPage (urgentes del Stack)
  ├─→ GmailSyncOverlayPage
  └─→ MiCuentaPage / NotificacionesPage / SeguridadPage
```

---

## 9. State Management — Riverpod

```
subscriptionDatasourceProvider (Provider)
  └→ subscriptionRepositoryProvider (Provider)
       └→ subscriptionNotifierProvider (StateNotifierProvider)
            └→ SubscriptionState {
                 isLoading: bool,
                 allSubscriptions: List<Subscription>,
                 error: String?
               }
```

Los providers de estructuras de datos (`data_structures_providers.dart`) exponen el Stack, Queue, LinkedList, etc. ya cargados.

---

## 10. Tema y Diseño

- **Sistema:** Material Design 3 (`useMaterial3: true`)
- **Color primario:** Azul `#2563EB`
- **Color secundario:** Verde `#10B981`
- **Fondo:** Gris `#FAFAFA`
- **Design tokens** centralizados en `design_tokens.dart` (colores, espaciados, tipografías)

---

## 11. Tests y CI/CD

### Suite de Tests (48 en total)

| Archivo | Tests | Cobertura |
|---------|-------|-----------|
| `data_structures_test.dart` | 42 | Stack, Queue, LinkedList, BinaryTree, HashTable, Graph |
| `subscription_service_test.dart` | 5 | Servicio distribuidor |
| `widget_test.dart` | 1 | Smoke test |

```bash
flutter test              # Ejecutar todos
flutter test --coverage   # Con reporte lcov
flutter analyze           # Análisis estático
```

### GitHub Actions (`.github/workflows/auto-merge.yml`)

En cada PR a `main`:
1. `flutter pub get`
2. `flutter analyze --fatal-infos --fatal-warnings`
3. `flutter test --coverage`
4. Auto-merge si pasa (squash + rebase)

---

## 12. Variables de Entorno

```env
# .env (no incluido en el repositorio)
SUPABASE_URL=https://YOUR_PROJECT.supabase.co
SUPABASE_ANON_KEY=YOUR_ANON_PUBLIC_KEY
```

Los archivos `google-services.json` (Android) y `GoogleService-Info.plist` (iOS) también están fuera del repositorio por seguridad.

---

## 13. Equipo

| Integrante | Rama | Responsabilidad |
|-----------|------|-----------------|
| Dave | `dave` | Backend · 6 Estructuras de datos · Domain Layer · Tests |
| Brandon | `brandonnn` | Frontend · UI/UX · Riverpod State · Theming |
| Jeferson | `Jeferson` | Gmail API · Datasources · Autenticación Firebase |

**Rama protegida:** `main` — solo merge vía Pull Request con CI en verde.

---

## 14. Plataformas Soportadas

- Android (primaria)
- iOS
- macOS
- Windows
- Web (secundaria)

---

## 15. Estado del Proyecto

| Módulo | Estado |
|--------|--------|
| 6 estructuras de datos | Completo |
| Clean Architecture | Completo |
| Autenticación Google | Completo |
| UI (15+ pantallas) | Completo |
| Datasource Supabase | Completo |
| Datasource Gmail | Integración final |
| 48 tests unitarios | Completo |
| CI/CD GitHub Actions | Completo |
| Dark theme | Pendiente |
| Deploy Google Play | Pendiente |
