import 'package:internat_app/src/shared/theme/app_theme.dart';
import 'package:internat_app/src/core/di/injection.dart';
import 'package:internat_app/src/app/routing/app_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");

  debugPrint(
    'Loaded SUPABASE_URL: ${dotenv.env['SUPABASE_URL'] != null ? 'OK' : 'MISSING'}',
  );

  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
  );

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
