import 'package:flutter/material.dart';
import 'package:billetera/constants/app_colors.dart';
import 'package:billetera/constants/app_styles.dart';
import 'package:billetera/constants/app_common_widget.dart';
import 'interest_simple_screen.dart';
import 'interest_compound_screen.dart';
import 'annuity_screen.dart';
import 'interest_rate_screen.dart';
import 'arithmetic_gradient_screen.dart';
import 'geometric_gradient_screen.dart';
import 'amortization_screen.dart';
import 'irr_screen.dart';

class InterestCalculationScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: AppStyles.spacingM),
            _buildCalculationOptions(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(AppStyles.spacingL),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(AppStyles.radiusXXL),
          bottomRight: Radius.circular(AppStyles.radiusXXL),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryColor.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.max,
        children: [
          Text(
            'Herramientas Financieras',
            style: AppStyles.headingMedium.copyWith(
              color: AppColors.textOnPrimary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppStyles.spacingS),
          Text(
            'Selecciona un método de cálculo para comenzar',
            style: AppStyles.bodyMedium.copyWith(
              color: AppColors.textOnPrimary.withOpacity(0.8),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
      width: double.infinity,
    );
  }

  Widget _buildOptionCard(BuildContext context, Map<String, dynamic> option) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppStyles.spacingM),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(AppStyles.radiusL),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => option['screen']),
            );
          },
          child: Container(
            decoration: AppStyles.primaryCardDecoration,
            child: Padding(
              padding: const EdgeInsets.all(AppStyles.spacingL),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(AppStyles.spacingM),
                    decoration: BoxDecoration(
                      color: AppColors.accentColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(AppStyles.radiusM),
                    ),
                    child: Icon(
                      option['icon'],
                      color: AppColors.accentColor,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: AppStyles.spacingL),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          option['title'],
                          style: AppStyles.subheadingMedium.copyWith(
                            color: AppColors.textPrimaryColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: AppStyles.spacingXS),
                        Text(
                          option['description'],
                          style: AppStyles.bodySmall.copyWith(
                            color: AppColors.textSecondaryColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(AppStyles.spacingS),
                    decoration: BoxDecoration(
                      color: AppColors.cardBackground,
                      borderRadius: BorderRadius.circular(AppStyles.radiusS),
                    ),
                    child: Icon(
                      Icons.arrow_forward_ios,
                      color: AppColors.textTertiaryColor,
                      size: 16,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCalculationOptions(BuildContext context) {
    List<Map<String, dynamic>> options = [
      {
        'title': 'Interés Simple',
        'icon': Icons.trending_up,
        'screen': InterestSimpleScreen(),
        'description': 'Cálculo de capital, interés y tiempo'
      },
      {
        'title': 'Interés Compuesto',
        'icon': Icons.show_chart,
        'screen': InterestCompoundScreen(),
        'description': 'Valor futuro, presente y tasas efectivas'
      },
      {
        'title': 'Tasa de Interés',
        'icon': Icons.percent,
        'screen': InterestRateScreen(),
        'description': 'Cálculo y conversión de tasas'
      },
      {
        'title': 'Anualidades',
        'icon': Icons.calendar_today,
        'screen': AnnuityScreen(),
        'description': 'Series uniformes de pagos o cobros'
      },
      
      {
        'title': 'Gradiente Aritmético',
        'icon': Icons.stacked_line_chart,
        'screen': ArithmeticGradientScreen(),
        'description': 'Series con incremento constante'
      },
      {
        'title': 'Gradiente Geométrico',
        'icon': Icons.show_chart,
        'screen': GeometricGradientScreen(),
        'description': 'Series con incremento porcentual'
      },
      {
        'title': 'Amortización',
        'icon': Icons.table_chart,
        'screen': AmortizationScreen(),
        'description': 'Tablas de amortización: alemana, francesa y americana'
      },
      {
        'title': 'TIR',
        'icon': Icons.analytics,
        'screen': IRRScreen(),
        'description': 'Tasa Interna de Retorno para inversiones'
      },
    ];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppStyles.spacingL),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CommonWidgets.buildSectionHeader(
            title: 'Todos los cálculos',
            subtitle: 'Herramientas disponibles para tus cálculos financieros',
          ),
          const SizedBox(height: AppStyles.spacingL),
          ...options
              .map((option) => _buildOptionCard(context, option))
              .toList(),
        ],
      ),
    );
  }
}