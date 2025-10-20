import 'package:flutter/material.dart';
import 'dart:math';
import 'package:billetera/constants/app_colors.dart';
import 'package:billetera/constants/app_styles.dart';
import 'package:billetera/constants/app_common_widget.dart';

class AmortizationFrenchScreen extends StatefulWidget {
  @override
  _AmortizationFrenchScreenState createState() =>
      _AmortizationFrenchScreenState();
}

class _AmortizationFrenchScreenState extends State<AmortizationFrenchScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _loanAmountController = TextEditingController();
  final TextEditingController _interestRateController = TextEditingController();
  final TextEditingController _yearsController = TextEditingController();
  final TextEditingController _capitalizationsController =
      TextEditingController(text: '12');

  List<Map<String, dynamic>> _amortizationTable = [];
  bool _showTable = false;

  double? _fixedPayment;
  double? _initialInterest;
  double? _firstAmortization;

  @override
  void dispose() {
    _loanAmountController.dispose();
    _interestRateController.dispose();
    _yearsController.dispose();
    _capitalizationsController.dispose();
    super.dispose();
  }

  void _calculateFrenchAmortization() {
    if (_formKey.currentState!.validate()) {
      double principal = double.parse(_loanAmountController.text);
      double annualRate = double.parse(_interestRateController.text) / 100;
      int years = int.parse(_yearsController.text);
      int capitalizationsPerYear = int.parse(_capitalizationsController.text);

      int totalPeriods = years * capitalizationsPerYear;
      double periodRate = annualRate / capitalizationsPerYear;

      double fixedPayment = principal *
          periodRate *
          pow(1 + periodRate, totalPeriods) /
          (pow(1 + periodRate, totalPeriods) - 1);

      List<Map<String, dynamic>> table = [];
      double remainingDebt = principal;

      double initialInterest = remainingDebt * periodRate;
      double firstAmortization = fixedPayment - initialInterest;

      for (int i = 1; i <= totalPeriods; i++) {
        double interest = remainingDebt * periodRate;
        double amortization = fixedPayment - interest;

        table.add({
          'period': i,
          'payment': fixedPayment,
          'capital': amortization,
          'interest': interest,
          'remainingDebt': remainingDebt - amortization,
        });

        remainingDebt -= amortization;
      }

      setState(() {
        _amortizationTable = table;
        _showTable = true;
        _fixedPayment = fixedPayment;
        _initialInterest = initialInterest;
        _firstAmortization = firstAmortization;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text('Sistema Francés',
            style: AppStyles.headingMedium
                .copyWith(color: AppColors.textOnPrimary)),
        backgroundColor: AppColors.primaryColor,
        elevation: 0,
        iconTheme: IconThemeData(color: AppColors.textOnPrimary),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTheoryCard(),
            SizedBox(height: 16),
            _buildCalculatorCard(),
            SizedBox(height: 16),
            if (_showTable) _buildKeyValuesCard(),
            SizedBox(height: 16),
            if (_showTable) _buildResultsCard(),
            SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildTheoryCard() {
    return Container(
      margin: EdgeInsets.all(16),
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.pink[400]!, Colors.pink[600]!],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.pink.withOpacity(0.3),
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.account_balance, color: Colors.white, size: 28),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Sistema de Amortización Francés',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          Text(
            'También conocido como sistema de cuotas fijas o anualidades. Es el más utilizado en préstamos hipotecarios y personales.',
            style: TextStyle(color: Colors.white70, fontSize: 14, height: 1.5),
          ),
          SizedBox(height: 12),
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: Colors.white, size: 20),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Cuotas constantes donde los intereses disminuyen y la amortización aumenta',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalculatorCard() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16),
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.calculate, color: AppColors.primaryColor, size: 24),
                SizedBox(width: 8),
                Text(
                  'Calculadora',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryColor,
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            TextFormField(
              controller: _loanAmountController,
              decoration: InputDecoration(
                labelText: 'Monto del préstamo',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: Icon(Icons.attach_money, color: Colors.pink),
                filled: true,
                fillColor: Colors.grey[50],
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Por favor ingrese el monto';
                }
                if (double.tryParse(value) == null ||
                    double.parse(value) <= 0) {
                  return 'Ingrese un valor numérico válido';
                }
                return null;
              },
            ),
            SizedBox(height: 16),
            TextFormField(
              controller: _interestRateController,
              decoration: InputDecoration(
                labelText: 'Tasa de interés (%)',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: Icon(Icons.percent, color: Colors.pink),
                filled: true,
                fillColor: Colors.grey[50],
              ),
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Por favor ingrese la tasa de interés';
                }
                if (double.tryParse(value) == null ||
                    double.parse(value) <= 0) {
                  return 'Ingrese un valor numérico válido';
                }
                return null;
              },
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _yearsController,
                    decoration: InputDecoration(
                      labelText: 'Períodos',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      prefixIcon:
                          Icon(Icons.calendar_today, color: Colors.pink),
                      filled: true,
                      fillColor: Colors.grey[50],
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Requerido';
                      }
                      if (int.tryParse(value) == null ||
                          int.parse(value) <= 0) {
                        return 'Valor inválido';
                      }
                      return null;
                    },
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _capitalizationsController,
                    decoration: InputDecoration(
                      labelText: 'Cap./año',
                      hintText: '12',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      prefixIcon: Icon(Icons.repeat, color: Colors.pink),
                      filled: true,
                      fillColor: Colors.grey[50],
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Requerido';
                      }
                      if (int.tryParse(value) == null ||
                          int.parse(value) <= 0) {
                        return 'Valor inválido';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
            SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _calculateFrenchAmortization,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accentColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.calculate),
                    SizedBox(width: 8),
                    Text(
                      'Calcular Amortización',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildKeyValuesCard() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16),
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.bar_chart, color: AppColors.primaryColor, size: 24),
              SizedBox(width: 8),
              Text(
                'Valores Clave',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryColor,
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          _buildKeyValueItem(
            'Cuota fija',
            '\$${_fixedPayment?.toStringAsFixed(2) ?? "0.00"}',
            Colors.pink[100]!,
            Icons.payment,
          ),
          SizedBox(height: 12),
          _buildKeyValueItem(
            'Intereses iniciales',
            '\$${_initialInterest?.toStringAsFixed(2) ?? "0.00"}',
            Colors.orange[100]!,
            Icons.trending_up,
          ),
          SizedBox(height: 12),
          _buildKeyValueItem(
            'Primera amortización',
            '\$${_firstAmortization?.toStringAsFixed(2) ?? "0.00"}',
            Colors.green[100]!,
            Icons.check_circle,
          ),
        ],
      ),
    );
  }

  Widget _buildKeyValueItem(
      String label, String value, Color bgColor, IconData icon) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: AppColors.primaryColor, size: 20),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondaryColor,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimaryColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultsCard() {
    double totalPayments =
        _amortizationTable.fold(0, (sum, item) => sum + item['payment']);
    double totalInterest =
        _amortizationTable.fold(0, (sum, item) => sum + item['interest']);
    double totalCapital =
        _amortizationTable.fold(0, (sum, item) => sum + item['capital']);

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16),
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.assignment, color: AppColors.primaryColor, size: 24),
              SizedBox(width: 8),
              Text(
                'Resultados',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryColor,
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                _buildSummaryRow(
                    'Total pagado', '\$${totalPayments.toStringAsFixed(2)}'),
                Divider(height: 24),
                _buildSummaryRow(
                    'Total capital', '\$${totalCapital.toStringAsFixed(2)}'),
                Divider(height: 24),
                _buildSummaryRow(
                    'Total intereses', '\$${totalInterest.toStringAsFixed(2)}'),
              ],
            ),
          ),
          SizedBox(height: 20),
          Text(
            'Tabla de Amortización',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              headingRowColor:
                  MaterialStateProperty.all(Colors.pink[50]),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(12),
              ),
              columns: [
                DataColumn(
                    label: Text('Período',
                        style: TextStyle(fontWeight: FontWeight.bold))),
                DataColumn(
                    label: Text('Cuota',
                        style: TextStyle(fontWeight: FontWeight.bold))),
                DataColumn(
                    label: Text('Capital',
                        style: TextStyle(fontWeight: FontWeight.bold))),
                DataColumn(
                    label: Text('Interés',
                        style: TextStyle(fontWeight: FontWeight.bold))),
                DataColumn(
                    label: Text('Saldo',
                        style: TextStyle(fontWeight: FontWeight.bold))),
              ],
              rows: _amortizationTable.map((row) {
                return DataRow(
                  cells: [
                    DataCell(Text(row['period'].toString())),
                    DataCell(Text('\$${row['payment'].toStringAsFixed(2)}')),
                    DataCell(Text('\$${row['capital'].toStringAsFixed(2)}')),
                    DataCell(Text('\$${row['interest'].toStringAsFixed(2)}')),
                    DataCell(
                        Text('\$${row['remainingDebt'].toStringAsFixed(2)}')),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 15,
            color: AppColors.textSecondaryColor,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimaryColor,
          ),
        ),
      ],
    );
  }
}