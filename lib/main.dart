import 'package:internat_app/src/shared/theme/app_theme.dart';
import 'package:internat_app/src/core/di/injection.dart';
import 'package:internat_app/src/app/routing/app_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'dart:developer' as dev;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Clés injectées via --dart-define au moment du build (CI GitHub Actions).
  // Localement : flutter run --dart-define=SUPABASE_URL=... --dart-define=SUPABASE_ANON_KEY=...
  const supabaseUrl = String.fromEnvironment('SUPABASE_URL');
  const supabaseAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY');

  dev.log('SUPABASE_URL: ${supabaseUrl.isNotEmpty ? 'OK' : 'MISSING'}');
  dev.log(
    'SUPABASE_ANON_KEY: ${supabaseAnonKey.isNotEmpty ? 'OK' : 'MISSING'}',
  );

  if (supabaseUrl.isNotEmpty && supabaseAnonKey.isNotEmpty) {
    await Supabase.initialize(url: supabaseUrl, anonKey: supabaseAnonKey);
  } else {
    dev.log(
      '[main] ERREUR : Clés Supabase manquantes — app démarrée sans connexion.',
    );
  }

  await configureDependencies();
  await initializeDateFormatting('fr_FR', null);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'InternatApp',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.getTheme(context),
      routerConfig: appRouter,
    );
  }
}
