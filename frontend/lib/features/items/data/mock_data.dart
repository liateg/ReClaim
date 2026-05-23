import 'models/item_model.dart';

final List<Item> mockItems = [
  Item(
    id: '1',
    title: 'Silver MacBook Air',
    location: 'Central Library, 2nd Floor',
    description: 'Found near the reading area with a gray sleeve.',
    category: 'Electronics',
    status: 'available',
    dateFound: DateTime(2026, 5, 8),
    verificationQuestion: 'What sticker is on the laptop cover?',
    verificationAnswer: 'Blue star',
    imageUrl: 'https://picsum.photos/id/180/1200/800',
  ),
  Item(
    id: '2',
    title: 'Black Backpack',
    location: 'Science Building Lobby',
    description: 'Backpack with notebooks and a water bottle.',
    category: 'Accessories',
    status: 'pending',
    dateFound: DateTime(2026, 5, 9),
    verificationQuestion: 'What brand is the backpack?',
    verificationAnswer: 'JanSport',
    imageUrl: 'https://picsum.photos/id/1062/1200/800',
  ),
  Item(
    id: '3',
    title: 'Gold Bracelet',
    location: 'Cafeteria',
    description: 'Small gold bracelet found near table 8.',
    category: 'Accessories',
    status: 'available',
    dateFound: DateTime(2026, 5, 10),
    verificationQuestion: 'What symbol is engraved on it?',
    verificationAnswer: 'Heart',
    imageUrl: 'https://picsum.photos/id/791/1200/800',
  ),
];

void addMockItem({
  required String title,
  required String location,
  required String description,
  required String verificationQuestion,
  required String verificationAnswer,
  String category = 'Other',
  String imageUrl = 'https://picsum.photos/1200/800',
}) {
  mockItems.insert(
    0,
    Item(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      location: location,
      description: description,
      category: category,
      status: 'available',
      dateFound: DateTime.now(),
      verificationQuestion: verificationQuestion,
      verificationAnswer: verificationAnswer,
      imageUrl: imageUrl,
    ),
  );
}

bool updateMockItem({
  required String id,
  required String title,
  required String location,
  String? description,
  String? category,
  String? verificationQuestion,
  String? verificationAnswer,
  String? status,
  String? imageUrl,
}) {
  final index = mockItems.indexWhere((item) => item.id == id);
  if (index == -1) return false;

  mockItems[index] = mockItems[index].copyWith(
    title: title,
    location: location,
    description: description,
    category: category,
    verificationQuestion: verificationQuestion,
    verificationAnswer: verificationAnswer,
    status: status,
    imageUrl: imageUrl,
  );
  return true;
}

bool removeMockItem(String id) {
  final before = mockItems.length;
  mockItems.removeWhere((item) => item.id == id);
  return mockItems.length < before;
}

bool submitClaimForItem({required String id, required String answer}) {
  final index = mockItems.indexWhere((item) => item.id == id);
  if (index == -1) return false;
  final expected = mockItems[index].verificationAnswer;
  if (expected.trim().toLowerCase() != answer.trim().toLowerCase()) {
    return false;
  }
  mockItems[index] = mockItems[index].copyWith(status: 'pending');
  return true;
}