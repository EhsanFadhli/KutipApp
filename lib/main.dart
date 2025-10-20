
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:myapp/add_payment_page.dart' show AddPaymentPage;
import 'package:myapp/log_service.dart';
import 'package:myapp/logs_page.dart';
import 'package:myapp/payment_model.dart';
import 'package:myapp/previous_payments_page.dart';
import 'package:myapp/ui/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

  Future<void> _showCashHandedConfirmation() async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return CountdownConfirmationDialog(
          onConfirm: () async {
            final prefs = await SharedPreferences.getInstance();
            final List<String> recentPaymentsJson = prefs.getStringList('payments') ?? [];
            final List<String> previousPaymentsJson = prefs.getStringList('previous_payments') ?? [];

            previousPaymentsJson.addAll(recentPaymentsJson);

            await prefs.setStringList('previous_payments', previousPaymentsJson);
            await prefs.remove('payments');

            final formattedAmount = NumberFormat.currency(locale: 'en_MY', symbol: 'RM').format(_totalCashCollected);
            await LogService.logAction('Archived all recent payments - $formattedAmount');

            _loadPayments();
          },
        );
      },
    );

    if (result == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cash Handed and Payments Archived!')),
      );
    }
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
        title: const Text(
          'Kutip',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 24,
            letterSpacing: 1.5,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.history, color: kSubtleText),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const PreviousPaymentsPage()),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.article, color: kSubtleText),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const LogsPage()),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 80.0), // Add padding for FAB
        children: <Widget>[
          TotalCashCard(totalCash: _totalCashCollected, onCashHanded: _showCashHandedConfirmation),
          const SizedBox(height: 24),
          const MonthlyFeeCard(),
          const SizedBox(height: 24),
          RecentPaymentsSection(payments: _payments),
        ],
      ),
      floatingActionButton: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: kPrimaryBlue.withOpacity(0.5),
              blurRadius: 15,
              spreadRadius: 2,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: FloatingActionButton.extended(
          onPressed: _navigateToAddPayment,
          backgroundColor: kPrimaryBlue,
          foregroundColor: kPrimaryText,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          icon: const Icon(Icons.add, size: 24),
          label: const Text(
            'New Payment',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ),
      ),
    );
  }
}

class TotalCashCard extends StatelessWidget {
  final double totalCash;
  final VoidCallback onCashHanded;
  const TotalCashCard({super.key, required this.totalCash, required this.onCashHanded});

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
              onPressed: onCashHanded,
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
  int _savedFeeInCents = 0;
  bool _isFeeChanged = false;

  @override
  void initState() {
    super.initState();
    _loadFee();
    _feeController.addListener(_onFeeChanged);
  }

  void _onFeeChanged() {
    final text = _feeController.text;
    final digitsOnly = text.replaceAll(RegExp(r'[^0-9]'), '');
    final currentFeeInCents = int.tryParse(digitsOnly) ?? 0;

    final hasChanged = currentFeeInCents != _savedFeeInCents;

    if (hasChanged != _isFeeChanged) {
      setState(() {
        _isFeeChanged = hasChanged;
      });
    }
  }

  Future<void> _loadFee() async {
    final prefs = await SharedPreferences.getInstance();
    final double fee = prefs.getDouble(_storageKey) ?? 0.0;
    setState(() {
      _savedFeeInCents = (fee * 100).round();
      _feeController.text = _formatCurrency(_savedFeeInCents);
      _isFeeChanged = false;
    });
  }

  Future<void> _saveFee() async {
    final prefs = await SharedPreferences.getInstance();
    final text = _feeController.text;
    final digitsOnly = text.replaceAll(RegExp(r'[^0-9]'), '');
    final feeInCents = int.tryParse(digitsOnly) ?? 0;
    final double fee = feeInCents / 100.0;

    await prefs.setDouble(_storageKey, fee);
    final formattedFee = NumberFormat.currency(locale: 'en_MY', symbol: 'RM').format(fee);
    await LogService.logAction('Set monthly fee - $formattedFee');
    setState(() {
      _savedFeeInCents = feeInCents;
      _isFeeChanged = false;
    });
    FocusScope.of(context).unfocus();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Monthly Fee Saved!')),
    );
  }

  String _formatCurrency(int amountInCents) {
    final format = NumberFormat.currency(locale: 'en_MY', symbol: 'RM', decimalDigits: 2);
    return format.format(amountInCents / 100.0);
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
              Expanded(
                child: TextField(
                  controller: _feeController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly, CurrencyInputFormatter()],
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: kPrimaryText,
                    fontFamily: 'Inter',
                  ),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                    isDense: true,
                  ),
                  textAlign: TextAlign.start,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _isFeeChanged ? _saveFee : null,
              icon: const Icon(Icons.check_circle),
              label: const Text('Set'),
              style: ElevatedButton.styleFrom(
                backgroundColor: kPrimaryBlue,
                foregroundColor: Colors.white,
                disabledBackgroundColor: kPrimaryBlue.withOpacity(0.5),
                padding: const EdgeInsets.symmetric(vertical: 16),
                textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _feeController.removeListener(_onFeeChanged);
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

class CountdownConfirmationDialog extends StatefulWidget {
  final Future<void> Function() onConfirm;

  const CountdownConfirmationDialog({super.key, required this.onConfirm});

  @override
  State<CountdownConfirmationDialog> createState() => _CountdownConfirmationDialogState();
}

class _CountdownConfirmationDialogState extends State<CountdownConfirmationDialog> {
  int _countdown = 10;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startCountdown();
  }

  void _startCountdown() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_countdown > 0) {
        setState(() {
          _countdown--;
        });
      } else {
        _timer?.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isConfirmEnabled = _countdown == 0;

    return AlertDialog(
      backgroundColor: kCardBackground,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Text('Confirm Action', style: TextStyle(color: kPrimaryText, fontWeight: FontWeight.bold)),
      content: Text(
        'This will archive all recent payments and reset the collected cash amount. This action cannot be undone.',
        style: TextStyle(color: kSubtleText),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Cancel', style: TextStyle(color: kPrimaryBlue)),
        ),
        ElevatedButton(
          onPressed: isConfirmEnabled
              ? () async {
                  await widget.onConfirm();
                  Navigator.of(context).pop(true);
                }
              : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: kAccentRed,
            disabledBackgroundColor: kAccentRed.withOpacity(0.5),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          child: Text(
            isConfirmEnabled ? 'Confirm' : 'Confirm ($_countdown)',
            style: const TextStyle(color: Colors.white),
          ),
        ),
      ],
    );
  }
}
