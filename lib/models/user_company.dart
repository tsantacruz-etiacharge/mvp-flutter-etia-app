class UserCompany {
  final String company;
  final String name;
  final String? imageUrl;
  final String? iconUrl;

  const UserCompany({
    required this.company,
    required this.name,
    this.imageUrl,
    this.iconUrl,
  });

  factory UserCompany.fromJson(Map<String, dynamic> json) {
    return UserCompany(
      company: json['company'] as String,
      name: json['name'] as String,
      imageUrl: json['imageUrl'] as String?,
      iconUrl: json['iconUrl'] as String?,
    );
  }
}
