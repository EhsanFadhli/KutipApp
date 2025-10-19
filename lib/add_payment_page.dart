
import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:myapp/payment_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

// --- Constants from main.dart ---
const Color kBackground = Color(0xFF121212);
const Color kPrimaryText = Color(0xFFFFFFFF);
const Color kCardBackground = Color(0xFF1E1E1E);
const Color kSubtleText = Color(0xFFBDBDBD);
const Color kPrimaryBlue = Color(0xFF0D63F8);
const Color kGreenAccent = Color(0xFF69F0AE);

class AddPaymentPage extends StatefulWidget {
  const AddPaymentPage({super.key});

  @override
  State<AddPaymentPage> createState() => _AddPaymentPageState();
}

class _AddPaymentPageState extends State<AddPaymentPage> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final _nameController = TextEditingController();
  final _unitController = TextEditingController();
  final _phoneController = TextEditingController();
  final _amountReceivedController = TextEditingController();

  // State variables
  String? _selectedBlock = 'C';
  String? _fromMonth;
  int _fromYear = DateTime.now().year;
  String? _untilMonth;
  int _untilYear = DateTime.now().year;
  double _monthlyFee = 0.0;
  double _amountToPay = 0.0;
  double _balance = 0.0;

  final List<String> _blocks = ['C', 'D'];
  final List<String> _months = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December'
  ];
  final List<int> _years = List<int>.generate(10, (i) => DateTime.now().year - 5 + i);

  @override
  void initState() {
    super.initState();
    _loadMonthlyFee();
    _amountReceivedController.addListener(_calculateBalance);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _unitController.dispose();
    _phoneController.dispose();
    _amountReceivedController.dispose();
    super.dispose();
  }

  Future<void> _loadMonthlyFee() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _monthlyFee = prefs.getDouble("monthly_fee") ?? 0.0;
    });
  }

  void _calculateAmountToPay() {
    if (_fromMonth != null && _untilMonth != null) {
      final fromMonthIndex = _months.indexOf(_fromMonth!);
      final untilMonthIndex = _months.indexOf(_untilMonth!);

      if (fromMonthIndex != -1 && untilMonthIndex != -1) {
        final monthDifference = (_untilYear - _fromYear) * 12 + (untilMonthIndex - fromMonthIndex) + 1;
        setState(() {
          _amountToPay = monthDifference > 0 ? monthDifference * _monthlyFee : 0.0;
          _calculateBalance();
        });
      }
    } else {
      setState(() {
        _amountToPay = 0.0;
        _calculateBalance();
      });
    }
  }

  void _calculateBalance() {
    final amountReceived = double.tryParse(_amountReceivedController.text) ?? 0.0;
    setState(() {
      _balance = _amountToPay - amountReceived;
    });
  }

  Future<void> _savePayment() async {
    if (_formKey.currentState!.validate()) {
      final newPayment = Payment(
        name: _nameController.text,
        block: _selectedBlock!,
        unit: _unitController.text,
        phone: _phoneController.text,
        fromMonth: _fromMonth!,
        fromYear: _fromYear,
        untilMonth: _untilMonth!,
        untilYear: _untilYear,
        amountToPay: _amountToPay,
        amountReceived: double.tryParse(_amountReceivedController.text) ?? 0.0,
        balance: _balance,
        createdAt: DateTime.now(),
      );

      final prefs = await SharedPreferences.getInstance();
      final List<String> paymentsJson = prefs.getStringList('payments') ?? [];
      paymentsJson.add(newPayment.toJson());
      await prefs.setStringList('payments', paymentsJson);

      log('Payment Saved: ${newPayment.toJson()}', name: 'AddPaymentPage');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Payment Saved Successfully!')),
      );
      Navigator.of(context).pop(true); // Return true to indicate a new payment was added
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackground,
      appBar: AppBar(
        title: const Text('Add Payment', style: TextStyle(fontWeight: FontWeight.bold, color: kPrimaryText)),
        backgroundColor: kBackground,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: kPrimaryText),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          children: [
            _FormCard(
              title: 'Payer Information',
              icon: Icons.person_outline,
              children: [
                _buildTextField(label: 'Name', controller: _nameController, icon: Icons.person),
                const SizedBox(height: 16),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 2,
                      child: _buildDropdown(_blocks, 'Block', _selectedBlock, (val) => setState(() => _selectedBlock = val)),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      flex: 3,
                      child: _buildTextField(
                        label: 'Unit',
                        controller: _unitController,
                        keyboardType: TextInputType.number,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildTextField(label: 'Phone', controller: _phoneController, keyboardType: TextInputType.phone, icon: Icons.phone),
              ],
            ),
            _FormCard(
              title: 'Payment Period',
              icon: Icons.date_range_outlined,
              children: [
                const _FormSectionHeader(title: 'From'),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: _buildDropdown(_months, 'Month', _fromMonth, (val) {
                        setState(() => _fromMonth = val);
                        _calculateAmountToPay();
                      }),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildDropdown(_years.map((y) => y.toString()).toList(), 'Year', _fromYear.toString(), (val) {
                        setState(() => _fromYear = int.parse(val!));
                         _calculateAmountToPay();
                      }),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const _FormSectionHeader(title: 'Until'),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: _buildDropdown(_months, 'Month', _untilMonth, (val) {
                        setState(() => _untilMonth = val);
                        _calculateAmountToPay();
                      }),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildDropdown(_years.map((y) => y.toString()).toList(), 'Year', _untilYear.toString(), (val) {
                        setState(() => _untilYear = int.parse(val!));
                        _calculateAmountToPay();
                      }),
                    ),
                  ],
                ),
              ],
            ),
            _FormCard(
              title: 'Amount Details',
              icon: Icons.monetization_on_outlined,
              children: [
                _buildAmountDisplayRow(
                  title: 'Amount to Pay',
                  amount: _amountToPay,
                  style: const TextStyle(fontSize: 28, color: kPrimaryBlue, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  label: 'Amount Received',
                  controller: _amountReceivedController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[\d.]'))],
                  icon: Icons.input,
                ),
                const SizedBox(height: 16),
                _buildAmountDisplayRow(
                  title: 'Balance',
                  amount: _balance,
                  style: TextStyle(fontSize: 20, color: _balance <= 0 ? kGreenAccent : Colors.redAccent, fontWeight: FontWeight.bold),
                ),

              ],
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _savePayment,
              style: ElevatedButton.styleFrom(
                backgroundColor: kPrimaryBlue,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
              ),
              child: const Text('Save Payment', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: kPrimaryText)),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    IconData? icon,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      decoration: _inputDecoration(label, icon),
      style: const TextStyle(color: kPrimaryText),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter a $label';
        }
        return null;
      },
    );
  }

  Widget _buildDropdown(List<String> items, String hint, String? value, ValueChanged<String?> onChanged) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: _inputDecoration(hint, null),
      items: items.map((item) => DropdownMenuItem(value: item, child: Text(item, style: const TextStyle(color: kSubtleText),))).toList(),
      onChanged: onChanged,
      style: const TextStyle(color: kPrimaryText),
      dropdownColor: kCardBackground,
      icon: const Icon(Icons.arrow_drop_down, color: kSubtleText),
      validator: (value) {
        if (value == null) {
          return 'Please select a $hint';
        }
        return null;
      },
    );
  }

  InputDecoration _inputDecoration(String label, IconData? icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: kSubtleText),
      prefixIcon: icon != null ? Icon(icon, color: kSubtleText, size: 20) : null,
      filled: true,
      fillColor: kCardBackground,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.red, width: 1)),
      focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.red, width: 2)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    );
  }

  Widget _buildAmountDisplayRow({required String title, required double amount, required TextStyle style}){
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: const TextStyle(fontSize: 16, color: kSubtleText, fontWeight: FontWeight.w600)),
        Text(
          'RM ${amount.toStringAsFixed(2)}',
          style: style,
        ),
      ],
    );
  }
}

class _FormCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<Widget> children;

  const _FormCard({required this.title, required this.icon, required this.children});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      color: kCardBackground.withOpacity(0.5),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
      margin: const EdgeInsets.only(bottom: 24),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: kSubtleText, size: 20),
                const SizedBox(width: 8),
                Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: kPrimaryText)),
              ],
            ),
            const Divider(height: 24, color: kSubtleText),
            ...children,
          ],
        ),
      ),
    );
  }
}

class _FormSectionHeader extends StatelessWidget {
  final String title;
  const _FormSectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Text(
        title,
        style: const TextStyle(color: kSubtleText, fontSize: 14, fontWeight: FontWeight.w500),
      ),
    );
  }
}
