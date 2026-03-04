import 'package:flutter_test/flutter_test.dart';
import 'package:qorga_app/widgets/password_validator.dart';

void main() {
  group('PasswordValidator', () {
    test('returns error for empty value', () {
      expect(
        PasswordValidator.validate('', emptyMessage: 'empty'),
        'empty',
      );
    });

    test('returns error for short password', () {
      expect(
        PasswordValidator.validate('Ab1!'),
        'Кемінде 8 таңба болуы керек',
      );
    });

    test('returns error for missing uppercase', () {
      expect(
        PasswordValidator.validate('lowercase1!'),
        'Кемінде 1 бас әріп (A-Z) қажет',
      );
    });

    test('returns null for strong password', () {
      expect(PasswordValidator.validate('StrongPass1!'), isNull);
    });
  });
}
