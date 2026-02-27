import 'package:internat_app/ui/home_page/home_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://ccsbzyqzyfgzivuymphn.supabase.co', // Trouvé dans Project Settings > API
    anonKey: 'sb_publishable_2Q95P7DszU73bD5CX-Xb0w_Y2fU401w',  // Trouvé dans Project Settings > API
  );

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: .fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const HomePage(),
    );
  }
}
