import 'dart:typed_data';

import 'package:csv/csv.dart';
import 'package:file_saver/file_saver.dart';
import 'package:flutter/material.dart';
import 'package:kutip/payment_model.dart';
import 'package:kutip/ui/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:developer' as developer;

class PreviousPaymentsPage extends StatefulWidget {
  const PreviousPaymentsPage({super.key});

  @override
  State<PreviousPaymentsPage> createState() => _PreviousPaymentsPageState();
}

class _PreviousPaymentsPageState extends State<PreviousPaymentsPage> {
  List<Payment> _payments = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPreviousPayments();
  }

  Future<void> _loadPreviousPayments() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> paymentsJson =
        prefs.getStringList('previous_payments') ?? [];

    final List<Payment> loadedPayments = [];
    for (final p in paymentsJson) {
      try {
        loadedPayments.add(Payment.fromJson(p));
      } catch (e, s) {
        developer.log(
          'Failed to parse payment, skipping.',
          name: 'PreviousPaymentsPage',
          error: e,
          stackTrace: s,
          level: 1000, // SEVERE
        );
      }
    }

    loadedPayments.sort(
      (a, b) => b.createdAt.compareTo(a.createdAt),
    ); // Sort by most recent

    if (mounted) {
      setState(() {
        _payments = loadedPayments;
        _isLoading = false;
      });
    }
  }

  void _showPaymentDetailsModal(BuildContext context, Payment payment) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => PaymentDetailsContent(payment: payment),
    );
  }

  Future<void> _exportToCSV() async {
    if (_payments.isEmpty) {
      if (!mounted) return;
      showFailureSnackBar(context, 'No payments to export.');
      return;
    }

    String formatAmount(double amount) {
      String formatted = amount.toStringAsFixed(2);
      if (formatted == '-0.00') {
        return '0.00';
      }
      return formatted;
    }

    final List<List<dynamic>> rows = [];
    // Add headers
    rows.add([
      'Name',
      'Phone',
      'Block',
      'Unit',
      'Amount to Pay',
      'Amount Received',
      'Balance',
      'Date',
      'From Month',
      'Until Month',
      'From Year',
      'Until Year',
      'Notes',
    ]);

    // Add data rows
    for (final payment in _payments) {
      rows.add([
        payment.name,
        payment.phone,
        payment.block,
        payment.unit,
        formatAmount(payment.amountToPay),
        formatAmount(payment.amountReceived),
        formatAmount(payment.balance),
        payment.createdAt.toIso8601String(),
        payment.fromMonth,
        payment.untilMonth,
        payment.fromYear,
        payment.untilYear,
        payment.notes,
      ]);
    }

    final String csv = const ListToCsvConverter().convert(rows);
    final Uint8List bytes = Uint8List.fromList(csv.codeUnits);

    try {
      final String baseName = 'kutip-payments-${DateTime.now().toIso8601String()}';
      final String? path = await FileSaver.instance.saveAs(
        name: baseName,
        bytes: bytes,
        fileExtension: 'csv',
        mimeType: MimeType.csv,
      );

      if (path != null && mounted) {
        showSuccessSnackBar(context, 'Exported to $path');
      } else if (mounted) {
        showFailureSnackBar(context, 'Save operation cancelled.');
      }
    } catch (e) {
      if (!mounted) return;
      showFailureSnackBar(context, 'Error exporting file: $e');
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackground,
      appBar: AppBar(
        title: const Text(
          'Previous Payments',
          style: TextStyle(color: kPrimaryText),
        ),
        backgroundColor: kBackground,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: kPrimaryText),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: IconButton(
              icon: const Icon(Icons.ios_share, color: kPrimaryText),
              onPressed: _exportToCSV,
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedCard(
          padding: const EdgeInsets.all(20),
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _payments.isEmpty
                        ? const Center(
                            child: Padding(
                              padding: EdgeInsets.symmetric(vertical: 32.0),
                              child: Text(
                                'No archived payments found.',
                                style: TextStyle(
                                  color: kSubtleText,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          )
                        : Expanded(
                            child: ListView.builder(
                              padding: EdgeInsets.zero,
                              itemCount: _payments.length,
                              itemBuilder: (context, index) {
                                final payment = _payments[index];
                                return InkWell(
                                  onTap: () => _showPaymentDetailsModal(
                                    context,
                                    payment,
                                  ),
                                  child: RecentPaymentTile(payment: payment),
                                );
                              },
                            ),
                          ),
                  ],
                ),
        ),
      ),
    );
  }
}
