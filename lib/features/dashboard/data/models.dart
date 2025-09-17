class UserProfile {
  final int id;
  final String name;
  final String? address;
  final String? email;
  final String? phone;
  final String? occupation;
  UserProfile({
    required this.id,
    required this.name,
    this.address,
    this.email,
    this.phone,
    this.occupation,
  });
  factory UserProfile.fromJson(Map<String,dynamic> j) => UserProfile(
    id: j['id'] as int,
    name: j['name'] as String,
    address: j['address'] as String?,
    email: j['email'] as String?,
    phone: j['phone'] as String?,
    occupation: j['occupation'] as String?,
  );
}

class CatatanKeuangan {
  final int id;
  final String fileName;
  final int amount;
  final DateTime? date;
  CatatanKeuangan({required this.id, required this.fileName, required this.amount, this.date});
  factory CatatanKeuangan.fromJson(Map<String,dynamic> j) => CatatanKeuangan(
    id: j['id'] as int,
    fileName: j['file_name'] as String,
    amount: (j['amount'] as num).toInt(),
    date: j['date'] != null && (j['date'] as String).isNotEmpty ? DateTime.tryParse(j['date'] as String) : null,
  );
}

class UploadItem {
  final int id;
  final String? path;
  final String? storePath;
  final int? catatanId;
  UploadItem({required this.id, this.path, this.storePath, this.catatanId});
  factory UploadItem.fromJson(Map<String,dynamic> j) => UploadItem(
    id: (j['id'] as num).toInt(),
    path: j['path'] as String?,
    storePath: j['store_path'] as String?,
    catatanId: j['catatan_id'] == null ? null : (j['catatan_id'] as num).toInt(),
  );
}

class RevenueMonth {
  final String month; // YYYY-MM
  final int total;
  RevenueMonth({required this.month, required this.total});
  factory RevenueMonth.fromJson(Map<String,dynamic> j) => RevenueMonth(
    month: j['month'] as String,
    total: (j['total'] as num).toInt(),
  );
}
