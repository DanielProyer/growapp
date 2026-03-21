import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    // Grundlegender Smoke Test - wird mit echten Tests erweitert
    expect(1 + 1, equals(2));
  });
}
