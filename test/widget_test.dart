import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:luxespend/data/repositories/expense_repository.dart';
import 'package:luxespend/providers/expense_controller.dart';
import 'package:luxespend/main.dart';

void main() {
  testWidgets('LuxeSpend app loads successfully smoke test', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    final repository = await ExpenseRepository.init();
    final controller = ExpenseController(repository);

    await tester.pumpWidget(LuxeSpendApp(controller: controller));
    await tester.pumpAndSettle();

    expect(find.text('TOTAL LIQUID WEALTH'), findsOneWidget);
  });
}
