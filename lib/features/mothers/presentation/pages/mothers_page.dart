import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../routing/route_names.dart';
import '../../domain/entities/mutterpflanze.dart';
import '../providers/muetter_provider.dart';
import 'mother_form_page.dart';

class MothersPage extends ConsumerStatefulWidget {
  const MothersPage({super.key});

  @override
  ConsumerState<MothersPage> createState() => _MothersPageState();
}

class _MothersPageState extends ConsumerState<MothersPage> {
  void _neueMutter() async {
    final gespeichert = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => const MotherFormPage()),
    );
    if (mounted && gespeichert == true) {
      ref.invalidate(muetterListeProvider);
    }
  }

  @override
  Widget build(BuildContext context) {
    final filterStatus = ref.watch(muetterStatusFilterProvider);
    final muetterAsync = ref.watch(gefilterteMuetterProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mutterpflanzen'),
        actions: [
          // Filter-Toggle
          PopupMenuButton<String?>(
            icon: const Icon(Icons.filter_list),
            tooltip: 'Status filtern',
            onSelected: (value) =>
                ref.read(muetterStatusFilterProvider.notifier).state = value,
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
                value: 'entsorgt',
                child: Row(
                  children: [
                    if (filterStatus == 'entsorgt')
                      const Icon(Icons.check, size: 18)
                    else
                      const SizedBox(width: 18),
                    const SizedBox(width: 8),
                    const Text('Entsorgt'),
                  ],
                ),
              ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () =>
                ref.read(muetterListeProvider.notifier).aktualisieren(),
          ),
        ],
      ),
      body: muetterAsync.when(
        data: (muetter) {
          if (muetter.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.nature, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'Noch keine Mutterpflanzen',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text('Lege deine erste Mutterpflanze an.',
                      style: TextStyle(color: Colors.grey[500])),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: _neueMutter,
                    icon: const Icon(Icons.add),
                    label: const Text('Mutterpflanze anlegen'),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () =>
                ref.read(muetterListeProvider.notifier).aktualisieren(),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: muetter.length,
              itemBuilder: (context, index) {
                final mutter = muetter[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: _MutterKarte(
                    mutter: mutter,
                    onTap: () => context.goNamed(
                      RouteNames.motherDetail,
                      pathParameters: {'id': mutter.id},
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
                    ref.read(muetterListeProvider.notifier).aktualisieren(),
                child: const Text('Erneut versuchen'),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _neueMutter,
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _MutterKarte extends StatelessWidget {
  final Mutterpflanze mutter;
  final VoidCallback onTap;

  const _MutterKarte({required this.mutter, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final istAktiv = mutter.istAktiv;

    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Icon
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: istAktiv
                      ? Colors.green.withAlpha(30)
                      : Colors.grey.withAlpha(30),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.nature,
                  color: istAktiv ? Colors.green : Colors.grey,
                ),
              ),
              const SizedBox(width: 16),
              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            mutter.anzeigeName,
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
                                : Colors.grey.withAlpha(30),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            mutter.statusLabel,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: istAktiv ? Colors.green : Colors.grey,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      [
                        if (mutter.gesamtStecklinge != null &&
                            mutter.gesamtStecklinge! > 0)
                          '${mutter.gesamtStecklinge} Stecklinge',
                        if (mutter.anzahlSchnitte != null &&
                            mutter.anzahlSchnitte! > 0)
                          '${mutter.anzahlSchnitte} Schnitte',
                        if (mutter.letzterSchnittFormatiert != null)
                          'Letzter: ${mutter.letzterSchnittFormatiert}',
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
