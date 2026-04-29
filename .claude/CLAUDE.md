# Sync App - Claude Context

You are working on a Flutter MVP called Sync.

Sync is an offline-first mobile app that allows users to create and edit management records locally, store pending sync operations in a local queue, and manually synchronize those operations with a simulated backend.

The project must be implemented as an MVP in approximately 8 hours. Avoid overengineering. Build only what is necessary to satisfy the technical challenge.

## Stack

Use:

- Flutter + Dart SDK 3.x
- flutter_modular for navigation and dependency injection
- flutter_bloc using Cubit
- Drift + SQLite for local persistence
- uuid for local IDs
- google_fonts using Space Grotesk or similar
- intl for date and amount formatting
- fake backend service to simulate synchronization

Do not use a real backend.

## Architecture

Use a simplified Clean Architecture with these layers inside each feature:

- domain
- application
- infrastructure
- presentation

## Project Structure

Use this structure:

lib/
  main.dart

  app/
    app_module.dart
    app_widget.dart
    app_routes.dart

  core/
    theme/
      app_colors.dart
      app_theme.dart

    database/
      app_database.dart
      tables/
        managements_table.dart
        sync_queue_table.dart

    network/
      fake_backend_service.dart

    widgets/
      app_primary_button.dart
      app_status_badge.dart
      app_bottom_navigation.dart

  features/
    managements/
      managements_module.dart

      domain/
        entities/
          management.dart
        repositories/
          management_repository.dart

      application/
        cubit/
          managements_cubit.dart
          managements_state.dart
          management_form_cubit.dart
          management_form_state.dart

      infrastructure/
        repositories/
          management_repository_impl.dart

      presentation/
        pages/
          managements_page.dart
          management_form_page.dart
        widgets/
          management_card.dart

    sync/
      sync_module.dart

      domain/
        entities/
          sync_operation.dart
          sync_summary.dart
        repositories/
          sync_repository.dart

      application/
        services/
          sync_engine.dart
        cubit/
          sync_cubit.dart
          sync_state.dart

      infrastructure/
        repositories/
          sync_repository_impl.dart

      presentation/
        pages/
          sync_page.dart
        widgets/
          sync_summary_card.dart
          sync_operation_card.dart

## Main Screens

The MVP needs only these screens:

1. Gestiones
2. Nueva / Editar Gestión
3. Cola / Sync

Use only 2 main bottom tabs:

- Gestiones
- Cola

## UI Style

The app must look like a modern fintech/neobank mobile app.

Use:

- Background: #f2f3f5
- Primary dark: #202020
- Accent lime: #c9f158
- Cards: #ffffff
- Very rounded corners
- Large black buttons
- Soft shadows
- Clean spacing
- Bold typography
- Space Grotesk or similar font

The UI text must be in Spanish.

## Core Requirement

Make the app work offline first.

When a user creates or edits a management record:

1. Save the record locally in SQLite using Drift.
2. Create a sync operation with status pending.
3. Show the record immediately in the local list.
4. Allow synchronization later from the Sync screen.

Make it work first, then improve the UI.
