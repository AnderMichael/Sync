# Sync App

Aplicación Android offline-first para crear, editar y sincronizar registros de gestión con un backend simulado.

---

## Instalación

Requiere [FVM](https://fvm.app) con Flutter **3.41.0** (Dart SDK ^3.11.0).

**IDE:** [Android Studio](https://developer.android.com/studio) — incluye el SDK de Android, emulador y herramientas de build integradas.

**Opcional:** `adb` CLI para gestionar dispositivos y emuladores desde terminal. Viene incluido con Android Studio en `platform-tools`.

```bash
fvm use
fvm flutter pub get
fvm flutter pub run build_runner build --delete-conflicting-outputs
fvm flutter run
```

`build_runner` debe ejecutarse cada vez que se modifique una tabla de Drift.

---

## Arquitectura

Clean Architecture por features con capas `domain / application / infrastructure / presentation`. La navegación y DI se manejan con `flutter_modular`. El estado con `flutter_bloc` usando Cubits.

```
lib/
  app/           rutas y shell de navegación
  core/          base de datos, red simulada, tema, widgets compartidos
  features/
    managements/ registros locales
    sync/        cola de sincronización
    bitacora/    historial persistente
```

---

## Módulos

### Gestiones

Crea y edita registros en SQLite. Al guardar, inserta automáticamente una operación `pending` en la cola de sync. El `syncStatus` de cada gestión se actualiza conforme avanza la sincronización. Los filtros (`Todos`, `Sincronizados`, `Pendientes`, `Fallidos`) operan directamente en el stream de Drift.

### Cola de sincronización

Procesa las operaciones pendientes en secuencia con hasta 3 reintentos y delay exponencial. El campo `attempts` se actualiza en BD en cada intento para reflejar la cuenta regresiva en tiempo real. Al iniciar una nueva tanda, se limpian los registros `synced` y `failed` de la tanda anterior. Los ítems fallidos tienen reintento individual.

El loader se corrigió eliminando el filtro `isNotValue('synced')` de `watchQueue()` y forzando `_listen()` en el `finally` del cubit, evitando que el stream dejara de emitir cuando toda la tanda quedaba sincronizada.

### Bitácora

Historial append-only en tabla `sync_log` separada de la cola. Registra éxitos y fallos con un snapshot JSON del registro (`gestion_version`) tomado antes de procesar la operación. Accesible desde la Cola como ruta pushed (`/bitacora`).

---

## Base de datos

| Tabla | Contenido |
|---|---|
| `managements` | Registros de gestión |
| `sync_queue` | Operaciones pendientes, en proceso y fallidas |
| `sync_log` | Historial permanente de operaciones completadas |

Schema v1 con `managements` y `sync_queue`. `sync_log` añadida en v2 con migración `onUpgrade`.

---

## Dependencias

| Paquete | Uso |
|---|---|
| `flutter_modular` | Navegación y DI |
| `flutter_bloc` | Estado con Cubits |
| `drift` + `drift_flutter` | ORM SQLite con streams reactivos |
| `sqlite3_flutter_libs` | Binarios nativos SQLite para Android |
| `uuid` | IDs locales v4 |
| `google_fonts` | Tipografía Space Grotesk |
| `equatable` | Comparación por valor en entidades y estados |
| `intl` | Formato de fechas y montos |
| `build_runner` + `drift_dev` | Generación de código de Drift |

---

## Próximos pasos

**Pendientes prioritarios**

- Verificación de conectividad antes de sincronizar — si no hay red, bloquear el botón y mostrar aviso, evitando intentos fallidos innecesarios.
- Restauración del estado original en operaciones fallidas — si una operación falla definitivamente, revertir el `syncStatus` de la gestión al estado previo en lugar de dejarlo como `failed` sin posibilidad de recuperación automática.

**Con más tiempo**

- Paginación o infinite scroll en las listas de gestiones y bitácora para no cargar todos los registros en memoria.
- Barra de búsqueda en gestiones para filtrar por título o descripción.
- Modo de sincronización automático que dispare la cola tras cada inserción o edición, sin necesidad de acción manual.
- Validación de cambios en formularios — comparar el estado actual del registro con los valores editados antes de encolar una operación, descartando el envío si no hubo modificaciones reales.
- Mejoras de UI: transiciones entre pantallas, skeleton loaders, feedback háptico en acciones.
