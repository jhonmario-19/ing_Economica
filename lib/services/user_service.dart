import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:billetera/models/user_model.dart';

class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  

  Future<UserModel?> getUserData() async {
    User? user = _auth.currentUser;
    if (user != null) {
      DocumentSnapshot doc =
          await _firestore.collection('users').doc(user.uid).get();
      if (doc.exists) {
        return UserModel.fromMap(doc.data() as Map<String, dynamic>);
      }
    }
    return null;
  }

  Future<void> updateUserData(UserModel user) async {
    await _firestore.collection('users').doc(user.uid).update(user.toMap());
  }

  // Nueva función para actualizar el saldo del usuario
  Future<void> updateUserBalance(double newBalance) async {
    User? currentUser = _auth.currentUser;
    if (currentUser != null) {
      await _firestore
          .collection('users')
          .doc(currentUser.uid)
          .update({'saldo': newBalance});
    } else {
      throw Exception('No hay usuario autenticado');
    }
  }
}
