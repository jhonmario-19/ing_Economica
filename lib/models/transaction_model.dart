class TransactionModel {
  final String id;
  final String userId;
  final double amount;
  final String description;
  final String type; // 'pago', 'préstamo', 'interés', etc.
  final DateTime date;
  final Map<String, dynamic>?
      metadata; // Datos adicionales específicos del tipo de transacción

  TransactionModel({
    required this.id,
    required this.userId,
    required this.amount,
    required this.description,
    required this.type,
    required this.date,
    this.metadata,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json['id'],
      userId: json['userId'],
      amount: json['amount'].toDouble(),
      description: json['description'],
      type: json['type'],
      date: DateTime.parse(json['date']),
      metadata: json['metadata'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'amount': amount,
      'description': description,
      'type': type,
      'date': date.toIso8601String(),
      'metadata': metadata,
    };
  }
}
