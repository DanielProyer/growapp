import '../entities/zelt.dart';

/// Abstraktes Repository für Zeltverwaltung
abstract class ZelteRepository {
  Future<List<Zelt>> alleLaden();
  Future<Zelt?> laden(String id);
  Future<void> erstellen(Zelt zelt);
  Future<void> aktualisieren(Zelt zelt);
  Future<void> loeschen(String id);
}
