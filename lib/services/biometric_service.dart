import 'dart:async';
import 'package:local_auth/local_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class BiometricService {
  final LocalAuthentication _auth = LocalAuthentication();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  static const String _keyEnabled = 'biometric_enabled';
  static const String _keyCedula = 'biometric_cedula';
  static const String _keyPassword = 'biometric_password';

  Future<bool> canCheckBiometrics() async {
    try {
      final bool canCheck = await _auth.canCheckBiometrics;
      debugPrint('📱 canCheckBiometrics: $canCheck');
      return canCheck;
    } on PlatformException catch (e) {
      debugPrint('❌ Error en canCheckBiometrics: ${e.message}');
      return false;
    }
  }

  Future<bool> isDeviceSupported() async {
    try {
      final bool isSupported = await _auth.isDeviceSupported();
      debugPrint('📱 isDeviceSupported: $isSupported');
      return isSupported;
    } on PlatformException catch (e) {
      debugPrint('❌ Error en isDeviceSupported: ${e.message}');
      return false;
    }
  }

  Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      final List<BiometricType> availableBiometrics = 
          await _auth.getAvailableBiometrics();
      debugPrint('🔍 Biométricas disponibles: $availableBiometrics');
      return availableBiometrics;
    } on PlatformException catch (e) {
      debugPrint('❌ Error obteniendo biométricas: ${e.message}');
      return [];
    }
  }

  Future<bool> hasStoredCredentials() async {
    try {
      final ced = await _storage.read(key: _keyCedula);
      final pwd = await _storage.read(key: _keyPassword);
      final hasCredentials = (ced != null && pwd != null);
      debugPrint('🔐 Tiene credenciales guardadas: $hasCredentials');
      return hasCredentials;
    } catch (e) {
      debugPrint('❌ Error verificando credenciales: $e');
      return false;
    }
  }

  Future<String> getBiometricTypeDescription() async {
    try {
      final types = await getAvailableBiometrics();
      
      if (types.isEmpty) {
        return 'Biometría';
      }
      
      if (types.contains(BiometricType.face)) {
        return 'Face ID';
      } else if (types.contains(BiometricType.fingerprint)) {
        return 'Huella dactilar';
      } else if (types.contains(BiometricType.iris)) {
        return 'Reconocimiento de iris';
      } else {
        return 'Biometría';
      }
    } catch (e) {
      debugPrint('❌ Error obteniendo tipo de biometría: $e');
      return 'Biometría';
    }
  }

  Future<bool> isBiometricEnabled() async {
    try {
      final enabled = await _storage.read(key: _keyEnabled);
      final isEnabled = enabled == 'true';
      debugPrint('✅ Biometría habilitada: $isEnabled');
      return isEnabled;
    } catch (e) {
      debugPrint('❌ Error verificando si está habilitada: $e');
      return false;
    }
  }

  Future<bool> enableBiometric({
    required String cedula,
    required String password,
    String localizedReason = 'Autentícate para activar acceso biométrico',
  }) async {
    try {
      debugPrint('🔄 Iniciando habilitación de biometría...');
      
      // Verificar disponibilidad
      final bool canCheck = await canCheckBiometrics();
      final bool isSupported = await isDeviceSupported();
      
      debugPrint('📱 canCheck: $canCheck, isSupported: $isSupported');
      
      if (!canCheck && !isSupported) {
        debugPrint('❌ Dispositivo no soporta biometría');
        return false;
      }

      // Verificar que hay biométricas disponibles
      final List<BiometricType> availableBiometrics = await getAvailableBiometrics();
      if (availableBiometrics.isEmpty) {
        debugPrint('❌ No hay sensores biométricos disponibles');
        return false;
      }

      debugPrint('✅ Sensores disponibles: $availableBiometrics');

      // Solicitar autenticación biométrica
      debugPrint('🔐 Solicitando autenticación biométrica...');
      final bool authenticated = await _authenticate(localizedReason);
      
      if (!authenticated) {
        debugPrint('❌ Autenticación biométrica cancelada o fallida');
        return false;
      }

      debugPrint('✅ Autenticación biométrica exitosa');

      // Guardar credenciales de forma segura
      await _storage.write(key: _keyCedula, value: cedula);
      await _storage.write(key: _keyPassword, value: password);
      await _storage.write(key: _keyEnabled, value: 'true');

      debugPrint('✅ Credenciales guardadas correctamente');
      debugPrint('✅ Biometría habilitada exitosamente');
      
      return true;
    } catch (e) {
      debugPrint('❌ Error habilitando biometría: $e');
      return false;
    }
  }

  Future<Map<String, String>?> getBiometricCredentials({
    String localizedReason = 'Autentícate para iniciar sesión',
  }) async {
    try {
      debugPrint('🔄 Intentando obtener credenciales con biometría...');
      
      // Verificar si está habilitada
      final enabled = await isBiometricEnabled();
      if (!enabled) {
        debugPrint('❌ Biometría no está habilitada');
        return null;
      }

      // Autenticar
      debugPrint('🔐 Solicitando autenticación biométrica...');
      final bool authenticated = await _authenticate(localizedReason);
      
      if (!authenticated) {
        debugPrint('❌ Autenticación biométrica cancelada o fallida');
        return null;
      }

      debugPrint('✅ Autenticación biométrica exitosa');

      // Leer credenciales
      final ced = await _storage.read(key: _keyCedula);
      final pwd = await _storage.read(key: _keyPassword);

      if (ced == null || pwd == null) {
        debugPrint('❌ No se encontraron credenciales guardadas');
        return null;
      }

      debugPrint('✅ Credenciales obtenidas correctamente');
      return {'cedula': ced, 'password': pwd};
    } catch (e) {
      debugPrint('❌ Error obteniendo credenciales: $e');
      return null;
    }
  }

  Future<void> disableBiometric() async {
    try {
      debugPrint('🔄 Deshabilitando biometría...');
      await _storage.delete(key: _keyCedula);
      await _storage.delete(key: _keyPassword);
      await _storage.delete(key: _keyEnabled);
      debugPrint('✅ Biometría deshabilitada correctamente');
    } catch (e) {
      debugPrint('❌ Error deshabilitando biometría: $e');
    }
  }

  Future<bool> _authenticate(String localizedReason) async {
    try {
      debugPrint('🔐 Llamando a authenticate...');
      
      // Verificar disponibilidad antes de autenticar
      final bool canAuthenticate = await _auth.canCheckBiometrics || 
                                   await _auth.isDeviceSupported();
      
      if (!canAuthenticate) {
        debugPrint('❌ No se puede autenticar - dispositivo no soportado');
        return false;
      }

      // MEJORA: Configuración más compatible
      final bool didAuthenticate = await _auth.authenticate(
        localizedReason: localizedReason,
        options: const AuthenticationOptions(
          stickyAuth: false, // Cambiado a false para mejor compatibilidad
          biometricOnly: false, // Permitir fallback a PIN/patrón
          useErrorDialogs: true,
          sensitiveTransaction: false,
        ),
      );

      debugPrint('✅ Resultado de autenticación: $didAuthenticate');
      return didAuthenticate;
      
    } on PlatformException catch (e) {
      debugPrint('❌ PlatformException en authenticate: ${e.code} - ${e.message}');
      
      // Manejar códigos de error específicos
      switch (e.code) {
        case 'no_fragment_activity':
          debugPrint('❌ ERROR CRÍTICO: MainActivity debe extender FlutterFragmentActivity');
          break;
        case 'NotAvailable':
          debugPrint('❌ Biometría no disponible en el dispositivo');
          break;
        case 'NotEnrolled':
          debugPrint('❌ No hay huellas registradas en el dispositivo');
          break;
        case 'LockedOut':
          debugPrint('❌ Biometría bloqueada temporalmente');
          break;
        case 'PermanentlyLockedOut':
          debugPrint('❌ Biometría bloqueada permanentemente');
          break;
        default:
          debugPrint('❌ Error desconocido: ${e.code}');
      }
      
      return false;
    } catch (e) {
      debugPrint('❌ Error desconocido en authenticate: $e');
      return false;
    }
  }
}