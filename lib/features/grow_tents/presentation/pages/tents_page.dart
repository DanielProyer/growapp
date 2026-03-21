import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/zelte_provider.dart';
import '../widgets/zelt_karte.dart';
import 'tent_form_page.dart';

class TentsPage extends ConsumerWidget {
  const TentsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final zelteAsync = ref.watch(zelteListeProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Zelte'),
      ),
      body: zelteAsync.when(
        data: (zelte) {
          if (zelte.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.house_outlined, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'Noch keine Zelte angelegt',
                    style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const TentFormPage()),
                    ),
                    icon: const Icon(Icons.add),
                    label: const Text('Erstes Zelt anlegen'),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => ref.read(zelteListeProvider.notifier).aktualisieren(),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: zelte.length,
              itemBuilder: (context, index) {
                final zelt = zelte[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: ZeltKarte(
                    zelt: zelt,
                    onTap: () => context.go('/zelte/${zelt.id}'),
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
                onPressed: () => ref.read(zelteListeProvider.notifier).aktualisieren(),
                child: const Text('Erneut versuchen'),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const TentFormPage()),
        ),
        child: const Icon(Icons.add),
      ),
    );
  }
}
