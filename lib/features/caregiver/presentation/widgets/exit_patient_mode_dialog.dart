import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';

class ExitPatientModeDialog extends StatefulWidget {
  const ExitPatientModeDialog({super.key});

  @override
  State<ExitPatientModeDialog> createState() => _ExitPatientModeDialogState();
}

class _ExitPatientModeDialogState extends State<ExitPatientModeDialog> {
  Timer? _holdTimer;
  double _progress = 0.0;

  @override
  void dispose() {
    _holdTimer?.cancel();
    super.dispose();
  }

  void _startHold() {
    _holdTimer?.cancel();
    setState(() => _progress = 0.05);
    _holdTimer = Timer.periodic(const Duration(milliseconds: 50), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      final next = _progress + 0.025;
      if (next >= 1.0) {
        timer.cancel();
        Navigator.of(context).pop(true);
      } else {
        setState(() => _progress = next);
      }
    });
  }

  void _cancelHold() {
    _holdTimer?.cancel();
    if (mounted) setState(() => _progress = 0.0);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Keluar dari Mode Pasien?'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Menu ini khusus untuk pendamping (caregiver). Tekan dan tahan tombol merah selama 2 detik untuk kembali ke Dasbor Pendamping.',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: AppSpacing.md),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: _progress,
              minHeight: 12,
              backgroundColor: AppColors.surfaceVariant,
              color: AppColors.danger,
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text(
            'Batal',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),
        ),
        GestureDetector(
          onTapDown: (_) => _startHold(),
          onTapUp: (_) => _cancelHold(),
          onTapCancel: _cancelHold,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            decoration: BoxDecoration(
              color: AppColors.danger,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text(
              'Tahan 2 Detik untuk Keluar',
              style: TextStyle(
                color: Colors.white,
                fontSize: 17,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
