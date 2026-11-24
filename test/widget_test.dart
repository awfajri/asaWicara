
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:asa_wicara/core/theme/app_spacing.dart';
import 'package:asa_wicara/core/widgets/geriatric_primary_button.dart';
import 'package:asa_wicara/core/widgets/state_feedback_views.dart';

void main() {
  testWidgets('primary button meets the minimum touch target', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: GeriatricPrimaryButton(
            label: 'Mulai latihan',
            onPressed: null,
          ),
        ),
      ),
    );

    expect(
      tester.getSize(find.byType(GeriatricPrimaryButton)).height,
      AppSpacing.primaryButtonHeight,
    );
  });

  testWidgets('primary button shows progress and disables while loading', (
    tester,
  ) async {
    var wasPressed = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: GeriatricPrimaryButton(
            label: 'Simpan',
            isLoading: true,
            onPressed: () => wasPressed = true,
          ),
        ),
      ),
    );

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    await tester.tap(find.byType(ElevatedButton));
    expect(wasPressed, isFalse);
  });

  testWidgets('empty state only shows action when callback is provided', (
    tester,
  ) async {
    var wasPressed = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: GeriatricEmptyView(
            title: 'Belum ada latihan',
            subtitle: 'Mulai latihan vokal pertama.',
            actionLabel: 'Mulai',
            onAction: () => wasPressed = true,
          ),
        ),
      ),
    );

    await tester.tap(find.text('Mulai'));
    expect(wasPressed, isTrue);

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: GeriatricEmptyView(
            title: 'Belum ada latihan',
            subtitle: 'Mulai latihan vokal pertama.',
            actionLabel: 'Mulai',
          ),
        ),
      ),
    );

    expect(find.text('Mulai'), findsNothing);
  });
}
