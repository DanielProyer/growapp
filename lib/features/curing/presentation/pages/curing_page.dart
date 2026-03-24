import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../routing/route_names.dart';
import '../../../grows/domain/entities/durchgang.dart';
import '../../../grows/presentation/providers/grows_provider.dart';
import '../../domain/entities/curing_glas.dart';
import '../providers/curing_provider.dart';
import 'curing_glas_form_page.dart';

class CuringPage extends ConsumerStatefulWidget {
  const CuringPage({super.key});

  @override
  ConsumerState<CuringPage> createState() => _CuringPageState();
}

class _CuringPageState extends ConsumerState<CuringPage> {
  void _neuesGlas() async {
    final gespeichert = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => const CuringGlasFormPage()),
    );
    if (mounted && gespeichert == true) {
      ref.invalidate(curingGlaeserListeProvider);
    }
  }

  @override
  Widget build(BuildContext context) {
    final filterStatus = ref.watch(curingStatusFilterProvider);
    final glaeserAsync = ref.watch(curingGlaeserGefiltertProvider);
    final durchgaengeAsync = ref.watch(durchgaengeListeProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Curing'),
        actions: [
          PopupMenuButton<String?>(
            icon: const Icon(Icons.filter_list),
            tooltip: 'Status filtern',
            onSelected: (value) =>
                ref.read(curingStatusFilterProvider.notifier).state = value,
            itemBuilder: (_) => [
              PopupMenuItem(
                value: null,
                child: Row(
                  children: [
                    if (filterStatus == null)
                      const Icon(Icons.check, size: 18)
                    else
                      const SizedBox(width: 18),
                    const SizedBox(width: 8),
                    const Text('Alle'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'trocknung',
                child: Row(
                  children: [
                    if (filterStatus == 'trocknung')
                      const Icon(Icons.check, size: 18)
                    else
                      const SizedBox(width: 18),
                    const SizedBox(width: 8),
                    const Text('Trocknung'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'curing',
                child: Row(
                  children: [
                    if (filterStatus == 'curing')
                      const Icon(Icons.check, size: 18)
                    else
                      const SizedBox(width: 18),
                    const SizedBox(width: 8),
                    const Text('Curing'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'fertig',
                child: Row(
                  children: [
                    if (filterStatus == 'fertig')
                      const Icon(Icons.check, size: 18)
                    else
                      const SizedBox(width: 18),
                    const SizedBox(width: 8),
                    const Text('Fertig'),
                  ],
                ),
              ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () =>
                ref.read(curingGlaeserListeProvider.notifier).aktualisieren(),
          ),
        ],
      ),
      body: glaeserAsync.when(
        data: (glaeser) {
          if (glaeser.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.local_bar, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'Noch keine Curing-Gläser angelegt',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text('Lege dein erstes Curing-Glas an.',
                      style: TextStyle(color: Colors.grey[500])),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: _neuesGlas,
                    icon: const Icon(Icons.add),
                    label: const Text('Glas anlegen'),
                  ),
                ],
              ),
            );
          }

          // Durchgänge-Map für Titel-Auflösung
          final durchgaengeMap = <String, Durchgang>{};
          final durchgaenge = durchgaengeAsync.valueOrNull ?? [];
          for (final d in durchgaenge) {
            durchgaengeMap[d.id] = d;
          }

          return RefreshIndicator(
            onRefresh: () =>
                ref.read(curingGlaeserListeProvider.notifier).aktualisieren(),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: glaeser.length,
              itemBuilder: (context, index) {
                final glas = glaeser[index];
                final durchgang = durchgaengeMap[glas.durchgangId];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: _GlasKarte(
                    glas: glas,
                    durchgangTitel: durchgang?.titel,
                    onTap: () => context.goNamed(
                      RouteNames.curingDetail,
                      pathParameters: {'id': glas.id},
                    ),
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
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              Text('Fehler: $error'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () =>
                    ref.read(curingGlaeserListeProvider.notifier).aktualisieren(),
                child: const Text('Erneut versuchen'),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _neuesGlas,
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _GlasKarte extends StatelessWidget {
  final CuringGlas glas;
  final String? durchgangTitel;
  final VoidCallback onTap;

  const _GlasKarte({
    required this.glas,
    this.durchgangTitel,
    required this.onTap,
  });

  Color _statusFarbe() {
    switch (glas.status) {
      case 'trocknung':
        return Colors.orange;
      case 'curing':
        return Colors.blue;
      case 'fertig':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  IconData _behaelterIcon() {
    switch (glas.behaelterTyp) {
      case 'glas':
        return Icons.local_bar;
      case 'grove_bag':
        return Icons.shopping_bag_outlined;
      case 'cvault':
        return Icons.lock_outlined;
      case 'eimer':
        return Icons.delete_outline;
      default:
        return Icons.inventory_2_outlined;
    }
  }

  Color _meilensteinFarbe() {
    switch (glas.meilenstein) {
      case 'Optimal':
        return Colors.green;
      case 'Gut':
        return Colors.blue;
      case 'Rauchbar':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final farbe = _statusFarbe();

    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: farbe.withAlpha(30),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(_behaelterIcon(), color: farbe),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Glas #${glas.glasNr}${glas.sorteName != null ? ' – ${glas.sorteName}' : ''}',
                            style: theme.textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.w600),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: farbe.withAlpha(30),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            glas.statusLabel,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: farbe,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      [
                        ?durchgangTitel,
                        if (glas.trockenGewichtG != null)
                          '${glas.trockenGewichtG!.toStringAsFixed(1)}g',
                        if (glas.letzteRlf != null) '${glas.letzteRlf}% RLF',
                        if (glas.einglasDatum != null)
                          '${glas.curingTage} Tage',
                      ].join(' · '),
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 13,
                      ),
                    ),
                    if (glas.schimmelErkannt || glas.einglasDatum != null) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          if (glas.schimmelErkannt)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.red.withAlpha(30),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Text(
                                'Schimmel!',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.red,
                                ),
                              ),
                            ),
                          if (glas.schimmelErkannt &&
                              glas.einglasDatum != null)
                            const SizedBox(width: 6),
                          if (glas.einglasDatum != null)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: _meilensteinFarbe().withAlpha(30),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                glas.meilenstein,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: _meilensteinFarbe(),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}
