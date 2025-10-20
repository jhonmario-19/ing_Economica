import 'package:local_auth/local_auth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/services.dart';

class BiometricAuthService {
  final LocalAuthentication _localAuth = LocalAuthentication();
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  // Claves para almacenamiento seguro
  static const String _keyBiometricEnabled = 'biometric_enabled';
  static const String _keyCedula = 'user_cedula';
  static const String _keyPassword = 'user_password';

  /// Verifica si el dispositivo tiene capacidad biométrica
  Future<bool> canCheckBiometrics() async {
    try {
      return await _localAuth.canCheckBiometrics;
    } on PlatformException catch (e) {
      print('Error verificando biométrica: ${e.message}');
      return false;
    }
  }

  /// Verifica si hay biometría disponible (huella, Face ID, etc.)
  Future<bool> isDeviceSupported() async {
    try {
      return await _localAuth.isDeviceSupported();
    } on PlatformException catch (e) {
      print('Error verificando dispositivo: ${e.message}');
      return false;
    }
  }

  /// Obtiene los tipos de autenticación biométrica disponibles
  Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      return await _localAuth.getAvailableBiometrics();
    } on PlatformException catch (e) {
      print('Error obteniendo biométricas: ${e.message}');
      return [];
    }
  }

  /// Autentica al usuario usando biometría
  Future<bool> authenticate({
    String localizedReason = 'Por favor autentícate para continuar',
    bool useErrorDialogs = true,
    bool stickyAuth = true,
  }) async {
    try {
      bool isAuthenticated = await _localAuth.authenticate(
        localizedReason: localizedReason,
        options: AuthenticationOptions(
          useErrorDialogs: useErrorDialogs,
          stickyAuth: stickyAuth,
          biometricOnly: true,
        ),
      );

      return isAuthenticated;
    } on PlatformException catch (e) {
      print('Error en autenticación: ${e.message}');
      return false;
    }
  }

  /// Verifica si la autenticación biométrica está habilitada
  Future<bool> isBiometricEnabled() async {
    String? enabled = await _secureStorage.read(key: _keyBiometricEnabled);
    return enabled == 'true';
  }

  /// Habilita la autenticación biométrica y guarda las credenciales
  Future<bool> enableBiometric(String cedula, String password) async {
    try {
      // Verificar que el dispositivo soporta biometría
      bool canAuthenticate = await canCheckBiometrics();
      bool isSupported = await isDeviceSupported();

      if (!canAuthenticate || !isSupported) {
        throw Exception('El dispositivo no soporta autenticación biométrica');
      }

      // Autenticar antes de guardar
      bool authenticated = await authenticate(
        localizedReason: 'Autentica para habilitar inicio de sesión con huella',
      );

      if (!authenticated) {
        return false;
      }

      // Guardar credenciales de forma segura
      await _secureStorage.write(key: _keyBiometricEnabled, value: 'true');
      await _secureStorage.write(key: _keyCedula, value: cedula);
      await _secureStorage.write(key: _keyPassword, value: password);

      return true;
    } catch (e) {
      print('Error habilitando biométrica: $e');
      return false;
    }
  }

  /// Deshabilita la autenticación biométrica y elimina las credenciales
  Future<void> disableBiometric() async {
    await _secureStorage.delete(key: _keyBiometricEnabled);
    await _secureStorage.delete(key: _keyCedula);
    await _secureStorage.delete(key: _keyPassword);
  }

  /// Obtiene las credenciales guardadas si la autenticación biométrica es exitosa
  Future<Map<String, String>?> getStoredCredentials() async {
    try {
      bool isEnabled = await isBiometricEnabled();
      if (!isEnabled) {
        return null;
      }

      bool authenticated = await authenticate(
        localizedReason: 'Autentica para iniciar sesión',
      );

      if (!authenticated) {
        return null;
      }

      String? cedula = await _secureStorage.read(key: _keyCedula);
      String? password = await _secureStorage.read(key: _keyPassword);

      if (cedula == null || password == null) {
        return null;
      }

      return {
        'cedula': cedula,
        'password': password,
      };
    } catch (e) {
      print('Error obteniendo credenciales: $e');
      return null;
    }
  }

  /// Obtiene un mensaje descriptivo del tipo de biometría disponible
  Future<String> getBiometricTypeDescription() async {
    List<BiometricType> availableBiometrics = await getAvailableBiometrics();
    
    if (availableBiometrics.isEmpty) {
      return 'No hay biometría disponible';
    }

    if (availableBiometrics.contains(BiometricType.face)) {
      return 'Face ID';
    } else if (availableBiometrics.contains(BiometricType.fingerprint)) {
      return 'Huella digital';
    } else if (availableBiometrics.contains(BiometricType.iris)) {
      return 'Reconocimiento de iris';
    } else {
      return 'Autenticación biométrica';
    }
  }

  /// Verifica si hay credenciales almacenadas
  Future<bool> hasStoredCredentials() async {
    String? cedula = await _secureStorage.read(key: _keyCedula);
    return cedula != null;
  }
}