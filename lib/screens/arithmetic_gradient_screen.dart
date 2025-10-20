import 'package:flutter/material.dart';
import 'dart:math';
import 'package:billetera/constants/app_colors.dart';
import 'package:billetera/constants/app_styles.dart';
import 'package:billetera/constants/app_common_widget.dart';

class ArithmeticGradientScreen extends StatefulWidget {
  @override
  _ArithmeticGradientScreenState createState() =>
      _ArithmeticGradientScreenState();
}

class _ArithmeticGradientScreenState extends State<ArithmeticGradientScreen> {
  final _formKey = GlobalKey<FormState>();
  String _calculationType = 'presentValue';
  TextEditingController _initialPaymentController = TextEditingController();
  TextEditingController _gradientController = TextEditingController();
  TextEditingController _interestRateController = TextEditingController();
  TextEditingController _periodsController = TextEditingController();
  TextEditingController _presentValueController = TextEditingController();
  TextEditingController _futureValueController = TextEditingController();
  TextEditingController _capitalizationsController =
      TextEditingController(text: '1');

  bool _showTheory = false;
  double _result = 0.0;
  String _resultLabel = '';

  // Colores de la aplicación
  final Color _primaryColor = AppColors.primaryColor;
  final Color _accentColor = AppColors.accentColor;

  void _calculate() {
    if (_formKey.currentState!.validate()) {
      double initialPayment =
          double.tryParse(_initialPaymentController.text) ?? 0;
      double gradient = double.tryParse(_gradientController.text) ?? 0;
      double annualInterestRate =
          (double.tryParse(_interestRateController.text) ?? 0) / 100;
      int years = int.tryParse(_periodsController.text) ?? 0;
      int capitalizations = int.tryParse(_capitalizationsController.text) ?? 1;

      // Ajustar tasa de interés y períodos según el número de capitalizaciones
      double interestRate = annualInterestRate / capitalizations;
      int periods = years * capitalizations;

      setState(() {
        switch (_calculationType) {
          case 'presentValue':
            // Valor Presente de un Gradiente Aritmético
            if (interestRate > 0) {
              double factor1 =
                  (1 - pow(1 + interestRate, -periods)) / interestRate;
              double factor2 = ((1 - pow(1 + interestRate, -periods)) /
                      (pow(interestRate, 2))) -
                  (periods / (interestRate * pow(1 + interestRate, periods)));

              _result = initialPayment * factor1 + gradient * factor2;
              _resultLabel = 'Valor Presente (P)';
            } else {
              _result = 0; // Evitar división por cero
            }
            break;

          case 'futureValue':
            // Valor Futuro de un Gradiente Aritmético
            if (interestRate > 0) {
              double factor1 =
                  ((pow(1 + interestRate, periods) - 1) / interestRate);
              double factor2 = (1 / interestRate) *
                  ((pow(1 + interestRate, periods) - 1) / interestRate -
                      periods);

              _result = initialPayment * factor1 + gradient * factor2;
              _resultLabel = 'Valor Futuro (F)';
            } else {
              _result = 0; // Evitar división por cero
            }
            break;

          case 'calculateSeries':
            // Calcular el valor de la serie (A) dado el valor presente o futuro y el gradiente
            if (_presentValueController.text.isNotEmpty) {
              // Calcular A desde el valor presente
              double presentValue =
                  double.tryParse(_presentValueController.text) ?? 0;
              if (interestRate > 0) {
                double factor1 =
                    (1 - pow(1 + interestRate, -periods)) / interestRate;
                double factor2 = ((1 - pow(1 + interestRate, -periods)) /
                        (pow(interestRate, 2))) -
                    (periods / (interestRate * pow(1 + interestRate, periods)));

                // Resolver para A: P = A(factor1) + G(factor2)
                _result = (presentValue - gradient * factor2) / factor1;
                _resultLabel = 'Valor de la Serie (A)';
              } else {
                _result = 0; // Evitar división por cero
              }
            } else if (_futureValueController.text.isNotEmpty) {
              // Calcular A desde el valor futuro
              double futureValue =
                  double.tryParse(_futureValueController.text) ?? 0;
              if (interestRate > 0) {
                double factor1 =
                    ((pow(1 + interestRate, periods) - 1) / interestRate);
                double factor2 = (1 / interestRate) *
                    ((pow(1 + interestRate, periods) - 1) / interestRate -
                        periods);

                // Resolver para A: F = A(factor1) + G(factor2)
                _result = (futureValue - gradient * factor2) / factor1;
                _resultLabel = 'Valor de la Serie (A)';
              } else {
                _result = 0; // Evitar división por cero
              }
            }
            break;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text('Gradiente Aritmético', 
          style: AppStyles.headingMedium.copyWith(color: AppColors.textOnPrimary)
        ),
        backgroundColor: AppColors.primaryColor,
        elevation: 0,
        iconTheme: IconThemeData(color: AppColors.textOnPrimary),
      ),
      body: RefreshIndicator(
        onRefresh: () async {},
        color: _primaryColor,
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16.0),
          physics: AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Teoría expandible con estilo de la HomeScreen
              _buildTheoryCard(),
              SizedBox(height: 16),

              // Tipo de cálculo
              _buildTypeSelectionCard(),
              SizedBox(height: 16),

              // Formulario con estilos actualizados
              _buildCalculationForm(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTheoryCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ExpansionTile(
        title: Text('Teoría del Gradiente Aritmético',
            style: TextStyle(fontWeight: FontWeight.bold)),
        children: [
          Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                    'Un gradiente aritmético es una serie de flujos de efectivo que cambia por una cantidad constante (G) en cada período.',
                    style: TextStyle(fontSize: 16)),
                SizedBox(height: 10),
                Text('Fórmulas principales:',
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                SizedBox(height: 5),
                Text('• Valor Presente de un Gradiente Aritmético:'),
                Text('P = A(P/A, i%, n) + G(P/G, i%, n)'),
                Text(
                    'donde (P/G, i%, n) = (1/i)[(n/(1+i)ⁿ) - ((1-(1+i)⁻ⁿ)/i²)]'),
                SizedBox(height: 10),
                Text('• Valor Futuro de un Gradiente Aritmético:'),
                Text('F = A(F/A, i%, n) + G(F/G, i%, n)'),
                Text('donde (F/G, i%, n) = (1/i)[(F/A, i%, n) - n]'),
                SizedBox(height: 10),
                Text('• Valor de la Serie (A) dado P y G:'),
                Text('A = (P - G(P/G, i%, n)) / (P/A, i%, n)'),
                SizedBox(height: 10),
                Text('• Valor de la Serie (A) dado F y G:'),
                Text('A = (F - G(F/G, i%, n)) / (F/A, i%, n)'),
                SizedBox(height: 10),
                Text('Donde:'),
                Text('A = Pago inicial de la serie'),
                Text('G = Incremento constante (gradiente)'),
                Text('i = Tasa de interés por período'),
                Text('n = Número de períodos'),
                Text('P = Valor presente'),
                Text('F = Valor futuro'),
              ],
            ),
          ),
        ],
        onExpansionChanged: (expanded) {
          setState(() {
            _showTheory = expanded;
          });
        },
        initiallyExpanded: _showTheory,
      ),
    );
  }

  Widget _buildTypeSelectionCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Tipo de Cálculo',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            SizedBox(height: 10),
            DropdownButtonFormField<String>(
              decoration: InputDecoration(
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 12, vertical: 15),
                filled: true,
                fillColor: Colors.white,
              ),
              value: _calculationType,
              onChanged: (value) {
                setState(() {
                  _calculationType = value!;
                  _result = 0.0;
                });
              },
              items: [
                DropdownMenuItem(
                    value: 'presentValue', child: Text('Valor Presente (P)')),
                DropdownMenuItem(
                    value: 'futureValue', child: Text('Valor Futuro (F)')),
                DropdownMenuItem(
                    value: 'calculateSeries',
                    child: Text('Valor de la Serie (A)')),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCalculationForm() {
    return Form(
      key: _formKey,
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Parámetros de Cálculo',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              SizedBox(height: 20),

              // Campo para pago inicial (visible solo para cálculos de P y F)
              if (_calculationType == 'presentValue' ||
                  _calculationType == 'futureValue')
                _buildTextField(
                  controller: _initialPaymentController,
                  labelText: 'Pago Inicial (A)',
                  prefixIcon: Icons.attach_money,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Este campo es requerido';
                    }
                    return null;
                  },
                ),
              if (_calculationType == 'presentValue' ||
                  _calculationType == 'futureValue')
                SizedBox(height: 15),

              // Campo para el gradiente
              _buildTextField(
                controller: _gradientController,
                labelText: 'Gradiente (G)',
                prefixIcon: Icons.trending_up,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Este campo es requerido';
                  }
                  return null;
                },
              ),
              SizedBox(height: 15),

              // Campo para la tasa de interés
              _buildTextField(
                controller: _interestRateController,
                labelText: 'Tasa de Interés (%)',
                prefixIcon: Icons.percent,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Este campo es requerido';
                  }
                  return null;
                },
              ),
              SizedBox(height: 15),

              // Campos para años y capitalizaciones
              Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: _buildTextField(
                      controller: _periodsController,
                      labelText: 'Número de Periodos',
                      prefixIcon: Icons.calendar_month,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Requerido';
                        }
                        return null;
                      },
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    flex: 2,
                    child: _buildTextField(
                      controller: _capitalizationsController,
                      labelText: 'Capitalizaciones',
                      prefixIcon: Icons.sync_alt,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Requerido';
                        }
                        if (int.tryParse(value) == 0) {
                          return 'Debe ser > 0';
                        }
                        return null;
                      },
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 15),

              // Campo para valor presente o futuro (solo visible cuando se calcula la serie)
              if (_calculationType == 'calculateSeries')
                Column(
                  children: [
                    _buildTextField(
                      controller: _presentValueController,
                      labelText: 'Valor Presente (P)',
                      prefixIcon: Icons.attach_money,
                      helperText: 'Deje en blanco si usará Valor Futuro',
                    ),
                    SizedBox(height: 15),
                    _buildTextField(
                      controller: _futureValueController,
                      labelText: 'Valor Futuro (F)',
                      prefixIcon: Icons.attach_money,
                      helperText: 'Deje en blanco si usará Valor Presente',
                    ),
                    SizedBox(height: 15),
                    _buildWarningBox(
                        'Complete el Valor Presente o el Valor Futuro, no ambos.'),
                  ],
                ),

              SizedBox(height: 25),

              Center(
                child: ElevatedButton(
                  onPressed: () {
                    if (_calculationType == 'calculateSeries') {
                      // Validación adicional para asegurar que solo un campo esté lleno
                      if (_presentValueController.text.isNotEmpty &&
                          _futureValueController.text.isNotEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                                'Por favor, complete solo Valor Presente o Valor Futuro, no ambos.'),
                            backgroundColor: Colors.red,
                          ),
                        );
                        return;
                      }
                      if (_presentValueController.text.isEmpty &&
                          _futureValueController.text.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                                'Por favor, complete al menos un valor (Presente o Futuro).'),
                            backgroundColor: Colors.red,
                          ),
                        );
                        return;
                      }
                    }
                    _calculate();
                  },
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: _accentColor,
                    padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text('Calcular', style: TextStyle(fontSize: 18)),
                ),
              ),

              if (_result != 0.0) ...[
                SizedBox(height: 25),
                _buildResultWidget(),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String labelText,
    required IconData prefixIcon,
    String? Function(String?)? validator,
    String? helperText,
    TextInputType keyboardType =
        const TextInputType.numberWithOptions(decimal: true),
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: AppStyles.bodyMedium.copyWith(color: AppColors.textSecondaryColor),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppStyles.radiusL)),
        prefixIcon: Icon(prefixIcon, color: AppColors.primaryColor),
        helperText: helperText,
        helperStyle: AppStyles.bodySmall.copyWith(color: AppColors.textSecondaryColor),
        filled: true,
        fillColor: AppColors.surfaceColor,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: _primaryColor),
        ),
      ),
      keyboardType: keyboardType,
      validator: validator,
    );
  }

  Widget _buildWarningBox(String message) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.amber.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.amber.shade200),
      ),
      child: Text(
        message,
        style: TextStyle(
          fontStyle: FontStyle.italic,
          color: Colors.amber.shade900,
        ),
      ),
    );
  }

  Widget _buildResultWidget() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [_primaryColor, Color(0xFF3A1C6C)],
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: _primaryColor.withOpacity(0.3),
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            'Resultado:',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white70,
            ),
          ),
          SizedBox(height: 8),
          Text(
            '$_resultLabel: \$${_result.toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Períodos totales: ${(int.tryParse(_periodsController.text) ?? 0) * (int.tryParse(_capitalizationsController.text) ?? 1)}',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white70,
            ),
          ),
          Text(
            'Tasa por período: ${((double.tryParse(_interestRateController.text) ?? 0) / (int.tryParse(_capitalizationsController.text) ?? 1)).toStringAsFixed(4)}%',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }
}
