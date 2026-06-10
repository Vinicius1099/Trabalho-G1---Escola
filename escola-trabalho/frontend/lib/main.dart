// frontend/lib/main.dart

import 'package:flutter/material.dart';
import 'screens/lista_page.dart';

void main() {
  runApp(const EscolaApp());
}

class EscolaApp extends StatelessWidget {
  const EscolaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Escola App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1565C0),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1565C0),
          foregroundColor: Colors.white,
          elevation: 2,
        ),
      ),
      home: const ListaPage(),
    );
  }
}
