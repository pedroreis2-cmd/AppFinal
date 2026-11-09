import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const MeusGamesApp());
}

class MeusGamesApp extends StatelessWidget {
  const MeusGamesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gerenciador de Games',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}