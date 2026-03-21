import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../routing/route_names.dart';
import '../providers/sorten_provider.dart';
import '../widgets/sorten_karte.dart';

class StrainsPage extends ConsumerWidget {
  const StrainsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sortenAsync = ref.watch(gefilterteSortenProvider);
    final suchbegriff = ref.watch(sortenSuchbegriffProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sorten'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () =>
                ref.read(sortenListeProvider.notifier).aktualisieren(),
          ),
        ],
      ),
      body: Column(
        children: [
          // Suchleiste
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Sorten durchsuchen...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: suchbegriff.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () => ref
                            .read(sortenSuchbegriffProvider.notifier)
                            .state = '',
                      )
                    : null,
              ),
              onChanged: (value) =>
                  ref.read(sortenSuchbegriffProvider.notifier).state = value,
            ),
          ),

          // Sortenliste
          Expanded(
            child: sortenAsync.when(
              data: (sorten) {
                if (sorten.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.local_florist_outlined,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          suchbegriff.isNotEmpty
                              ? 'Keine Sorten gefunden'
                              : 'Noch keine Sorten angelegt',
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    color: Colors.grey[600],
                                  ),
                        ),
                        if (suchbegriff.isEmpty) ...[
                          const SizedBox(height: 8),
                          Text(
                            'Füge deine erste Cannabissorte hinzu.',
                            style: TextStyle(color: Colors.grey[500]),
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton.icon(
                            onPressed: () =>
                                context.goNamed(RouteNames.strainCreate),
                            icon: const Icon(Icons.add),
                            label: const Text('Sorte hinzufügen'),
                          ),
                        ],
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () =>
                      ref.read(sortenListeProvider.notifier).aktualisieren(),
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: sorten.length,
                    itemBuilder: (context, index) {
                      final sorte = sorten[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: SortenKarte(
                          sorte: sorte,
                          onTap: () => context.goNamed(
                            RouteNames.strainDetail,
                            pathParameters: {'id': sorte.id},
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 48, color: Colors.red),
                    const SizedBox(height: 16),
                    Text('Fehler: $error'),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () =>
                          ref.read(sortenListeProvider.notifier).aktualisieren(),
                      child: const Text('Erneut versuchen'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.goNamed(RouteNames.strainCreate),
        child: const Icon(Icons.add),
      ),
    );
  }
}
