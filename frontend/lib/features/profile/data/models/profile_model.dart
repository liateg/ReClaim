class ProfileModel {
  final int id;
  final String email;
  final String name;
  final String? phone;
  final String? avatarUrl;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  ProfileModel({
    required this.id,
    required this.email,
    required this.name,
    this.phone,
    this.avatarUrl,
    this.createdAt,
    this.updatedAt,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    DateTime? parse(String? s) {
      if (s == null) return null;
      try {
        return DateTime.parse(s);
      } catch (_) {
        return null;
      }
    }

    int parseInt(dynamic v) {
      if (v == null) throw FormatException('Missing integer value');
      if (v is int) return v;
      final s = v.toString();
      return int.parse(s);
    }

    final idVal = json['id'] ?? json['Id'];
    final createdVal = json['createdAt'] ?? json['created_at'];
    final updatedVal = json['updatedAt'] ?? json['updated_at'];

    return ProfileModel(
      id: parseInt(idVal),
      email: (json['email'] ?? '').toString(),
      name: (json['name'] ?? json['full_name'] ?? '').toString(),
      phone: (json['phone'] ?? null) as String?,
      avatarUrl: (json['avatarUrl'] ?? json['avatar_url']) as String?,
      createdAt: parse(createdVal?.toString()),
      updatedAt: parse(updatedVal?.toString()),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'email': email,
        'name': name,
        'phone': phone,
        'avatar_url': avatarUrl,
        'created_at': createdAt?.toIso8601String(),
        'updated_at': updatedAt?.toIso8601String(),
      };
}
