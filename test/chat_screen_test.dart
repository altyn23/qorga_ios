import 'package:flutter_test/flutter_test.dart';
import 'package:qorga_app/chat.dart';

import 'test_helpers.dart';

void main() {
  testWidgets('Chat screen asks login when no userId', (tester) async {
    await pumpScreen(tester, const ChatScreen(), prefs: const {'role': 'user'});

    expect(find.text('Чатқа кіру үшін алдымен аккаунтқа кіріңіз.'), findsOneWidget);
  });

  testWidgets('Chat screen still prompts auth for psychologist without userId',
      (tester) async {
    await pumpScreen(
      tester,
      const ChatScreen(),
      prefs: const {'role': 'psychologist'},
    );

    expect(find.text('Чаттар'), findsOneWidget);
    expect(find.text('Чатқа кіру үшін алдымен аккаунтқа кіріңіз.'),
        findsOneWidget);
  });
}
