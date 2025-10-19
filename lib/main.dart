
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:myapp/add_payment_page.dart';
import 'package:myapp/payment_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

// --- Professional Color Palette ---
const Color kPrimaryBlue = Color(0xFF0D63F8);
const Color kAccentRed = Color(0xFFFF4081);
const Color kBackground = Color(0xFF121212);
const Color kCardBackground = Color(0xFF1E1E1E);
const Color kSubtleText = Color(0xFFBDBDBD);
const Color kPrimaryText = Color(0xFFFFFFFF);
const Color kGreenAccent = Color(0xFF69F0AE);

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: kBackground,
        textTheme: Theme.of(context).textTheme.apply(
              bodyColor: kPrimaryText,
              displayColor: kPrimaryText,
              fontFamily: 'Inter', // A clean, modern default
            ),
      ),
      home: const DashboardScreen(),
    );
  }
}

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  List<Payment> _payments = [];
  double _totalCashCollected = 0.0;

  @override
  void initState() {
    super.initState();
    _loadPayments();
  }

  Future<void> _loadPayments() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> paymentsJson = prefs.getStringList('payments') ?? [];
    final List<Payment> payments = paymentsJson.map((p) => Payment.fromJson(p)).toList();
    payments.sort((a, b) => b.createdAt.compareTo(a.createdAt)); // Sort by most recent
    final double totalCash = payments.fold(0.0, (sum, item) => sum + item.amountReceived);

    setState(() {
      _payments = payments;
      _totalCashCollected = totalCash;
    });
  }

  void _navigateToAddPayment() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddPaymentPage()),
    );

    if (result == true) {
      _loadPayments();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: kBackground,
        elevation: 0,
        title: const Row(
          children: [
            Icon(Icons.dashboard_customize, color: kPrimaryBlue),
            SizedBox(width: 12),
            Text(
              'Dashboard',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 24,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
              icon: const Icon(Icons.notifications_active, color: kSubtleText),
              onPressed: () {}),
          IconButton(
              icon: const Icon(Icons.account_circle, color: kSubtleText),
              onPressed: () {}),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: <Widget>[
          TotalCashCard(totalCash: _totalCashCollected),
          const SizedBox(height: 24),
          const MonthlyFeeCard(),
          const SizedBox(height: 24),
          RecentPaymentsSection(payments: _payments),
        ],
      ),
      bottomNavigationBar: BottomAppBar(
        color: kCardBackground,
        elevation: 8,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            IconButton(
                icon: const Icon(Icons.home_filled, color: kSubtleText),
                onPressed: () {}),
            IconButton(
                icon: const Icon(Icons.donut_large, color: kSubtleText),
                onPressed: () {}),
            IconButton(
              icon: const Icon(Icons.add_circle, size: 40, color: kPrimaryBlue),
              onPressed: _navigateToAddPayment,
            ),
            IconButton(
                icon: const Icon(Icons.history_edu, color: kSubtleText),
                onPressed: () {}),
            IconButton(
                icon: const Icon(Icons.settings, color: kSubtleText),
                onPressed: () {}),
          ],
        ),
      ),
    );
  }
}

class ElevatedCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  const ElevatedCard({super.key, required this.child, this.padding});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: kCardBackground,
        borderRadius: BorderRadius.circular(16.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
          BoxShadow(
            color: kPrimaryBlue.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Padding(
        padding: padding ?? const EdgeInsets.all(20.0),
        child: child,
      ),
    );
  }
}

class TotalCashCard extends StatelessWidget {
  final double totalCash;
  const TotalCashCard({super.key, required this.totalCash});

  @override
  Widget build(BuildContext context) {
    final formattedTotal = NumberFormat.currency(locale: 'en_MY', symbol: 'RM').format(totalCash);
    return ElevatedCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.account_balance_wallet, color: kSubtleText, size: 20),
              SizedBox(width: 8),
              Text(
                'Total Cash Collected',
                style: TextStyle(color: kSubtleText, fontSize: 16),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            formattedTotal,
            style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.arrow_upward),
              label: const Text('Cash Handed'),
              style: ElevatedButton.styleFrom(
                backgroundColor: kAccentRed,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class MonthlyFeeCard extends StatefulWidget {
  const MonthlyFeeCard({super.key});

  @override
  State<MonthlyFeeCard> createState() => _MonthlyFeeCardState();
}

class _MonthlyFeeCardState extends State<MonthlyFeeCard> {
  final TextEditingController _feeController = TextEditingController();
  static const String _storageKey = "monthly_fee";

  @override
  void initState() {
    super.initState();
    _loadFee();
  }

  Future<void> _loadFee() async {
    final prefs = await SharedPreferences.getInstance();
    final double fee = prefs.getDouble(_storageKey) ?? 0.0;
    _feeController.text = fee.toStringAsFixed(2);
  }

  Future<void> _saveFee() async {
    final prefs = await SharedPreferences.getInstance();
    final double? fee = double.tryParse(_feeController.text);
    if (fee != null) {
      await prefs.setDouble(_storageKey, fee);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Monthly Fee Saved!')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid amount')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.autorenew, color: kSubtleText, size: 20),
              SizedBox(width: 8),
              Text(
                'Monthly Fee',
                style: TextStyle(color: kSubtleText, fontSize: 16),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              const Text(
                'RM',
                style: TextStyle(
                    fontSize: 32,
                    color: kSubtleText,
                    fontWeight: FontWeight.w500),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: _feeController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[\d.]'))
                  ],
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: kPrimaryText,
                  ),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                    isDense: true,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton.icon(
                onPressed: _saveFee,
                icon: const Icon(Icons.check_circle),
                label: const Text('Set'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: kPrimaryBlue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _feeController.dispose();
    super.dispose();
  }
}

// --- Recent Payments Section ---
class RecentPaymentsSection extends StatelessWidget {
  final List<Payment> payments;
  const RecentPaymentsSection({super.key, required this.payments});

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
    return ElevatedCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Recent Payments',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: kPrimaryText),
          ),
          const SizedBox(height: 16),
          if (payments.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 32.0),
                child: Text(
                  'No payments recorded yet.',
                  style: TextStyle(color: kSubtleText, fontSize: 16),
                ),
              ),
            )
          else
            ListView.builder(
              padding: EdgeInsets.zero,
              itemCount: payments.length,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemBuilder: (context, index) {
                final payment = payments[index];
                return InkWell(
                  onTap: () => _showPaymentDetailsModal(context, payment),
                  child: RecentPaymentTile(payment: payment),
                );
              },
            ),
        ],
      ),
    );
  }
}

class RecentPaymentTile extends StatelessWidget {
  final Payment payment;

  const RecentPaymentTile({super.key, required this.payment});

  String _formatMonthRange() {
    final fromMonthShort = payment.fromMonth.substring(0, 3);
    final untilMonthShort = payment.untilMonth.substring(0, 3);

    if (payment.fromYear == payment.untilYear) {
      if (payment.fromMonth == payment.untilMonth) {
        return '$fromMonthShort ${payment.fromYear}';
      } else {
        return '$fromMonthShort - $untilMonthShort ${payment.untilYear}';
      }
    } else {
      return '$fromMonthShort ${payment.fromYear} - $untilMonthShort ${payment.untilYear}';
    }
  }

  @override
  Widget build(BuildContext context) {
    final formattedAmount = NumberFormat.currency(locale: 'en_MY', symbol: 'RM ').format(payment.amountReceived);
    final blockAndUnit = '${payment.block}-${payment.unit}';
    final initial = payment.name.isNotEmpty ? payment.name[0].toUpperCase() : '';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: kBackground.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: kPrimaryBlue.withOpacity(0.2),
                foregroundColor: kPrimaryText,
                child: Text(initial, style: const TextStyle(fontWeight: FontWeight.bold)),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(payment.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  Text(blockAndUnit, style: const TextStyle(color: kSubtleText, fontSize: 12)),
                ],
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(formattedAmount, style: const TextStyle(color: kGreenAccent, fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text(_formatMonthRange(), style: const TextStyle(color: kSubtleText, fontSize: 12)),
            ],
          )
        ],
      ),
    );
  }
}

class PaymentDetailsContent extends StatelessWidget {
  final Payment payment;
  const PaymentDetailsContent({super.key, required this.payment});

  @override
  Widget build(BuildContext context) {
    final formattedDate = DateFormat('MMMM d, yyyy ''at'' h:mm a').format(payment.createdAt);

    String formatPeriod(Payment p) {
      final from = '${p.fromMonth} ${p.fromYear}';
      final until = '${p.untilMonth} ${p.untilYear}';
      return from == until ? from : '$from - $until';
    }

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: kCardBackground,
        borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Payment Details', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: kPrimaryText)),
              IconButton(
                icon: const Icon(Icons.close, color: kSubtleText),
                onPressed: () => Navigator.of(context).pop(),
              )
            ],
          ),
          const Divider(color: kSubtleText, height: 24),
          _buildDetailRow(icon: Icons.person, label: 'Payer', value: payment.name),
          _buildDetailRow(icon: Icons.home_work, label: 'Unit', value: '${payment.block}-${payment.unit}'),
          _buildDetailRow(icon: Icons.phone, label: 'Phone', value: payment.phone),
          _buildDetailRow(icon: Icons.calendar_today, label: 'Period', value: formatPeriod(payment)),
          const Divider(color: kSubtleText, height: 32),
          _buildAmountRow(label: 'Amount to Pay', amount: payment.amountToPay, color: kPrimaryText),
          _buildAmountRow(label: 'Amount Received', amount: payment.amountReceived, color: kPrimaryText),
          _buildAmountRow(
            label: 'Balance',
            amount: payment.balance,
            color: payment.balance <= 0 ? kGreenAccent : kAccentRed,
            isBold: true,
          ),
          const SizedBox(height: 24),
          Center(child: Text('Paid on: $formattedDate', style: const TextStyle(color: kSubtleText, fontSize: 12)))
        ],
      ),
    );
  }

  Widget _buildDetailRow({required IconData icon, required String label, required String value}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: kSubtleText, size: 18),
          const SizedBox(width: 16),
          Expanded(child: Text(label, style: const TextStyle(color: kSubtleText, fontSize: 16))),
          Text(value, style: const TextStyle(color: kPrimaryText, fontSize: 16, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _buildAmountRow({required String label, required double amount, required Color color, bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: kSubtleText, fontSize: 16)),
          Text(
            NumberFormat.currency(locale: 'en_MY', symbol: 'RM ').format(amount),
            style: TextStyle(
              color: color,
              fontSize: isBold ? 20 : 18,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
