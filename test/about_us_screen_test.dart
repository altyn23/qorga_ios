import 'package:flutter_test/flutter_test.dart';
import 'package:qorga_app/about_us.dart';

import 'test_helpers.dart';

void main() {
  testWidgets('About us screen renders', (tester) async {
    await pumpScreen(tester, const AboutUsScreen());

    expect(find.text('Біз туралы'), findsWidgets);
    expect(find.textContaining('Qorga'), findsWidgets);
    expect(find.text('АВТОРЛАР'), findsOneWidget);
    expect(find.text('Серікқызы Алуа'), findsOneWidget);
    expect(find.text('Қабыкен Алтынай'), findsOneWidget);
  });

  testWidgets('About us screen shows contact phones', (tester) async {
    await pumpScreen(tester, const AboutUsScreen());
    await tester.scrollUntilVisible(find.textContaining('9006'), 300);
    await tester.scrollUntilVisible(find.textContaining('4322'), 300);

    expect(find.textContaining('9006'), findsOneWidget);
    expect(find.textContaining('4322'), findsOneWidget);
  });
}
