import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:billetera/models/user_model.dart';
import 'dart:async';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Registro corregido para evitar el error PigeonUserDetails
  Future<User?> registerWithCedulaAndPassword(
      UserModel user, String password) async {
    
    User? createdUser;
    
    try {
      // 1. Verificar cédula duplicada
      QuerySnapshot cedulaCheck = await _firestore
          .collection('users')
          .where('cedula', isEqualTo: user.cedula.trim())
          .limit(1)
          .get();
      
      if (cedulaCheck.docs.isNotEmpty) {
        throw FirebaseAuthException(
          code: 'cedula-already-in-use',
          message: 'Ya existe un usuario con esta cédula',
        );
      }

      // 2. Crear usuario en Firebase Auth de forma síncrona
      print('🔄 Creando usuario en Firebase Auth...');
      
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: user.email.trim().toLowerCase(),
        password: password,
      );
      
      createdUser = result.user;
      
      if (createdUser != null) {
        print('✅ Usuario creado en Auth: ${createdUser.uid}');
        
        // 3. Guardar en Firestore inmediatamente después
        await _saveUserToFirestore(createdUser, user);
        
        return createdUser;
      }
      
      return null;
      
    } on FirebaseAuthException catch (e) {
      print('Firebase Auth Error: ${e.code} - ${e.message}');
      
      // Mapear errores específicos
      switch (e.code) {
        case 'email-already-in-use':
          throw Exception('Este correo electrónico ya está registrado');
        case 'weak-password':
          throw Exception('La contraseña es muy débil');
        case 'invalid-email':
          throw Exception('El correo electrónico no es válido');
        case 'cedula-already-in-use':
          throw Exception('Ya existe un usuario con esta cédula');
        default:
          throw Exception('Error en el registro: ${e.message}');
      }
      
    } catch (e) {
      print('Error general: ${e.toString()}');
      
      // Verificar si hay un usuario creado que necesita limpieza
      try {
        User? currentUser = _auth.currentUser;
        if (currentUser != null && createdUser?.uid == currentUser.uid) {
          print('🧹 Limpiando usuario después del error...');
          await currentUser.delete();
        }
      } catch (cleanupError) {
        print('Error en limpieza: $cleanupError');
      }
      
      // Re-lanzar el error original si es una excepción conocida
      if (e is Exception) {
        rethrow;
      }
      
      throw Exception('Error inesperado en el registro: Por favor intenta de nuevo');
    }
  }
  
  // Método separado para guardar en Firestore con mejor manejo de errores
  Future<void> _saveUserToFirestore(User firebaseUser, UserModel user) async {
    try {
      user.uid = firebaseUser.uid;
      
      Map<String, dynamic> userData = {
        'uid': firebaseUser.uid,
        'nombres': user.nombres.trim(),
        'apellidos': user.apellidos.trim(),
        'email': user.email.trim().toLowerCase(),
        'cedula': user.cedula.trim(),
        'telefono': user.telefono.trim(),
        'saldo': 0.0,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };
      
      print('🔄 Guardando usuario en Firestore...');
      
      // Guardar con timeout y reintentos
      await _firestoreWriteWithRetry(firebaseUser.uid, userData);
      
      print('✅ Usuario guardado en Firestore');
      
      // Verificar que se guardó
      await _verifyFirestoreSave(firebaseUser.uid);
      
    } catch (e) {
      print('❌ Error guardando en Firestore: $e');
      throw Exception('No se pudo guardar la información del usuario');
    }
  }
  
  // Método para escribir en Firestore con reintentos
  Future<void> _firestoreWriteWithRetry(String uid, Map<String, dynamic> userData, {int maxRetries = 3}) async {
    for (int i = 0; i < maxRetries; i++) {
      try {
        await _firestore
            .collection('users')
            .doc(uid)
            .set(userData)
            .timeout(Duration(seconds: 10));
        return; // Éxito, salir del bucle
      } catch (e) {
        print('Intento ${i + 1} falló: $e');
        if (i == maxRetries - 1) {
          rethrow; // Último intento, re-lanzar error
        }
        await Future.delayed(Duration(seconds: 2)); // Esperar antes del siguiente intento
      }
    }
  }
  
  // Verificar guardado en Firestore
  Future<void> _verifyFirestoreSave(String uid) async {
    try {
      await Future.delayed(Duration(milliseconds: 500));
      
      DocumentSnapshot doc = await _firestore
          .collection('users')
          .doc(uid)
          .get()
          .timeout(Duration(seconds: 10));
      
      if (doc.exists) {
        print('✅ Verificación: Usuario encontrado en Firestore');
        Map<String, dynamic>? data = doc.data() as Map<String, dynamic>?;
        if (data != null) {
          print('📄 Datos guardados: nombres=${data['nombres']}, email=${data['email']}');
        }
      } else {
        throw Exception('Usuario no se guardó en Firestore');
      }
    } catch (e) {
      print('Error en verificación: $e');
      rethrow;
    }
  }

  // Login sin cambios (pero con mejor manejo de errores)
  Future<User?> signInWithCedulaAndPassword(
      String cedula, String password) async {
    try {
      QuerySnapshot userSnapshot = await _firestore
          .collection('users')
          .where('cedula', isEqualTo: cedula.trim())
          .limit(1)
          .get();

      if (userSnapshot.docs.isEmpty) {
        throw FirebaseAuthException(
          code: 'user-not-found',
          message: 'No se encontró un usuario con esa cédula',
        );
      }

      String email = userSnapshot.docs.first['email'];

      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      return result.user;
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'user-not-found':
          throw Exception('Usuario no encontrado. Verifica tu cédula.');
        case 'wrong-password':
          throw Exception('Contraseña incorrecta. Inténtalo de nuevo.');
        case 'user-disabled':
          throw Exception('Esta cuenta ha sido deshabilitada.');
        case 'too-many-requests':
          throw Exception('Demasiados intentos. Espera un momento e inténtalo de nuevo.');
        default:
          throw Exception('Error de inicio de sesión: ${e.message}');
      }
    } catch (e) {
      print('Error en login: ${e.toString()}');
      if (e is Exception) {
        rethrow;
      }
      throw Exception('Error inesperado en el inicio de sesión');
    }
  }

  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim().toLowerCase());
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'user-not-found':
          throw Exception('No se encontró un usuario con este correo electrónico.');
        case 'invalid-email':
          throw Exception('El correo electrónico no es válido.');
        default:
          throw Exception('Error al enviar el correo: ${e.message}');
      }
    } catch (e) {
      print('Error en reset password: ${e.toString()}');
      if (e is Exception) {
        rethrow;
      }
      throw Exception('Error inesperado al restablecer la contraseña');
    }
  }

  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      print('Error al cerrar sesión: ${e.toString()}');
      throw Exception('Error al cerrar sesión');
    }
  }
  
  User? get currentUser => _auth.currentUser;
  Stream<User?> get authStateChanges => _auth.authStateChanges();
}