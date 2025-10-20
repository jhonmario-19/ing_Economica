import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:billetera/models/interest_calculator.dart';
import 'package:billetera/constants/app_colors.dart';
import 'package:billetera/constants/app_styles.dart';
import 'package:billetera/constants/app_common_widget.dart';

class InterestSimpleScreen extends StatefulWidget {
  @override
  _InterestSimpleScreenState createState() => _InterestSimpleScreenState();
}

class _InterestSimpleScreenState extends State<InterestSimpleScreen> {
  final InterestCalculator _calculator = InterestCalculator();
  String? _selectedCalculation;
  final TextEditingController _principalController = TextEditingController();
  final TextEditingController _rateController = TextEditingController();
  final TextEditingController _daysController = TextEditingController();
  final TextEditingController _monthsController = TextEditingController();
  final TextEditingController _yearsController = TextEditingController();
  final TextEditingController _futureValueController = TextEditingController();
  final TextEditingController _interestController = TextEditingController();

  double? _result;
  String? _formattedResult;
  String? _explanationText;

  void _calculate() {
    final double principal =
        double.tryParse(_principalController.text.replaceAll(',', '.')) ?? 0;
    final double rate =
        double.tryParse(_rateController.text.replaceAll(',', '.')) ?? 0;
    final double days =
        double.tryParse(_daysController.text.replaceAll(',', '.')) ?? 0;
    final double months =
        double.tryParse(_monthsController.text.replaceAll(',', '.')) ?? 0;
    final double years =
        double.tryParse(_yearsController.text.replaceAll(',', '.')) ?? 0;
    final double time = _calculator.convertTimeToYears(days, months, years);
    final double futureValue =
        double.tryParse(_futureValueController.text.replaceAll(',', '.')) ?? 0;
    final double interest =
        double.tryParse(_interestController.text.replaceAll(',', '.')) ?? 0;

    setState(() {
      _result = _calculator.calculate(_selectedCalculation!, principal, rate,
          time, futureValue, interest, 1, 1);

      if (_selectedCalculation!.contains('Tasa de Interés')) {
        _formattedResult = NumberFormat("##0.00%").format(_result! / 100);
        _explanationText =
            "La tasa de interés es la cantidad que se cobra por el préstamo de dinero, expresada como porcentaje del capital prestado por un período de tiempo determinado.";
      } else if (_selectedCalculation == 'Interés Simple - Tiempo') {
        _formattedResult = _calculator.formatTime(_result!);
        _explanationText =
            "El tiempo es el período durante el cual se presta o invierte el capital. El resultado muestra el tiempo necesario para alcanzar el monto futuro con la tasa de interés especificada.";
      } else if (_selectedCalculation == 'Interés Simple - Capital Inicial') {
        _formattedResult = NumberFormat("#,##0.00").format(_result);
        _explanationText =
            "El capital inicial es el monto original de dinero que se presta o invierte antes de que se acumulen intereses.";
      } else {
        _formattedResult = NumberFormat("#,##0.00").format(_result);
        _explanationText =
            "El monto futuro es la suma del capital inicial más los intereses acumulados después del período de tiempo especificado.";
      }
    });

    // Mostrar notificación de éxito
    ScaffoldMessenger.of(context).showSnackBar(
      CommonWidgets.buildCustomSnackBar(
        message: 'Cálculo realizado exitosamente',
        type: SnackBarType.success,
      ),
    );
  }

  @override
  void dispose() {
    _principalController.dispose();
    _rateController.dispose();
    _daysController.dispose();
    _monthsController.dispose();
    _yearsController.dispose();
    _futureValueController.dispose();
    _interestController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        title: Text(
          'Interés Simple',
          style: AppStyles.headingSmall.copyWith(
            color: AppColors.textOnPrimary,
          ),
        ),
        backgroundColor: AppColors.primaryColor,
        elevation: 0,
        iconTheme: IconThemeData(color: AppColors.textOnPrimary),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppStyles.spacingM),
          child: Column(
            children: [
              // Tarjeta de explicación
              _buildExplanationCard(),
              const SizedBox(height: AppStyles.spacingM),

              // Tarjeta de calculadora
              _buildCalculatorCard(),

              // Resultado si existe
              if (_formattedResult != null) ...[
                const SizedBox(height: AppStyles.spacingM),
                _buildResultCard(),
              ],

              const SizedBox(height: AppStyles.spacingM),

              // Tarjeta de fórmulas
              _buildFormulasCard(),

              const SizedBox(height: AppStyles.spacingM),

              // Tarjeta de ejemplos prácticos
              _buildExamplesCard(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildExplanationCard() {
    return Container(
      padding: const EdgeInsets.all(AppStyles.spacingL),
      decoration: AppStyles.balanceCardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '¿Qué es el interés simple?',
            style: AppStyles.headingSmall.copyWith(
              color: AppColors.textOnPrimary,
            ),
          ),
          const SizedBox(height: AppStyles.spacingS),
          Text(
            'El interés simple es aquel que se calcula siempre sobre el capital inicial. '
            'A diferencia del interés compuesto, los intereses generados no producen nuevos intereses.',
            style: AppStyles.bodyMedium.copyWith(
              color: AppColors.textOnPrimary.withOpacity(0.9),
            ),
          ),
          const SizedBox(height: AppStyles.spacingM),
          Container(
            padding: const EdgeInsets.all(AppStyles.spacingM),
            decoration: BoxDecoration(
              color: AppColors.textOnPrimary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppStyles.radiusM),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Fórmula general:',
                  style: AppStyles.bodyMedium.copyWith(
                    color: AppColors.textOnPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: AppStyles.spacingXS),
                Text(
                  'Interés = Capital × Tasa × Tiempo',
                  style: AppStyles.bodyMedium.copyWith(
                    color: AppColors.textOnPrimary,
                    fontStyle: FontStyle.italic,
                  ),
                ),
                const SizedBox(height: AppStyles.spacingXS),
                Text(
                  'Monto Final = Capital + Interés',
                  style: AppStyles.bodyMedium.copyWith(
                    color: AppColors.textOnPrimary,
                    fontStyle: FontStyle.italic,
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
      padding: const EdgeInsets.all(AppStyles.spacingL),
      decoration: AppStyles.primaryCardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Calculadora de Interés Simple',
            style: AppStyles.headingSmall.copyWith(
              color: AppColors.primaryColor,
            ),
          ),
          const SizedBox(height: AppStyles.spacingL),

          // Dropdown para tipo de cálculo
          Container(
            padding: const EdgeInsets.symmetric(horizontal: AppStyles.spacingM),
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.dividerColor),
              borderRadius: BorderRadius.circular(AppStyles.radiusM),
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
              icon: Icon(Icons.arrow_drop_down, color: AppColors.accentColor),
              underline: const SizedBox(),
              style: AppStyles.bodyMedium,
              items: [
                'Interés Simple - Monto Futuro',
                'Interés Simple - Tasa de Interés',
                'Interés Simple - Tiempo',
                'Interés Simple - Capital Inicial',
              ].map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
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
          const SizedBox(height: AppStyles.spacingL),

          // Campos de entrada
          if (_selectedCalculation != null) ..._buildInputFields(),

          const SizedBox(height: AppStyles.spacingL),

          // Botón de cálculo
          Center(
            child: CommonWidgets.buildCustomButton(
              text: 'Calcular',
              onPressed: _selectedCalculation != null ? _calculate : () {},
              backgroundColor: AppColors.accentColor,
              icon: Icons.calculate,
              width: double.infinity,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppStyles.spacingL),
      decoration: AppStyles.getColoredCardDecoration(AppColors.successColor),
      child: Column(
        children: [
          Text(
            'Resultado:',
            style: AppStyles.subheadingMedium.copyWith(
              color: AppColors.textOnPrimary,
            ),
          ),
          const SizedBox(height: AppStyles.spacingM),
          Text(
            _formattedResult!,
            style: AppStyles.balanceMedium,
          ),
          if (_explanationText != null) ...[
            const SizedBox(height: AppStyles.spacingM),
            Text(
              _explanationText!,
              style: AppStyles.bodyMedium.copyWith(
                color: AppColors.textOnPrimary.withOpacity(0.9),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildFormulasCard() {
    return Container(
      padding: const EdgeInsets.all(AppStyles.spacingL),
      decoration: AppStyles.primaryCardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CommonWidgets.buildSectionHeader(
            title: 'Fórmulas utilizadas',
            subtitle: 'Ecuaciones matemáticas para cada tipo de cálculo',
          ),
          const SizedBox(height: AppStyles.spacingM),
          _buildFormulaItem(
            'Monto Futuro (F)',
            'F = P × (1 + r × t)',
            'Donde P es el capital inicial, r es la tasa de interés (en decimal) y t es el tiempo en años.',
          ),
          const Divider(color: AppColors.dividerColor),
          _buildFormulaItem(
            'Tasa de Interés (r)',
            'r = (F/P - 1) ÷ t × 100',
            'Donde F es el monto futuro, P es el capital inicial y t es el tiempo en años.',
          ),
          const Divider(color: AppColors.dividerColor),
          _buildFormulaItem(
            'Tiempo (t)',
            't = (F/P - 1) ÷ r × 100',
            'Donde F es el monto futuro, P es el capital inicial y r es la tasa de interés (en porcentaje).',
          ),
          const Divider(color: AppColors.dividerColor),
          _buildFormulaItem(
            'Capital Inicial (P)',
            'P = I ÷ (r × t ÷ 100)',
            'Donde I es el interés generado, r es la tasa de interés (en porcentaje) y t es el tiempo en años.',
          ),
        ],
      ),
    );
  }

  Widget _buildExamplesCard() {
    return Container(
      padding: const EdgeInsets.all(AppStyles.spacingL),
      decoration: AppStyles.primaryCardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CommonWidgets.buildSectionHeader(
            title: 'Ejemplos prácticos',
            subtitle: 'Casos de uso comunes del interés simple',
          ),
          const SizedBox(height: AppStyles.spacingM),
          _buildExampleItem(
            '1',
            'Si inviertes \$10,000 a una tasa de interés simple del 5% anual durante 3 años, recibirás un monto final de \$11,500.',
          ),
          const SizedBox(height: AppStyles.spacingM),
          _buildExampleItem(
            '2',
            'Para obtener \$500 de interés con un capital de \$10,000 a una tasa del 2% anual, necesitarás mantener la inversión por 2.5 años.',
          ),
        ],
      ),
    );
  }

  Widget _buildExampleItem(String number, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(AppStyles.spacingS),
          decoration: BoxDecoration(
            color: AppColors.accentColor.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Text(
            number,
            style: AppStyles.bodyMedium.copyWith(
              color: AppColors.accentColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(width: AppStyles.spacingM),
        Expanded(
          child: Text(
            text,
            style: AppStyles.bodyMedium,
          ),
        ),
      ],
    );
  }

  Widget _buildFormulaItem(String title, String formula, String explanation) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppStyles.spacingS),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppStyles.subheadingSmall.copyWith(
              color: AppColors.accentColor,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppStyles.spacingXS),
          Text(
            formula,
            style: AppStyles.bodyMedium.copyWith(
              fontStyle: FontStyle.italic,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: AppStyles.spacingXS),
          Text(
            explanation,
            style: AppStyles.bodySmall,
          ),
        ],
      ),
    );
  }

  List<Widget> _buildInputFields() {
    List<Widget> fields = [];

    Widget buildField(
      TextEditingController controller,
      String label,
      IconData icon,
      String? helperText,
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

    if (_selectedCalculation == 'Interés Simple - Monto Futuro') {
      fields = [
        buildField(
          _principalController,
          'Capital Inicial',
          Icons.attach_money,
          'Cantidad inicial de dinero invertida o prestada',
        ),
        buildField(
          _rateController,
          'Tasa de Interés (%)',
          Icons.percent,
          'Porcentaje anual de interés',
        ),
        buildField(
          _yearsController,
          'Años',
          Icons.calendar_today,
          'Número de años del período',
        ),
        buildField(
          _monthsController,
          'Meses',
          Icons.calendar_month,
          'Número de meses adicionales (opcional)',
        ),
        buildField(
          _daysController,
          'Días',
          Icons.today,
          'Número de días adicionales (opcional)',
        ),
      ];
    } else if (_selectedCalculation == 'Interés Simple - Tasa de Interés') {
      fields = [
        buildField(
          _principalController,
          'Capital Inicial',
          Icons.attach_money,
          'Cantidad inicial de dinero invertida o prestada',
        ),
        buildField(
          _futureValueController,
          'Monto Futuro',
          Icons.account_balance_wallet,
          'Cantidad total al final del período',
        ),
        buildField(
          _yearsController,
          'Años',
          Icons.calendar_today,
          'Número de años del período',
        ),
        buildField(
          _monthsController,
          'Meses',
          Icons.calendar_month,
          'Número de meses adicionales (opcional)',
        ),
        buildField(
          _daysController,
          'Días',
          Icons.today,
          'Número de días adicionales (opcional)',
        ),
      ];
    } else if (_selectedCalculation == 'Interés Simple - Tiempo') {
      fields = [
        buildField(
          _principalController,
          'Capital Inicial',
          Icons.attach_money,
          'Cantidad inicial de dinero invertida o prestada',
        ),
        buildField(
          _futureValueController,
          'Monto Futuro',
          Icons.account_balance_wallet,
          'Cantidad total al final del período',
        ),
        buildField(
          _rateController,
          'Tasa de Interés (%)',
          Icons.percent,
          'Porcentaje anual de interés',
        ),
      ];
    } else if (_selectedCalculation == 'Interés Simple - Capital Inicial') {
      fields = [
        buildField(
          _interestController,
          'Interés',
          Icons.attach_money,
          'Monto de interés generado durante el período',
        ),
        buildField(
          _rateController,
          'Tasa de Interés (%)',
          Icons.percent,
          'Porcentaje anual de interés',
        ),
        buildField(
          _yearsController,
          'Años',
          Icons.calendar_today,
          'Número de años del período',
        ),
        buildField(
          _monthsController,
          'Meses',
          Icons.calendar_month,
          'Número de meses adicionales (opcional)',
        ),
        buildField(
          _daysController,
          'Días',
          Icons.today,
          'Número de días adicionales (opcional)',
        ),
      ];
    }

    return fields;
  }
}