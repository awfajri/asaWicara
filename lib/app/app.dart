import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'features/home/presentation/pages/home_page.dart';

class AsaWicaraApp extends StatelessWidget {
  const AsaWicaraApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'AsaWicara',
      theme: AppTheme.light,
      home: const HomePage(),
    );
  }
}
