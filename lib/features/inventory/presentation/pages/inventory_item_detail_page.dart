import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../domain/entities/inventar_item.dart';
import '../../domain/entities/inventar_buchung.dart';
import '../providers/inventar_provider.dart';
import '../widgets/buchung_dialog.dart';
import 'inventory_item_form_page.dart';

class InventoryItemDetailPage extends ConsumerStatefulWidget {
  final String itemId;

  const InventoryItemDetailPage({super.key, required this.itemId});

  @override
  ConsumerState<InventoryItemDetailPage> createState() =>
      _InventoryItemDetailPageState();
}

class _InventoryItemDetailPageState
    extends ConsumerState<InventoryItemDetailPage> {
  Future<void> _bearbeiten(InventarItem item) async {
    final gespeichert = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => InventoryItemFormPage(item: item),
      ),
    );
    if (mounted && gespeichert == true) {
      ref.invalidate(inventarListeProvider);
    }
  }

  Future<void> _loeschen(InventarItem item) async {
    final bestaetigt = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Artikel löschen'),
        content: Text('Möchtest du "${item.name}" wirklich löschen?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Abbrechen'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Löschen'),
          ),
        ],
      ),
    );

    if (bestaetigt == true && mounted) {
      try {
        await ref.read(inventarListeProvider.notifier).loeschen(item.id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Artikel gelöscht')),
          );
          context.pop();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Fehler: $e')),
          );
        }
      }
    }
  }

  Future<void> _neueBuchung(InventarItem item) async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => BuchungDialog(
        artikelName: item.name,
        einheit: item.einheit,
      ),
    );

    if (result == null || !mounted) return;

    try {
      await buchungErstellen(
        ref,
        artikelId: item.id,
        typ: result['typ'] as String,
        menge: result['menge'] as double,
        stueckpreis: result['stueckpreis'] as double?,
        datum: result['datum'] as DateTime,
        bemerkung: result['bemerkung'] as String?,
        preisAktualisieren: result['preis_aktualisieren'] as bool,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Buchung erstellt')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Fehler: $e')),
        );
      }
    }
  }

  Future<void> _buchungLoeschenDialog(InventarBuchung buchung) async {
    final bestaetigt = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Buchung löschen'),
        content: const Text(
            'Möchtest du diese Buchung wirklich löschen? Der Bestand wird entsprechend korrigiert.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Abbrechen'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Löschen'),
          ),
        ],
      ),
    );

    if (bestaetigt == true && mounted) {
      try {
        await buchungLoeschen(ref, buchung: buchung);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Buchung gelöscht')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Fehler: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final itemAsync = ref.watch(inventarItemProvider(widget.itemId));

    return itemAsync.when(
      data: (item) {
        if (item == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Artikel')),
            body: const Center(child: Text('Artikel nicht gefunden.')),
          );
        }
        return _DetailContent(
          item: item,
          onBearbeiten: () => _bearbeiten(item),
          onLoeschen: () => _loeschen(item),
          onNeueBuchung: () => _neueBuchung(item),
          onBuchungLoeschen: _buchungLoeschenDialog,
        );
      },
      loading: () => Scaffold(
        appBar: AppBar(title: const Text('Artikel')),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (error, _) => Scaffold(
        appBar: AppBar(title: const Text('Artikel')),
        body: Center(child: Text('Fehler: $error')),
      ),
    );
  }
}

class _DetailContent extends ConsumerWidget {
  final InventarItem item;
  final VoidCallback onBearbeiten;
  final VoidCallback onLoeschen;
  final VoidCallback onNeueBuchung;
  final void Function(InventarBuchung) onBuchungLoeschen;

  const _DetailContent({
    required this.item,
    required this.onBearbeiten,
    required this.onLoeschen,
    required this.onNeueBuchung,
    required this.onBuchungLoeschen,
  });

  String _formatMenge(double menge) {
    return menge == menge.roundToDouble()
        ? menge.toInt().toString()
        : menge.toStringAsFixed(2);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final buchungenAsync = ref.watch(buchungenProvider(item.id));

    return Scaffold(
      appBar: AppBar(
        title: Text(item.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: onBearbeiten,
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: onLoeschen,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Stammdaten Card
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                item.name,
                                style: theme.textTheme.headlineSmall
                                    ?.copyWith(fontWeight: FontWeight.bold),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.primaryContainer,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Text(
                                item.typLabel,
                                style: TextStyle(
                                  color:
                                      theme.colorScheme.onPrimaryContainer,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        _DetailZeile('Kategorie', item.kategorieLabel),
                        if (item.einheit != null)
                          _DetailZeile('Einheit', item.einheit!),
                        if (item.preis != null)
                          _DetailZeile(
                              'Preis', '${item.preis!.toStringAsFixed(2)} €'),
                        if (item.lieferant != null)
                          _DetailZeile('Lieferant', item.lieferant!),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Bestand Card
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text('Bestand',
                                style: theme.textTheme.titleMedium
                                    ?.copyWith(
                                        fontWeight: FontWeight.w600)),
                            if (item.bestandNiedrig) ...[
                              const SizedBox(width: 8),
                              Icon(Icons.warning_amber_rounded,
                                  color: Colors.orange[700], size: 20),
                              const SizedBox(width: 4),
                              Text(
                                'Niedrig!',
                                style: TextStyle(
                                  color: Colors.orange[700],
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 12),
                        _DetailZeile(
                          'Aktueller Bestand',
                          item.einheit != null
                              ? '${_formatMenge(item.aktuellerBestand)} ${item.einheit}'
                              : _formatMenge(item.aktuellerBestand),
                        ),
                        if (item.mindestBestand > 0)
                          _DetailZeile(
                            'Mindestbestand',
                            item.einheit != null
                                ? '${_formatMenge(item.mindestBestand)} ${item.einheit}'
                                : _formatMenge(item.mindestBestand),
                          ),
                      ],
                    ),
                  ),
                ),

                // Bemerkung
                if (item.bemerkung != null) ...[
                  const SizedBox(height: 16),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Bemerkung',
                              style: theme.textTheme.titleMedium
                                  ?.copyWith(
                                      fontWeight: FontWeight.w600)),
                          const SizedBox(height: 12),
                          Text(item.bemerkung!),
                        ],
                      ),
                    ),
                  ),
                ],

                const SizedBox(height: 16),

                // Buchungen
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text('Buchungen',
                                  style: theme.textTheme.titleMedium
                                      ?.copyWith(
                                          fontWeight: FontWeight.w600)),
                            ),
                            FilledButton.icon(
                              onPressed: onNeueBuchung,
                              icon: const Icon(Icons.add, size: 18),
                              label: const Text('Neue Buchung'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        buchungenAsync.when(
                          data: (buchungen) {
                            if (buchungen.isEmpty) {
                              return Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16),
                                child: Center(
                                  child: Text(
                                    'Noch keine Buchungen vorhanden',
                                    style: TextStyle(
                                        color: Colors.grey[500]),
                                  ),
                                ),
                              );
                            }
                            return Column(
                              children: buchungen.map((b) {
                                final datumText =
                                    '${b.datum.day.toString().padLeft(2, '0')}.${b.datum.month.toString().padLeft(2, '0')}.${b.datum.year}';
                                final vorzeichen =
                                    b.istEingang ? '+' : '-';
                                final farbe = b.istEingang
                                    ? Colors.green
                                    : Colors.red;

                                return ListTile(
                                  contentPadding: EdgeInsets.zero,
                                  leading: Icon(
                                    b.istEingang
                                        ? Icons.add_circle
                                        : Icons.remove_circle,
                                    color: farbe,
                                  ),
                                  title: Text(
                                    '$vorzeichen${_formatMenge(b.menge)}${item.einheit != null ? ' ${item.einheit}' : ''}',
                                    style: TextStyle(
                                      color: farbe,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(datumText),
                                      if (b.stueckpreis != null)
                                        Text(
                                            '${b.stueckpreis!.toStringAsFixed(2)} €/Stk'),
                                      if (b.bemerkung != null)
                                        Text(b.bemerkung!,
                                            style: TextStyle(
                                                color: Colors.grey[600])),
                                    ],
                                  ),
                                  trailing: IconButton(
                                    icon: const Icon(
                                        Icons.delete_outline,
                                        size: 20),
                                    onPressed: () =>
                                        onBuchungLoeschen(b),
                                  ),
                                );
                              }).toList(),
                            );
                          },
                          loading: () => const Padding(
                            padding: EdgeInsets.all(16),
                            child: Center(
                                child: CircularProgressIndicator()),
                          ),
                          error: (error, _) =>
                              Text('Fehler: $error'),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DetailZeile extends StatelessWidget {
  final String label;
  final String wert;

  const _DetailZeile(this.label, this.wert);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 160,
            child: Text(
              label,
              style: TextStyle(
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(child: Text(wert)),
        ],
      ),
    );
  }
}
