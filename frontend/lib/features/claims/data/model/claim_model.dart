import '../../enum/claim_status.dart';

class Claim {
  final String id;
  final String title;
  final String description;
  final ClaimStatus status;
  final String category;
  final String location;
  final String? imageUrl;
  final DateTime date;

  Claim({
    required this.id,
    required this.title,
    required this.description,
    required this.status,
    required this.category,
    required this.location,
    this.imageUrl,
    required this.date,
  });

  Claim copyWith({
    String? id,
    String? title,
    String? description,
    ClaimStatus? status,
    String? category,
    String? location,
    String? imageUrl,
    DateTime? date,
  }) {
    return Claim(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      status: status ?? this.status,
      category: category ?? this.category,
      location: location ?? this.location,
      imageUrl: imageUrl ?? this.imageUrl,
      date: date ?? this.date,
    );
  }

  factory Claim.fromJson(Map<String, dynamic> json) {
    return Claim(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? 'Untitled',
      description: json['description'] as String? ?? '',
      status: _parseStatus(json['status'] as String?),
      category: json['category'] as String? ?? 'Others',
      location: json['location'] as String? ?? 'Unknown',
      imageUrl: json['imageUrl'] as String?,
      date: json['date'] != null ? DateTime.parse(json['date'] as String) : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'status': status.name,
      'category': category,
      'location': location,
      'imageUrl': imageUrl,
      'date': date.toIso8601String(),
    };
  }

  static ClaimStatus _parseStatus(String? status) {
    if (status == null) return ClaimStatus.pending;
    switch (status.toLowerCase()) {
      case 'approved':
        return ClaimStatus.approved;
      case 'rejected':
        return ClaimStatus.rejected;
      case 'pending':
      default:
        return ClaimStatus.pending;
    }
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Claim &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          title == other.title &&
          description == other.description &&
          status == other.status &&
          category == other.category &&
          location == other.location &&
          imageUrl == other.imageUrl &&
          date == other.date;

  @override
  int get hashCode =>
      id.hashCode ^
      title.hashCode ^
      description.hashCode ^
      status.hashCode ^
      category.hashCode ^
      location.hashCode ^
      imageUrl.hashCode ^
      date.hashCode;
}