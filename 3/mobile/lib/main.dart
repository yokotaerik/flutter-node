import 'package:flutter/material.dart';
import 'screens/contacts_screen.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gerenciador de Contatos',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const ContactsScreen(),
    );
  }
}
