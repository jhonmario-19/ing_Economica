import 'package:flutter/material.dart';
import 'package:billetera/constants/app_colors.dart';
import 'package:billetera/constants/app_styles.dart';
import 'package:billetera/constants/app_common_widget.dart';

class AmortizationAmericanScreen extends StatefulWidget {
  @override
  _AmortizationAmericanScreenState createState() =>
      _AmortizationAmericanScreenState();
}

class _AmortizationAmericanScreenState
    extends State<AmortizationAmericanScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _loanAmountController = TextEditingController();
  final TextEditingController _interestRateController = TextEditingController();
  final TextEditingController _periodsController = TextEditingController();
  final TextEditingController _capitalizationController =
      TextEditingController(text: '1');

  List<Map<String, dynamic>> _amortizationTable = [];
  bool _showTable = false;

  @override
  void dispose() {
    _loanAmountController.dispose();
    _interestRateController.dispose();
    _periodsController.dispose();
    _capitalizationController.dispose();
    super.dispose();
  }

  void _calculateAmericanAmortization() {
    if (_formKey.currentState!.validate()) {
      double principal = double.parse(_loanAmountController.text);
      double annualRate = double.parse(_interestRateController.text) / 100;
      int capitalization = int.parse(_capitalizationController.text);
      int years = int.parse(_periodsController.text);

      int periods = years * capitalization;
      double ratePerPeriod = annualRate / capitalization;
      double interest = principal * ratePerPeriod;

      List<Map<String, dynamic>> table = [];

      for (int i = 1; i <= periods - 1; i++) {
        table.add({
          'period': i,
          'payment': interest,
          'capital': 0.0,
          'interest': interest,
          'interestPerPeriod': interest,
          'remainingDebt': principal,
        });
      }

      table.add({
        'period': periods,
        'payment': principal + interest,
        'capital': principal,
        'interest': interest,
        'interestPerPeriod': interest,
        'remainingDebt': 0.0,
      });

      setState(() {
        _amortizationTable = table;
        _showTable = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text('Sistema Americano',
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.timeline, color: Colors.white, size: 28),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Sistema de Amortización Americano',
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
            'Se caracteriza por el pago exclusivo de intereses durante todo el plazo del préstamo, con un único pago del capital al final del período.',
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
                    'Común en bonos corporativos e inversionistas con liquidez futura',
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
                prefixIcon: Icon(Icons.attach_money, color: Colors.blue),
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
                prefixIcon: Icon(Icons.percent, color: Colors.blue),
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _periodsController,
                    decoration: InputDecoration(
                      labelText: 'Períodos',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      prefixIcon: Icon(Icons.calendar_today, color: Colors.blue),
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
                    controller: _capitalizationController,
                    decoration: InputDecoration(
                      labelText: 'Cap./año',
                      hintText: '1',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      prefixIcon: Icon(Icons.repeat, color: Colors.blue),
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
                onPressed: _calculateAmericanAmortization,
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

  Widget _buildResultsCard() {
    double totalPayments =
        _amortizationTable.fold(0, (sum, item) => sum + item['payment']);
    double totalInterest =
        _amortizationTable.fold(0, (sum, item) => sum + item['interest']);
    double totalCapital =
        _amortizationTable.fold(0, (sum, item) => sum + item['capital']);

    int capitalization = int.parse(_capitalizationController.text);
    double annualRate = double.parse(_interestRateController.text);
    double ratePerPeriod = annualRate / capitalization;

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
                Divider(height: 24),
                _buildSummaryRow(
                    'Tasa por período', '${ratePerPeriod.toStringAsFixed(4)}%'),
                Divider(height: 24),
                _buildSummaryRow(
                    'Frecuencia', _getCapitalizationText(capitalization)),
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
                  MaterialStateProperty.all(Colors.blue[50]),
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
                    label: Text('Int/Período',
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
                    DataCell(Text(
                        '\$${row['interestPerPeriod'].toStringAsFixed(2)}')),
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

  String _getCapitalizationText(int capitalization) {
    Map<int, String> capitalizationTypes = {
      1: 'Anual',
      2: 'Semestral',
      4: 'Trimestral',
      12: 'Mensual',
      24: 'Quincenal',
      52: 'Semanal',
      365: 'Diaria'
    };

    return capitalizationTypes[capitalization] ??
        '$capitalization veces por año';
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