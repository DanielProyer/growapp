import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../routing/route_names.dart';
import '../providers/inventar_provider.dart';
import '../widgets/inventar_item_karte.dart';
import 'inventory_item_form_page.dart';

class InventoryPage extends ConsumerStatefulWidget {
  const InventoryPage({super.key});

  @override
  ConsumerState<InventoryPage> createState() => _InventoryPageState();
}

class _InventoryPageState extends ConsumerState<InventoryPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        final typ =
            _tabController.index == 0 ? 'verbrauchsmaterial' : 'equipment';
        ref.read(inventarFilterTypProvider.notifier).state = typ;
      }
    });
    // Default: Verbrauchsmaterial
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(inventarFilterTypProvider.notifier).state =
          'verbrauchsmaterial';
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _neuerArtikel() async {
    final typ = _tabController.index == 0 ? 'verbrauchsmaterial' : 'equipment';
    final gespeichert = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => InventoryItemFormPage(vorausgewaehlterTyp: typ),
      ),
    );
    if (mounted && gespeichert == true) {
      ref.invalidate(inventarListeProvider);
    }
  }

  @override
  Widget build(BuildContext context) {
    final inventarAsync = ref.watch(gefiltertesInventarProvider);
    final suchbegriff = ref.watch(inventarSuchbegriffProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Inventar'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () =>
                ref.read(inventarListeProvider.notifier).aktualisieren(),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(
              icon: Icon(Icons.science_outlined),
              text: 'Verbrauchsmaterial',
            ),
            Tab(
              icon: Icon(Icons.build_outlined),
              text: 'Equipment',
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // Suchleiste
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Inventar durchsuchen...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: suchbegriff.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () => ref
                            .read(inventarSuchbegriffProvider.notifier)
                            .state = '',
                      )
                    : null,
              ),
              onChanged: (value) =>
                  ref.read(inventarSuchbegriffProvider.notifier).state = value,
            ),
          ),

          // Inventarliste
          Expanded(
            child: inventarAsync.when(
              data: (items) {
                if (items.isEmpty) {
                  return _EmptyState(
                    suchbegriff: suchbegriff,
                    typ: _tabController.index == 0
                        ? 'Verbrauchsmaterial'
                        : 'Equipment',
                    onHinzufuegen: _neuerArtikel,
                  );
                }

                return RefreshIndicator(
                  onRefresh: () =>
                      ref.read(inventarListeProvider.notifier).aktualisieren(),
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final item = items[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: InventarItemKarte(
                          item: item,
                          onTap: () => context.goNamed(
                            RouteNames.inventoryDetail,
                            pathParameters: {'id': item.id},
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
              loading: () =>
                  const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline,
                        size: 48, color: Colors.red),
                    const SizedBox(height: 16),
                    Text('Fehler: $error'),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => ref
                          .read(inventarListeProvider.notifier)
                          .aktualisieren(),
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
        onPressed: _neuerArtikel,
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final String suchbegriff;
  final String typ;
  final VoidCallback onHinzufuegen;

  const _EmptyState({
    required this.suchbegriff,
    required this.typ,
    required this.onHinzufuegen,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inventory_2_outlined,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            suchbegriff.isNotEmpty
                ? 'Keine Artikel gefunden'
                : 'Noch kein $typ angelegt',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.grey[600],
                ),
          ),
          if (suchbegriff.isEmpty) ...[
            const SizedBox(height: 8),
            Text(
              'Füge deinen ersten Artikel hinzu.',
              style: TextStyle(color: Colors.grey[500]),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onHinzufuegen,
              icon: const Icon(Icons.add),
              label: const Text('Artikel hinzufügen'),
            ),
          ],
        ],
      ),
    );
  }
}
