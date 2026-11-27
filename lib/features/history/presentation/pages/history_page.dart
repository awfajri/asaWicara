import 'package:flutter/material.dart';

class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Riwayat Latihan')),
      body: const SafeArea(
        child: Center(child: Text('Belum ada riwayat latihan yang tersimpan.')),
      ),
    );
  }
}
