import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../routing/route_names.dart';
import '../../../grow_tents/presentation/providers/zelte_provider.dart';
import '../../domain/entities/schaedlings_behandlung.dart';
import '../providers/schaedlings_provider.dart';
import '../widgets/vorfall_karte.dart';
import 'pest_incident_form_page.dart';
import 'pest_treatment_form_page.dart';

class PestManagementPage extends ConsumerStatefulWidget {
  const PestManagementPage({super.key});

  @override
  ConsumerState<PestManagementPage> createState() =>
      _PestManagementPageState();
}

class _PestManagementPageState extends ConsumerState<PestManagementPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _neuerVorfall() async {
    final gespeichert = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => const PestIncidentFormPage()),
    );
    if (mounted && gespeichert == true) {
      ref.invalidate(vorfaelleListeProvider);
    }
  }

  void _neueProphylaxe() async {
    final gespeichert = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => const PestTreatmentFormPage()),
    );
    if (mounted && gespeichert == true) {
      ref.invalidate(prophylaxeListeProvider);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Schädlinge'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.read(vorfaelleListeProvider.notifier).aktualisieren();
              ref.read(prophylaxeListeProvider.notifier).aktualisieren();
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.bug_report_outlined), text: 'Vorfälle'),
            Tab(icon: Icon(Icons.shield_outlined), text: 'Prophylaxe'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _VorfaelleTab(onNeuErstellen: _neuerVorfall),
          _ProphylaxeTab(onNeuErstellen: _neueProphylaxe),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (_tabController.index == 0) {
            _neuerVorfall();
          } else {
            _neueProphylaxe();
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _VorfaelleTab extends ConsumerWidget {
  final VoidCallback onNeuErstellen;

  const _VorfaelleTab({required this.onNeuErstellen});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final zelteAsync = ref.watch(zelteListeProvider);
    final filterZeltId = ref.watch(vorfaelleZeltFilterProvider);
    final vorfaelleAsync = ref.watch(gefilterteVorfaelleProvider);

    return Column(
      children: [
        // Zelt-Filter
        Padding(
          padding: const EdgeInsets.all(16),
          child: zelteAsync.when(
            data: (zelte) => DropdownButtonFormField<String?>(
              initialValue: filterZeltId,
              decoration: const InputDecoration(
                labelText: 'Zelt filtern',
                prefixIcon: Icon(Icons.filter_list),
              ),
              items: [
                const DropdownMenuItem<String?>(
                  value: null,
                  child: Text('Alle Zelte'),
                ),
                ...zelte.map((z) => DropdownMenuItem<String?>(
                      value: z.id,
                      child: Text(z.name),
                    )),
              ],
              onChanged: (value) =>
                  ref.read(vorfaelleZeltFilterProvider.notifier).state = value,
            ),
            loading: () => const LinearProgressIndicator(),
            error: (_, _) => const SizedBox.shrink(),
          ),
        ),

        // Vorfälle-Liste
        Expanded(
          child: vorfaelleAsync.when(
            data: (vorfaelle) {
              if (vorfaelle.isEmpty) {
                return _EmptyState(
                  icon: Icons.check_circle_outline,
                  text: filterZeltId != null
                      ? 'Keine Vorfälle für dieses Zelt'
                      : 'Keine Schädlingsvorfälle',
                  subText: 'Hoffentlich bleibt das so!',
                  onHinzufuegen: onNeuErstellen,
                  buttonText: 'Vorfall melden',
                );
              }

              return RefreshIndicator(
                onRefresh: () =>
                    ref.read(vorfaelleListeProvider.notifier).aktualisieren(),
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: vorfaelle.length,
                  itemBuilder: (context, index) {
                    final vorfall = vorfaelle[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: VorfallKarte(
                        vorfall: vorfall,
                        onTap: () => context.goNamed(
                          RouteNames.pestIncidentDetail,
                          pathParameters: {'id': vorfall.id},
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
                    onPressed: () => ref
                        .read(vorfaelleListeProvider.notifier)
                        .aktualisieren(),
                    child: const Text('Erneut versuchen'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ProphylaxeTab extends ConsumerWidget {
  final VoidCallback onNeuErstellen;

  const _ProphylaxeTab({required this.onNeuErstellen});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prophylaxeAsync = ref.watch(prophylaxeListeProvider);
    final theme = Theme.of(context);

    return prophylaxeAsync.when(
      data: (behandlungen) {
        if (behandlungen.isEmpty) {
          return _EmptyState(
            icon: Icons.shield_outlined,
            text: 'Keine Prophylaxe-Behandlungen',
            subText: 'Dokumentiere vorbeugende Maßnahmen.',
            onHinzufuegen: onNeuErstellen,
            buttonText: 'Behandlung hinzufügen',
          );
        }

        return RefreshIndicator(
          onRefresh: () =>
              ref.read(prophylaxeListeProvider.notifier).aktualisieren(),
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: behandlungen.length,
            itemBuilder: (context, index) {
              final b = behandlungen[index];
              return _ProphylaxeKarte(behandlung: b, theme: theme);
            },
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(child: Text('Fehler: $error')),
    );
  }
}

class _ProphylaxeKarte extends ConsumerWidget {
  final SchaedlingsBehandlung behandlung;
  final ThemeData theme;

  const _ProphylaxeKarte({required this.behandlung, required this.theme});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: theme.colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            Icons.shield,
            color: theme.colorScheme.onPrimaryContainer,
            size: 22,
          ),
        ),
        title: Text(
          behandlung.mittel,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
                '${behandlung.behandlungTypLabel} · ${behandlung.datumFormatiert}'),
            if (behandlung.zeltName != null)
              Text('Zelt: ${behandlung.zeltName}'),
            if (behandlung.menge != null) Text('Menge: ${behandlung.menge}'),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline, size: 20),
          onPressed: () async {
            final bestaetigt = await showDialog<bool>(
              context: context,
              builder: (ctx) => AlertDialog(
                title: const Text('Behandlung löschen'),
                content: const Text(
                    'Möchtest du diese Behandlung wirklich löschen?'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(ctx, false),
                    child: const Text('Abbrechen'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(ctx, true),
                    style: TextButton.styleFrom(foregroundColor: Colors.red),
                    child: const Text('Löschen'),
                  ),
                ],
              ),
            );
            if (bestaetigt == true && context.mounted) {
              try {
                await behandlungLoeschen(ref, behandlung: behandlung);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Behandlung gelöscht')),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Fehler: $e')),
                  );
                }
              }
            }
          },
        ),
        isThreeLine: true,
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String text;
  final String subText;
  final VoidCallback onHinzufuegen;
  final String buttonText;

  const _EmptyState({
    required this.icon,
    required this.text,
    required this.subText,
    required this.onHinzufuegen,
    required this.buttonText,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            text,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.grey[600],
                ),
          ),
          const SizedBox(height: 8),
          Text(subText, style: TextStyle(color: Colors.grey[500])),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: onHinzufuegen,
            icon: const Icon(Icons.add),
            label: Text(buttonText),
          ),
        ],
      ),
    );
  }
}
