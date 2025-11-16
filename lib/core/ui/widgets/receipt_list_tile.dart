import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../design_tokens.dart';

class ReceiptListTile extends StatelessWidget {
  final String fileName;
  final int amount;
  final DateTime? date;
  const ReceiptListTile({super.key, required this.fileName, required this.amount, this.date});
  @override
  Widget build(BuildContext context) {
    final currency = NumberFormat.decimalPattern();
    final dateFmt = DateFormat('yyyy-MM-dd');
    return ListTile(
      dense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: Spacing.sm),
      leading: const Icon(Icons.receipt_long),
      title: Text(fileName),
      subtitle: Text(currency.format(amount)),
      trailing: date != null ? Text(dateFmt.format(date!)) : null,
    );
  }
}
