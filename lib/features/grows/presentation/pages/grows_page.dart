import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/grows_provider.dart';
import '../widgets/durchgang_karte.dart';
import 'grow_form_page.dart';

class GrowsPage extends ConsumerWidget {
  const GrowsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final durchgaengeAsync = ref.watch(durchgaengeListeProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Grows'),
      ),
      body: durchgaengeAsync.when(
        data: (durchgaenge) {
          if (durchgaenge.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.eco_outlined, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'Noch keine Grows angelegt',
                    style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const GrowFormPage()),
                    ),
                    icon: const Icon(Icons.add),
                    label: const Text('Ersten Grow starten'),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () =>
                ref.read(durchgaengeListeProvider.notifier).aktualisieren(),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: durchgaenge.length,
              itemBuilder: (context, index) {
                final d = durchgaenge[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: DurchgangKarte(
                    durchgang: d,
                    onTap: () => context.go('/grows/${d.id}'),
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
                onPressed: () =>
                    ref.read(durchgaengeListeProvider.notifier).aktualisieren(),
                child: const Text('Erneut versuchen'),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const GrowFormPage()),
        ),
        child: const Icon(Icons.add),
      ),
    );
  }
}
