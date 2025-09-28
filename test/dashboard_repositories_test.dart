import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import 'package:fotonota/features/dashboard/data/dashboard_repositories.dart';
import 'package:fotonota/features/dashboard/data/models.dart';
import 'package:fotonota/core/services/api_client.dart';
import 'helpers/mock_adapter.dart';
import 'package:fotonota/core/errors/api_exception.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues({});

  group('Dashboard Repositories', () {
    late MockAdapter adapter;

    setUp(() {
      adapter = MockAdapter();
      ApiClient.instance.dio.options.baseUrl = 'http://test/';
      ApiClient.instance.dio.httpClientAdapter = adapter;
    });

    test('Profile get returns value', () async {
      adapter.on('GET', '/profile', (_) async => adapter.json({'id':1,'name':'John'}));
      final repo = ProfileRepository();
      final p = await repo.getProfile();
      expect(p, isNotNull);
      expect(p!.name, 'John');
    });

    test('List catatan limited to 2', () async {
      adapter.on('GET', '/catatan', (_) async => adapter.json([
        {'id':1,'file_name':'f1','amount':10},
        {'id':2,'file_name':'f2','amount':20},
        {'id':3,'file_name':'f3','amount':30},
      ]));
      final repo = CatatanRepository();
      final list = await repo.listCatatan(limit:2);
      expect(list.length, 2);
      expect(list.first.fileName, 'f1');
    });

    test('Revenue mapping', () async {
      adapter.on('GET', '/catatan/revenue', (_) async => adapter.json([
        {'month':'2025-09','total':123},
        {'month':'2025-08','total':90},
      ]));
      final repo = CatatanRepository();
      final rev = await repo.revenue();
      expect(rev, isA<List<RevenueMonth>>());
      expect(rev.first.month, '2025-09');
    });

    test('Upload list returns items', () async {
      adapter.on('GET', '/uploads', (_) async => adapter.json([
        {'id':5,'path':'/tmp/a.png'},
      ]));
      final repo = UploadRepository();
      final up = await repo.listUploads(limit:5);
      expect(up.length, 1);
  expect(up.first.id, 5);
  expect(up.first.path, isNotNull);
    });

    test('Upload image returns item', () async {
      // Create temp file
      final file = File('${Directory.systemTemp.path}/upload_test.txt');
      await file.writeAsString('dummy');
      adapter.on('POST', '/uploads', (_) async => adapter.json({'id':9,'path':'/p/x.png'}));
      final repo = UploadRepository();
      final item = await repo.uploadImage(filePath: file.path);
      expect(item.id, 9);
    });

    test('Repository error wrapped', () async {
      adapter.on('GET', '/catatan/total', (_) async => adapter.json({'message':'Boom'}, status:500));
      final repo = CatatanRepository();
      expect(()=> repo.totalAmount(), throwsA(isA<ApiException>()));
    });
  });
}
