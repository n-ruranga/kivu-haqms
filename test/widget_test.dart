import 'package:flutter_test/flutter_test.dart';
import 'package:kivu_haqms/app.dart';

void main() {
  testWidgets('App launches on login screen', (WidgetTester tester) async {
    await tester.pumpWidget(const KivuApp());
    await tester.pumpAndSettle();

    expect(find.text('Login'), findsOneWidget);
  });
}
