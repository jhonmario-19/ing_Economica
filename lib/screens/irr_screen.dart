import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:billetera/constants/app_colors.dart';
import 'package:billetera/constants/app_styles.dart';
import 'dart:math';

class IRRScreen extends StatefulWidget {
  @override
  _IRRScreenState createState() => _IRRScreenState();
}

class _IRRScreenState extends State<IRRScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  List<TextEditingController> _cashFlowControllers = [TextEditingController()];
  late TabController _tabController;
  String _resultado = '';
  bool _isCalculating = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _cashFlowControllers.first.text = "-1000";
    _addCashFlowField();
  }

  @override
  void dispose() {
    _tabController.dispose();
    for (var controller in _cashFlowControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _addCashFlowField() {
    setState(() {
      _cashFlowControllers.add(TextEditingController());
    });
  }

  void _removeCashFlowField(int index) {
    if (_cashFlowControllers.length > 2) {
      setState(() {
        _cashFlowControllers[index].dispose();
        _cashFlowControllers.removeAt(index);
      });
    }
  }

  void _calcularTIR() {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isCalculating = true;
    });

    List<double> cashFlows = _cashFlowControllers
        .map((controller) => double.parse(controller.text.replaceAll(',', '.')))
        .toList();

    try {
      double irr = _calculateIRR(cashFlows);
      setState(() {
        _resultado = 'TIR: ${(irr * 100).toStringAsFixed(2)}%';
        _isCalculating = false;
      });
    } catch (e) {
      setState(() {
        _resultado =
            'Error: No se pudo calcular la TIR. Verifica los flujos de caja.';
        _isCalculating = false;
      });
    }
  }

  double _calculateIRR(List<double> cashFlows) {
    double guess = 0.1;
    int maxIterations = 100;
    double precision = 0.0000001;

    for (int i = 0; i < maxIterations; i++) {
      double npv = 0;
      double derivative = 0;

      for (int j = 0; j < cashFlows.length; j++) {
        npv += cashFlows[j] / pow(1 + guess, j);
        if (j > 0) {
          derivative -= j * cashFlows[j] / pow(1 + guess, j + 1);
        }
      }

      double newGuess = guess - npv / derivative;

      if ((newGuess - guess).abs() < precision) {
        return newGuess;
      }

      guess = newGuess;
    }

    throw Exception("No se pudo converger a una solución");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text('Tasa Interna de Retorno (TIR)',
            style: AppStyles.headingMedium
                .copyWith(color: AppColors.textOnPrimary)),
        backgroundColor: AppColors.primaryColor,
        elevation: 0,
        iconTheme: IconThemeData(color: AppColors.textOnPrimary),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Calculadora', icon: Icon(Icons.calculate)),
            Tab(text: 'Teoría', icon: Icon(Icons.book)),
          ],
          indicatorColor: Colors.white,
          labelColor: Colors.white,
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildCalculatorTab(),
          _buildTheoryTab(),
        ],
      ),
    );
  }

  Widget _buildCalculatorTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Colors.teal[400]!, Colors.teal[600]!],
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.teal.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.show_chart, color: Colors.white, size: 28),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Calculadora de TIR',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.info_outline, color: Colors.white, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Ingresa tu inversión inicial (negativa) y los flujos de caja futuros',
                            style: const TextStyle(
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
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.attach_money, color: AppColors.primaryColor, size: 24),
                      const SizedBox(width: 8),
                      Text(
                        'Flujos de Caja',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _cashFlowControllers.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12.0),
                        child: Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _cashFlowControllers[index],
                                decoration: InputDecoration(
                                  labelText: index == 0
                                      ? 'Inversión Inicial (t=0)'
                                      : 'Flujo $index',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  prefixText: '\$ ',
                                  prefixIcon: Icon(
                                    index == 0
                                        ? Icons.arrow_downward
                                        : Icons.arrow_upward,
                                    color: index == 0 ? Colors.red : Colors.green,
                                  ),
                                  filled: true,
                                  fillColor: Colors.grey[50],
                                ),
                                keyboardType: const TextInputType.numberWithOptions(
                                    decimal: true, signed: true),
                                inputFormatters: [
                                  FilteringTextInputFormatter.allow(
                                      RegExp(r'^-?\d*\.?\d*')),
                                ],
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Este campo es requerido';
                                  }
                                  return null;
                                },
                              ),
                            ),
                            if (index > 0)
                              IconButton(
                                icon: const Icon(Icons.remove_circle,
                                    color: Colors.red),
                                onPressed: () => _removeCashFlowField(index),
                              ),
                          ],
                        ),
                      );
                    },
                  ),
                  Center(
                    child: TextButton.icon(
                      onPressed: _addCashFlowField,
                      icon: Icon(Icons.add_circle, color: AppColors.accentColor),
                      label: Text('Agregar flujo de caja',
                          style: TextStyle(
                            color: AppColors.accentColor,
                            fontWeight: FontWeight.bold,
                          )),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 50,
              child: ElevatedButton(
                onPressed: _isCalculating ? null : _calcularTIR,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accentColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                ),
                child: _isCalculating
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(Icons.calculate),
                          SizedBox(width: 8),
                          Text(
                            'Calcular TIR',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
            const SizedBox(height: 24),
            if (_resultado.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: _resultado.contains('Error')
                        ? Colors.red
                        : Colors.green,
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: (_resultado.contains('Error')
                              ? Colors.red
                              : Colors.green)
                          .withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Icon(
                          _resultado.contains('Error')
                              ? Icons.error_outline
                              : Icons.check_circle,
                          color: _resultado.contains('Error')
                              ? Colors.red
                              : Colors.green,
                          size: 32,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Resultado:',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: AppColors.textPrimaryColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _resultado,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: _resultado.contains('Error')
                            ? Colors.red
                            : Colors.green[700],
                      ),
                      textAlign: TextAlign.center,
                    ),
                    if (!_resultado.contains('Error'))
                      Padding(
                        padding: const EdgeInsets.only(top: 16),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.green[50],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.lightbulb_outline,
                                  color: Colors.green[700], size: 20),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Esta es la tasa de descuento que hace que el VPN sea cero.',
                                  style: TextStyle(
                                    fontStyle: FontStyle.italic,
                                    color: Colors.green[900],
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTheoryTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Colors.indigo[400]!, Colors.indigo[600]!],
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.indigo.withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.book, color: Colors.white, size: 28),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        '¿Qué es la TIR?',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  'La Tasa Interna de Retorno es la tasa de interés que hace que el Valor Presente Neto (VPN) sea igual a cero.',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          _buildTheoryCard(
            'Definición matemática',
            Icons.functions,
            Colors.blue,
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'La TIR es la tasa de descuento que hace que el VPN = 0:',
                  style: const TextStyle(fontStyle: FontStyle.italic),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: const [
                      Text(
                        '0 = FC₀ + FC₁/(1+i)¹ + FC₂/(1+i)² + ... + FCₙ/(1+i)ⁿ',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      SizedBox(height: 12),
                      Text(
                        'VPN = Σ[FCₜ/(1+i)ᵗ] = 0',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                _buildBulletPoint('FC₀, FC₁, ..., FCₙ: Flujos de caja'),
                _buildBulletPoint('i: Tasa interna de retorno (TIR)'),
                _buildBulletPoint('n: Número de períodos'),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _buildTheoryCard(
            'Interpretación de la TIR',
            Icons.analytics,
            Colors.green,
            Column(
              children: [
                _buildInterpretationItem(
                    'TIR > Tasa de descuento',
                    'El proyecto es rentable y debe aceptarse.',
                    Colors.green),
                const Divider(height: 24),
                _buildInterpretationItem(
                    'TIR = Tasa de descuento',
                    'El proyecto no genera ni pérdidas ni ganancias.',
                    Colors.amber),
                const Divider(height: 24),
                _buildInterpretationItem(
                    'TIR < Tasa de descuento',
                    'El proyecto no es rentable y debe rechazarse.',
                    Colors.red),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _buildTheoryCard(
            'Ventajas y Limitaciones',
            Icons.balance,
            Colors.orange,
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Ventajas:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: AppColors.primaryColor,
                  ),
                ),
                const SizedBox(height: 8),
                _buildBulletPoint('Considera el valor del dinero en el tiempo'),
                _buildBulletPoint('Fácil de interpretar como porcentaje'),
                const SizedBox(height: 16),
                Text(
                  'Limitaciones:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: AppColors.primaryColor,
                  ),
                ),
                const SizedBox(height: 8),
                _buildBulletPoint(
                    'Puede haber múltiples TIR con cambios de signo'),
                _buildBulletPoint('No considera el tamaño de la inversión'),
                _buildBulletPoint(
                    'Asume reinversión a la misma TIR (poco realista)'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTheoryCard(
      String title, IconData icon, Color color, Widget content) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 24),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          content,
        ],
      ),
    );
  }

  Widget _buildBulletPoint(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 6,
            height: 6,
            margin: const EdgeInsets.only(top: 7, right: 8),
            decoration: BoxDecoration(
              color: AppColors.primaryColor,
              shape: BoxShape.circle,
            ),
          ),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }

  Widget _buildInterpretationItem(
      String condition, String description, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 12,
            height: 12,
            margin: const EdgeInsets.only(top: 5, right: 12),
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  condition,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    color: AppColors.textSecondaryColor,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}