final _emailRegex = RegExp(
  r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$",
);

bool isValidEmail(String value) {
  final trimmed = value.trim();
  return trimmed.isNotEmpty && _emailRegex.hasMatch(trimmed);
}

bool passwordHasLength(String value) => value.length >= 8 && value.length <= 64;

bool passwordHasNumber(String value) => RegExp(r'[0-9]').hasMatch(value);

bool passwordHasLetters(String value) =>
    RegExp(r'[a-z]').hasMatch(value) && RegExp(r'[A-Z]').hasMatch(value);

bool isValidPassword(String value) =>
    passwordHasLength(value) &&
    passwordHasNumber(value) &&
    passwordHasLetters(value);

bool isValidRepeatPassword(String value, String password) =>
    value.isNotEmpty && value == password;

bool isValidCode(String value, {int digits = 6}) =>
    value.length == digits && RegExp(r'^[0-9]+$').hasMatch(value);

bool isValidDni(String value) =>
    value.length == 8 && RegExp(r'^[1-9][0-9]+$').hasMatch(value);
