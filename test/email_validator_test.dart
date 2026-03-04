import 'package:flutter_test/flutter_test.dart';
import 'package:qorga_app/widgets/email_validator.dart';

void main() {
  group('EmailValidator', () {
    test('accepts valid domains', () {
      expect(EmailValidator.isValid('user@gmail.com'), isTrue);
      expect(EmailValidator.isValid('user@mail.ru'), isTrue);
      expect(EmailValidator.isValid('user@bk.ru'), isTrue);
      expect(EmailValidator.isValid('user@icloud.com'), isTrue);
    });

    test('rejects invalid email formats', () {
      expect(EmailValidator.isValid('bad-email'), isFalse);
      expect(EmailValidator.isValid('name@localhost'), isFalse);
      expect(EmailValidator.isValid(''), isFalse);
    });
  });
}
