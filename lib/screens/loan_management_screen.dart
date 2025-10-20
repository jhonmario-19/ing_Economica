import 'package:flutter/material.dart';
import 'package:billetera/models/loan_model.dart';
import 'package:billetera/services/loan_service.dart';
import 'package:billetera/screens/loan_request_screen.dart';
import 'package:billetera/screens/loan_details_screen.dart';
import 'package:billetera/constants/app_colors.dart';
import 'package:billetera/constants/app_styles.dart';
import 'package:intl/intl.dart';

class LoanManagementScreen extends StatefulWidget {
  @override
  _LoanManagementScreenState createState() => _LoanManagementScreenState();
}

class _LoanManagementScreenState extends State<LoanManagementScreen> {
  final LoanService _loanService = LoanService();
  List<LoanModel> _loans = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadLoans();
  }

  Future<void> _loadLoans() async {
    setState(() {
      _isLoading = true;
    });

    try {
      List<LoanModel> loans = await _loanService.getUserLoans();
      setState(() {
        _loans = loans;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.error, color: Colors.white),
              SizedBox(width: 12),
              Expanded(child: Text('Error al cargar préstamos: ${e.toString()}')),
            ],
          ),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Mis Préstamos'
            , style: TextStyle(color: Colors.white),
            textAlign: TextAlign.center,),
        backgroundColor: AppColors.primaryColor,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: true, // ← Esta línea es clave
        iconTheme: const IconThemeData(
          color: Colors.white, // ← Asegura contraste
        ),
        elevation: 0,
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(
                color: AppColors.primaryColor,
              ),
            )
          : RefreshIndicator(
              onRefresh: _loadLoans,
              color: AppColors.primaryColor,
              child: _buildLoansList(),
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => LoanRequestScreen()),
          );
          _loadLoans();
        },
        backgroundColor: AppColors.accentColor,
        icon: Icon(Icons.add),
        label: Text('Solicitar'),
      ),
    );
  }

  Widget _buildLoansList() {
    if (_loans.isEmpty) {
      return Center(
        child: SingleChildScrollView(
          physics: AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.account_balance,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                ),
                SizedBox(height: 24),
                Text(
                  'No tienes préstamos activos',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimaryColor,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Solicita tu primer préstamo de manera\nrápida y sencilla',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondaryColor,
                  ),
                ),
                SizedBox(height: 32),
                ElevatedButton.icon(
                  icon: Icon(Icons.add_circle_outline),
                  label: Text('Solicitar un préstamo'),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => LoanRequestScreen()),
                    ).then((_) => _loadLoans());
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accentColor,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return ListView.builder(
      physics: AlwaysScrollableScrollPhysics(),
      padding: EdgeInsets.all(16),
      itemCount: _loans.length,
      itemBuilder: (context, index) {
        return _buildLoanCard(_loans[index]);
      },
    );
  }

  Widget _buildLoanCard(LoanModel loan) {
    NumberFormat formatter = NumberFormat('#,###');
    Color statusColor;
    IconData statusIcon;

    switch (loan.status) {
      case 'pendiente':
        statusColor = Colors.orange;
        statusIcon = Icons.hourglass_empty;
        break;
      case 'aprobado':
        statusColor = Colors.green;
        statusIcon = Icons.check_circle;
        break;
      case 'rechazado':
        statusColor = Colors.red;
        statusIcon = Icons.cancel;
        break;
      case 'pagado':
        statusColor = Colors.blue;
        statusIcon = Icons.paid;
        break;
      default:
        statusColor = Colors.grey;
        statusIcon = Icons.help;
    }

    return Container(
      margin: EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
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
              MaterialPageRoute(
                builder: (context) => LoanDetailsScreen(loan: loan),
              ),
            ).then((_) => _loadLoans());
          },
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header con ID y estado
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: statusColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(statusIcon, size: 24, color: statusColor),
                        ),
                        SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Préstamo #${loan.id.substring(0, 6)}',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: AppColors.textPrimaryColor,
                              ),
                            ),
                            SizedBox(height: 4),
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: statusColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                loan.status.toUpperCase(),
                                style: TextStyle(
                                  color: statusColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 11,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                      color: Colors.grey[400],
                    ),
                  ],
                ),
                
                SizedBox(height: 20),
                
                // Información principal
                Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Monto',
                              style: TextStyle(
                                color: AppColors.textSecondaryColor,
                                fontSize: 12,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              '\$${formatter.format(loan.amount)}',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                color: AppColors.textPrimaryColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        width: 1,
                        height: 40,
                        color: Colors.grey[300],
                      ),
                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.only(left: 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Tasa',
                                style: TextStyle(
                                  color: AppColors.textSecondaryColor,
                                  fontSize: 12,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                '${loan.interestRate.toStringAsFixed(1)}%',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                  color: AppColors.textPrimaryColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Container(
                        width: 1,
                        height: 40,
                        color: Colors.grey[300],
                      ),
                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.only(left: 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Plazo',
                                style: TextStyle(
                                  color: AppColors.textSecondaryColor,
                                  fontSize: 12,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                '${loan.termMonths}m',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                  color: AppColors.textPrimaryColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Información adicional según estado
                if (loan.status == 'aprobado') ...[
                  SizedBox(height: 16),
                  Divider(),
                  SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Próximo pago',
                            style: TextStyle(
                              color: AppColors.textSecondaryColor,
                              fontSize: 12,
                            ),
                          ),
                          SizedBox(height: 4),
                          loan.nextPayment != null
                              ? Text(
                                  DateFormat('dd/MM/yyyy')
                                      .format(loan.nextPayment!.dueDate),
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textPrimaryColor,
                                  ),
                                )
                              : Text(
                                  'Sin pagos pendientes',
                                  style: TextStyle(
                                    color: Colors.green,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            'Monto pendiente',
                            style: TextStyle(
                              color: AppColors.textSecondaryColor,
                              fontSize: 12,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            '\$${formatter.format(loan.pendingAmount)}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AppColors.accentColor,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
                
                if (loan.status == 'pendiente') ...[
                  SizedBox(height: 16),
                  Row(
                    children: [
                      Icon(
                        Icons.schedule,
                        size: 14,
                        color: Colors.grey[600],
                      ),
                      SizedBox(width: 6),
                      Text(
                        'Solicitado el ${DateFormat('dd/MM/yyyy').format(loan.requestDate)}',
                        style: TextStyle(
                          color: AppColors.textSecondaryColor,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}