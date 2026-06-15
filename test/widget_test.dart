import 'package:flutter_test/flutter_test.dart';
import 'package:radharadha/app.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const RadhaRadhaApp());
  });
}
