# Sync MVP Scope

Build only the MVP. The goal is to complete the challenge in approximately 8 hours.

## Include

Implement only the following features:

1. Create management records offline.
2. Edit management records offline.
3. Save records locally using Drift + SQLite.
4. Every create or update must create a sync operation.
5. Show a management records list.
6. Show a create/edit form.
7. Show a sync queue screen.
8. Add a manual "Sincronizar ahora" button.
9. Process the sync queue in FIFO order.
10. Add automatic retries up to 3 attempts with simple backoff.
11. Add manual retry for failed operations.
12. Show a sync summary:
   - pendientes
   - sincronizadas
   - fallidas
   - última sincronización
13. Persist local data after closing and reopening the app.

## Exclude

Do not implement:

- Optional sync logs.
- Bitácora.
- Login.
- User profile.
- Real backend.
- Real internet detection.
- Background synchronization.
- Push notifications.
- Complex animations.
- Complex error hierarchy.
- Excessive use cases.
- Extra screens not required by the MVP.
- Tests unless explicitly requested.

## Required Screens

### 1. Gestiones

Must show:

- Title: "Gestiones Recientes"
- Subtitle: "Administra tus registros locales y sincronizados."
- Button: "Nueva gestión"
- Filter chips:
  - Todos
  - Sincronizados
  - Pendientes
- List of management cards

Each card must show:

- Title
- Description
- Date
- Amount
- Sync status badge

### 2. Nueva / Editar Gestión

Must show:

- Field: Título
- Field: Descripción
- Field: Fecha
- Field: Monto
- Button: "Guardar gestión"
- Helper text: "Se guardará localmente y se sincronizará cuando haya conexión."

Validation:

- title required
- description required
- date required
- amount required and greater than 0

### 3. Cola / Sync

Must show:

- Sync summary
- Button: "Sincronizar ahora"
- List of sync operations
- Button: "Reintentar fallidos"

## Required Data

A management record must have:

- localId
- title
- description
- date
- amount
- syncStatus
- createdAt
- updatedAt

A sync operation must have:

- id
- localId
- operationType
- status
- attempts
- lastError
- createdAt
- updatedAt
- syncedAt

## Sync Statuses

Use these values:

- pending
- syncing
- synced
- failed

## Operation Types

Use these values:

- create
- update

## Sync Rules

When creating a management record:

1. Generate localId using uuid.
2. Insert record into managements table.
3. Insert operation into sync_queue with:
   - operationType = create
   - status = pending
   - attempts = 0

When editing a management record:

1. Update record in managements table.
2. Insert operation into sync_queue with:
   - operationType = update
   - status = pending
   - attempts = 0

When synchronizing:

1. Get pending operations ordered by createdAt ASC.
2. Process one operation at a time.
3. Mark operation as syncing.
4. Send it to FakeBackendService.
5. If success:
   - mark operation as synced
   - set syncedAt
   - update management syncStatus to synced
6. If failure:
   - retry up to 3 times
   - use simple backoff
   - if still failing, mark operation as failed
   - save lastError
   - update management syncStatus to failed
7. Continue with the next pending operation.

## Retry Policy

Use simple backoff:

- Attempt 1: wait 1 second
- Attempt 2: wait 2 seconds
- Attempt 3: wait 3 seconds

Maximum attempts: 3.

## Fake Backend

Create a FakeBackendService that:

- simulates network delay
- randomly fails 30% of the time
- succeeds 70% of the time

Do not call a real API.
