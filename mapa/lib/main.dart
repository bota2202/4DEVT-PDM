import 'package:flutter/material.dart';
import 'screens/mapa_screen.dart';

void main() => runApp(const MapaLocaisApp());

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
