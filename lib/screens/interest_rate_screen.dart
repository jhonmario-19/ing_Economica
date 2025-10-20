import 'package:flutter/material.dart';
import 'package:billetera/constants/app_colors.dart';
import 'package:billetera/constants/app_styles.dart';

class InterestRateScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        title: Text(
          'Información de Tasas de Interés',
          style: AppStyles.headingMedium.copyWith(color: AppColors.textOnPrimary),
        ),
        backgroundColor: AppColors.primaryColor,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textOnPrimary),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppStyles.spacingM),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: AppStyles.spacingL),
            _buildInfoCard('Interés Simple', _buildSimpleInterestInfo()),
            const SizedBox(height: AppStyles.spacingM),
            _buildInfoCard('Interés Compuesto', _buildCompoundInterestInfo()),
            const SizedBox(height: AppStyles.spacingM),
            _buildInfoCard('Tasa de Interés Económica', _buildEconomicRateInfo()),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      margin: const EdgeInsets.only(bottom: AppStyles.spacingL),
      padding: const EdgeInsets.all(AppStyles.spacingL),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(AppStyles.radiusL),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryColor.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.trending_up, 
            color: AppColors.textOnPrimary, 
            size: 40
          ),
          const SizedBox(height: AppStyles.spacingM),
          Text(
            'Tasas de Interés',
            style: AppStyles.headingMedium.copyWith(
              color: AppColors.textOnPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: AppStyles.spacingS),
          Text(
            'La tasa de interés es el porcentaje que se cobra sobre un monto de dinero prestado o invertido durante un período.',
            style: AppStyles.bodyMedium.copyWith(
              color: AppColors.textOnPrimary.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(String title, Widget content) {
    return Container(
      decoration: AppStyles.primaryCardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppStyles.spacingM),
            decoration: BoxDecoration(
              color: AppColors.primaryColor.withOpacity(0.05),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(AppStyles.radiusM),
                topRight: Radius.circular(AppStyles.radiusM),
              ),
            ),
            child: Text(
              title,
              style: AppStyles.headingSmall.copyWith(
                color: AppColors.primaryColor,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(AppStyles.spacingM),
            child: content,
          ),
        ],
      ),
    );
  }

  Widget _buildSimpleInterestInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'El interés simple se calcula únicamente sobre el capital inicial durante todo el período.',
          style: AppStyles.bodyMedium,
        ),
        const SizedBox(height: AppStyles.spacingM),
        _buildFormulaBox(
          'Interés = Capital × Tasa × Tiempo',
          'Donde la tasa está expresada en decimal (5% = 0.05)',
        ),
        const SizedBox(height: AppStyles.spacingM),
        _buildExampleBox(
          'Ejemplo:',
          'Si inviertes \$1,000 a una tasa de interés del 5% anual durante 3 años:',
          'Interés = 1,000 × 0.05 × 3 = \$150',
          'Monto Final = \$1,000 + \$150 = \$1,150',
        ),
      ],
    );
  }

  Widget _buildCompoundInterestInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'El interés compuesto se calcula sobre el capital inicial y también sobre los intereses acumulados de períodos anteriores.',
          style: AppStyles.bodyMedium,
        ),
        const SizedBox(height: AppStyles.spacingM),
        _buildFormulaBox(
          'Monto Final = Capital × (1 + Tasa)^Tiempo',
          'Donde la tasa está expresada en decimal y el tiempo en períodos',
        ),
        const SizedBox(height: AppStyles.spacingM),
        _buildExampleBox(
          'Ejemplo:',
          'Si inviertes \$1,000 a una tasa de interés compuesto del 5% anual durante 3 años:',
          'Monto Final = 1,000 × (1 + 0.05)^3 = \$1,157.63',
          'Interés Total = \$1,157.63 - \$1,000 = \$157.63',
        ),
      ],
    );
  }

  Widget _buildEconomicRateInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'La tasa de interés económica considera el costo de oportunidad y otros factores económicos.',
          style: AppStyles.bodyMedium,
        ),
        const SizedBox(height: AppStyles.spacingM),
        Text(
          'Factores que influyen en la tasa de interés económica:',
          style: AppStyles.bodyMedium.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: AppStyles.spacingS),
        _buildBulletPoint('Inflación - Protege el poder adquisitivo del dinero'),
        _buildBulletPoint('Riesgo - Mayor riesgo implica mayor tasa'),
        _buildBulletPoint('Plazo - Períodos más largos suelen tener tasas más altas'),
        _buildBulletPoint('Liquidez - Menos liquidez, mayor tasa'),
        const SizedBox(height: AppStyles.spacingM),
        Container(
          padding: const EdgeInsets.all(AppStyles.spacingM),
          decoration: BoxDecoration(
            color: AppColors.infoLight,
            borderRadius: BorderRadius.circular(AppStyles.radiusS),
          ),
          child: Row(
            children: [
              Icon(Icons.info_outline, color: AppColors.infoColor),
              const SizedBox(width: AppStyles.spacingS),
              Expanded(
                child: Text(
                  'Para decisiones financieras óptimas, siempre compara la Tasa Efectiva Anual (TEA) entre diferentes opciones.',
                  style: AppStyles.bodySmall,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFormulaBox(String formula, String description) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppStyles.spacingM),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(AppStyles.radiusS),
        border: Border.all(color: AppColors.dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            formula,
            style: AppStyles.getCustomTextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimaryColor,
            ).copyWith(fontFamily: 'Courier'),
          ),
          const SizedBox(height: AppStyles.spacingXS),
          Text(
            description,
            style: AppStyles.bodySmall.copyWith(
              color: AppColors.textSecondaryColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExampleBox(
      String title, String scenario, String calculation, String result) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppStyles.spacingM),
      decoration: BoxDecoration(
        color: AppColors.infoLight,
        borderRadius: BorderRadius.circular(AppStyles.radiusS),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppStyles.bodyMedium.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.infoColor,
            ),
          ),
          const SizedBox(height: AppStyles.spacingXS),
          Text(
            scenario, 
            style: AppStyles.bodySmall
          ),
          const SizedBox(height: AppStyles.spacingXS),
          Text(
            calculation,
            style: AppStyles.bodySmall.copyWith(
              fontWeight: FontWeight.w500,
              color: AppColors.infoColor,
            ),
          ),
          const SizedBox(height: AppStyles.spacingXS),
          Text(
            result,
            style: AppStyles.bodySmall.copyWith(
              fontWeight: FontWeight.w500,
              color: AppColors.infoColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBulletPoint(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppStyles.spacingXS),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 8),
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: AppColors.primaryColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: AppStyles.spacingS),
          Expanded(
            child: Text(
              text, 
              style: AppStyles.bodyMedium
            ),
          ),
        ],
      ),
    );
  }
}