import '../../domain/entities/sorte.dart';
import '../../domain/repositories/sorten_repository.dart';
import '../datasources/sorten_datasource.dart';
import '../models/sorte_model.dart';

/// Implementierung des SortenRepository mit Supabase
class SortenRepositoryImpl implements SortenRepository {
  final SortenDatasource _datasource;

  SortenRepositoryImpl(this._datasource);

  @override
  Future<List<Sorte>> alleLaden() async {
    return await _datasource.alleLaden();
  }

  @override
  Future<Sorte?> laden(String id) async {
    return await _datasource.laden(id);
  }

  @override
  Future<Sorte> erstellen(Sorte sorte) async {
    final model = SorteModel.fromEntity(sorte);
    return await _datasource.erstellen(model);
  }

  @override
  Future<Sorte> aktualisieren(Sorte sorte) async {
    final model = SorteModel.fromEntity(sorte);
    return await _datasource.aktualisieren(sorte.id, model);
  }

  @override
  Future<void> loeschen(String id) async {
    await _datasource.loeschen(id);
  }

  @override
  Future<List<Sorte>> nachStatusFiltern(String status) async {
    return await _datasource.nachStatusFiltern(status);
  }

  @override
  Future<List<Sorte>> suchen(String suchbegriff) async {
    return await _datasource.suchen(suchbegriff);
  }
}
