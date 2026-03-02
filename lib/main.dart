import 'package:internat_app/src/shared/theme/app_theme.dart';
import 'package:internat_app/src/core/di/injection.dart';
import 'package:internat_app/src/app/routing/app_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'dart:developer' as dev;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Clés injectées via --dart-define au moment du build (CI) ou via
  // launch.json (VS Code local). Voir .vscode/launch.json.
  const supabaseUrl = String.fromEnvironment('SUPABASE_URL');
  const supabaseAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY');

  dev.log('SUPABASE_URL: ${supabaseUrl.isNotEmpty ? 'OK' : 'MISSING'}');
  dev.log(
    'SUPABASE_ANON_KEY: ${supabaseAnonKey.isNotEmpty ? 'OK' : 'MISSING'}',
  );

  final bool supabaseReady =
      supabaseUrl.isNotEmpty && supabaseAnonKey.isNotEmpty;

  if (supabaseReady) {
    await Supabase.initialize(url: supabaseUrl, anonKey: supabaseAnonKey);
    await configureDependencies();
    await initializeDateFormatting('fr_FR', null);
    runApp(const MyApp());
  } else {
    // Lancer une UI minimale pour signaler la misconfiguration plutôt que crash.
    runApp(const _MissingKeysApp());
  }
}

// ── App principale ────────────────────────────────────────────────────────────
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

// ── Écran de secours : clés Supabase manquantes ───────────────────────────────
class _MissingKeysApp extends StatelessWidget {
  const _MissingKeysApp();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: Colors.red.shade900,
        body: const Center(
          child: Padding(
            padding: EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.error_outline, color: Colors.white, size: 64),
                SizedBox(height: 24),
                Text(
                  'Configuration manquante',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 12),
                Text(
                  'Les clés Supabase ne sont pas configurées.\n\n'
                  'En local : relancez avec\n'
                  '--dart-define=SUPABASE_URL=...\n'
                  '--dart-define=SUPABASE_ANON_KEY=...',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
