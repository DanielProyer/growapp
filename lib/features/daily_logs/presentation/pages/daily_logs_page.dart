import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../grows/presentation/providers/grows_provider.dart';
import '../providers/tages_logs_provider.dart';
import '../widgets/tages_log_karte.dart';

class DailyLogsPage extends ConsumerStatefulWidget {
  const DailyLogsPage({super.key});

  @override
  ConsumerState<DailyLogsPage> createState() => _DailyLogsPageState();
}

class _DailyLogsPageState extends ConsumerState<DailyLogsPage> {
  String? _gewaehlterDurchgangId;

  @override
  Widget build(BuildContext context) {
    final durchgaengeAsync = ref.watch(aktiveDurchgaengeProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tägliche Logs'),
      ),
      body: durchgaengeAsync.when(
        data: (durchgaenge) {
          if (durchgaenge.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.edit_note_outlined,
                      size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'Keine aktiven Grows',
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Starte einen Grow, um tägliche Logs zu erfassen.',
                    style: TextStyle(color: Colors.grey[500]),
                  ),
                ],
              ),
            );
          }

          // Auto-select first grow if none selected
          if (_gewaehlterDurchgangId == null ||
              !durchgaenge.any((d) => d.id == _gewaehlterDurchgangId)) {
            _gewaehlterDurchgangId = durchgaenge.first.id;
          }

          return Column(
            children: [
              // Grow-Auswahl Dropdown
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: DropdownButtonFormField<String>(
                  initialValue: _gewaehlterDurchgangId,
                  decoration: const InputDecoration(
                    labelText: 'Grow-Durchgang',
                    prefixIcon: Icon(Icons.eco_outlined),
                  ),
                  items: durchgaenge
                      .map((d) => DropdownMenuItem(
                            value: d.id,
                            child: Text(d.titel),
                          ))
                      .toList(),
                  onChanged: (v) {
                    if (v != null) {
                      setState(() => _gewaehlterDurchgangId = v);
                    }
                  },
                ),
              ),

              // Log-Liste
              Expanded(
                child: _LogListe(durchgangId: _gewaehlterDurchgangId!),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Fehler: $error'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.invalidate(aktiveDurchgaengeProvider),
                child: const Text('Erneut versuchen'),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: _gewaehlterDurchgangId != null
          ? FloatingActionButton(
              onPressed: () =>
                  context.go('/logs/neu?grow=$_gewaehlterDurchgangId'),
              child: const Icon(Icons.add),
            )
          : null,
    );
  }
}

class _LogListe extends ConsumerWidget {
  final String durchgangId;

  const _LogListe({required this.durchgangId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final logsAsync = ref.watch(tagesLogsFuerDurchgangProvider(durchgangId));

    return logsAsync.when(
      data: (logs) {
        if (logs.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.edit_note_outlined,
                    size: 64, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text(
                  'Noch keine Logs für diesen Grow',
                  style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () =>
                      context.go('/logs/neu?grow=$durchgangId'),
                  icon: const Icon(Icons.add),
                  label: const Text('Ersten Log erstellen'),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () => ref
              .read(tagesLogsFuerDurchgangProvider(durchgangId).notifier)
              .aktualisieren(),
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: logs.length,
            itemBuilder: (context, index) {
              final log = logs[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: TagesLogKarte(
                  log: log,
                  onTap: () => context.go('/logs/${log.id}'),
                ),
              );
            },
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Fehler: $error'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => ref
                  .read(tagesLogsFuerDurchgangProvider(durchgangId).notifier)
                  .aktualisieren(),
              child: const Text('Erneut versuchen'),
            ),
          ],
        ),
      ),
    );
  }
}
