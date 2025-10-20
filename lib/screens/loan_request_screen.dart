// screens/loan_request_screen.dart
import 'dart:math';
import 'package:billetera/services/user_service.dart';
import 'package:flutter/material.dart';
import 'package:billetera/services/loan_service.dart';
import 'package:intl/intl.dart';

class LoanRequestScreen extends StatefulWidget {
  @override
  _LoanRequestScreenState createState() => _LoanRequestScreenState();
}

class _LoanRequestScreenState extends State<LoanRequestScreen> {
  final LoanService _loanService = LoanService();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _termController = TextEditingController();

  // Tasa de interés establecida por el banco (fija, no seleccionable por el usuario)
  final double _interestRate = 15.0;
  String _paymentMethod = 'francesa'; // Método de pago predeterminado
  bool _isLoading = false;

  final Color _primaryColor = Color(0xFF5C2A9D);
  final Color _accentColor = Color(0xFFEA3788);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Solicitar Préstamo'),
        backgroundColor: _primaryColor,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildInfoCard(),
              SizedBox(height: 24),
              Text(
                'Detalles del Préstamo',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),
              _buildAmountField(),
              SizedBox(height: 16),
              _buildTermField(),
              SizedBox(height: 16),
              _buildInterestRateInfo(),
              SizedBox(height: 16),
              _buildPaymentMethodSelector(),
              SizedBox(height: 24),
              _buildCalculationSummary(),
              SizedBox(height: 24),
              _buildSubmitButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue[300]!),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: Colors.blue),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              'Solicita tu préstamo de manera rápida y sencilla. Recibirás una respuesta en menos de 24 horas.',
              style: TextStyle(color: Colors.blue[800]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAmountField() {
    return TextFormField(
      controller: _amountController,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        labelText: 'Monto a solicitar',
        prefixIcon: Icon(Icons.attach_money),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        hintText: 'Ej: 1000000',
      ),
      onChanged: (_) => setState(() {}),
    );
  }

  Widget _buildTermField() {
    return TextFormField(
      controller: _termController,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        labelText: 'Plazo (meses)',
        prefixIcon: Icon(Icons.calendar_today),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        hintText: 'Ej: 12',
      ),
      onChanged: (_) => setState(() {}),
    );
  }

  Widget _buildInterestRateInfo() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Row(
        children: [
          Icon(Icons.percent, color: _accentColor),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tasa de interés del banco',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 4),
                Text(
                  '${_interestRate.toStringAsFixed(1)}% anual',
                  style: TextStyle(
                    fontSize: 16,
                    color: _accentColor,
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
        Text('Sistema de amortización:'),
        SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: _paymentMethod,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          items: [
            DropdownMenuItem(
              value: 'francesa',
              child: Text('Francés (cuotas iguales)'),
            ),
            DropdownMenuItem(
              value: 'alemana',
              child: Text('Alemán (capital constante)'),
            ),
            DropdownMenuItem(
              value: 'americana',
              child: Text('Americano (capital al final)'),
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
    // Validar entrada para evitar errores
    double? amount = double.tryParse(_amountController.text);
    int? term = int.tryParse(_termController.text);

    if (amount == null || term == null || amount <= 0 || term <= 0) {
      return Container();
    }

    // Calcular cuota aproximada (sistema francés)
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
      // Para simplificar, mostramos la primera cuota
      double interest = amount * monthlyRate;
      monthlyPayment = capitalPerMonth + interest;

      // Cálculo aproximado del total
      double remainingCapital = amount;
      totalPayment = 0;
      for (int i = 0; i < term; i++) {
        double interest = remainingCapital * monthlyRate;
        totalPayment += (capitalPerMonth + interest);
        remainingCapital -= capitalPerMonth;
      }
    } else {
      // americana
      double interest = amount * monthlyRate;
      monthlyPayment = interest;
      totalPayment = (interest * term) + amount;
    }

    NumberFormat formatter = NumberFormat('#,###');

    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Resumen del préstamo',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Monto solicitado:'),
              Text('\$${formatter.format(amount)}',
                  style: TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          Divider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Cuota estimada:'),
              Text('\$${formatter.format(monthlyPayment)}',
                  style: TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          if (_paymentMethod == 'americana')
            Text('(Solo interés, capital al final)',
                style: TextStyle(fontSize: 12, color: Colors.grey)),
          Divider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Total a pagar:'),
              Text('\$${formatter.format(totalPayment)}',
                  style: TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          Divider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Intereses:'),
              Text('\$${formatter.format(totalPayment - amount)}',
                  style: TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: _accentColor,
          foregroundColor: Colors.white,
          padding: EdgeInsets.symmetric(vertical: 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onPressed: _isLoading ? null : _submitLoanRequest,
        child: _isLoading
            ? CircularProgressIndicator(color: Colors.white)
            : Text('SOLICITAR PRÉSTAMO'),
      ),
    );
  }

  void _submitLoanRequest() async {
    // Validar entrada
    double? amount = double.tryParse(_amountController.text);
    int? term = int.tryParse(_termController.text);

    if (amount == null || term == null || amount <= 0 || term <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Por favor ingresa valores válidos')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Instanciar el servicio de usuario
      final UserService userService = UserService();

      // Obtener datos actuales del usuario
      final currentUser = await userService.getUserData();

      if (currentUser == null) {
        throw Exception('No se pudo obtener información del usuario');
      }

      // Calcular nuevo saldo
      double newBalance = currentUser.saldo + amount;

      // Registrar el préstamo en la base de datos
      await _loanService.requestLoan(
        amount,
        _interestRate,
        term,
        _paymentMethod,
      );

      // Actualizar el saldo del usuario automáticamente
      await userService.updateUserBalance(newBalance);

      // Mostrar confirmación
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              '¡Préstamo aprobado automáticamente! El monto ha sido añadido a tu saldo.'),
          backgroundColor: Colors.green,
        ),
      );

      // Volver a la pantalla anterior
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
}
