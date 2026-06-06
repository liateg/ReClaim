/// Lightweight category model with the id<->name mapping used by item APIs.
class CategoryModel {
  final int id;
  final String name;

  const CategoryModel({required this.id, required this.name});

  static const Map<int, String> idToName = {
    1: 'Electronics',
    2: 'Accessories',
    3: 'Clothing',
  };

  static const Map<String, int> nameToId = {
    'Electronics': 1,
    'Accessories': 2,
    'Clothing': 3,
  };

  /// All known categories.
  static List<CategoryModel> get all => idToName.entries
      .map((e) => CategoryModel(id: e.key, name: e.value))
      .toList();

  /// Resolves a category name from an id, defaulting to `Other`.
  static String nameFromId(dynamic categoryId) {
    final id = categoryId is int ? categoryId : int.tryParse('$categoryId');
    return idToName[id] ?? 'Other';
  }

  /// Resolves a category id from a name, or null when unknown.
  static int? idFromName(String? name) {
    if (name == null || name.isEmpty) return null;
    return nameToId[name];
  }

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    final rawId = json['id'] ?? json['categoryId'] ?? json['category_id'];
    final id = rawId is int ? rawId : int.tryParse('$rawId') ?? 0;
    final name = json['name']?.toString() ?? nameFromId(id);
    return CategoryModel(id: id, name: name);
  }

  Map<String, dynamic> toJson() => {'id': id, 'name': name};

  @override
  bool operator ==(Object other) =>
      other is CategoryModel && other.id == id && other.name == name;

  @override
  int get hashCode => Object.hash(id, name);
}
