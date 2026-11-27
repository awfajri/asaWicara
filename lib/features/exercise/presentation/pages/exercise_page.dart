import 'package:flutter/material.dart';

class ExercisePage extends StatelessWidget {
  const ExercisePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Latihan AIUEO')),
      body: const SafeArea(
        child: Center(
          child: Text('Fitur latihan akan tersedia pada fase berikutnya.'),
        ),
      ),
    );
  }
}
