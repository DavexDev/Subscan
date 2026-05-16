# GitHub CI/CD Setup

## ✅ Configuración Completada

### 1. GitHub Actions Workflow
Se creó el archivo `.github/workflows/ci.yml` que:
- ✓ Ejecuta `flutter analyze` en cada PR
- ✓ Corre todos los unit tests (42 tests)
- ✓ Genera reporte de cobertura
- ✓ Auto-mergea si todo pasa ✓

### 2. Lo que Hace el CI/CD

```
PR abierto en main/dave
    ↓
Trigger: GitHub Actions
    ↓
[1] flutter pub get (dependencias)
    ↓
[2] flutter analyze (code quality)
    ↓
[3] flutter test (42 unit tests)
    ↓
[4] Coverage report
    ↓
Todo pasó? → ✓ Auto-merge PR
Todo pasó? → ✗ Bloquea merge + comenta fallo
```

### 3. Configurar Branch Protection en GitHub

**Ve a:** https://github.com/DavexDev/Subscan/settings/branches

1. Haz clic en **"Add rule"**
2. **Branch name pattern:** `main`
3. Marca estas opciones:
   - ✓ Require a pull request before merging
   - ✓ Require status checks to pass before merging
   - ✓ Require branches to be up to date before merging
4. Under "Status checks that must pass":
   - Selecciona **"analyze-and-test"**
5. Click **"Create"**

Repite para rama `dave` si lo deseas.

### 4. Resultado Final

**Workflow en cada PR:**
```
developer push → PR abierto
    ↓
GitHub Actions inicia automáticamente
    ↓
✓ flutter analyze OK
✓ flutter test (42/42) OK
    ↓
Auto-merge: SQUASH + rebase
    ↓
✓ PR merged to main/dave
```

**Si algo falla:**
```
✗ flutter analyze ERROR
    ↓
PR bloqueado (no se puede mergear)
    ↓
Sistema comenta en PR: "❌ Analyze failed"
    ↓
Developer arregla + push
    ↓
CI corre de nuevo automáticamente
```

### 5. Archivos Generados

```
.github/
└── workflows/
    └── ci.yml  [✓ Creado]
```

### 6. Nota Importante

**NO** haremos auto-merge automático de todas las PRs. El workflow:
- Siempre corre tests y analyze
- Comenta resultados en la PR
- OPCIONALMENTE auto-mergea (ver configuración abajo)

**Para cambiar a "Solo Review Manual":**
1. Quita la sección `auto-merge` de `ci.yml`
2. Mantén solo `analyze-and-test`
3. Requiere que alguien apruebe antes de mergear (en branch protection)

### 7. Test Coverage

Se genera reporte de cobertura en cada PR. Localización:
- Local: `coverage/lcov.info`
- En PR: Se sube a Codecov (opcional, necesita cuenta)

### 8. Comandos Manuales Equivalentes

Si quieres correr el CI localmente:
```powershell
flutter pub get
flutter analyze --fatal-infos --fatal-warnings
flutter test --coverage
```

---

## Status

✅ **CI/CD workflow creado**
⏳ **Falta:** Configurar branch protection en GitHub (manual, ver paso 3)
✅ **Auto-merge:** Configurado
✅ **Test coverage:** Habilitado

**Próximo paso:** Ve a https://github.com/DavexDev/Subscan/settings/branches y configura protección de rama `main`
