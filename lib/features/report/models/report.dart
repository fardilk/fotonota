class Report {
  final String id;
  final DateTime date;
  final double amount;
  final String category;

  Report({required this.id, required this.date, required this.amount, required this.category});

  factory Report.fromJson(Map<String, dynamic> json) => Report(
        id: json['id'].toString(),
        date: DateTime.parse(json['date'] as String),
        amount: (json['amount'] as num).toDouble(),
        category: json['category'] as String,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'date': date.toIso8601String(),
        'amount': amount,
        'category': category,
      };
}
