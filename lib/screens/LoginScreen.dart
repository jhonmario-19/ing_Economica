import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:billetera/services/auth_service.dart';
import 'package:billetera/constants/app_colors.dart';
import 'package:billetera/constants/app_styles.dart';
import 'package:billetera/constants/app_common_widget.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _cedulaController = TextEditingController();
  final _passwordController = TextEditingController();

  final AuthService _authService = AuthService();
  bool _isLoading = false;
  String? _errorMessage;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _cedulaController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      User? result = await _authService.signInWithCedulaAndPassword(
        _cedulaController.text.trim(),
        _passwordController.text,
      );

      if (result != null) {
        // Mostrar mensaje de éxito
        ScaffoldMessenger.of(context).showSnackBar(
          CommonWidgets.buildCustomSnackBar(
            message: '¡Bienvenido de vuelta!',
            type: SnackBarType.success,
          ),
        );
        Navigator.pushReplacementNamed(context, '/home');
      } else {
        setState(() {
          _errorMessage = 'Credenciales inválidas. Verifica tu cédula y contraseña.';
        });
      }
    } catch (e) {
      setState(() {
        if (e.toString().contains('user-not-found')) {
          _errorMessage = 'Usuario no encontrado. Verifica tu cédula.';
        } else if (e.toString().contains('wrong-password')) {
          _errorMessage = 'Contraseña incorrecta. Inténtalo de nuevo.';
        } else if (e.toString().contains('too-many-requests')) {
          _errorMessage = 'Demasiados intentos. Espera un momento.';
        } else {
          _errorMessage = 'Error de conexión. Verifica tu internet.';
        }
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: AppStyles.spacingL,
            vertical: AppStyles.spacingM,
          ),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: size.height - MediaQuery.of(context).padding.top - MediaQuery.of(context).padding.bottom,
            ),
            child: IntrinsicHeight(
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Logo y bienvenida
                    _buildHeader(),
                    
                    const SizedBox(height: AppStyles.spacingXL),
                    
                    // Mensaje de error
                    if (_errorMessage != null) ...[
                      _buildErrorMessage(),
                      const SizedBox(height: AppStyles.spacingL),
                    ],

                    // Formulario
                    _buildForm(),
                    
                    const SizedBox(height: AppStyles.spacingL),
                    
                    // Botón de login
                    _buildLoginButton(),
                    
                    const SizedBox(height: AppStyles.spacingM),
                    
                    // Enlace olvido contraseña
                    _buildForgotPasswordLink(),
                    
                    const Spacer(),
                    
                    // Enlace registro
                    _buildRegisterLink(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Logo placeholder (puedes reemplazar con tu logo)
        Center(
          child: Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(AppStyles.radiusXL),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryColor.withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: const Icon(
              Icons.account_balance_wallet,
              size: 48,
              color: AppColors.textOnPrimary,
            ),
          ),
        ),
        
        const SizedBox(height: AppStyles.spacingXL),
        
        Text(
          '¡Bienvenido de vuelta!',
          style: AppStyles.headingMedium,
        ),
        
        const SizedBox(height: AppStyles.spacingS),
        
        Text(
          'Inicia sesión para continuar gestionando tus finanzas',
          style: AppStyles.subheadingMedium,
        ),
      ],
    );
  }

  Widget _buildErrorMessage() {
    return Container(
      padding: const EdgeInsets.all(AppStyles.spacingM),
      decoration: BoxDecoration(
        color: AppColors.errorLight,
        borderRadius: BorderRadius.circular(AppStyles.radiusM),
        border: Border.all(
          color: AppColors.errorColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.error_outline,
            color: AppColors.errorColor,
            size: 20,
          ),
          const SizedBox(width: AppStyles.spacingM),
          Expanded(
            child: Text(
              _errorMessage!,
              style: AppStyles.bodyMedium.copyWith(
                color: AppColors.errorColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildForm() {
    return Column(
      children: [
        // Campo cédula
        TextFormField(
          controller: _cedulaController,
          keyboardType: TextInputType.number,
          decoration: AppStyles.inputDecoration(
            label: 'Número de cédula',
            icon: Icons.person_outline,
            hint: 'Ingresa tu cédula',
          ),
          style: AppStyles.bodyMedium,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Por favor ingresa tu cédula';
            }
            if (value.trim().length < 8) {
              return 'La cédula debe tener al menos 8 dígitos';
            }
            return null;
          },
        ),
        
        const SizedBox(height: AppStyles.spacingL),
        
        // Campo contraseña
        TextFormField(
          controller: _passwordController,
          obscureText: _obscurePassword,
          decoration: AppStyles.inputDecoration(
            label: 'Contraseña',
            icon: Icons.lock_outline,
            hint: 'Ingresa tu contraseña',
            suffix: IconButton(
              icon: Icon(
                _obscurePassword ? Icons.visibility_off : Icons.visibility,
                color: AppColors.textTertiaryColor,
              ),
              onPressed: () {
                setState(() {
                  _obscurePassword = !_obscurePassword;
                });
              },
            ),
          ),
          style: AppStyles.bodyMedium,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Por favor ingresa tu contraseña';
            }
            if (value.length < 6) {
              return 'La contraseña debe tener al menos 6 caracteres';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildLoginButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: AppStyles.primaryButtonStyle,
        onPressed: _isLoading ? null : _login,
        child: _isLoading
            ? SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  color: AppColors.textOnPrimary,
                  strokeWidth: 2,
                ),
              )
            : Text(
                'Iniciar Sesión',
                style: AppStyles.buttonLarge.copyWith(
                  color: AppColors.textOnPrimary,
                ),
              ),
      ),
    );
  }

  Widget _buildForgotPasswordLink() {
    return Align(
      alignment: Alignment.centerRight,
      child: TextButton(
        onPressed: () {
          Navigator.pushNamed(context, '/reset_password');
        },
        style: AppStyles.textButtonStyle,
        child: Text(
          '¿Olvidaste tu contraseña?',
          style: AppStyles.buttonMedium.copyWith(
            color: AppColors.accentColor,
          ),
        ),
      ),
    );
  }

  Widget _buildRegisterLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          '¿No tienes una cuenta? ',
          style: AppStyles.bodyMedium,
        ),
        TextButton(
          onPressed: () {
            Navigator.pushNamed(context, '/register');
          },
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            minimumSize: const Size(0, 36),
          ),
          child: Text(
            'Regístrate aquí',
            style: AppStyles.buttonMedium.copyWith(
              color: AppColors.accentColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}