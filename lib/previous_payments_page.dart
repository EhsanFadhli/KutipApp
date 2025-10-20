import 'package:flutter/material.dart';
import 'package:myapp/payment_model.dart';
import 'package:myapp/ui/widgets.dart';
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
