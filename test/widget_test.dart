import 'package:flutter_test/flutter_test.dart';
import 'package:nexvolt/app.dart';
import 'package:nexvolt/core/services/firestore_service.dart';

void main() {
  testWidgets('Dashboard renders with profile greeting', (
    WidgetTester tester,
  ) async {
    final repository = AppRepository(firebaseReady: false);
    await repository.seedDefaults();

    await tester.pumpWidget(
      NexVoltApp(
        repository: repository,
        firebaseReady: false,
        enableMaps: false,
      ),
    );

    await tester.pump(const Duration(milliseconds: 600));
    expect(find.textContaining('Good Morning'), findsOneWidget);
    expect(find.text('Map Explorer'), findsOneWidget);
  });
}
