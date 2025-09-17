import '../../../core/services/api_client.dart';

class DashboardService {
  final _dio = ApiClient.instance.dio;

  Future<Map<String, dynamic>> fetchSummary() async {
    final res = await _dio.get('/dashboard/summary');
    return res.data as Map<String, dynamic>;
  }
}
