const MIN_PASSWORD_LENGTH = 8;
const MAX_PASSWORD_LENGTH = 64;

function validatePassword(password) {
  const value = String(password || '');

  if (!value) return 'Пароль обязателен';
  if (value.length < MIN_PASSWORD_LENGTH) {
    return 'Пароль должен содержать минимум 8 символов';
  }
  if (value.length > MAX_PASSWORD_LENGTH) {
    return 'Пароль должен содержать не более 64 символов';
  }
  if (/\s/.test(value)) {
    return 'Пароль не должен содержать пробелы';
  }
  if (!/[a-z]/.test(value)) {
    return 'Пароль должен содержать минимум 1 строчную букву (a-z)';
  }
  if (!/[A-Z]/.test(value)) {
    return 'Пароль должен содержать минимум 1 заглавную букву (A-Z)';
  }
  if (!/\d/.test(value)) {
    return 'Пароль должен содержать минимум 1 цифру';
  }
  if (!/[^A-Za-z0-9]/.test(value)) {
    return 'Пароль должен содержать минимум 1 спецсимвол';
  }

  return null;
}

module.exports = {
  validatePassword,
};
