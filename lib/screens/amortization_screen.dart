import 'package:flutter/material.dart';
import 'package:billetera/constants/app_colors.dart';
import 'package:billetera/constants/app_styles.dart';
import 'package:billetera/constants/app_common_widget.dart';
import 'amortization_german_screen.dart';
import 'amortization_french_screen.dart';
import 'amortization_american_screen.dart';

class AmortizationScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text(
          'Sistemas de Amortización',
          style: AppStyles.headingMedium.copyWith(color: AppColors.textOnPrimary),
        ),
        backgroundColor: AppColors.primaryColor,
        elevation: 0,
        iconTheme: IconThemeData(color: AppColors.textOnPrimary),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildIntroductionCard(),
            SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Text(
                'Sistemas disponibles',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            _buildMethodButton(
              context,
              'Sistema Francés',
              'Cuotas fijas a lo largo del tiempo',
              AmortizationFrenchScreen(),
              Icons.account_balance,
              Colors.pink[100]!,
            ),
            SizedBox(height: 12),
            _buildMethodButton(
              context,
              'Sistema Alemán',
              'Cuotas decrecientes en el tiempo',
              AmortizationGermanScreen(),
              Icons.trending_down,
              Colors.purple[100]!,
            ),
            SizedBox(height: 12),
            _buildMethodButton(
              context,
              'Sistema Americano',
              'Pago de intereses y capital al final',
              AmortizationAmericanScreen(),
              Icons.timeline,
              Colors.blue[100]!,
            ),
            SizedBox(height: 24),
            _buildComparisonCard(),
            SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildIntroductionCard() {
    return Container(
      margin: EdgeInsets.all(16),
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primaryColor, Color(0xFF3A1C6C)],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryColor.withOpacity(0.3),
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
              Icon(Icons.info_outline, color: Colors.white70, size: 24),
              SizedBox(width: 8),
              Text(
                'Sistemas de Amortización',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          Text(
            'La amortización es el proceso de pago de una deuda a lo largo del tiempo mediante pagos periódicos que incluyen capital e intereses.',
            style: TextStyle(color: Colors.white70, fontSize: 14, height: 1.5),
          ),
          SizedBox(height: 8),
          Text(
            'Existen varios sistemas que afectan la distribución de los pagos y el costo total del préstamo.',
            style: TextStyle(color: Colors.white70, fontSize: 14, height: 1.5),
          ),
        ],
      ),
    );
  }

  Widget _buildComparisonCard() {
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
              Icon(Icons.compare_arrows, color: AppColors.primaryColor, size: 24),
              SizedBox(width: 8),
              Text(
                'Comparación de Sistemas',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryColor,
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          _buildComparisonRow(
            'Francés',
            'Cuota fija',
            'Préstamos a largo plazo',
            Colors.pink,
          ),
          Divider(height: 24),
          _buildComparisonRow(
            'Alemán',
            'Cuota decreciente',
            'Empresas y corto plazo',
            Colors.purple,
          ),
          Divider(height: 24),
          _buildComparisonRow(
            'Americano',
            'Solo intereses',
            'Inversionistas con liquidez futura',
            Colors.blue,
          ),
          SizedBox(height: 16),
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.orange[50],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(Icons.lightbulb_outline, color: Colors.orange[700], size: 20),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Cada sistema tiene ventajas según el tipo de financiamiento y capacidad de pago.',
                    style: TextStyle(
                      fontSize: 12,
                      fontStyle: FontStyle.italic,
                      color: Colors.orange[900],
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

  Widget _buildComparisonRow(String title, String cuota, String ideal, Color color) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 50,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: AppColors.textPrimaryColor,
                ),
              ),
              SizedBox(height: 4),
              Text(
                cuota,
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondaryColor,
                ),
              ),
              SizedBox(height: 2),
              Text(
                ideal,
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondaryColor,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMethodButton(
    BuildContext context,
    String title,
    String subtitle,
    Widget screen,
    IconData icon,
    Color bgColor,
  ) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => screen),
            );
          },
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: bgColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: AppColors.primaryColor, size: 28),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: AppColors.textPrimaryColor,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  color: AppColors.textSecondaryColor,
                  size: 18,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}