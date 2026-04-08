class Avis {
  final int id;
  final double rating;
  final String comment;
  final String createdAt;
  final String userName;
  final int? userId;
  final int professionalId;

  Avis({
    required this.id,
    required this.rating,
    required this.comment,
    required this.createdAt,
    required this.userName,
    this.userId,
    required this.professionalId,
  });

  factory Avis.fromJson(Map<String, dynamic> json) {
    return Avis(
      id: json['id'] as int,
      rating: (json['rating'] as num).toDouble(),
      comment: json['comment'] as String? ?? '',
      createdAt: json['createdAt'] as String? ?? '',
      userName: json['userName'] as String? ?? 'Anonyme',
      userId: json['userId'] as int?,
      professionalId: json['professionalId'] as int,
    );
  }
}
