import '../entities/sorte.dart';

/// Abstraktes Repository für Sorten
abstract class SortenRepository {
  /// Alle Sorten laden
  Future<List<Sorte>> alleLaden();

  /// Einzelne Sorte laden
  Future<Sorte?> laden(String id);

  /// Neue Sorte erstellen
  Future<Sorte> erstellen(Sorte sorte);

  /// Sorte aktualisieren
  Future<Sorte> aktualisieren(Sorte sorte);

  /// Sorte löschen
  Future<void> loeschen(String id);

  /// Sorten nach Status filtern
  Future<List<Sorte>> nachStatusFiltern(String status);

  /// Sorten durchsuchen (Name oder Züchter)
  Future<List<Sorte>> suchen(String suchbegriff);
}
