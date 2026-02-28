import 'package:internat_app/src/shared/theme/app_theme.dart';
import 'package:internat_app/src/core/di/injection.dart';
import 'package:internat_app/src/app/routing/app_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await dotenv.load(fileName: ".env");
  } catch (e) {
    debugPrint(
      "Aucun fichier .env trouvé ou erreur de format, utilisation des variables d'environnement du système si disponibles.",
    );
  }

  final supabaseUrl =
      dotenv.env['SUPABASE_URL'] ??
      const String.fromEnvironment('SUPABASE_URL', defaultValue: '');
  final supabaseAnonKey =
      dotenv.env['SUPABASE_ANON_KEY'] ??
      const String.fromEnvironment('SUPABASE_ANON_KEY', defaultValue: '');

  debugPrint(
    'Loaded SUPABASE_URL: ${supabaseUrl.isNotEmpty ? 'OK' : 'MISSING'}',
  );

  if (supabaseUrl.isNotEmpty && supabaseAnonKey.isNotEmpty) {
    await Supabase.initialize(url: supabaseUrl, anonKey: supabaseAnonKey);
  } else {
    debugPrint("Erreur : Clés Supabase manquantes.");
  }

  await configureDependencies();

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
