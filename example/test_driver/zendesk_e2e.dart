import 'package:flutter_test/flutter_test.dart';
import 'package:e2e/e2e.dart';
import 'package:zendesk/zendesk.dart';

void main() {
  E2EWidgetsFlutterBinding.ensureInitialized();

  testWidgets('sets visitor info', (WidgetTester tester) async {
    await Zendesk().setVisitorInfo(
      name: 'some-user',
      email: 'email@domain.com',
      phoneNumber: '12341234',
      note: 'abcabc',
    );
  });

  testWidgets('retrieves version', (WidgetTester tester) async {
    final version = await Zendesk().version();

    expect(version, isNotEmpty);
  });
}
