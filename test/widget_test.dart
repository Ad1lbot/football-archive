import 'package:flutter_test/flutter_test.dart';
import 'package:football_archive/main.dart';

void main() {
  testWidgets('Football Archive displays splash screen',
      (WidgetTester tester) async {
    await tester.pumpWidget(const FootballArchiveApp());

    expect(find.text('FOOTBALL'), findsOneWidget);
    expect(find.text('ARCHIVE'), findsOneWidget);
    expect(
      find.text('WHERE FOOTBALL HISTORY LIVES'),
      findsOneWidget,
    );
  });
}
