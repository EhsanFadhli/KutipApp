
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:myapp/add_payment_page.dart' show AddPaymentPage;
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

  Future<void> _cashHanded() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> recentPaymentsJson = prefs.getStringList('payments') ?? [];
    final List<String> previousPaymentsJson = prefs.getStringList('previous_payments') ?? [];

    previousPaymentsJson.addAll(recentPaymentsJson);

    await prefs.setStringList('previous_payments', previousPaymentsJson);
    await prefs.remove('payments');

    _loadPayments();
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
              icon: const Icon(Icons.history, color: kSubtleText),
              onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const PreviousPaymentsPage()),
                  )),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 80.0), // Add padding for FAB
        children: <Widget>[
          TotalCashCard(totalCash: _totalCashCollected, onCashHanded: _cashHanded),
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
  double _savedFee = 0.0;
  bool _isFeeChanged = false;

  @override
  void initState() {
    super.initState();
    _loadFee();
    _feeController.addListener(_onFeeChanged);
  }

  void _onFeeChanged() {
    final currentFee = double.tryParse(_feeController.text);
    bool hasChanged;

    if (currentFee == null) {
      hasChanged = !(_feeController.text.isEmpty && _savedFee == 0.0);
    } else {
      final roundedCurrent = (currentFee * 100).round();
      final roundedSaved = (_savedFee * 100).round();
      hasChanged = roundedCurrent != roundedSaved;
    }

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
      _savedFee = fee;
      _feeController.text = fee.toStringAsFixed(2);
      _isFeeChanged = false;
    });
  }

  Future<void> _saveFee() async {
    final prefs = await SharedPreferences.getInstance();
    final double? fee = double.tryParse(_feeController.text);
    if (fee != null) {
      await prefs.setDouble(_storageKey, fee);
      setState(() {
        _savedFee = fee;
        _isFeeChanged = false;
      });
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
                  inputFormatters: [DecimalTextInputFormatter()],
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
                onPressed: _isFeeChanged ? _saveFee : null,
                icon: const Icon(Icons.check_circle),
                label: const Text('Set'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: kPrimaryBlue,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: kPrimaryBlue.withOpacity(0.5),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
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
