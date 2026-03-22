import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../domain/entities/kalender_eintrag.dart';
import '../providers/kalender_provider.dart';
import 'calendar_entry_form_page.dart';

class CalendarPage extends ConsumerStatefulWidget {
  const CalendarPage({super.key});

  @override
  ConsumerState<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends ConsumerState<CalendarPage> {
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();
  CalendarFormat _calendarFormat = CalendarFormat.month;

  @override
  Widget build(BuildContext context) {
    final eventsAsync = ref.watch(kalenderEventsProvider);
    final tagesEintraegeAsync = ref.watch(kalenderTagProvider(_selectedDay));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Kalender'),
        actions: [
          IconButton(
            icon: const Icon(Icons.today),
            tooltip: 'Heute',
            onPressed: () {
              setState(() {
                _focusedDay = DateTime.now();
                _selectedDay = DateTime.now();
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Kalender
          eventsAsync.when(
            data: (events) => TableCalendar<KalenderEintrag>(
              locale: 'de_DE',
              firstDay: DateTime(2024),
              lastDay: DateTime(2030),
              focusedDay: _focusedDay,
              selectedDayPredicate: (day) => isSameDay(day, _selectedDay),
              calendarFormat: _calendarFormat,
              onFormatChanged: (format) {
                setState(() => _calendarFormat = format);
              },
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;
                });
              },
              onPageChanged: (focusedDay) {
                _focusedDay = focusedDay;
              },
              eventLoader: (day) {
                final key = DateTime(day.year, day.month, day.day);
                return events[key] ?? [];
              },
              calendarStyle: CalendarStyle(
                markerDecoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  shape: BoxShape.circle,
                ),
                markerSize: 6,
                markersMaxCount: 3,
                todayDecoration: BoxDecoration(
                  color: Theme.of(context)
                      .colorScheme
                      .primary
                      .withAlpha(80),
                  shape: BoxShape.circle,
                ),
                selectedDecoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  shape: BoxShape.circle,
                ),
              ),
              headerStyle: const HeaderStyle(
                formatButtonShowsNext: false,
              ),
            ),
            loading: () => const SizedBox(
              height: 300,
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (e, _) => SizedBox(
              height: 300,
              child: Center(child: Text('Fehler: $e')),
            ),
          ),

          const Divider(height: 1),

          // Tagesliste
          Expanded(
            child: tagesEintraegeAsync.when(
              data: (eintraege) {
                if (eintraege.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.event_available,
                          size: 48,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Keine Termine an diesem Tag',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: eintraege.length,
                  itemBuilder: (context, index) {
                    final eintrag = eintraege[index];
                    return _EintragKachel(
                      eintrag: eintrag,
                      onErledigt: (erledigt) {
                        ref
                            .read(kalenderListeProvider.notifier)
                            .erledigtToggeln(eintrag.id, erledigt);
                      },
                      onTap: () => _eintragBearbeiten(eintrag),
                      onLoeschen: () => _eintragLoeschen(eintrag),
                    );
                  },
                );
              },
              loading: () =>
                  const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Fehler: $e')),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _neuerEintrag(),
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<void> _neuerEintrag() async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => CalendarEntryFormPage(
          vorausgewaehltesDatum: _selectedDay,
        ),
      ),
    );
    if (result == true) {
      ref.invalidate(kalenderListeProvider);
      ref.invalidate(anstehendeTermineProvider);
    }
  }

  Future<void> _eintragBearbeiten(KalenderEintrag eintrag) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => CalendarEntryFormPage(eintrag: eintrag),
      ),
    );
    if (result == true) {
      ref.invalidate(kalenderListeProvider);
      ref.invalidate(anstehendeTermineProvider);
    }
  }

  Future<void> _eintragLoeschen(KalenderEintrag eintrag) async {
    final bestaetigt = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Termin löschen'),
        content: Text('„${eintrag.titel}" wirklich löschen?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Abbrechen'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Löschen'),
          ),
        ],
      ),
    );
    if (bestaetigt == true) {
      await ref.read(kalenderListeProvider.notifier).loeschen(eintrag.id);
    }
  }
}

class _EintragKachel extends StatelessWidget {
  final KalenderEintrag eintrag;
  final ValueChanged<bool> onErledigt;
  final VoidCallback onTap;
  final VoidCallback onLoeschen;

  const _EintragKachel({
    required this.eintrag,
    required this.onErledigt,
    required this.onTap,
    required this.onLoeschen,
  });

  IconData _typIcon(String typ) {
    switch (typ) {
      case 'bewaesserung':
        return Icons.water_drop;
      case 'duengung':
        return Icons.science;
      case 'ernte':
        return Icons.content_cut;
      case 'stecklinge':
        return Icons.call_split;
      case 'umtopfen':
        return Icons.swap_vert;
      case 'schaedlingskontrolle':
        return Icons.bug_report;
      case 'foto':
        return Icons.camera_alt;
      case 'allgemein':
      default:
        return Icons.event;
    }
  }

  Color _typFarbe(String typ) {
    switch (typ) {
      case 'bewaesserung':
        return Colors.blue;
      case 'duengung':
        return Colors.green;
      case 'ernte':
        return Colors.amber;
      case 'stecklinge':
        return Colors.teal;
      case 'umtopfen':
        return Colors.brown;
      case 'schaedlingskontrolle':
        return Colors.red;
      case 'foto':
        return Colors.purple;
      case 'allgemein':
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final zeit = eintrag.geplantAm.toLocal();
    final zeitStr =
        '${zeit.hour.toString().padLeft(2, '0')}:${zeit.minute.toString().padLeft(2, '0')}';

    return Dismissible(
      key: ValueKey(eintrag.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16),
        color: Colors.red,
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      confirmDismiss: (_) async {
        onLoeschen();
        return false; // Dialog handled in onLoeschen
      },
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _typFarbe(eintrag.typ).withAlpha(30),
          child: Icon(
            _typIcon(eintrag.typ),
            color: _typFarbe(eintrag.typ),
            size: 20,
          ),
        ),
        title: Text(
          eintrag.titel,
          style: TextStyle(
            decoration: eintrag.erledigt
                ? TextDecoration.lineThrough
                : null,
            color: eintrag.erledigt ? Colors.grey : null,
          ),
        ),
        subtitle: Text(
          '$zeitStr · ${eintrag.typLabel}',
          style: TextStyle(
            color: eintrag.erledigt ? Colors.grey : null,
          ),
        ),
        trailing: Checkbox(
          value: eintrag.erledigt,
          onChanged: (value) => onErledigt(value ?? false),
        ),
        onTap: onTap,
      ),
    );
  }
}
