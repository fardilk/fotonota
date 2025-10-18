import 'dart:math';
import 'dashboard_repositories.dart';
import 'models.dart';

class MockProfileRepository extends ProfileRepository {
  MockProfileRepository() : super();
  @override
  Future<UserProfile?> getProfile() async => UserProfile(id: 1, name: 'Demo User');
  @override
  Future<int> createProfile({required String name, String? address, String? email, String? phone, String? occupation}) async => 1;
}

class MockCatatanRepository extends CatatanRepository {
  MockCatatanRepository() : super();
  @override
  Future<List<CatatanKeuangan>> listCatatan({int limit = 10}) async {
    final now = DateTime.now();
    final list = <CatatanKeuangan>[
      CatatanKeuangan(id: 1, fileName: 'receipt_small.jpg', amount: 15000, date: now.subtract(const Duration(days: 1))),
      CatatanKeuangan(id: 2, fileName: 'receipt_big.jpg', amount: 250000, date: now.subtract(const Duration(days: 2))),
      CatatanKeuangan(id: 3, fileName: 'receipt_discount.png', amount: 9900, date: now.subtract(const Duration(days: 3))),
      CatatanKeuangan(id: 4, fileName: 'receipt_long_text.png', amount: 1234567, date: now.subtract(const Duration(days: 7))),
    ];
    return list.take(limit).toList();
  }
  @override
  Future<int> createCatatan({required String fileName, required int amount, DateTime? date}) async => Random().nextInt(10000) + 1;
  @override
  Future<int> totalAmount() async => 250000 + 15000 + 9900 + 1234567;
  @override
  Future<List<RevenueMonth>> revenue() async {
    return [
      RevenueMonth(month: '2025-06', total: 230000),
      RevenueMonth(month: '2025-07', total: 540000),
      RevenueMonth(month: '2025-08', total: 330000),
      RevenueMonth(month: '2025-09', total: 900000),
      RevenueMonth(month: '2025-10', total: 1200000),
    ];
  }
}

class MockUploadRepository extends UploadRepository {
  MockUploadRepository() : super();
  @override
  Future<List<UploadItem>> listUploads({int limit = 10}) async {
    return [
      UploadItem(id: 1, path: '/tmp/receipt_small.jpg'),
      UploadItem(id: 2, path: '/tmp/receipt_big.jpg'),
    ];
  }
  @override
  Future<UploadItem> uploadImage({required String filePath, String folder = 'keu', int? amount, int? keuanganId}) async {
    // Fake a small delay
    return UploadItem(id: Random().nextInt(1000) + 1, path: filePath, catatanId: keuanganId);
  }
}
