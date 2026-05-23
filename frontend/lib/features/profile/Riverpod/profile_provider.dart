import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:frontend/features/items/Riverpod/items_provider.dart';
import 'package:frontend/features/profile/data/models/profile_model.dart';
import 'package:frontend/features/profile/data/profile_service.dart';
import 'package:frontend/features/reports/Riverpod/report_provider.dart';

class ProfileOverview {
  final ProfileModel profile;
  final int postsCount;
  final int reportsCount;

  const ProfileOverview({
    required this.profile,
    required this.postsCount,
    required this.reportsCount,
  });
}

final profileServiceProvider = Provider<ProfileService>((ref) {
  return ProfileService();
});

final profileOverviewProvider = FutureProvider<ProfileOverview>((ref) async {
  final profileService = ref.read(profileServiceProvider);
  final itemsService = ref.read(itemsServiceProvider);
  final reportsService = ref.read(reportServiceProvider);

  final profileJson = await profileService.getCurrentProfile();
  final profile = ProfileModel.fromJson({
    'id': profileJson['id'],
    'email': profileJson['email'],
    'name': profileJson['full_name'] ?? profileJson['name'] ?? '',
    'createdAt': profileJson['createdAt'] ?? profileJson['created_at'],
    'updatedAt': profileJson['updatedAt'] ?? profileJson['updated_at'],
  });

  final items = await itemsService.getItems();
  final reports = await reportsService.getMyReports();
  final postsCount = items.where((item) => item.postedBy == profile.id).length;

  return ProfileOverview(
    profile: profile,
    postsCount: postsCount,
    reportsCount: reports.length,
  );
});
