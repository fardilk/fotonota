import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dashboard_repositories.dart';
import 'models.dart';

// Repositories
final profileRepoProvider = Provider((ref) => ProfileRepository());
final catatanRepoProvider = Provider((ref) => CatatanRepository());
final uploadRepoProvider = Provider((ref) => UploadRepository());

// Refresh notifiers
class _RefreshToken extends StateNotifier<int> {
  _RefreshToken(): super(0);
  void bump() => state++;
}
final dashboardRefreshProvider = StateNotifierProvider<_RefreshToken,int>((ref) => _RefreshToken());

// Profile provider
final profileProvider = FutureProvider<UserProfile?>((ref) async {
  ref.watch(dashboardRefreshProvider); // refetch when bumped
  final repo = ref.watch(profileRepoProvider);
  try { return await repo.getProfile(); } catch (_) { return null; }
});

// Totals
final catatanTotalProvider = FutureProvider<int>((ref) async {
  ref.watch(dashboardRefreshProvider);
  final repo = ref.watch(catatanRepoProvider);
  try { return await repo.totalAmount(); } catch (_) { return 0; }
});

final revenueProvider = FutureProvider<List<RevenueMonth>>((ref) async {
  ref.watch(dashboardRefreshProvider);
  final repo = ref.watch(catatanRepoProvider);
  try { return await repo.revenue(); } catch (_) { return <RevenueMonth>[]; }
});

final recentCatatanProvider = FutureProvider<List<CatatanKeuangan>>((ref) async {
  ref.watch(dashboardRefreshProvider);
  final repo = ref.watch(catatanRepoProvider);
  try { return await repo.listCatatan(limit: 5); } catch (_) { return <CatatanKeuangan>[]; }
});

final recentUploadsProvider = FutureProvider<List<UploadItem>>((ref) async {
  ref.watch(dashboardRefreshProvider);
  final repo = ref.watch(uploadRepoProvider);
  try { return await repo.listUploads(limit: 5); } catch (_) { return <UploadItem>[]; }
});
