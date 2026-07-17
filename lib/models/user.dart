class User {
  final String self;
  final int? dni;
  final String email;
  final String firstName;
  final String lastName;
  final String countryCode;
  final String dateOfBirth;
  final String gender;
  final int credits;

  const User({
    required this.self,
    this.dni,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.countryCode,
    required this.dateOfBirth,
    required this.gender,
    required this.credits,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      self: json['self'] as String,
      dni: json['dni'] as int?,
      email: json['email'] as String,
      firstName: json['firstName'] as String,
      lastName: json['lastName'] as String,
      countryCode: json['countryCode'] as String? ?? '',
      dateOfBirth: json['dateOfBirth'] as String? ?? '',
      gender: json['gender'] as String? ?? '',
      credits: (json['credits'] as num?)?.toInt() ?? 0,
    );
  }

  String get fullName => '$firstName $lastName';
}
