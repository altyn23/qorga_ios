class PasswordValidator {
  PasswordValidator._();

  static const int minLength = 8;
  static const int maxLength = 64;

  static const String requirementsShort =
      'Кемінде 8 таңба: A-Z, a-z, 0-9 және арнайы таңба.';

  static String? validate(
    String? value, {
    String emptyMessage = 'Құпиясөз енгізіңіз',
  }) {
    final password = value ?? '';

    if (password.isEmpty) return emptyMessage;
    if (password.length < minLength) {
      return 'Кемінде 8 таңба болуы керек';
    }
    if (password.length > maxLength) {
      return 'Құпиясөз 64 таңбадан аспауы керек';
    }
    if (password.contains(RegExp(r'\s'))) {
      return 'Құпиясөзде бос орын болмауы керек';
    }
    if (!RegExp(r'[a-z]').hasMatch(password)) {
      return 'Кемінде 1 кіші әріп (a-z) қажет';
    }
    if (!RegExp(r'[A-Z]').hasMatch(password)) {
      return 'Кемінде 1 бас әріп (A-Z) қажет';
    }
    if (!RegExp(r'\d').hasMatch(password)) {
      return 'Кемінде 1 сан қажет';
    }
    if (!RegExp(r'[^A-Za-z0-9]').hasMatch(password)) {
      return 'Кемінде 1 арнайы таңба қажет';
    }
    return null;
  }
}
