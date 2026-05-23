import 'package:dio/dio.dart';
import '../../data/model/claim_model.dart';
import '../../../../core/api/dio_client.dart';

class ClaimService {
  final Dio _dio;

  ClaimService(this._dio);

  Future<List<Claim>> getClaims() async {
    try {
      final response = await _dio.get('/claims');
      if (response.data['claims'] is List) {
        return (response.data['claims'] as List)
            .map((json) => Claim.fromJson(json))
            .toList();
      }
      return [];
    } catch (e) {
      rethrow;
    }
  }

  Future<Claim> getClaimById(String id) async {
    try {
      final response = await _dio.get('/claims/$id');
      return Claim.fromJson(response.data['claim']);
    } catch (e) {
      rethrow;
    }
  }

  Future<Claim> createClaim(Claim claim) async {
    try {
      final response = await _dio.post('/claims', data: claim.toJson());
      return Claim.fromJson(response.data['claim']);
    } catch (e) {
      rethrow;
    }
  }

  Future<Claim> updateClaim(Claim claim) async {
    try {
      final response = await _dio.put('/claims/${claim.id}', data: claim.toJson());
      return Claim.fromJson(response.data['claim']);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteClaim(String id) async {
    try {
      await _dio.delete('/claims/$id');
    } catch (e) {
      rethrow;
    }
  }

  Future<Claim> approveClaim(String id) async {
    try {
      final response = await _dio.patch('/claims/$id/approve');
      return Claim.fromJson(response.data['claim']);
    } catch (e) {
      rethrow;
    }
  }

  Future<String> uploadImage(String filePath) async {
    try {
      final formData = FormData.fromMap({
        'image': await MultipartFile.fromFile(filePath),
      });
      final response = await _dio.post('/upload', data: formData);
      return response.data['imageUrl'];
    } catch (e) {
      rethrow;
    }
  }
}
