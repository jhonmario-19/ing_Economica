import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'dart:math';
import 'package:billetera/constants/app_colors.dart';
import 'package:billetera/constants/app_styles.dart';
import 'package:billetera/constants/app_common_widget.dart';

class AnnuityScreen extends StatefulWidget {
  @override
  _AnnuityScreenState createState() => _AnnuityScreenState();
}

class _AnnuityScreenState extends State<AnnuityScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _rateController = TextEditingController();
  final _periodsController = TextEditingController();
  final _deferredPeriodsController = TextEditingController();

  String _selectedCalculationType = 'Valor Futuro';
  String _selectedAnnuityType = 'Ordinaria (Vencida)';
  String _selectedPaymentFrequency = 'Anual';
  String _result = '';
  String _formattedResult = '';
  bool _showTheory = false;

  @override
  void dispose() {
    _amountController.dispose();
    _rateController.dispose();
    _periodsController.dispose();
    _deferredPeriodsController.dispose();
    super.dispose();
  }

  void _calculate() {
    if (_formKey.currentState!.validate()) {
      try {
        double amount = double.parse(_amountController.text);
        double rate = double.parse(_rateController.text) / 100;
        int periods = int.parse(_periodsController.text);
        int deferredPeriods = _selectedAnnuityType == 'Diferida'
            ? int.parse(_deferredPeriodsController.text)
            : 0;

        double result = 0;

        // Ajustar la tasa según la frecuencia de pago
        double adjustedRate = _adjustRateByFrequency(rate);
        int adjustedPeriods = _adjustPeriodsByFrequency(periods);
        int adjustedDeferredPeriods = _adjustPeriodsByFrequency(deferredPeriods);

        if (_selectedCalculationType == 'Valor Futuro') {
          if (_selectedAnnuityType == 'Ordinaria (Vencida)') {
            result = amount *
                ((pow(1 + adjustedRate, adjustedPeriods) - 1) / adjustedRate);
          } else if (_selectedAnnuityType == 'Anticipada') {
            result = amount *
                ((pow(1 + adjustedRate, adjustedPeriods) - 1) *
                    (1 + adjustedRate) /
                    adjustedRate);
          } else if (_selectedAnnuityType == 'Diferida') {
            result = amount *
                ((pow(1 + adjustedRate, adjustedPeriods) - 1) / adjustedRate) *
                pow(1 + adjustedRate, adjustedDeferredPeriods);
          }
        } else if (_selectedCalculationType == 'Valor Presente') {
          if (_selectedAnnuityType == 'Ordinaria (Vencida)') {
            result = amount *
                (1 - pow(1 + adjustedRate, -adjustedPeriods)) /
                adjustedRate;
          } else if (_selectedAnnuityType == 'Anticipada') {
            result = amount *
                (1 - pow(1 + adjustedRate, -adjustedPeriods)) *
                (1 + adjustedRate) /
                adjustedRate;
          } else if (_selectedAnnuityType == 'Diferida') {
            result = amount *
                (1 - pow(1 + adjustedRate, -adjustedPeriods)) /
                adjustedRate *
                pow(1 + adjustedRate, -adjustedDeferredPeriods);
          }
        } else if (_selectedCalculationType == 'Monto de la Anualidad') {
          if (_selectedAnnuityType == 'Ordinaria (Vencida)') {
            result = amount *
                adjustedRate /
                (1 - pow(1 + adjustedRate, -adjustedPeriods));
          } else if (_selectedAnnuityType == 'Anticipada') {
            result = amount *
                adjustedRate /
                (1 - pow(1 + adjustedRate, -adjustedPeriods)) /
                (1 + adjustedRate);
          } else if (_selectedAnnuityType == 'Diferida') {
            result = amount *
                adjustedRate /
                (1 - pow(1 + adjustedRate, -adjustedPeriods)) *
                pow(1 + adjustedRate, adjustedDeferredPeriods);
          }
        }

        setState(() {
          _result = '${_selectedCalculationType}: \$${result.toStringAsFixed(2)}';
          _formattedResult = NumberFormat("#,##0.00").format(result);
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
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        CommonWidgets.buildCustomSnackBar(
          message: 'Por favor completa todos los campos requeridos',
          type: SnackBarType.warning,
        ),
      );
    }
  }

  void _clearFields() {
    setState(() {
      _amountController.clear();
      _rateController.clear();
      _periodsController.clear();
      _deferredPeriodsController.clear();
      _selectedCalculationType = 'Valor Futuro';
      _selectedAnnuityType = 'Ordinaria (Vencida)';
      _selectedPaymentFrequency = 'Anual';
      _result = '';
      _formattedResult = '';
    });
  }

  double _adjustRateByFrequency(double annualRate) {
    switch (_selectedPaymentFrequency) {
      case 'Anual':
        return annualRate;
      case 'Semestral':
        return annualRate / 2;
      case 'Trimestral':
        return annualRate / 4;
      case 'Mensual':
        return annualRate / 12;
      default:
        return annualRate;
    }
  }

  int _adjustPeriodsByFrequency(int years) {
    switch (_selectedPaymentFrequency) {
      case 'Anual':
        return years;
      case 'Semestral':
        return years * 2;
      case 'Trimestral':
        return years * 4;
      case 'Mensual':
        return years * 12;
      default:
        return years;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        title: Text(
          'Cálculo de Anualidades',
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
            _buildTheoryToggle(),
            if (_showTheory) ...[
              const SizedBox(height: AppStyles.spacingM),
              _buildTheorySection(),
            ],
            const SizedBox(height: AppStyles.spacingM),
            _buildCalculatorSection(),
            if (_formattedResult.isNotEmpty) ...[
              const SizedBox(height: AppStyles.spacingM),
              _buildResultCard(),
            ],
            const SizedBox(height: AppStyles.spacingXL),
          ],
        ),
      ),
    );
  }

  Widget _buildTheoryToggle() {
    return CommonWidgets.buildCustomButton(
      text: _showTheory ? 'Ocultar Teoría' : 'Mostrar Teoría',
      onPressed: () {
        setState(() {
          _showTheory = !_showTheory;
        });
      },
      backgroundColor: AppColors.primaryColor,
      icon: _showTheory ? Icons.visibility_off : Icons.visibility,
      width: double.infinity,
    );
  }

  Widget _buildTheorySection() {
    return Container(
      decoration: AppStyles.primaryCardDecoration,
      child: Padding(
        padding: const EdgeInsets.all(AppStyles.spacingL),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CommonWidgets.buildSectionHeader(
              title: 'Conceptos Básicos de Anualidades',
              subtitle: 'Fundamentos teóricos y fórmulas principales',
            ),
            const SizedBox(height: AppStyles.spacingM),
            Text(
              'Las anualidades son pagos periódicos iguales que no necesariamente tienen que ser anuales. Son una sucesión de pagos generalmente iguales que se proyectan en períodos constantes de tiempo.',
              style: AppStyles.bodyMedium,
            ),
            const SizedBox(height: AppStyles.spacingL),
            
            _buildTheorySubsection(
              'Tipos de Anualidades',
              [
                _buildAnnuityTypeCard(
                  'Anualidades Ordinarias o Vencidas',
                  'Los pagos se realizan al final de cada intervalo.',
                  'Ejemplos: cuotas vencidas, salario al final del mes.',
                  Icons.schedule,
                ),
                _buildAnnuityTypeCard(
                  'Anualidades Anticipadas',
                  'Los pagos se realizan al principio del intervalo.',
                  'Ejemplos: alquileres, primas de seguro.',
                  Icons.fast_forward,
                ),
                _buildAnnuityTypeCard(
                  'Anualidades Diferidas',
                  'La primera renta se realiza algún tiempo después de finalizado el primer intervalo.',
                  'Ejemplo: préstamo con período de gracia.',
                  Icons.schedule_send,
                ),
              ],
            ),
            
            const SizedBox(height: AppStyles.spacingL),
            _buildFormulasSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildTheorySubsection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppStyles.headingSmall.copyWith(
            color: AppColors.accentColor,
          ),
        ),
        const SizedBox(height: AppStyles.spacingM),
        ...children,
      ],
    );
  }

  Widget _buildAnnuityTypeCard(String title, String description, String examples, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppStyles.spacingS),
      padding: const EdgeInsets.all(AppStyles.spacingM),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(AppStyles.radiusM),
        border: Border.all(color: AppColors.dividerColor),
      ),
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
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: AppStyles.spacingXS),
                Text(
                  description,
                  style: AppStyles.bodySmall,
                ),
                const SizedBox(height: AppStyles.spacingXS),
                Text(
                  examples,
                  style: AppStyles.bodySmall.copyWith(
                    fontStyle: FontStyle.italic,
                    color: AppColors.textTertiaryColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormulasSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Fórmulas Principales',
          style: AppStyles.headingSmall.copyWith(
            color: AppColors.accentColor,
          ),
        ),
        const SizedBox(height: AppStyles.spacingM),
        _buildFormulaCard(
          'Valor Futuro (Ordinaria)',
          'VF = A × [(1 + i)ⁿ - 1] / i',
          'VF = Valor Futuro\nA = Monto de la anualidad\ni = Tasa de interés por período\nn = Número de períodos',
          Icons.trending_up,
        ),
        _buildFormulaCard(
          'Valor Presente (Ordinaria)',
          'VA = A × [1 - (1 + i)⁻ⁿ] / i',
          'VA = Valor Actual o Presente\nA = Monto de la anualidad\ni = Tasa de interés por período\nn = Número de períodos',
          Icons.savings,
        ),
        _buildFormulaCard(
          'Valor Futuro (Anticipada)',
          'VF = A × [(1 + i)ⁿ - 1] × (1 + i) / i',
          'Para anualidades anticipadas, se multiplica por (1+i) adicional',
          Icons.fast_forward,
        ),
        _buildFormulaCard(
          'Valor Presente (Anticipada)',
          'VA = A × [1 - (1 + i)⁻ⁿ] × (1 + i) / i',
          'Para anualidades anticipadas, se multiplica por (1+i) adicional',
          Icons.payment,
        ),
      ],
    );
  }

  Widget _buildFormulaCard(String title, String formula, String description, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppStyles.spacingM),
      decoration: AppStyles.simpleCardDecoration,
      child: Padding(
        padding: const EdgeInsets.all(AppStyles.spacingM),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
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
                const SizedBox(width: AppStyles.spacingS),
                Text(
                  title,
                  style: AppStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppStyles.spacingS),
            Container(
              padding: const EdgeInsets.all(AppStyles.spacingS),
              decoration: BoxDecoration(
                color: AppColors.cardBackground,
                borderRadius: BorderRadius.circular(AppStyles.radiusS),
              ),
              child: Text(
                formula,
                style: AppStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                  fontFamily: 'monospace',
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: AppStyles.spacingS),
            Text(
              description,
              style: AppStyles.bodySmall,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCalculatorSection() {
    return Container(
      decoration: AppStyles.primaryCardDecoration,
      child: Padding(
        padding: const EdgeInsets.all(AppStyles.spacingL),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CommonWidgets.buildSectionHeader(
                title: 'Calculadora de Anualidades',
                subtitle: 'Configura los parámetros de tu cálculo',
              ),
              const SizedBox(height: AppStyles.spacingL),
              
              _buildDropdownField(
                'Tipo de Cálculo',
                _selectedCalculationType,
                ['Valor Futuro', 'Valor Presente', 'Monto de la Anualidad'],
                Icons.calculate,
                (value) {
                  setState(() {
                    _selectedCalculationType = value!;
                  });
                },
              ),
              const SizedBox(height: AppStyles.spacingM),
              
              _buildDropdownField(
                'Tipo de Anualidad',
                _selectedAnnuityType,
                ['Ordinaria (Vencida)', 'Anticipada', 'Diferida'],
                Icons.category,
                (value) {
                  setState(() {
                    _selectedAnnuityType = value!;
                  });
                },
              ),
              const SizedBox(height: AppStyles.spacingM),
              
              _buildDropdownField(
                'Frecuencia de Pago',
                _selectedPaymentFrequency,
                ['Anual', 'Semestral', 'Trimestral', 'Mensual'],
                Icons.schedule,
                (value) {
                  setState(() {
                    _selectedPaymentFrequency = value!;
                  });
                },
              ),
              const SizedBox(height: AppStyles.spacingL),
              
              _buildTextFormField(
                _amountController,
                _selectedCalculationType == 'Monto de la Anualidad'
                    ? 'Valor a calcular'
                    : 'Monto de la Anualidad (\$)',
                'Ingrese el monto',
                Icons.attach_money,
              ),
              const SizedBox(height: AppStyles.spacingM),
              
              _buildTextFormField(
                _rateController,
                'Tasa de Interés Anual (%)',
                'Ingrese la tasa de interés',
                Icons.percent,
              ),
              const SizedBox(height: AppStyles.spacingM),
              
              _buildTextFormField(
                _periodsController,
                'Número de Períodos (años)',
                'Ingrese el número de períodos',
                Icons.timeline,
              ),
              
              if (_selectedAnnuityType == 'Diferida') ...[
                const SizedBox(height: AppStyles.spacingM),
                _buildTextFormField(
                  _deferredPeriodsController,
                  'Períodos de Diferimiento (años)',
                  'Ingrese los períodos de diferimiento',
                  Icons.schedule_send,
                ),
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
                    Icons.assessment,
                    color: AppColors.textOnPrimary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: AppStyles.spacingS),
                Text(
                  _selectedCalculationType,
                  style: AppStyles.subheadingMedium.copyWith(
                    color: AppColors.textOnPrimary.withOpacity(0.8),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppStyles.spacingM),
            Text(
              '\$${_formattedResult}',
              style: AppStyles.balanceLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppStyles.spacingS),
            Text(
              '${_selectedAnnuityType} - ${_selectedPaymentFrequency}',
              style: AppStyles.bodyMedium.copyWith(
                color: AppColors.textOnPrimary.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdownField(
    String label,
    String value,
    List<String> items,
    IconData icon,
    void Function(String?) onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppStyles.bodyMedium.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: AppStyles.spacingS),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: AppStyles.spacingM),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.dividerColor),
            borderRadius: BorderRadius.circular(AppStyles.radiusM),
            color: AppColors.surfaceColor,
          ),
          child: Row(
            children: [
              Icon(icon, color: AppColors.textTertiaryColor, size: 20),
              const SizedBox(width: AppStyles.spacingS),
              Expanded(
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    isExpanded: true,
                    value: value,
                    style: AppStyles.bodyMedium,
                    icon: const Icon(Icons.arrow_drop_down, color: AppColors.accentColor),
                    items: items.map((String item) {
                      return DropdownMenuItem<String>(
                        value: item,
                        child: Text(item),
                      );
                    }).toList(),
                    onChanged: onChanged,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTextFormField(
    TextEditingController controller,
    String label,
    String hintText,
    IconData icon,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppStyles.bodyMedium.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: AppStyles.spacingS),
        TextFormField(
          controller: controller,
          decoration: AppStyles.inputDecoration(
            label: '',
            icon: icon,
            hint: hintText,
          ),
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
          ],
          style: AppStyles.bodyMedium,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Este campo es obligatorio';
            }
            if (double.tryParse(value) == null) {
              return 'Ingrese un valor numérico válido';
            }
            return null;
          },
        ),
      ],
    );
  }
}