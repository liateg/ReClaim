import 'package:dio/dio.dart';

class NotificationModel {
  final int id;
  final String title;
  final String message;
  final bool read;
  final DateTime createdAt;

  NotificationModel({
    required this.id,
    required this.title,
    required this.message,
    required this.read,
    required this.createdAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'],
      title: json['title'],
      message: json['message'],
      read: json['read'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}

class NotificationService {
  final Dio _dio;
  NotificationService(this._dio);

  Future<List<NotificationModel>> getNotifications() async {
    try {
      final response = await _dio.get('/notifications');
      return (response.data['notifications'] as List)
          .map((n) => NotificationModel.fromJson(n))
          .toList();
    } catch (e) {
      return [];
    }
  }

  Future<void> markAsRead(int id) async {
    await _dio.patch('/notifications/$id/read');
  }
}
