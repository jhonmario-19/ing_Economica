// services/loan_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:billetera/models/loan_model.dart';
import 'package:billetera/models/transaction_model.dart';
import 'package:billetera/services/transaction_service.dart';
import 'package:billetera/services/user_service.dart';
import 'dart:math';

class LoanService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TransactionService _transactionService = TransactionService();
  final UserService _userService = UserService();

  // Obtener préstamos del usuario actual
  Future<List<LoanModel>> getUserLoans() async {
    final userId = _auth.currentUser!.uid;
    final loansSnapshot = await _firestore
        .collection('loans')
        .where('userId', isEqualTo: userId)
        .get();

    return loansSnapshot.docs
        .map((doc) => LoanModel.fromMap(doc.data(), doc.id))
        .toList();
  }

  // Solicitar un nuevo préstamo (modificado para aprobación automática)
  Future<String> requestLoan(double amount, double interestRate, int termMonths,
      String paymentMethod) async {
    final userId = _auth.currentUser!.uid;
    final requestDate = DateTime.now();

    // Generar pagos según el método seleccionado
    List<LoanPaymentModel> payments = _generatePayments(
        amount, interestRate, termMonths, paymentMethod, requestDate);

    // Obtener el usuario actual para actualizar su saldo
    final user = await _userService.getUserData();
    if (user == null) {
      throw Exception('No se pudo obtener información del usuario');
    }

    // Crear modelo de préstamo con estado "aprobado" en lugar de "pendiente"
    LoanModel newLoan = LoanModel(
      id: '',
      userId: userId,
      amount: amount,
      interestRate: interestRate,
      termMonths: termMonths,
      paymentMethod: paymentMethod,
      requestDate: requestDate,
      status: 'aprobado', // Cambiado de 'pendiente' a 'aprobado'
      approvalDate: requestDate, // Añadir fecha de aprobación
      payments: payments,
    );

    // Guardar en Firestore
    DocumentReference docRef =
        await _firestore.collection('loans').add(newLoan.toMap());

    // Actualizar el saldo del usuario sumando el monto del préstamo
    double newBalance = user.saldo + amount;
    await _userService.updateUserBalance(newBalance);

    // Crear registro de transacción (ahora con signo positivo por ser un ingreso)
    await _transactionService.addTransaction(
      TransactionModel(
        id: '',
        userId: userId,
        amount: amount, // Ahora es positivo porque es un ingreso
        description: 'Préstamo aprobado y depositado',
        type: 'préstamo',
        date: requestDate,
      ),
    );

    return docRef.id;
  }

  // Pagar una cuota de préstamo
  Future<void> payLoanInstallment(String loanId, int paymentNumber) async {
    final userId = _auth.currentUser!.uid;

    // Obtener datos del préstamo
    DocumentSnapshot loanDoc =
        await _firestore.collection('loans').doc(loanId).get();
    LoanModel loan =
        LoanModel.fromMap(loanDoc.data() as Map<String, dynamic>, loanId);

    // Buscar el pago específico
    LoanPaymentModel? paymentToPay;
    int paymentIndex = -1;

    for (int i = 0; i < loan.payments.length; i++) {
      if (loan.payments[i].paymentNumber == paymentNumber &&
          !loan.payments[i].paid) {
        paymentToPay = loan.payments[i];
        paymentIndex = i;
        break;
      }
    }

    if (paymentToPay == null) {
      throw Exception('Pago no encontrado o ya fue pagado');
    }

    // Verificar saldo disponible
    final user = await _userService.getUserData();
    if (user == null || user.saldo < paymentToPay.amount) {
      throw Exception('Saldo insuficiente');
    }

    // Actualizar el pago como pagado
    List<Map<String, dynamic>> updatedPayments =
        loan.payments.map((p) => p.toMap()).toList();
    updatedPayments[paymentIndex]['paid'] = true;
    updatedPayments[paymentIndex]['paymentDate'] = DateTime.now();

    // Actualizar en Firestore
    await _firestore.collection('loans').doc(loanId).update({
      'payments': updatedPayments,
    });

    // Reducir el saldo del usuario
    await _userService.updateUserBalance(user.saldo - paymentToPay.amount);

    // Registrar la transacción
    await _transactionService.addTransaction(
      TransactionModel(
        id: '',
        userId: userId,
        amount: -paymentToPay.amount,
        description: 'Pago de cuota #$paymentNumber - Préstamo',
        type: 'pago',
        date: DateTime.now(),
      ),
    );

    // Verificar si todos los pagos están completados para actualizar el estado
    bool allPaid = true;
    for (var payment in updatedPayments) {
      if (payment['paid'] == false) {
        allPaid = false;
        break;
      }
    }

    if (allPaid) {
      await _firestore
          .collection('loans')
          .doc(loanId)
          .update({'status': 'pagado'});
    }
  }

  // Generar tabla de pagos según el método seleccionado
  List<LoanPaymentModel> _generatePayments(double amount, double interestRate,
      int termMonths, String paymentMethod, DateTime startDate) {
    List<LoanPaymentModel> payments = [];
    double monthlyInterestRate = interestRate / 100 / 12;

    switch (paymentMethod) {
      case 'francesa':
        // Sistema francés: cuotas iguales
        double cuota = amount *
            monthlyInterestRate *
            pow((1 + monthlyInterestRate), termMonths) /
            (pow((1 + monthlyInterestRate), termMonths) - 1);

        double remainingCapital = amount;

        for (int i = 1; i <= termMonths; i++) {
          double interest = remainingCapital * monthlyInterestRate;
          double capitalPaid = cuota - interest;
          remainingCapital -= capitalPaid;

          payments.add(LoanPaymentModel(
            paymentNumber: i,
            amount: cuota,
            dueDate:
                DateTime(startDate.year, startDate.month + i, startDate.day),
            paid: false,
          ));
        }
        break;

      case 'alemana':
        // Sistema alemán: amortización constante de capital
        double capitalPerMonth = amount / termMonths;

        for (int i = 1; i <= termMonths; i++) {
          double remainingCapital = amount - (capitalPerMonth * (i - 1));
          double interest = remainingCapital * monthlyInterestRate;
          double totalPayment = capitalPerMonth + interest;

          payments.add(LoanPaymentModel(
            paymentNumber: i,
            amount: totalPayment,
            dueDate:
                DateTime(startDate.year, startDate.month + i, startDate.day),
            paid: false,
          ));
        }
        break;

      case 'americana':
        // Sistema americano: intereses periódicos y capital al final
        double interest = amount * monthlyInterestRate;

        for (int i = 1; i <= termMonths; i++) {
          payments.add(LoanPaymentModel(
            paymentNumber: i,
            amount: i == termMonths ? (interest + amount) : interest,
            dueDate:
                DateTime(startDate.year, startDate.month + i, startDate.day),
            paid: false,
          ));
        }
        break;

      default:
        // Por defecto usamos el sistema francés
        double cuota = amount *
            monthlyInterestRate *
            pow((1 + monthlyInterestRate), termMonths) /
            (pow((1 + monthlyInterestRate), termMonths) - 1);

        for (int i = 1; i <= termMonths; i++) {
          payments.add(LoanPaymentModel(
            paymentNumber: i,
            amount: cuota,
            dueDate:
                DateTime(startDate.year, startDate.month + i, startDate.day),
            paid: false,
          ));
        }
    }

    return payments;
  }
}
