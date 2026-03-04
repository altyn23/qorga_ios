class EmailValidator {
  EmailValidator._();

  static final RegExp _emailRegex = RegExp(
    r"^[A-Za-z0-9.!#$%&'*+/=?^_`{|}~-]+@[A-Za-z0-9-]+(\.[A-Za-z0-9-]+)+$",
  );

  static bool isValid(String? value) {
    final email = value?.trim() ?? '';
    if (email.isEmpty) return false;
    return _emailRegex.hasMatch(email);
  }
}
