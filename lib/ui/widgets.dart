
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:myapp/payment_model.dart';


// --- Professional Color Palette ---
const Color kPrimaryBlue = Color(0xFF0D63F8);
const Color kAccentRed = Color(0xFFFF4081);
const Color kBackground = Color(0xFF121212);
const Color kCardBackground = Color(0xFF1E1E1E);
const Color kSubtleText = Color(0xFFBDBDBD);
const Color kPrimaryText = Color(0xFFFFFFFF);
const Color kGreenAccent = Color(0xFF69F0AE);

// --- Reusable Widgets ---

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
    final formattedDate = DateFormat("MMMM d, yyyy 'at' h:mm a").format(payment.createdAt);
    final roundedBalance = (payment.balance * 100).round() / 100;

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
            color: roundedBalance <= 0 ? kGreenAccent : kAccentRed,
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


// Custom formatter to allow only two decimal places
class DecimalTextInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.text.isEmpty) {
      return newValue;
    }

    final newDouble = double.tryParse(newValue.text);
    if (newDouble == null) {
      return oldValue; // Not a valid number
    }

    if (newValue.text.contains('.') && newValue.text.split('.')[1].length > 2) {
      return oldValue; // More than 2 decimal places
    }

    return newValue; // Accept the change
  }
}
