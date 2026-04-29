# Sync Implementation Rules

Follow these rules strictly.

## General Rules

- Build only the MVP.
- Avoid overengineering.
- Prefer fewer files over unnecessary abstraction.
- Keep code readable and practical.
- Use clear names.
- Do not implement optional sync logs or bitácora.
- Do not add features that were not requested.
- Make it work first, then polish the UI.

## Architecture Rules

Use simplified Clean Architecture:

- domain
- application
- infrastructure
- presentation

### Domain

Domain contains:

- entities
- repository contracts

Domain must not depend on:

- Flutter
- Drift
- Dio
- Cubit
- Modular
- UI widgets

### Application

Application contains:

- Cubits
- States
- SyncEngine

Application coordinates behavior but should not render UI.

### Infrastructure

Infrastructure contains:

- repository implementations
- Drift database operations
- calls to FakeBackendService

Infrastructure can depend on Drift and fake backend.

### Presentation

Presentation contains:

- pages
- widgets

Presentation must not:

- access Drift directly
- contain sync logic
- contain business rules

Widgets should only render UI and trigger Cubit actions.

## State Management

Use flutter_bloc with Cubit.

Main Cubits:

- ManagementsCubit
- ManagementFormCubit
- SyncCubit

### ManagementsCubit

Responsible for:

- loading management records
- filtering records
- exposing loading, empty, loaded, error states

### ManagementFormCubit

Responsible for:

- creating management records
- editing management records
- validating simple form data
- exposing loading, success, error states

### SyncCubit

Responsible for:

- loading sync queue
- loading sync summary
- running manual synchronization
- retrying failed operations
- exposing loading, loaded, syncing, error states

## UI States

Use simple states:

- initial
- loading
- empty
- loaded
- error

For sync:

- initial
- loading
- loaded
- syncing
- error

## Database Rules

Use Drift + SQLite.

Only create these tables:

- managements
- sync_queue

Do not create sync_logs table.

## Navigation Rules

Use flutter_modular.

Use only necessary routes:

- /managements
- /managements/form
- /managements/form/:localId
- /sync

Use only 2 bottom tabs:

- Gestiones
- Cola

## Naming Rules

Use descriptive names.

Good names:

- Management
- SyncOperation
- SyncSummary
- ManagementRepository
- SyncRepository
- ManagementRepositoryImpl
- SyncRepositoryImpl
- ManagementsCubit
- ManagementFormCubit
- SyncCubit
- SyncEngine
- FakeBackendService

Avoid vague names:

- Manager
- Helper
- Service1
- DataService
- Utils2

## UI Rules

The UI must be in Spanish.

Use this visual style:

- background #f2f3f5
- primary dark #202020
- accent lime #c9f158
- white cards #ffffff
- rounded cards
- black buttons
- soft shadows
- clean spacing
- modern fintech style

## Error Messages

Use simple Spanish messages:

- "No se pudieron cargar las gestiones."
- "No se pudo guardar la gestión."
- "No se pudo sincronizar la cola."
- "La operación falló después de 3 intentos."

## Do Not Add

Do not add:

- login
- user profile
- real API
- real connectivity detection
- background tasks
- push notifications
- optional logs
- bitácora
- complex animations
- unnecessary abstractions
- excessive use cases
