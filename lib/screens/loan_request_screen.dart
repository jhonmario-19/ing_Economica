import 'dart:math';
import 'package:billetera/services/user_service.dart';
import 'package:flutter/material.dart';
import 'package:billetera/services/loan_service.dart';
import 'package:billetera/constants/app_colors.dart';
import 'package:billetera/constants/app_styles.dart';
import 'package:intl/intl.dart';

class LoanRequestScreen extends StatefulWidget {
  @override
  _LoanRequestScreenState createState() => _LoanRequestScreenState();
}

class _LoanRequestScreenState extends State<LoanRequestScreen> {
  final LoanService _loanService = LoanService();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _termController = TextEditingController();

  final double _interestRate = 15.0;
  String _paymentMethod = 'francesa';
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text('Solicitar Préstamo'),
        backgroundColor: AppColors.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildInfoCard(),
              SizedBox(height: 24),
              _buildFormSection(),
              SizedBox(height: 24),
              _buildCalculationSummary(),
              SizedBox(height: 24),
              _buildSubmitButton(),
              SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.blue[400]!, Colors.blue[600]!],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.3),
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.info_outline,
              color: Colors.white,
              size: 28,
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Préstamo rápido',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Solicita tu préstamo de manera rápida y sencilla. Recibirás una respuesta en menos de 24 horas.',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormSection() {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Detalles del Préstamo',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimaryColor,
            ),
          ),
          SizedBox(height: 20),
          _buildAmountField(),
          SizedBox(height: 16),
          _buildTermField(),
          SizedBox(height: 16),
          _buildInterestRateInfo(),
          SizedBox(height: 16),
          _buildPaymentMethodSelector(),
        ],
      ),
    );
  }

  Widget _buildAmountField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Monto a solicitar',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimaryColor,
            fontSize: 14,
          ),
        ),
        SizedBox(height: 8),
        TextFormField(
          controller: _amountController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            prefixIcon: Icon(Icons.attach_money, color: AppColors.accentColor),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.primaryColor, width: 2),
            ),
            hintText: 'Ej: 1,000,000',
            filled: true,
            fillColor: Colors.grey[50],
          ),
          onChanged: (_) => setState(() {}),
        ),
      ],
    );
  }

  Widget _buildTermField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Plazo (meses)',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimaryColor,
            fontSize: 14,
          ),
        ),
        SizedBox(height: 8),
        TextFormField(
          controller: _termController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            prefixIcon: Icon(Icons.calendar_today, color: AppColors.accentColor),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.primaryColor, width: 2),
            ),
            hintText: 'Ej: 12',
            filled: true,
            fillColor: Colors.grey[50],
          ),
          onChanged: (_) => setState(() {}),
        ),
      ],
    );
  }

  Widget _buildInterestRateInfo() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.accentColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.accentColor.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.accentColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(Icons.percent, color: AppColors.accentColor, size: 24),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tasa de interés del banco',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimaryColor,
                    fontSize: 13,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  '${_interestRate.toStringAsFixed(1)}% anual',
                  style: TextStyle(
                    fontSize: 18,
                    color: AppColors.accentColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethodSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Sistema de amortización',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimaryColor,
            fontSize: 14,
          ),
        ),
        SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: _paymentMethod,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.primaryColor, width: 2),
            ),
            filled: true,
            fillColor: Colors.grey[50],
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          ),
          items: [
            DropdownMenuItem(
              value: 'francesa',
              child: Row(
                children: [
                  Icon(Icons.equalizer, size: 20, color: AppColors.primaryColor),
                  SizedBox(width: 12),
                  Text('Francés (cuotas iguales)'),
                ],
              ),
            ),
            DropdownMenuItem(
              value: 'alemana',
              child: Row(
                children: [
                  Icon(Icons.trending_down, size: 20, color: AppColors.primaryColor),
                  SizedBox(width: 12),
                  Text('Alemán (capital constante)'),
                ],
              ),
            ),
            DropdownMenuItem(
              value: 'americana',
              child: Row(
                children: [
                  Icon(Icons.payment, size: 20, color: AppColors.primaryColor),
                  SizedBox(width: 12),
                  Text('Americano (capital al final)'),
                ],
              ),
            ),
          ],
          onChanged: (value) {
            setState(() {
              _paymentMethod = value!;
            });
          },
        ),
      ],
    );
  }

  Widget _buildCalculationSummary() {
    double? amount = double.tryParse(_amountController.text);
    int? term = int.tryParse(_termController.text);

    if (amount == null || term == null || amount <= 0 || term <= 0) {
      return Container();
    }

    double monthlyRate = _interestRate / 100 / 12;
    double monthlyPayment;
    double totalPayment;

    if (_paymentMethod == 'francesa') {
      monthlyPayment = amount *
          monthlyRate *
          pow((1 + monthlyRate), term) /
          (pow((1 + monthlyRate), term) - 1);
      totalPayment = monthlyPayment * term;
    } else if (_paymentMethod == 'alemana') {
      double capitalPerMonth = amount / term;
      double interest = amount * monthlyRate;
      monthlyPayment = capitalPerMonth + interest;

      double remainingCapital = amount;
      totalPayment = 0;
      for (int i = 0; i < term; i++) {
        double interest = remainingCapital * monthlyRate;
        totalPayment += (capitalPerMonth + interest);
        remainingCapital -= capitalPerMonth;
      }
    } else {
      double interest = amount * monthlyRate;
      monthlyPayment = interest;
      totalPayment = (interest * term) + amount;
    }

    NumberFormat formatter = NumberFormat('#,###');

    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.calculate,
                  color: AppColors.primaryColor,
                  size: 20,
                ),
              ),
              SizedBox(width: 12),
              Text(
                'Resumen del préstamo',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: AppColors.textPrimaryColor,
                ),
              ),
            ],
          ),
          SizedBox(height: 20),
          _buildSummaryRow('Monto solicitado:', '\$${formatter.format(amount)}'),
          Divider(height: 20),
          _buildSummaryRow('Cuota estimada:', '\$${formatter.format(monthlyPayment)}'),
          if (_paymentMethod == 'americana')
            Padding(
              padding: EdgeInsets.only(top: 4),
              child: Text(
                '(Solo interés, capital al final)',
                style: TextStyle(fontSize: 12, color: AppColors.textSecondaryColor),
              ),
            ),
          Divider(height: 20),
          _buildSummaryRow('Total a pagar:', '\$${formatter.format(totalPayment)}'),
          Divider(height: 20),
          _buildSummaryRow(
            'Intereses:',
            '\$${formatter.format(totalPayment - amount)}',
            highlightValue: true,
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool highlightValue = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: AppColors.textSecondaryColor,
            fontSize: 14,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: highlightValue ? AppColors.accentColor : AppColors.textPrimaryColor,
          ),
        ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.accentColor,
          foregroundColor: Colors.white,
          padding: EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
        ),
        onPressed: _isLoading ? null : _submitLoanRequest,
        child: _isLoading
            ? SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : Text(
                'SOLICITAR PRÉSTAMO',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }

  void _submitLoanRequest() async {
    double? amount = double.tryParse(_amountController.text);
    int? term = int.tryParse(_termController.text);

    if (amount == null || term == null || amount <= 0 || term <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.warning, color: Colors.white),
              SizedBox(width: 12),
              Text('Por favor ingresa valores válidos'),
            ],
          ),
          backgroundColor: Colors.orange,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final UserService userService = UserService();
      final currentUser = await userService.getUserData();

      if (currentUser == null) {
        throw Exception('No se pudo obtener información del usuario');
      }

      double newBalance = currentUser.saldo + amount;

      await _loanService.requestLoan(
        amount,
        _interestRate,
        term,
        _paymentMethod,
      );

      await userService.updateUserBalance(newBalance);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 12),
              Expanded(
                child: Text('¡Préstamo aprobado automáticamente! El monto ha sido añadido a tu saldo.'),
              ),
            ],
          ),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          duration: Duration(seconds: 3),
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.error, color: Colors.white),
              SizedBox(width: 12),
              Expanded(child: Text('Error: ${e.toString()}')),
            ],
          ),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
}