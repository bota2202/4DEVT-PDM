import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'firebase_options.dart';
import 'screens/mapa_screen.dart';
import 'services/local_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  // Cache local: abre instantâneo com os últimos dados e funciona offline.
  FirebaseFirestore.instance.settings = const Settings(persistenceEnabled: true);
  // Não bloqueia a abertura do app; se falhar, as telas mostram o erro do Firestore.
  LocalService().prepararDados().catchError((e) => debugPrint('Falha ao preparar locais: $e'));
  runApp(const MapaLocaisApp());
}

class MapaLocaisApp extends StatelessWidget {
  const MapaLocaisApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Mapa de Locais',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xff202020)),
        scaffoldBackgroundColor: Colors.white,
        inputDecorationTheme: InputDecorationTheme(isDense: true, filled: true, fillColor: Colors.white, border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
        appBarTheme: const AppBarTheme(backgroundColor: Colors.white, surfaceTintColor: Colors.transparent),
        cardTheme: const CardThemeData(color: Colors.white, surfaceTintColor: Colors.white),
      ),
      home: const MapaScreen(),
    );
  }
}
