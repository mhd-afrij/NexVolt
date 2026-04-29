import 'package:flutter_test/flutter_test.dart';
import 'package:nexvolt/main.dart';

void main() {
  testWidgets('NexVolt app loads', (WidgetTester tester) async {
    await tester.pumpWidget(const NexVoltApp());
    expect(find.text('NexVolt'), findsOneWidget);
    expect(find.text('Start Booking'), findsOneWidget);
  });
}