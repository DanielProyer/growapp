# GrowApp - Cannabis Grow Management

## Projekt-Übersicht
Web App zur Dokumentation und Verwaltung von Cannabis-Anbau und -Zucht.
Desktop PC + Android Phone (responsive).

## Tech Stack
- **Frontend:** Flutter (Web + Android)
- **Backend:** Supabase (PostgreSQL, Auth, Storage, Realtime)
- **State Management:** Riverpod 3.x
- **Routing:** go_router
- **Sprache:** Nur Deutsch (UI)

## Architektur
Feature-first Clean Architecture:
- `lib/features/<feature>/data/` – Datasources, Models, Repository-Impl
- `lib/features/<feature>/domain/` – Entities, Repositories (abstract), UseCases
- `lib/features/<feature>/presentation/` – Providers, Pages, Widgets

## Befehle
- `flutter run -d chrome` – Web starten
- `flutter analyze` – Statische Analyse
- `flutter test` – Tests ausführen
- `npx supabase start` – Lokale Supabase starten
- `npx supabase db reset` – DB zurücksetzen und Migrationen anwenden

## Konventionen
- Deutsche UI-Texte, englische Code-Bezeichner
- Supabase-Migrationen in `supabase/migrations/`
- RLS auf allen Tabellen, `created_by` Pattern
- Responsive Breakpoints: 600px (mobile), 1024px (tablet), 1200px (desktop)
