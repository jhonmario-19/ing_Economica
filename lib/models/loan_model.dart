class LoanModel {
  final String id;
  final String userId;
  final double amount;
  final double interestRate;
  final int termMonths;
  final String paymentMethod; // alemana, francesa, americana
  final DateTime requestDate;
  final DateTime? approvalDate;
  final String status; // pendiente, aprobado, rechazado, pagado
  final List<LoanPaymentModel> payments;

  LoanModel({
    required this.id,
    required this.userId,
    required this.amount,
    required this.interestRate,
    required this.termMonths,
    required this.paymentMethod,
    required this.requestDate,
    this.approvalDate,
    required this.status,
    required this.payments,
  });

  factory LoanModel.fromMap(Map<String, dynamic> map, String id) {
    List<LoanPaymentModel> paymentsList = [];
    if (map['payments'] != null) {
      paymentsList = List<LoanPaymentModel>.from(
          map['payments'].map((x) => LoanPaymentModel.fromMap(x)));
    }

    return LoanModel(
      id: id,
      userId: map['userId'],
      amount: map['amount'].toDouble(),
      interestRate: map['interestRate'].toDouble(),
      termMonths: map['termMonths'],
      paymentMethod: map['paymentMethod'],
      requestDate: map['requestDate'].toDate(),
      approvalDate: map['approvalDate']?.toDate(),
      status: map['status'],
      payments: paymentsList,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'amount': amount,
      'interestRate': interestRate,
      'termMonths': termMonths,
      'paymentMethod': paymentMethod,
      'requestDate': requestDate,
      'approvalDate': approvalDate,
      'status': status,
      'payments': payments.map((x) => x.toMap()).toList(),
    };
  }

  // Calcular el monto total a pagar
  double get totalAmount {
    double total = 0;
    for (var payment in payments) {
      total += payment.amount;
    }
    return total;
  }

  // Calcular el monto pendiente
  double get pendingAmount {
    double paid = 0;
    for (var payment in payments) {
      if (payment.paid) {
        paid += payment.amount;
      }
    }
    return totalAmount - paid;
  }

  // Calcular la próxima cuota
  LoanPaymentModel? get nextPayment {
    for (var payment in payments) {
      if (!payment.paid) {
        return payment;
      }
    }
    return null;
  }
}

// Modelo de pago de préstamo
class LoanPaymentModel {
  final int paymentNumber;
  final double amount;
  final DateTime dueDate;
  final bool paid;
  final DateTime? paymentDate;

  LoanPaymentModel({
    required this.paymentNumber,
    required this.amount,
    required this.dueDate,
    required this.paid,
    this.paymentDate,
  });

  factory LoanPaymentModel.fromMap(Map<String, dynamic> map) {
    return LoanPaymentModel(
      paymentNumber: map['paymentNumber'],
      amount: map['amount'].toDouble(),
      dueDate: map['dueDate'].toDate(),
      paid: map['paid'],
      paymentDate: map['paymentDate']?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'paymentNumber': paymentNumber,
      'amount': amount,
      'dueDate': dueDate,
      'paid': paid,
      'paymentDate': paymentDate,
    };
  }
}
