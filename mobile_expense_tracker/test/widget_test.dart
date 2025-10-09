import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_expense_tracker/main.dart';

void main() {
  testWidgets('App renders AppShell with bottom navigation', (WidgetTester tester) async {
    await tester.pumpWidget(const ExpenseApp());
    await tester.pumpAndSettle();

    expect(find.byType(BottomNavigationBar), findsOneWidget);
    expect(find.text('Dashboard'), findsOneWidget);
  });
}
