import 'package:flutter/material.dart';
import 'package:billetera/models/loan_model.dart';
import 'package:billetera/services/loan_service.dart';
import 'package:billetera/constants/app_colors.dart';
import 'package:billetera/constants/app_styles.dart';
import 'package:intl/intl.dart';

class LoanDetailsScreen extends StatefulWidget {
  final LoanModel loan;

  const LoanDetailsScreen({Key? key, required this.loan}) : super(key: key);

  @override
  _LoanDetailsScreenState createState() => _LoanDetailsScreenState();
}

class _LoanDetailsScreenState extends State<LoanDetailsScreen> {
  final LoanService _loanService = LoanService();
  bool _isProcessing = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
       backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text('Detalles del Préstamo'
            , style: TextStyle(color: Colors.white)),
        backgroundColor: AppColors.primaryColor,
        
        foregroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: true, // ← Esta línea es clave
        iconTheme: IconThemeData(
          color: Colors.white, // ← Asegura contraste
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildLoanHeader(),
            SizedBox(height: 16),
            _buildLoanDetails(),
            SizedBox(height: 16),
            _buildPaymentSchedule(),
            SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildLoanHeader() {
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'Préstamo #${widget.loan.id.substring(0, 6)}',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              SizedBox(width: 8),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: _getLoanStatusColor().withOpacity(0.2),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: _getLoanStatusColor().withOpacity(0.5),
                    width: 1,
                  ),
                ),
                child: Text(
                  widget.loan.status.toUpperCase(),
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Text(
            widget.loan.paymentMethod.toUpperCase(),
            style: TextStyle(
              color: Colors.white70,
              fontSize: 13,
            ),
          ),
          SizedBox(height: 20),
          // Cambiar de Row a Column para evitar desbordamiento
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildAmountSection(
                'Monto total',
                widget.loan.amount,
              ),
              if (widget.loan.status == 'aprobado') ...[
                SizedBox(height: 16),
                _buildAmountSection(
                  'Pendiente',
                  widget.loan.pendingAmount,
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAmountSection(String label, double amount) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(color: Colors.white70, fontSize: 14),
        ),
        SizedBox(height: 4),
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Text(
            '\$${NumberFormat('#,###').format(amount)}',
            style: TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Color _getLoanStatusColor() {
    switch (widget.loan.status) {
      case 'pendiente':
        return Colors.orange;
      case 'aprobado':
        return Colors.green;
      case 'rechazado':
        return Colors.red;
      case 'pagado':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  Widget _buildLoanDetails() {
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
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Detalles del préstamo',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimaryColor,
            ),
          ),
          SizedBox(height: 20),
          _buildDetailRow('Tasa de interés', '${widget.loan.interestRate}%'),
          Divider(height: 24),
          _buildDetailRow('Plazo', '${widget.loan.termMonths} meses'),
          Divider(height: 24),
          _buildDetailRow(
            'Fecha de solicitud',
            DateFormat('dd/MM/yyyy').format(widget.loan.requestDate),
          ),
          if (widget.loan.approvalDate != null) ...[
            Divider(height: 24),
            _buildDetailRow(
              'Fecha de aprobación',
              DateFormat('dd/MM/yyyy').format(widget.loan.approvalDate!),
            ),
          ],
          Divider(height: 24),
          _buildDetailRow(
            'Sistema de amortización',
            widget.loan.paymentMethod.capitalize(),
          ),
          Divider(height: 24),
          _buildDetailRow(
            'Monto total con interés',
            '\$${NumberFormat('#,###').format(widget.loan.totalAmount)}',
          ),
          if (widget.loan.status == 'aprobado') ...[
            Divider(height: 24),
            _buildDetailRow(
              'Pagos realizados',
              '${widget.loan.payments.where((p) => p.paid).length}/${widget.loan.payments.length}',
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 3,
          child: Text(
            label,
            style: TextStyle(
              color: AppColors.textSecondaryColor,
              fontSize: 14,
            ),
          ),
        ),
        SizedBox(width: 8),
        Expanded(
          flex: 2,
          child: Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimaryColor,
              fontSize: 14,
            ),
            textAlign: TextAlign.end,
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentSchedule() {
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
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Calendario de pagos',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimaryColor,
            ),
          ),
          SizedBox(height: 16),
          if (widget.loan.payments.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  children: [
                    Icon(Icons.calendar_today, size: 48, color: Colors.grey[400]),
                    SizedBox(height: 16),
                    Text(
                      'No hay pagos programados',
                      style: TextStyle(color: AppColors.textSecondaryColor),
                    ),
                  ],
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: widget.loan.payments.length,
              separatorBuilder: (context, index) => SizedBox(height: 8),
              itemBuilder: (context, index) {
                return _buildPaymentItem(widget.loan.payments[index]);
              },
            ),
        ],
      ),
    );
  }

  Widget _buildPaymentItem(LoanPaymentModel payment) {
    bool isPastDue = !payment.paid && payment.dueDate.isBefore(DateTime.now());
    Color statusColor = payment.paid
        ? Colors.green
        : isPastDue
            ? Colors.red
            : Colors.orange;

    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: statusColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  payment.paid
                      ? Icons.check_circle
                      : isPastDue
                          ? Icons.warning
                          : Icons.schedule,
                  color: statusColor,
                  size: 20,
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Cuota ${payment.paymentNumber}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimaryColor,
                        fontSize: 14,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Vence: ${DateFormat('dd/MM/yyyy').format(payment.dueDate)}',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondaryColor,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      '\$${NumberFormat('#,###').format(payment.amount)}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: AppColors.textPrimaryColor,
                      ),
                    ),
                  ),
                  SizedBox(height: 4),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      payment.paid
                          ? 'PAGADO'
                          : isPastDue
                              ? 'VENCIDO'
                              : 'PENDIENTE',
                      style: TextStyle(
                        color: statusColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 9,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          if (!payment.paid && widget.loan.status == 'aprobado') ...[
            SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: _isProcessing
                    ? SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Icon(Icons.payment, size: 18),
                label: Text(_isProcessing ? 'Procesando...' : 'Pagar cuota'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accentColor,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: _isProcessing ? null : () => _showPaymentConfirmation(payment),
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _showPaymentConfirmation(LoanPaymentModel payment) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Realizar pago',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '¿Deseas pagar la cuota ${payment.paymentNumber}?',
              style: TextStyle(color: AppColors.textSecondaryColor),
            ),
            SizedBox(height: 16),
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  _buildDetailRow(
                    'Monto a pagar:',
                    '\$${NumberFormat('#,###').format(payment.amount)}',
                  ),
                  Divider(height: 16),
                  _buildDetailRow(
                    'Fecha de vencimiento:',
                    DateFormat('dd/MM/yyyy').format(payment.dueDate),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('CANCELAR', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accentColor,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () {
              Navigator.pop(context);
              _processPayment(payment);
            },
            child: Text('PAGAR'),
          ),
        ],
      ),
    );
  }

  Future<void> _processPayment(LoanPaymentModel payment) async {
    setState(() {
      _isProcessing = true;
    });

    try {
      await _loanService.payLoanInstallment(
        widget.loan.id,
        payment.paymentNumber,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 12),
              Expanded(child: Text('Pago realizado correctamente')),
            ],
          ),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );

      setState(() {
        final paymentIndex = widget.loan.payments.indexWhere(
          (p) => p.paymentNumber == payment.paymentNumber,
        );
        if (paymentIndex >= 0) {
          final updatedPayments =
              List<LoanPaymentModel>.from(widget.loan.payments);
          updatedPayments[paymentIndex] = LoanPaymentModel(
            paymentNumber: payment.paymentNumber,
            amount: payment.amount,
            dueDate: payment.dueDate,
            paid: true,
            paymentDate: DateTime.now(),
          );
        }
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.error, color: Colors.white),
              SizedBox(width: 12),
              Expanded(child: Text('Error: ${e.toString()}')),
            ],
          ),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
    } finally {
      setState(() {
        _isProcessing = false;
      });
    }
  }
}

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${this.substring(1)}";
  }
}