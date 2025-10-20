import 'package:flutter/material.dart';
import 'package:billetera/models/user_model.dart';
import 'package:billetera/services/user_service.dart';
import 'package:billetera/services/auth_service.dart';
import 'package:billetera/services/biometric_service.dart';
import 'package:billetera/constants/app_colors.dart';
import 'package:billetera/constants/app_styles.dart';
import 'package:billetera/constants/app_common_widget.dart';

class ProfileScreen extends StatefulWidget {
  final UserModel user;

  ProfileScreen({required this.user});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nombresController;
  late TextEditingController _apellidosController;
  late TextEditingController _emailController;
  late TextEditingController _cedulaController;
  late TextEditingController _telefonoController;

  final UserService _userService = UserService();
  final AuthService _authService = AuthService();
  final BiometricService _biometricService = BiometricService();

  bool _isEditing = false;
  bool _isLoading = false;
  bool _biometricEnabled = false;
  bool _biometricAvailable = false;
  String _biometricType = '';
  String? _tempPassword;

  @override
  void initState() {
    super.initState();
    _nombresController = TextEditingController(text: widget.user.nombres);
    _apellidosController = TextEditingController(text: widget.user.apellidos);
    _emailController = TextEditingController(text: widget.user.email);
    _cedulaController = TextEditingController(text: widget.user.cedula);
    _telefonoController = TextEditingController(text: widget.user.telefono);
    _checkBiometricStatus();
  }

  @override
  void dispose() {
    _nombresController.dispose();
    _apellidosController.dispose();
    _emailController.dispose();
    _cedulaController.dispose();
    _telefonoController.dispose();
    super.dispose();
  }

  Future<void> _checkBiometricStatus() async {
    final canCheck = await _biometricService.canCheckBiometrics();
    final isSupported = await _biometricService.isDeviceSupported();
    final isEnabled = await _biometricService.isBiometricEnabled();
    final biometricType = await _biometricService.getBiometricTypeDescription();

    setState(() {
      _biometricAvailable = canCheck || isSupported;
      _biometricEnabled = isEnabled;
      _biometricType = biometricType;
    });
  }

  Future<void> _toggleBiometric(bool value) async {
    if (value) {
      // Activar biometría - necesitamos la contraseña
      _showPasswordDialog();
    } else {
      // Desactivar biometría
      _showDisableBiometricDialog();
    }
  }

  Future<void> _showPasswordDialog() async {
    final passwordController = TextEditingController();
    bool obscurePassword = true;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppStyles.radiusL),
              ),
              title: Row(
                children: [
                  Icon(Icons.fingerprint, color: AppColors.accentColor),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Activar $_biometricType',
                      style: AppStyles.subheadingLarge,
                    ),
                  ),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Ingresa tu contraseña para configurar $_biometricType',
                    style: AppStyles.bodyLarge,
                  ),
                  SizedBox(height: AppStyles.spacingL),
                  TextFormField(
                    controller: passwordController,
                    obscureText: obscurePassword,
                    decoration: AppStyles.inputDecoration(
                      label: 'Contraseña',
                      icon: Icons.lock_outline,
                      hint: 'Tu contraseña actual',
                      suffix: IconButton(
                        icon: Icon(
                          obscurePassword ? Icons.visibility_off : Icons.visibility,
                          color: AppColors.textTertiaryColor,
                        ),
                        onPressed: () {
                          setDialogState(() {
                            obscurePassword = !obscurePassword;
                          });
                        },
                      ),
                    ),
                    style: AppStyles.bodyMedium,
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text(
                    'Cancelar',
                    style: TextStyle(color: AppColors.textSecondaryColor),
                  ),
                ),
                ElevatedButton(
                  style: AppStyles.primaryButtonStyle,
                  onPressed: () async {
                    if (passwordController.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        CommonWidgets.buildCustomSnackBar(
                          message: 'Por favor ingresa tu contraseña',
                          type: SnackBarType.error,
                        ),
                      );
                      return;
                    }

                    Navigator.pop(context);
                    await _enableBiometric(passwordController.text);
                  },
                  child: Text('Continuar'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _enableBiometric(String password) async {
    setState(() {
      _isLoading = true;
    });

    bool success = await _biometricService.enableBiometric(
      cedula: widget.user.cedula,
      password: password,
    );

    setState(() {
      _isLoading = false;
      _biometricEnabled = success;
    });

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        CommonWidgets.buildCustomSnackBar(
          message: '¡$_biometricType activada correctamente!',
          type: SnackBarType.success,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        CommonWidgets.buildCustomSnackBar(
          message: 'No se pudo activar $_biometricType. Verifica tu contraseña.',
          type: SnackBarType.error,
        ),
      );
    }
  }

  Future<void> _showDisableBiometricDialog() async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppStyles.radiusL),
          ),
          title: Row(
            children: [
              Icon(Icons.warning_amber, color: AppColors.errorColor),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Desactivar $_biometricType',
                  style: AppStyles.subheadingLarge,
                ),
              ),
            ],
          ),
          content: Text(
            '¿Estás seguro de que deseas desactivar $_biometricType? Deberás ingresar tu cédula y contraseña para iniciar sesión.',
            style: AppStyles.bodyLarge,
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text(
                'Cancelar',
                style: TextStyle(color: AppColors.textSecondaryColor),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.errorColor,
              ),
              onPressed: () async {
                Navigator.pop(context);
                await _disableBiometric();
              },
              child: Text('Desactivar'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _disableBiometric() async {
    setState(() {
      _isLoading = true;
    });

    await _biometricService.disableBiometric();

    setState(() {
      _isLoading = false;
      _biometricEnabled = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      CommonWidgets.buildCustomSnackBar(
        message: '$_biometricType desactivada correctamente',
        type: SnackBarType.success,
      ),
    );
  }

  Future<void> _updateProfile() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        UserModel updatedUser = UserModel(
          uid: widget.user.uid,
          nombres: _nombresController.text,
          apellidos: _apellidosController.text,
          email: _emailController.text,
          cedula: _cedulaController.text,
          telefono: _telefonoController.text,
          saldo: widget.user.saldo,
        );

        await _userService.updateUserData(updatedUser);

        setState(() {
          _isEditing = false;
          _isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          CommonWidgets.buildCustomSnackBar(
            message: 'Perfil actualizado correctamente',
            type: SnackBarType.success,
          ),
        );

        Navigator.pop(context, true);
      } catch (e) {
        setState(() {
          _isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          CommonWidgets.buildCustomSnackBar(
            message: 'Error al actualizar el perfil: $e',
            type: SnackBarType.error,
          ),
        );
      }
    }
  }

  Future<void> _signOut() async {
    try {
      await _authService.signOut();
      Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        CommonWidgets.buildCustomSnackBar(
          message: 'Error al cerrar sesión: $e',
          type: SnackBarType.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        title: Text(
          'Mi Perfil',
          style: AppStyles.subheadingLarge.copyWith(
            color: AppColors.textOnPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: AppColors.primaryColor,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textOnPrimary),
        actions: [
          if (!_isEditing)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                setState(() {
                  _isEditing = true;
                });
              },
            ),
        ],
      ),
      body: _isLoading
          ? CommonWidgets.buildLoadingIndicator(
              message: 'Actualizando perfil...',
            )
          : SafeArea(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    _buildProfileHeader(),
                    _buildProfileForm(),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildProfileHeader() {
    final String fullName = '${widget.user.nombres} ${widget.user.apellidos}';
    
    return Container(
      padding: const EdgeInsets.all(AppStyles.spacingXL),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(AppStyles.radiusXXL),
          bottomRight: Radius.circular(AppStyles.radiusXXL),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryColor.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Column(
        children: [
          CommonWidgets.buildUserAvatar(
            name: fullName,
            size: 100,
            backgroundColor: AppColors.surfaceColor,
          ),
          const SizedBox(height: AppStyles.spacingL),
          Text(
            fullName,
            style: AppStyles.headingMedium.copyWith(
              color: AppColors.textOnPrimary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppStyles.spacingS),
          Text(
            widget.user.email,
            style: AppStyles.bodyLarge.copyWith(
              color: AppColors.textOnPrimary.withOpacity(0.8),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildProfileForm() {
    return Container(
      padding: const EdgeInsets.all(AppStyles.spacingL),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            CommonWidgets.buildSectionHeader(
              title: 'Información Personal',
              subtitle: 'Datos básicos de tu perfil',
            ),
            const SizedBox(height: AppStyles.spacingL),
            _buildTextField(
              controller: _nombresController,
              label: 'Nombres',
              icon: Icons.person,
              enabled: _isEditing,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Por favor ingrese sus nombres';
                }
                return null;
              },
            ),
            const SizedBox(height: AppStyles.spacingL),
            _buildTextField(
              controller: _apellidosController,
              label: 'Apellidos',
              icon: Icons.person_outline,
              enabled: _isEditing,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Por favor ingrese sus apellidos';
                }
                return null;
              },
            ),
            const SizedBox(height: AppStyles.spacingXL),
            CommonWidgets.buildSectionHeader(
              title: 'Información de Contacto',
              subtitle: 'Datos de contacto y comunicación',
            ),
            const SizedBox(height: AppStyles.spacingL),
            _buildTextField(
              controller: _emailController,
              label: 'Correo Electrónico',
              icon: Icons.email,
              enabled: _isEditing,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Por favor ingrese su correo electrónico';
                }
                if (!RegExp(r'^[\w\-.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                  return 'Por favor ingrese un correo electrónico válido';
                }
                return null;
              },
            ),
            const SizedBox(height: AppStyles.spacingL),
            _buildTextField(
              controller: _telefonoController,
              label: 'Número de Teléfono',
              icon: Icons.phone,
              enabled: _isEditing,
              keyboardType: TextInputType.phone,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Por favor ingrese su número de teléfono';
                }
                return null;
              },
            ),
            const SizedBox(height: AppStyles.spacingXL),
            CommonWidgets.buildSectionHeader(
              title: 'Identificación',
              subtitle: 'Documento de identidad',
            ),
            const SizedBox(height: AppStyles.spacingL),
            _buildTextField(
              controller: _cedulaController,
              label: 'Cédula',
              icon: Icons.badge,
              enabled: _isEditing,
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Por favor ingrese su cédula';
                }
                return null;
              },
            ),
            
            // Sección de Seguridad con Biometría
            if (_biometricAvailable) ...[
              const SizedBox(height: AppStyles.spacingXXL),
              CommonWidgets.buildSectionHeader(
                title: 'Seguridad',
                subtitle: 'Configuración de acceso biométrico',
              ),
              const SizedBox(height: AppStyles.spacingL),
              _buildBiometricOption(),
            ],
            
            const SizedBox(height: AppStyles.spacingXXL),
            if (_isEditing)
              Row(
                children: [
                  Expanded(
                    child: CommonWidgets.buildCustomButton(
                      text: 'Cancelar',
                      isOutlined: true,
                      onPressed: () {
                        setState(() {
                          _isEditing = false;
                          _nombresController.text = widget.user.nombres;
                          _apellidosController.text = widget.user.apellidos;
                          _emailController.text = widget.user.email;
                          _cedulaController.text = widget.user.cedula;
                          _telefonoController.text = widget.user.telefono;
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: AppStyles.spacingL),
                  Expanded(
                    child: CommonWidgets.buildCustomButton(
                      text: 'Guardar',
                      onPressed: _updateProfile,
                      icon: Icons.save,
                      isLoading: _isLoading,
                    ),
                  ),
                ],
              ),
            const SizedBox(height: AppStyles.spacingL),
            if (!_isEditing) ...[
              _buildBiometricSettings(),
              const SizedBox(height: AppStyles.spacingL),
            ],
            if (!_isEditing)
              CommonWidgets.buildCustomButton(
                text: 'Cerrar Sesión',
                backgroundColor: AppColors.errorColor,
                icon: Icons.logout,
                onPressed: _signOut,
              ),
            const SizedBox(height: AppStyles.spacingXL),
          ],
        ),
      ),
    );
  }

  Widget _buildBiometricSettings() {
  return FutureBuilder<Map<String, dynamic>>(
    future: _getBiometricStatus(),
    builder: (context, snapshot) {
      if (!snapshot.hasData) {
        return const SizedBox.shrink();
      }

      final data = snapshot.data!;
      final isAvailable = data['isAvailable'] as bool;
      final isEnabled = data['isEnabled'] as bool;
      final biometricType = data['biometricType'] as String;

      if (!isAvailable) {
        return const SizedBox.shrink();
      }

      return Container(
        margin: const EdgeInsets.symmetric(horizontal: AppStyles.spacingL),
        decoration: AppStyles.primaryCardDecoration,
        child: Padding(
          padding: const EdgeInsets.all(AppStyles.spacingL),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CommonWidgets.buildSectionHeader(
                title: 'Seguridad',
                subtitle: 'Configuración de autenticación',
              ),
              const SizedBox(height: AppStyles.spacingL),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(AppStyles.spacingM),
                    decoration: BoxDecoration(
                      color: AppColors.accentColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(AppStyles.radiusM),
                    ),
                    child: Icon(
                      Icons.fingerprint,
                      color: AppColors.accentColor,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: AppStyles.spacingL),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          biometricType,
                          style: AppStyles.subheadingMedium.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: AppStyles.spacingXS),
                        Text(
                          isEnabled
                              ? 'Habilitado para inicio rápido'
                              : 'Deshabilitado',
                          style: AppStyles.bodySmall.copyWith(
                            color: isEnabled
                                ? AppColors.successColor
                                : AppColors.textSecondaryColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Switch(
                    value: isEnabled,
                    onChanged: (value) => _toggleBiometricAuth(value),
                    activeColor: AppColors.accentColor,
                  ),
                ],
              ),
              if (isEnabled) ...[
                const SizedBox(height: AppStyles.spacingM),
                Container(
                  padding: const EdgeInsets.all(AppStyles.spacingM),
                  decoration: BoxDecoration(
                    color: AppColors.successLight,
                    borderRadius: BorderRadius.circular(AppStyles.radiusS),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.check_circle,
                        color: AppColors.successColor,
                        size: 16,
                      ),
                      const SizedBox(width: AppStyles.spacingS),
                      Expanded(
                        child: Text(
                          'Puedes iniciar sesión usando $biometricType en tu próximo acceso',
                          style: AppStyles.bodySmall.copyWith(
                            color: AppColors.successColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      );
    },
  );
}

// Método para obtener el estado de la biometría
Future<Map<String, dynamic>> _getBiometricStatus() async {
  bool isAvailable = await _authService.isBiometricAvailable();
  bool isEnabled = await _authService.isBiometricEnabled();
  String biometricType = await _authService.getBiometricTypeDescription();

  return {
    'isAvailable': isAvailable,
    'isEnabled': isEnabled,
    'biometricType': biometricType,
  };
}

// Método para alternar la biometría
Future<void> _toggleBiometricAuth(bool enable) async {
  if (enable) {
    // Mostrar diálogo de confirmación
    bool? confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppStyles.radiusL),
          ),
          title: Row(
            children: [
              Icon(
                Icons.fingerprint,
                color: AppColors.accentColor,
                size: 28,
              ),
              const SizedBox(width: AppStyles.spacingM),
              Expanded(
                child: Text(
                  'Habilitar Biometría',
                  style: AppStyles.headingSmall,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Para habilitar el inicio de sesión biométrico, necesitas ingresar tu contraseña actual.',
                style: AppStyles.bodyMedium,
              ),
              const SizedBox(height: AppStyles.spacingL),
              TextFormField(
                obscureText: true,
                decoration: AppStyles.inputDecoration(
                  label: 'Contraseña',
                  icon: Icons.lock_outline,
                  hint: 'Ingresa tu contraseña',
                ),
                onChanged: (value) {
                  // Guardar la contraseña temporalmente
                  setState(() {
                    _tempPassword = value;
                  });
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(
                'Cancelar',
                style: AppStyles.buttonMedium.copyWith(
                  color: AppColors.textSecondaryColor,
                ),
              ),
            ),
            ElevatedButton(
              style: AppStyles.accentButtonStyle,
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(
                'Habilitar',
                style: AppStyles.buttonMedium.copyWith(
                  color: AppColors.textOnPrimary,
                ),
              ),
            ),
          ],
        );
      },
    );

    if (confirm == true && _tempPassword != null) {
      setState(() {
        _isLoading = true;
      });

      try {
        // Habilitar biometría con la contraseña ingresada
        bool success = await _authService.enableBiometricAuth(
          widget.user.cedula,
          _tempPassword!,
        );

        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            CommonWidgets.buildCustomSnackBar(
              message: 'Autenticación biométrica habilitada correctamente',
              type: SnackBarType.success,
            ),
          );
          setState(() {}); // Actualizar UI
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            CommonWidgets.buildCustomSnackBar(
              message: 'No se pudo habilitar la autenticación biométrica',
              type: SnackBarType.error,
            ),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          CommonWidgets.buildCustomSnackBar(
            message: 'Error: ${e.toString()}',
            type: SnackBarType.error,
          ),
        );
      } finally {
        setState(() {
          _isLoading = false;
          _tempPassword = null;
        });
      }
    }
  } else {
    // Deshabilitar biometría
    bool? confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppStyles.radiusL),
          ),
          title: Text(
            'Deshabilitar Biometría',
            style: AppStyles.headingSmall,
          ),
          content: Text(
            '¿Estás seguro de que deseas deshabilitar el inicio de sesión biométrico?',
            style: AppStyles.bodyMedium,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(
                'Cancelar',
                style: AppStyles.buttonMedium.copyWith(
                  color: AppColors.textSecondaryColor,
                ),
              ),
            ),
            ElevatedButton(
              style: AppStyles.errorButtonStyle,
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(
                'Deshabilitar',
                style: AppStyles.buttonMedium.copyWith(
                  color: AppColors.textOnPrimary,
                ),
              ),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      await _authService.disableBiometricAuth();
      ScaffoldMessenger.of(context).showSnackBar(
        CommonWidgets.buildCustomSnackBar(
          message: 'Autenticación biométrica deshabilitada',
          type: SnackBarType.info,
        ),
      );
      setState(() {}); // Actualizar UI
    }
  }
}


  Widget _buildBiometricOption() {
    return Container(
      decoration: AppStyles.primaryCardDecoration,
      padding: const EdgeInsets.all(AppStyles.spacingL),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _biometricEnabled 
                  ? AppColors.successLight 
                  : AppColors.accentColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppStyles.radiusM),
            ),
            child: Icon(
              Icons.fingerprint,
              color: _biometricEnabled 
                  ? AppColors.successColor 
                  : AppColors.accentColor,
              size: 28,
            ),
          ),
          const SizedBox(width: AppStyles.spacingL),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _biometricType,
                  style: AppStyles.subheadingMedium.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _biometricEnabled 
                      ? 'Acceso rápido activado' 
                      : 'Inicia sesión más rápido',
                  style: AppStyles.bodySmall.copyWith(
                    color: AppColors.textSecondaryColor,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: _biometricEnabled,
            onChanged: _isLoading ? null : _toggleBiometric,
            activeColor: AppColors.successColor,
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool enabled = true,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return Container(
      decoration: enabled 
          ? AppStyles.primaryCardDecoration 
          : AppStyles.simpleCardDecoration,
      child: TextFormField(
        controller: controller,
        enabled: enabled,
        keyboardType: keyboardType,
        style: AppStyles.bodyLarge.copyWith(
          color: enabled 
              ? AppColors.textPrimaryColor 
              : AppColors.textSecondaryColor,
        ),
        decoration: AppStyles.inputDecoration(
          label: label,
          icon: icon,
        ).copyWith(
          filled: true,
          fillColor: enabled 
              ? AppColors.surfaceColor 
              : AppColors.cardBackground,
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppStyles.radiusM),
            borderSide: const BorderSide(
              color: AppColors.accentColor,
              width: 2,
            ),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppStyles.radiusM),
            borderSide: const BorderSide(
              color: AppColors.errorColor,
              width: 1,
            ),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppStyles.radiusM),
            borderSide: const BorderSide(
              color: AppColors.errorColor,
              width: 2,
            ),
          ),
        ),
        validator: validator,
      ),
    );
  }
}