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
      return await _auth.canCheckBiometrics;
    } on PlatformException {
      return false;
    }
  }

  Future<bool> isDeviceSupported() async {
    try {
      return await _auth.isDeviceSupported();
    } on PlatformException {
      return false;
    }
  }

  Future<bool> hasStoredCredentials() async {
    try {
      final ced = await _storage.read(key: _keyCedula);
      final pwd = await _storage.read(key: _keyPassword);
      return (ced != null && pwd != null);
    } catch (_) {
      return false;
    }
  }

  Future<String> getBiometricTypeDescription() async {
    try {
      final types = await _auth.getAvailableBiometrics();
      if (types.contains(BiometricType.fingerprint)) {
        return 'Huella dactilar';
      } else if (types.contains(BiometricType.face)) {
        return 'Face ID';
      } else if (types.contains(BiometricType.iris)) {
        return 'Iris';
      } else {
        return 'Biometría';
      }
    } catch (_) {
      return 'Biometría';
    }
  }

  Future<bool> isBiometricEnabled() async {
    try {
      final enabled = await _storage.read(key: _keyEnabled);
      return enabled == 'true';
    } catch (_) {
      return false;
    }
  }

  /// Habilita biometría: primero solicita autenticación biométrica y si pasa,
  /// guarda cedula + password en secure storage.
  Future<bool> enableBiometric({
    required String cedula,
    required String password,
    String localizedReason = 'Autentícate para activar acceso biométrico',
  }) async {
    try {
      final bool available = await isDeviceSupported() || await canCheckBiometrics();
      if (!available) return false;

      final bool authenticated = await _authenticate(localizedReason);
      if (!authenticated) return false;

      await _storage.write(key: _keyCedula, value: cedula);
      await _storage.write(key: _keyPassword, value: password);
      await _storage.write(key: _keyEnabled, value: 'true');
      return true;
    } catch (e) {
      debugPrint('enableBiometric error: $e');
      return false;
    }
  }

  /// Intenta obtener las credenciales almacenadas después de autenticar biométricamente.
  /// Devuelve null si falla o usuario canceló.
  Future<Map<String, String>?> getBiometricCredentials({
    String localizedReason = 'Autentícate para iniciar sesión',
  }) async {
    try {
      final enabled = await isBiometricEnabled();
      if (!enabled) return null;

      final bool authenticated = await _authenticate(localizedReason);
      if (!authenticated) return null;

      final ced = await _storage.read(key: _keyCedula);
      final pwd = await _storage.read(key: _keyPassword);

      if (ced == null || pwd == null) return null;

      return {'cedula': ced, 'password': pwd};
    } catch (e) {
      debugPrint('getBiometricCredentials error: $e');
      return null;
    }
  }

  Future<void> disableBiometric() async {
    try {
      await _storage.delete(key: _keyCedula);
      await _storage.delete(key: _keyPassword);
      await _storage.delete(key: _keyEnabled);
    } catch (e) {
      debugPrint('disableBiometric error: $e');
    }
  }

  Future<bool> _authenticate(String localizedReason) async {
    try {
      final bool canAuth = await (_auth.isDeviceSupported());
      if (!canAuth && !(await _auth.canCheckBiometrics)) return false;

      return await _auth.authenticate(
        localizedReason: localizedReason,
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: false,
        ),
      );
    } on PlatformException catch (e) {
      debugPrint('LocalAuth PlatformException: $e');
      return false;
    } catch (e) {
      debugPrint('LocalAuth unknown error: $e');
      return false;
    }
  }
}