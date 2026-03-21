import '../../domain/entities/zelt.dart';
import '../../domain/repositories/zelte_repository.dart';
import '../datasources/zelte_datasource.dart';
import '../models/zelt_model.dart';

/// Repository-Implementierung für Zelte
class ZelteRepositoryImpl implements ZelteRepository {
  final ZelteDatasource _datasource;

  ZelteRepositoryImpl(this._datasource);

  @override
  Future<List<Zelt>> alleLaden() => _datasource.alleLaden();

  @override
  Future<Zelt?> laden(String id) => _datasource.laden(id);

  @override
  Future<void> erstellen(Zelt zelt) async {
    await _datasource.erstellen(ZeltModel.fromEntity(zelt));
  }

  @override
  Future<void> aktualisieren(Zelt zelt) async {
    await _datasource.aktualisieren(zelt.id, ZeltModel.fromEntity(zelt));
  }

  @override
  Future<void> loeschen(String id) => _datasource.loeschen(id);
}
