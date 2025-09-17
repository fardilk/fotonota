import 'package:dio/dio.dart';
import '../../../core/services/api_client.dart';
import '../../../core/utils/prefs_helper.dart';
import '../../../core/errors/api_exception.dart';
import 'models.dart';

// Helper to inject bearer token quickly; in future move to interceptor.
Future<Options> _authOptions() async {
  final t = await PrefsHelper.getToken();
  return Options(headers: {'Authorization': 'Bearer $t'});
}

class ProfileRepository {
  final _dio = ApiClient.instance.dio;
  Future<UserProfile?> getProfile() async {
    try {
      final res = await _dio.get('/profile', options: await _authOptions());
      if (res.data == null) return null;
      return UserProfile.fromJson(res.data as Map<String,dynamic>);
    } on DioException catch (e) {
      throw _toApi(e);
    }
  }
  Future<int> createProfile({required String name, String? address, String? email, String? phone, String? occupation}) async {
    try {
      final res = await _dio.post('/profile', data: {
        'name': name,
        if (address != null && address.isNotEmpty) 'address': address,
        if (email != null && email.isNotEmpty) 'email': email,
        if (phone != null && phone.isNotEmpty) 'phone': phone,
        if (occupation != null && occupation.isNotEmpty) 'occupation': occupation,
      }, options: await _authOptions());
      return (res.data as Map<String,dynamic>)['id'] as int;
    } on DioException catch (e) { throw _toApi(e); }
  }
}

class CatatanRepository {
  final _dio = ApiClient.instance.dio;
  Future<List<CatatanKeuangan>> listCatatan({int limit = 10}) async {
    try {
      final res = await _dio.get('/catatan', options: await _authOptions());
      final list = (res.data as List).cast<Map>();
      return list.take(limit).map((e) => CatatanKeuangan.fromJson(e.cast<String,dynamic>())).toList();
    } on DioException catch (e) { throw _toApi(e); }
  }
  Future<int> createCatatan({required String fileName, required int amount, DateTime? date}) async {
    try {
      final res = await _dio.post('/catatan', data: {
        'file_name': fileName,
        'amount': amount,
        if (date != null) 'date': date.toUtc().toIso8601String(),
      }, options: await _authOptions());
      return (res.data as Map<String,dynamic>)['id'] as int;
    } on DioException catch (e) { throw _toApi(e); }
  }
  Future<int> totalAmount() async {
    try {
      final res = await _dio.get('/catatan/total', options: await _authOptions());
      return (res.data as Map<String,dynamic>)['total'] as int;
    } on DioException catch (e) { throw _toApi(e); }
  }
  Future<List<RevenueMonth>> revenue() async {
    try {
      final res = await _dio.get('/catatan/revenue', options: await _authOptions());
      final list = (res.data as List).cast<Map>();
      return list.map((e) => RevenueMonth.fromJson(e.cast<String,dynamic>())).toList();
    } on DioException catch (e) { throw _toApi(e); }
  }
}

class UploadRepository {
  final _dio = ApiClient.instance.dio;
  Future<List<UploadItem>> listUploads({int limit = 10}) async {
    try {
      final res = await _dio.get('/uploads', options: await _authOptions());
      final list = (res.data as List).cast<Map>();
      return list.take(limit).map((e) => UploadItem.fromJson(e.cast<String,dynamic>())).toList();
    } on DioException catch (e) { throw _toApi(e); }
  }
  Future<UploadItem> uploadImage({required String filePath, String folder = 'keu', int? amount, int? keuanganId}) async {
    try {
      final fileName = filePath.split('/').last;
      final form = FormData.fromMap({
        'file': await MultipartFile.fromFile(filePath, filename: fileName),
        'folder': folder,
        if (amount != null) 'amount': amount.toString(),
        if (keuanganId != null) 'keuangan_id': keuanganId.toString(),
      });
      final res = await _dio.post('/uploads', data: form, options: await _authOptions());
      return UploadItem.fromJson((res.data as Map).cast<String,dynamic>());
    } on DioException catch (e) { throw _toApi(e); }
  }
}

ApiException _toApi(DioException e) {
  final status = e.response?.statusCode;
  dynamic data = e.response?.data;
  String message;
  if (data is Map && data['message'] is String) {
    message = data['message'] as String;
  } else {
    message = mapStatusToMessage(status);
  }
  return ApiException(statusCode: status, message: message, data: data);
}
