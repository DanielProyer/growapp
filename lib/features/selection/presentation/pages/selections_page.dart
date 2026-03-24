import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../routing/route_names.dart';
import '../../domain/entities/selektion.dart';
import '../providers/selektions_provider.dart';
import 'selection_form_page.dart';

class SelectionsPage extends ConsumerStatefulWidget {
  const SelectionsPage({super.key});

  @override
  ConsumerState<SelectionsPage> createState() => _SelectionsPageState();
}

class _SelectionsPageState extends ConsumerState<SelectionsPage> {
  void _neueSelektion() async {
    final gespeichert = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => const SelectionFormPage()),
    );
    if (mounted && gespeichert == true) {
      ref.invalidate(selektionenListeProvider);
    }
  }

  @override
  Widget build(BuildContext context) {
    final filterStatus = ref.watch(selektionenStatusFilterProvider);
    final selektionenAsync = ref.watch(gefilterteSelektionenProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Selektionen'),
        actions: [
          PopupMenuButton<String?>(
            icon: const Icon(Icons.filter_list),
            tooltip: 'Status filtern',
            onSelected: (value) =>
                ref.read(selektionenStatusFilterProvider.notifier).state = value,
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
                value: 'aktiv',
                child: Row(
                  children: [
                    if (filterStatus == 'aktiv')
                      const Icon(Icons.check, size: 18)
                    else
                      const SizedBox(width: 18),
                    const SizedBox(width: 8),
                    const Text('Aktiv'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'abgeschlossen',
                child: Row(
                  children: [
                    if (filterStatus == 'abgeschlossen')
                      const Icon(Icons.check, size: 18)
                    else
                      const SizedBox(width: 18),
                    const SizedBox(width: 8),
                    const Text('Abgeschlossen'),
                  ],
                ),
              ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () =>
                ref.read(selektionenListeProvider.notifier).aktualisieren(),
          ),
        ],
      ),
      body: selektionenAsync.when(
        data: (selektionen) {
          if (selektionen.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.science, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'Noch keine Selektionen',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text('Starte deine erste Pheno-Selektion.',
                      style: TextStyle(color: Colors.grey[500])),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: _neueSelektion,
                    icon: const Icon(Icons.add),
                    label: const Text('Selektion anlegen'),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () =>
                ref.read(selektionenListeProvider.notifier).aktualisieren(),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: selektionen.length,
              itemBuilder: (context, index) {
                final selektion = selektionen[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: _SelektionKarte(
                    selektion: selektion,
                    onTap: () => context.goNamed(
                      RouteNames.selectionDetail,
                      pathParameters: {'id': selektion.id},
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
                    ref.read(selektionenListeProvider.notifier).aktualisieren(),
                child: const Text('Erneut versuchen'),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _neueSelektion,
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _SelektionKarte extends StatelessWidget {
  final Selektion selektion;
  final VoidCallback onTap;

  const _SelektionKarte({required this.selektion, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final istAktiv = selektion.istAktiv;

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
                  color: istAktiv
                      ? Colors.green.withAlpha(30)
                      : Colors.blue.withAlpha(30),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.science,
                  color: istAktiv ? Colors.green : Colors.blue,
                ),
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
                            selektion.name,
                            style: theme.textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.w600),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: istAktiv
                                ? Colors.green.withAlpha(30)
                                : Colors.blue.withAlpha(30),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            selektion.statusLabel,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: istAktiv ? Colors.green : Colors.blue,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      [
                        if (selektion.sorteName != null) selektion.sorteName!,
                        '${selektion.pflanzenAnzahl ?? 0} Pflanzen',
                        if ((selektion.keeperAnzahl ?? 0) > 0)
                          '${selektion.keeperAnzahl} Keeper',
                        if (selektion.startDatumFormatiert != null)
                          selektion.startDatumFormatiert!,
                      ].join(' · '),
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 13,
                      ),
                    ),
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
