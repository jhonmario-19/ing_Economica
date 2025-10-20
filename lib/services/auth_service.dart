import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:billetera/models/user_model.dart';
import 'package:billetera/services/biometric_service.dart';
import 'dart:async';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final BiometricService _biometricService = BiometricService();

  // Método existente de registro (sin cambios)
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

      // 2. Crear usuario en Firebase Auth
      print('🔄 Creando usuario en Firebase Auth...');
      
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: user.email.trim().toLowerCase(),
        password: password,
      );
      
      createdUser = result.user;
      
      if (createdUser != null) {
        print('✅ Usuario creado en Auth: ${createdUser.uid}');
        
        // 3. Guardar en Firestore
        await _saveUserToFirestore(createdUser, user);
        
        return createdUser;
      }
      
      return null;
      
    } on FirebaseAuthException catch (e) {
      print('Firebase Auth Error: ${e.code} - ${e.message}');
      
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
      
      try {
        User? currentUser = _auth.currentUser;
        if (currentUser != null && createdUser?.uid == currentUser.uid) {
          print('🧹 Limpiando usuario después del error...');
          await currentUser.delete();
        }
      } catch (cleanupError) {
        print('Error en limpieza: $cleanupError');
      }
      
      if (e is Exception) {
        rethrow;
      }
      
      throw Exception('Error inesperado en el registro: Por favor intenta de nuevo');
    }
  }
  
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
      
      await _firestoreWriteWithRetry(firebaseUser.uid, userData);
      
      print('✅ Usuario guardado en Firestore');
      
      await _verifyFirestoreSave(firebaseUser.uid);
      
    } catch (e) {
      print('❌ Error guardando en Firestore: $e');
      throw Exception('No se pudo guardar la información del usuario');
    }
  }
  
  Future<void> _firestoreWriteWithRetry(String uid, Map<String, dynamic> userData, {int maxRetries = 3}) async {
    for (int i = 0; i < maxRetries; i++) {
      try {
        await _firestore
            .collection('users')
            .doc(uid)
            .set(userData)
            .timeout(Duration(seconds: 10));
        return;
      } catch (e) {
        print('Intento ${i + 1} falló: $e');
        if (i == maxRetries - 1) {
          rethrow;
        }
        await Future.delayed(Duration(seconds: 2));
      }
    }
  }
  
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

  // Login tradicional con cédula y contraseña
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

  // NUEVO: Login con biometría
  Future<User?> signInWithBiometric() async {
    try {
      // Verificar si la biometría está habilitada
      bool isEnabled = await _biometricService.isBiometricEnabled();
      if (!isEnabled) {
        throw Exception('La autenticación biométrica no está habilitada');
      }

      // CORRECCIÓN: Usar el método correcto
      Map<String, String>? credentials = await _biometricService.getBiometricCredentials(); // ✅ Cambiado de getStoredCredentials a getBiometricCredentials
      
      if (credentials == null) {
        throw Exception('No se pudieron obtener las credenciales');
      }

      // Iniciar sesión con las credenciales obtenidas
      return await signInWithCedulaAndPassword(
        credentials['cedula']!,
        credentials['password']!,
      );
    } catch (e) {
      print('Error en login biométrico: ${e.toString()}');
      if (e is Exception) {
        rethrow;
      }
      throw Exception('Error en la autenticación biométrica');
    }
  }

  // CORREGIR: Habilitar autenticación biométrica
  Future<bool> enableBiometricAuth(String cedula, String password) async {
    try {
      return await _biometricService.enableBiometric(
        cedula: cedula, // ✅ Agregar nombre del parámetro
        password: password,
      );
    } catch (e) {
      print('Error habilitando biometría: $e');
      return false;
    }
  }

  // NUEVO: Deshabilitar autenticación biométrica
  Future<void> disableBiometricAuth() async {
    await _biometricService.disableBiometric();
  }

  // NUEVO: Verificar si la biometría está habilitada
  Future<bool> isBiometricEnabled() async {
    return await _biometricService.isBiometricEnabled();
  }

  // NUEVO: Verificar si hay credenciales guardadas
  Future<bool> hasStoredCredentials() async {
    return await _biometricService.hasStoredCredentials();
  }

  // NUEVO: Obtener descripción del tipo de biometría
  Future<String> getBiometricTypeDescription() async {
    return await _biometricService.getBiometricTypeDescription();
  }

  // NUEVO: Verificar disponibilidad de biometría
  Future<bool> isBiometricAvailable() async {
    bool canCheck = await _biometricService.canCheckBiometrics();
    bool isSupported = await _biometricService.isDeviceSupported();
    return canCheck && isSupported;
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