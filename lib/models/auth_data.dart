class AuthData {
  final int authID;
  final String email;
  final String role;
  final String user;
  final String company;

  const AuthData({
    required this.authID,
    required this.email,
    required this.role,
    required this.user,
    required this.company,
  });

  factory AuthData.fromJwt(Map<String, dynamic> payload) {
    return AuthData(
      authID: (payload['authID'] as num?)?.toInt() ?? 0,
      email: payload['email'] as String? ?? '',
      role: payload['role'] as String? ?? '',
      user: payload['user'] as String? ?? '',
      company: payload['company'] as String? ?? '',
    );
  }
}
