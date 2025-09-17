import '../../../core/services/api_client.dart';

class ReportService {
  final _dio = ApiClient.instance.dio;

  Future<List<Map<String, dynamic>>> fetchReports() async {
    final res = await _dio.get('/reports');
    return (res.data as List).cast<Map<String, dynamic>>();
  }
}
