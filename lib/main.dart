import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app/app.dart';
import 'features/calendar/services/notification_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Supabase initialisieren
  await Supabase.initialize(
    url: const String.fromEnvironment(
      'SUPABASE_URL',
      defaultValue: 'https://uayxzdojxrvlxjjlfnqe.supabase.co',
    ),
    anonKey: const String.fromEnvironment(
      'SUPABASE_ANON_KEY',
      defaultValue: 'sb_publishable_kBfgQakzLCdmNP_HYbZjbA_gq1yN9ew',
    ),
  );

  // Notifications initialisieren
  await NotificationService().initialisieren();

  runApp(
    const ProviderScope(
      child: GrowApp(),
    ),
  );
}
