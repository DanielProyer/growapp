import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/supabase/supabase_client.dart';
import '../../data/datasources/fotos_datasource.dart';
import '../../domain/entities/foto.dart';

final fotosDatasourceProvider = Provider<FotosDatasource>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return FotosDatasource(client);
});

/// Fotos für eine Pflanze (chronologisch sortiert)
final fotosProvider =
    FutureProvider.family<List<Foto>, String>((ref, pflanzeId) async {
  final ds = ref.watch(fotosDatasourceProvider);
  return await ds.fuerPflanzeLaden(pflanzeId);
});
