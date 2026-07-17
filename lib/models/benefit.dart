class Benefit {
  final String self;
  final String name;
  final String title;
  final String description;
  final String? cardImageUrl;
  final String? detailImageUrl;
  final String? bannerIconUrl;
  final String? termsUrl;
  final bool? active;

  const Benefit({
    required this.self,
    required this.name,
    required this.title,
    required this.description,
    this.cardImageUrl,
    this.detailImageUrl,
    this.bannerIconUrl,
    this.termsUrl,
    this.active,
  });

  factory Benefit.fromJson(Map<String, dynamic> json) {
    return Benefit(
      self: json['self'] as String,
      name: json['name'] as String? ?? '',
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      cardImageUrl: json['cardImageUrl'] as String?,
      detailImageUrl: json['detailImageUrl'] as String?,
      bannerIconUrl: json['bannerIconUrl'] as String?,
      termsUrl: json['termsUrl'] as String?,
      active: json['active'] as bool?,
    );
  }
}
