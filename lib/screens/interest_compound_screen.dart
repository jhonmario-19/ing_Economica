import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'dart:math';
import 'package:billetera/constants/app_colors.dart';
import 'package:billetera/constants/app_styles.dart';
import 'package:billetera/constants/app_common_widget.dart';
import 'package:billetera/models/interest_calculator.dart';

class InterestCompoundScreen extends StatefulWidget {
  @override
  _InterestCompoundScreenState createState() => _InterestCompoundScreenState();
}

class _InterestCompoundScreenState extends State<InterestCompoundScreen> {
  final InterestCalculator _calculator = InterestCalculator();

  String? _selectedCalculation;
  final TextEditingController _principalController = TextEditingController();
  final TextEditingController _rateController = TextEditingController();
  final TextEditingController _timeCompoundingController = TextEditingController();
  final TextEditingController _compoundingPeriodsController = TextEditingController();
  final TextEditingController _futureValueController = TextEditingController();

  double? _result;
  String? _formattedResult;
  String? _explanationText;

  void _calculate() {
    final double principal = double.tryParse(_principalController.text.replaceAll(',', '.')) ?? 0;
    final double rate = double.tryParse(_rateController.text.replaceAll(',', '.')) ?? 0;
    final double timeCompounding = double.tryParse(_timeCompoundingController.text.replaceAll(',', '.')) ?? 0;
    final int compoundingPeriods = int.tryParse(_compoundingPeriodsController.text) ?? 1;
    final double futureValue = double.tryParse(_futureValueController.text.replaceAll(',', '.')) ?? 0;

    if (_selectedCalculation == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        CommonWidgets.buildCustomSnackBar(
          message: 'Por favor selecciona un tipo de cálculo',
          type: SnackBarType.warning,
        ),
      );
      return;
    }

    try {
      setState(() {
        if (_selectedCalculation!.contains('Capital Inicial')) {
          _result = _calculator.calculateCompoundInterestPrincipal(
            futureValue,
            rate / compoundingPeriods,
            timeCompounding * compoundingPeriods,
          );
        } else {
          _result = _calculator.calculate(
            _selectedCalculation!,
            principal,
            rate,
            timeCompounding,
            futureValue,
            0,
            compoundingPeriods,
            timeCompounding,
          );
        }

        if (_selectedCalculation!.contains('Tasa de Interés')) {
          _formattedResult = NumberFormat("##0.00%").format(_result! / 100);
          _explanationText = "La tasa de interés efectiva para lograr el monto futuro deseado.";
        } else if (_selectedCalculation!.contains('Tiempo')) {
          _formattedResult = NumberFormat("#,##0.00").format(_result);
          _explanationText = "El tiempo requerido (en años) para alcanzar el monto futuro deseado.";
        } else if (_selectedCalculation!.contains('Capital Inicial')) {
          _formattedResult = NumberFormat("#,##0.00").format(_result);
          _explanationText = "El capital inicial necesario para lograr el monto futuro deseado.";
        } else {
          _formattedResult = NumberFormat("#,##0.00").format(_result);
          _explanationText = "El monto futuro que se alcanzará con la capitalización periódica.";
        }
      });

      ScaffoldMessenger.of(context).showSnackBar(
        CommonWidgets.buildCustomSnackBar(
          message: 'Cálculo realizado exitosamente',
          type: SnackBarType.success,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        CommonWidgets.buildCustomSnackBar(
          message: 'Error en el cálculo. Verifica los datos ingresados.',
          type: SnackBarType.error,
        ),
      );
    }
  }

  void _clearFields() {
    setState(() {
      _principalController.clear();
      _rateController.clear();
      _timeCompoundingController.clear();
      _compoundingPeriodsController.clear();
      _futureValueController.clear();
      _selectedCalculation = null;
      _result = null;
      _formattedResult = null;
      _explanationText = null;
    });
  }

  @override
  void dispose() {
    _principalController.dispose();
    _rateController.dispose();
    _timeCompoundingController.dispose();
    _compoundingPeriodsController.dispose();
    _futureValueController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        title: Text(
          'Interés Compuesto',
          style: AppStyles.headingMedium.copyWith(
            color: AppColors.textOnPrimary,
          ),
        ),
        backgroundColor: AppColors.primaryColor,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textOnPrimary),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _clearFields,
            tooltip: 'Limpiar campos',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppStyles.spacingM),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildExplanationCard(),
            const SizedBox(height: AppStyles.spacingM),
            _buildCalculatorCard(),
            const SizedBox(height: AppStyles.spacingM),
            if (_formattedResult != null) _buildResultCard(),
            if (_formattedResult != null) const SizedBox(height: AppStyles.spacingM),
            _buildFormulasCard(),
            const SizedBox(height: AppStyles.spacingM),
            _buildCapitalizationCard(),
            const SizedBox(height: AppStyles.spacingXL),
          ],
        ),
      ),
    );
  }

  Widget _buildExplanationCard() {
    return Container(
      decoration: AppStyles.primaryCardDecoration,
      child: Padding(
        padding: const EdgeInsets.all(AppStyles.spacingL),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.accentColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppStyles.radiusS),
                  ),
                  child: const Icon(
                    Icons.info_outline,
                    color: AppColors.accentColor,
                    size: 20,
                  ),
                ),
                const SizedBox(width: AppStyles.spacingS),
                Expanded(
                  child: Text(
                    '¿Qué es el interés compuesto?',
                    style: AppStyles.headingSmall.copyWith(
                      color: AppColors.accentColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppStyles.spacingM),
            Text(
              'El interés compuesto es aquel que se calcula sobre el capital inicial más los intereses acumulados en períodos anteriores, produciendo un efecto de "capitalización".',
              style: AppStyles.bodyMedium,
            ),
            const SizedBox(height: AppStyles.spacingS),
            Container(
              padding: const EdgeInsets.all(AppStyles.spacingS),
              decoration: BoxDecoration(
                color: AppColors.cardBackground,
                borderRadius: BorderRadius.circular(AppStyles.radiusS),
              ),
              child: Text(
                'Fórmula general: Monto Final = P × (1 + r/n)^(n×t)',
                style: AppStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.w500,
                  fontStyle: FontStyle.italic,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCalculatorCard() {
    return Container(
      decoration: AppStyles.primaryCardDecoration,
      child: Padding(
        padding: const EdgeInsets.all(AppStyles.spacingL),
        child: Column(
          children: [
            CommonWidgets.buildSectionHeader(
              title: 'Calculadora de Interés Compuesto',
              subtitle: 'Selecciona el tipo de cálculo que deseas realizar',
            ),
            const SizedBox(height: AppStyles.spacingL),
            
            // Dropdown personalizado
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: AppStyles.spacingM),
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.dividerColor),
                borderRadius: BorderRadius.circular(AppStyles.radiusM),
                color: AppColors.surfaceColor,
              ),
              child: DropdownButton<String>(
                value: _selectedCalculation,
                hint: Text(
                  'Seleccione el tipo de cálculo',
                  style: AppStyles.bodyMedium.copyWith(
                    color: AppColors.textTertiaryColor,
                  ),
                ),
                isExpanded: true,
                icon: const Icon(Icons.arrow_drop_down, color: AppColors.accentColor),
                underline: const SizedBox(),
                style: AppStyles.bodyMedium,
                items: [
                  'Interés Compuesto - Monto Futuro',
                  'Interés Compuesto - Tasa de Interés',
                  'Interés Compuesto - Tiempo',
                  'Interés Compuesto - Capital Inicial',
                ].map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(
                      value,
                      overflow: TextOverflow.ellipsis,
                    ),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedCalculation = newValue;
                    _formattedResult = null;
                    _explanationText = null;
                  });
                },
              ),
            ),
            
            if (_selectedCalculation != null) ...[
              const SizedBox(height: AppStyles.spacingL),
              ..._buildInputFields(),
            ],
            
            const SizedBox(height: AppStyles.spacingL),
            CommonWidgets.buildCustomButton(
              text: 'Calcular',
              onPressed: _calculate,
              backgroundColor: AppColors.accentColor,
              icon: Icons.calculate,
              width: double.infinity,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultCard() {
    return Container(
      width: double.infinity,
      decoration: AppStyles.balanceCardDecoration,
      child: Padding(
        padding: const EdgeInsets.all(AppStyles.spacingL),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.textOnPrimary.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(AppStyles.radiusS),
                  ),
                  child: const Icon(
                    Icons.trending_up,
                    color: AppColors.textOnPrimary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: AppStyles.spacingS),
                Text(
                  'Resultado del Cálculo',
                  style: AppStyles.subheadingMedium.copyWith(
                    color: AppColors.textOnPrimary.withOpacity(0.8),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppStyles.spacingM),
            Text(
              _formattedResult!,
              style: AppStyles.balanceLarge,
              textAlign: TextAlign.center,
            ),
            if (_explanationText != null) ...[
              const SizedBox(height: AppStyles.spacingS),
              Text(
                _explanationText!,
                style: AppStyles.bodyMedium.copyWith(
                  color: AppColors.textOnPrimary.withOpacity(0.7),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildFormulasCard() {
    return Container(
      decoration: AppStyles.primaryCardDecoration,
      child: Padding(
        padding: const EdgeInsets.all(AppStyles.spacingL),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CommonWidgets.buildSectionHeader(
              title: 'Fórmulas utilizadas',
              subtitle: 'Ecuaciones matemáticas para cada cálculo',
            ),
            const SizedBox(height: AppStyles.spacingM),
            _buildFormulaItem(
              'Monto Futuro (F)',
              'F = P × (1 + r/n)^(n×t)',
              Icons.trending_up,
            ),
            CommonWidgets.buildDividerWithText(''),
            _buildFormulaItem(
              'Tasa de Interés (r)',
              'r = n × ((F/P)^(1/(n×t)) - 1) × 100',
              Icons.percent,
            ),
            CommonWidgets.buildDividerWithText(''),
            _buildFormulaItem(
              'Tiempo (t)',
              't = log(F/P) / (n × log(1 + r/n))',
              Icons.schedule,
            ),
            CommonWidgets.buildDividerWithText(''),
            _buildFormulaItem(
              'Capital Inicial (P)',
              'P = F / (1 + r/n)^(n×t)',
              Icons.savings,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCapitalizationCard() {
    return Container(
      decoration: AppStyles.primaryCardDecoration,
      child: Padding(
        padding: const EdgeInsets.all(AppStyles.spacingL),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CommonWidgets.buildSectionHeader(
              title: 'Frecuencia de capitalización',
              subtitle: 'Diferentes períodos de capitalización disponibles',
            ),
            const SizedBox(height: AppStyles.spacingM),
            _buildCapitalizationItem('Anual (n=1)', 'Una vez al año', Icons.calendar_month),
            _buildCapitalizationItem('Semestral (n=2)', 'Cada 6 meses', Icons.date_range),
            _buildCapitalizationItem('Trimestral (n=4)', 'Cada 3 meses', Icons.calendar_today),
            _buildCapitalizationItem('Mensual (n=12)', 'Mensualmente', Icons.repeat),
            _buildCapitalizationItem('Diaria (n=365)', 'Cada día', Icons.today),
          ],
        ),
      ),
    );
  }

  Widget _buildFormulaItem(String title, String formula, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppStyles.spacingS),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.accentColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppStyles.radiusS),
            ),
            child: Icon(
              icon,
              color: AppColors.accentColor,
              size: 20,
            ),
          ),
          const SizedBox(width: AppStyles.spacingM),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  formula,
                  style: AppStyles.bodySmall.copyWith(
                    fontFamily: 'Courier',
                    color: AppColors.textSecondaryColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCapitalizationItem(String title, String description, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppStyles.spacingS),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.accentColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppStyles.radiusS),
            ),
            child: Icon(
              icon,
              color: AppColors.accentColor,
              size: 16,
            ),
          ),
          const SizedBox(width: AppStyles.spacingM),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  description,
                  style: AppStyles.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildInputFields() {
    List<Widget> fields = [];

    Widget buildStyledField(
      TextEditingController controller,
      String label,
      String? helperText,
      IconData icon,
    ) {
      return Padding(
        padding: const EdgeInsets.only(bottom: AppStyles.spacingM),
        child: TextField(
          controller: controller,
          decoration: AppStyles.inputDecoration(
            label: label,
            icon: icon,
            hint: helperText,
          ),
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
          ],
          style: AppStyles.bodyMedium,
        ),
      );
    }

    if (_selectedCalculation == 'Interés Compuesto - Monto Futuro') {
      fields = [
        buildStyledField(
          _principalController,
          'Capital Inicial',
          'Cantidad inicial invertida',
          Icons.attach_money,
        ),
        buildStyledField(
          _rateController,
          'Tasa de Interés (%)',
          'Porcentaje anual',
          Icons.percent,
        ),
        buildStyledField(
          _timeCompoundingController,
          'Tiempo (años)',
          'Duración de la inversión',
          Icons.schedule,
        ),
        buildStyledField(
          _compoundingPeriodsController,
          'Períodos de Capitalización',
          '1=anual, 2=semestral, 4=trimestral, 12=mensual, 365=diario',
          Icons.repeat,
        ),
      ];
    } else if (_selectedCalculation == 'Interés Compuesto - Tasa de Interés') {
      fields = [
        buildStyledField(
          _futureValueController,
          'Monto Futuro',
          'Cantidad total al final',
          Icons.trending_up,
        ),
        buildStyledField(
          _principalController,
          'Capital Inicial',
          'Cantidad inicial invertida',
          Icons.attach_money,
        ),
        buildStyledField(
          _timeCompoundingController,
          'Tiempo (años)',
          'Duración de la inversión',
          Icons.schedule,
        ),
        buildStyledField(
          _compoundingPeriodsController,
          'Períodos de Capitalización',
          '1=anual, 2=semestral, 4=trimestral, 12=mensual, 365=diario',
          Icons.repeat,
        ),
      ];
    } else if (_selectedCalculation == 'Interés Compuesto - Tiempo') {
      fields = [
        buildStyledField(
          _futureValueController,
          'Monto Futuro',
          'Cantidad total al final',
          Icons.trending_up,
        ),
        buildStyledField(
          _principalController,
          'Capital Inicial',
          'Cantidad inicial invertida',
          Icons.attach_money,
        ),
        buildStyledField(
          _rateController,
          'Tasa de Interés (%)',
          'Porcentaje anual',
          Icons.percent,
        ),
        buildStyledField(
          _compoundingPeriodsController,
          'Períodos de Capitalización',
          '1=anual, 2=semestral, 4=trimestral, 12=mensual, 365=diario',
          Icons.repeat,
        ),
      ];
    } else if (_selectedCalculation == 'Interés Compuesto - Capital Inicial') {
      fields = [
        buildStyledField(
          _futureValueController,
          'Monto Futuro',
          'Cantidad total al final',
          Icons.trending_up,
        ),
        buildStyledField(
          _rateController,
          'Tasa de Interés (%)',
          'Porcentaje anual',
          Icons.percent,
        ),
        buildStyledField(
          _timeCompoundingController,
          'Tiempo (años)',
          'Duración de la inversión',
          Icons.schedule,
        ),
        buildStyledField(
          _compoundingPeriodsController,
          'Períodos de Capitalización',
          '1=anual, 2=semestral, 4=trimestral, 12=mensual, 365=diario',
          Icons.repeat,
        ),
      ];
    }

    return fields;
  }
}