
import 'package:flutter_test/flutter_test.dart';
import 'package:todo/main.dart';

void main() {
  testWidgets('Barbie Planner opens', (WidgetTester tester) async {
    await tester.pumpWidget(const BarbieApp());

    await tester.pump();

    expect(find.text('BARBIE PLANNER'), findsOneWidget);
  });
}
