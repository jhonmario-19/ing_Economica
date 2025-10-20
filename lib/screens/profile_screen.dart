import 'package:flutter/material.dart';
import 'package:billetera/models/user_model.dart';
import 'package:billetera/services/user_service.dart';
import 'package:billetera/services/auth_service.dart';
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

  bool _isEditing = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nombresController = TextEditingController(text: widget.user.nombres);
    _apellidosController = TextEditingController(text: widget.user.apellidos);
    _emailController = TextEditingController(text: widget.user.email);
    _cedulaController = TextEditingController(text: widget.user.cedula);
    _telefonoController = TextEditingController(text: widget.user.telefono);
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
                if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                    .hasMatch(value)) {
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
                          // Restaurar valores originales
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