import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:myapp/log_service.dart';
import 'package:myapp/payment_model.dart';
import 'package:myapp/ui/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Custom formatter for phone number
class PhoneNumberInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digitsOnly = newValue.text.replaceAll(RegExp(r'\D'), '');
    final newTextLength = digitsOnly.length;

    var newString = StringBuffer();
    if (newTextLength > 0) {
      newString.write(
        digitsOnly.substring(0, newTextLength > 3 ? 3 : newTextLength),
      );
    }
    if (newTextLength > 3) {
      newString.write('-');
      newString.write(
        digitsOnly.substring(3, newTextLength > 6 ? 6 : newTextLength),
      );
    }
    if (newTextLength > 6) {
      newString.write(' ');
      newString.write(
        digitsOnly.substring(6, newTextLength > 11 ? 11 : newTextLength),
      );
    }

    return TextEditingValue(
      text: newString.toString(),
      selection: TextSelection.collapsed(offset: newString.length),
    );
  }
}

class AddPaymentPage extends StatefulWidget {
  const AddPaymentPage({super.key});

  @override
  State<AddPaymentPage> createState() => _AddPaymentPageState();
}

class _AddPaymentPageState extends State<AddPaymentPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  String? _selectedBlock;
  final _unitController = TextEditingController();
  final _amountReceivedController = TextEditingController();
  String? _fromMonth;
  String? _untilMonth;
  String? _fromYear;
  String? _untilYear;

  double _amountToPay = 0.0;
  double _monthlyFee = 0.0;
  double _balance = 0.0;

  @override
  void initState() {
    super.initState();
    _loadMonthlyFee();
    final currentYear = DateTime.now().year.toString();
    _fromYear = currentYear;
    _untilYear = currentYear;
    _amountReceivedController.addListener(_calculateBalance);
  }

  Future<void> _loadMonthlyFee() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _monthlyFee = prefs.getDouble('monthly_fee') ?? 0.0;
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _unitController.dispose();
    _amountReceivedController.dispose();
    super.dispose();
  }

  void _calculateAmountToPay() {
    if (_fromMonth != null &&
        _fromYear != null &&
        _untilMonth != null &&
        _untilYear != null) {
      final months = DateFormat.MMMM().dateSymbols.MONTHS;
      final fromMonthIndex = months.indexOf(_fromMonth!);
      final untilMonthIndex = months.indexOf(_untilMonth!);
      final fromYearInt = int.parse(_fromYear!);
      final untilYearInt = int.parse(_untilYear!);

      if (fromYearInt > untilYearInt ||
          (fromYearInt == untilYearInt && fromMonthIndex > untilMonthIndex)) {
        setState(() {
          _amountToPay = 0;
          _calculateBalance();
        });
        return;
      }

      final monthDifference =
          (untilYearInt - fromYearInt) * 12 +
          (untilMonthIndex - fromMonthIndex) +
          1;

      setState(() {
        _amountToPay = monthDifference * _monthlyFee;
        _calculateBalance();
      });
    } else {
      setState(() {
        _amountToPay = 0;
        _calculateBalance();
      });
    }
  }

  void _calculateBalance() {
    final text = _amountReceivedController.text;
    final digitsOnly = text.replaceAll(RegExp(r'[^0-9]'), '');
    final amountReceivedInCents = int.tryParse(digitsOnly) ?? 0;
    final amountReceived = amountReceivedInCents / 100.0;
    setState(() {
      _balance = amountReceived - _amountToPay;
    });
  }

  Future<void> _savePayment() async {
    if (_formKey.currentState!.validate()) {
      final text = _amountReceivedController.text;
      final digitsOnly = text.replaceAll(RegExp(r'[^0-9]'), '');
      final amountReceivedInCents = int.tryParse(digitsOnly) ?? 0;
      final amountReceived = amountReceivedInCents / 100.0;

      final newPayment = Payment(
        name: _nameController.text,
        phone: _phoneController.text,
        block: _selectedBlock!,
        unit: _unitController.text,
        amountToPay: _amountToPay,
        amountReceived: amountReceived,
        balance: _balance,
        createdAt: DateTime.now(),
        fromMonth: _fromMonth!,
        untilMonth: _untilMonth!,
        fromYear: _fromYear!,
        untilYear: _untilYear!,
      );

      final prefs = await SharedPreferences.getInstance();
      final List<String> paymentsJson = prefs.getStringList('payments') ?? [];
      paymentsJson.add(newPayment.toJson());
      await prefs.setStringList('payments', paymentsJson);

      final formattedAmount = NumberFormat.currency(
        locale: 'en_MY',
        symbol: 'RM',
      ).format(amountReceived);
      await LogService.logAction(
        'Added payment for ${_nameController.text} - $formattedAmount',
      );

      if (mounted) {
        showSuccessSnackBar(context, 'Payment saved successfully!');
        Navigator.of(context).pop(true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackground,
      appBar: AppBar(
        title: const Text(
          'Add New Payment',
          style: TextStyle(color: kPrimaryText),
        ),
        backgroundColor: kBackground,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              _buildSectionCard(
                title: 'Info',
                children: [
                  _buildTextField(
                    label: 'Name',
                    controller: _nameController,
                    icon: Icons.person,
                    textCapitalization: TextCapitalization.words,
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    label: 'Phone',
                    controller: _phoneController,
                    icon: Icons.phone,
                    keyboardType: TextInputType.phone,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      PhoneNumberInputFormatter(),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(child: _buildBlockDropdown()),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildTextField(
                          label: 'Unit',
                          controller: _unitController,
                          icon: Icons.home,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _buildSectionCard(
                title: 'Period',
                children: [_buildMonthYearPicker()],
              ),
              const SizedBox(height: 24),
              _buildSectionCard(
                title: 'Amount',
                titleAccessory: Text(
                  '${NumberFormat.currency(locale: 'en_MY', symbol: 'RM ').format(_monthlyFee)}/month',
                  style: const TextStyle(
                    color: kSubtleText,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                children: [
                  _buildAmountToPayDisplay(),
                  const SizedBox(height: 16),
                  _buildAmountField(
                    label: 'Amount Received',
                    controller: _amountReceivedController,
                  ),
                  const SizedBox(height: 16),
                  _buildBalanceDisplay(),
                ],
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _savePayment,
                style: ElevatedButton.styleFrom(
                  backgroundColor: kPrimaryBlue,
                  foregroundColor: kPrimaryText,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Save Payment',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required List<Widget> children,
    Widget? titleAccessory,
  }) {
    return ElevatedCard(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: kPrimaryText,
                ),
              ),
              if (titleAccessory != null) titleAccessory,
            ],
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    TextCapitalization textCapitalization = TextCapitalization.none,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      textCapitalization: textCapitalization,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: kSubtleText),
        filled: true,
        fillColor: kBackground,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter a $label';
        }
        return null;
      },
    );
  }

  Widget _buildBlockDropdown() {
    return DropdownButtonFormField<String>(
      initialValue: _selectedBlock,
      hint: const Text('Block', style: TextStyle(color: kSubtleText)),
      items: ['C', 'D'].map((String value) {
        return DropdownMenuItem<String>(value: value, child: Text(value));
      }).toList(),
      onChanged: (newValue) {
        setState(() {
          _selectedBlock = newValue;
        });
      },
      decoration: InputDecoration(
        prefixIcon: const Icon(Icons.location_city, color: kSubtleText),
        filled: true,
        fillColor: kBackground,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
      validator: (value) {
        if (value == null) {
          return 'Please select a block';
        }
        return null;
      },
    );
  }

  Widget _buildAmountToPayDisplay() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Amount to Pay',
          style: TextStyle(color: kSubtleText, fontSize: 16),
        ),
        const SizedBox(height: 8),
        Text(
          NumberFormat.currency(
            locale: 'en_MY',
            symbol: 'RM ',
          ).format(_amountToPay),
          style: const TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: kPrimaryText,
          ),
        ),
      ],
    );
  }

  Widget _buildAmountField({
    required String label,
    required TextEditingController controller,
  }) {
    return TextFormField(
      controller: controller,
      onChanged: (_) => _calculateBalance(),
      keyboardType: TextInputType.number,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        CurrencyInputFormatter(),
      ],
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: kBackground,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter an amount';
        }
        final digitsOnly = value.replaceAll(RegExp(r'[^0-9]'), '');
        if (int.tryParse(digitsOnly) == null) {
          return 'Please enter a valid number';
        }
        return null;
      },
      textAlign: TextAlign.start,
      style: const TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: kPrimaryText,
      ),
    );
  }

  Widget _buildBalanceDisplay() {
    final bool isEffectivelyZero = _balance.abs() < 0.005;
    final double displayBalance = isEffectivelyZero ? 0.0 : _balance;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: kBackground,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Balance',
            style: TextStyle(fontSize: 18, color: kSubtleText),
          ),
          Text(
            'RM ${displayBalance.toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: displayBalance >= 0 ? kGreenAccent : kAccentRed,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthYearPicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: _buildMonthDropdown(
                label: 'From',
                value: _fromMonth,
                onChanged: (val) {
                  setState(() => _fromMonth = val);
                  _calculateAmountToPay();
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildYearDropdown(
                label: 'Year',
                value: _fromYear,
                onChanged: (val) {
                  setState(() => _fromYear = val);
                  _calculateAmountToPay();
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildMonthDropdown(
                label: 'Until',
                value: _untilMonth,
                onChanged: (val) {
                  setState(() => _untilMonth = val);
                  _calculateAmountToPay();
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildYearDropdown(
                label: 'Year',
                value: _untilYear,
                onChanged: (val) {
                  setState(() => _untilYear = val);
                  _calculateAmountToPay();
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMonthDropdown({
    required String label,
    String? value,
    required ValueChanged<String?> onChanged,
  }) {
    return DropdownButtonFormField<String>(
      initialValue: value,
      hint: Text(label, style: const TextStyle(color: kSubtleText)),
      items: DateFormat.MMMM().dateSymbols.MONTHS.map((String month) {
        return DropdownMenuItem<String>(value: month, child: Text(month));
      }).toList(),
      onChanged: onChanged,
      decoration: InputDecoration(
        filled: true,
        fillColor: kBackground,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
      validator: (val) {
        if (val == null) {
          return 'Please select a month';
        }
        return null;
      },
    );
  }

  Widget _buildYearDropdown({
    required String label,
    String? value,
    required ValueChanged<String?> onChanged,
  }) {
    final currentYear = DateTime.now().year;
    final years = List<String>.generate(
      11,
      (index) => (currentYear - 5 + index).toString(),
    );

    return DropdownButtonFormField<String>(
      initialValue: value,
      hint: Text(label, style: const TextStyle(color: kSubtleText)),
      items: years.map((String year) {
        return DropdownMenuItem<String>(value: year, child: Text(year));
      }).toList(),
      onChanged: onChanged,
      decoration: InputDecoration(
        filled: true,
        fillColor: kBackground,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
      validator: (val) {
        if (val == null) {
          return 'Please select a year';
        }
        return null;
      },
    );
  }
}
