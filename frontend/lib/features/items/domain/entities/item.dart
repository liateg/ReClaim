import '../../data/models/item_model.dart';

class Item {
  const Item({
    required this.id,
    required this.title,
    required this.location,
    required this.description,
    required this.category,
    required this.status,
    required this.dateFound,
    required this.verificationQuestion,
    required this.verificationAnswer,
    required this.imageUrl,
  });

  final String id;
  final String title;
  final String location;
  final String description;
  final String category;
  final String status;
  final String dateFound;
  final String verificationQuestion;
  final String verificationAnswer;
  final String imageUrl;

  factory Item.fromMap(Map<String, dynamic> map) {
    return Item(
      id: map[ItemModel.keyId]?.toString() ?? '',
      title: map[ItemModel.keyTitle] as String? ?? '',
      location: map[ItemModel.keyLocation] as String? ?? '',
      description: map[ItemModel.keyDesc] as String? ?? '',
      category: map['category'] as String? ?? 'Other',
      status: map[ItemModel.keyStatus] as String? ?? 'available',
      dateFound: map[ItemModel.keyDate] as String? ?? '',
      verificationQuestion: map[ItemModel.keyQuestion] as String? ?? '',
      verificationAnswer: map[ItemModel.keyAnswer] as String? ?? '',
      imageUrl: map[ItemModel.keyImage] as String? ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      ItemModel.keyId: id,
      ItemModel.keyTitle: title,
      ItemModel.keyLocation: location,
      ItemModel.keyDesc: description,
      'category': category,
      ItemModel.keyStatus: status,
      ItemModel.keyDate: dateFound,
      ItemModel.keyQuestion: verificationQuestion,
      ItemModel.keyAnswer: verificationAnswer,
      ItemModel.keyImage: imageUrl,
    };
  }
}
