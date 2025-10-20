import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:billetera/models/transaction_model.dart';

class TransactionService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Obtener el ID del usuario actual
  String? get _userId => _auth.currentUser?.uid;

  // Colección de transacciones
  CollectionReference get _transactionsCollection =>
      _firestore.collection('transactions');

  // Obtener transacciones recientes con un listener en tiempo real
  Stream<List<TransactionModel>> getRecentTransactionsStream(int limit) {
    if (_userId == null) return Stream.value([]);

    return _transactionsCollection
        .where('userId', isEqualTo: _userId)
        .orderBy('date', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return TransactionModel.fromJson(data);
      }).toList();
    });
  }

  // Obtener transacciones recientes
  Future<List<TransactionModel>> getRecentTransactions(int limit) async {
    if (_userId == null) return [];

    try {
      // Usar get() para obtener datos actualizados de Firestore (no desde caché)
      QuerySnapshot snapshot = await _transactionsCollection
          .where('userId', isEqualTo: _userId)
          .orderBy('date', descending: true)
          .limit(limit)
          .get(GetOptions(source: Source.server));

      return snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return TransactionModel.fromJson(data);
      }).toList();
    } catch (e) {
      print('Error al obtener transacciones: $e');

      // Intentar obtener desde caché si falla la conexión
      try {
        QuerySnapshot snapshot = await _transactionsCollection
            .where('userId', isEqualTo: _userId)
            .orderBy('date', descending: true)
            .limit(limit)
            .get();

        return snapshot.docs.map((doc) {
          Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
          data['id'] = doc.id;
          return TransactionModel.fromJson(data);
        }).toList();
      } catch (cacheError) {
        print('Error al obtener transacciones desde caché: $cacheError');
        return [];
      }
    }
  }

  // Agregar una nueva transacción
  Future<bool> addTransaction(TransactionModel transaction) async {
    if (_userId == null) return false;

    try {
      await _transactionsCollection.add(transaction.toJson());
      return true;
    } catch (e) {
      print('Error al agregar transacción: $e');
      return false;
    }
  }

  // Obtener transacciones por tipo
  Future<List<TransactionModel>> getTransactionsByType(String type) async {
    if (_userId == null) return [];

    try {
      QuerySnapshot snapshot = await _transactionsCollection
          .where('userId', isEqualTo: _userId)
          .where('type', isEqualTo: type)
          .orderBy('date', descending: true)
          .get(GetOptions(source: Source.server));

      return snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return TransactionModel.fromJson(data);
      }).toList();
    } catch (e) {
      print('Error al obtener transacciones por tipo: $e');
      return [];
    }
  }

  // Obtener transacciones en un rango de fechas
  Future<List<TransactionModel>> getTransactionsByDateRange(
      DateTime start, DateTime end) async {
    if (_userId == null) return [];

    try {
      QuerySnapshot snapshot = await _transactionsCollection
          .where('userId', isEqualTo: _userId)
          .where('date', isGreaterThanOrEqualTo: start)
          .where('date', isLessThanOrEqualTo: end)
          .orderBy('date', descending: true)
          .get(GetOptions(source: Source.server));

      return snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return TransactionModel.fromJson(data);
      }).toList();
    } catch (e) {
      print('Error al obtener transacciones por rango de fechas: $e');
      return [];
    }
  }
}
