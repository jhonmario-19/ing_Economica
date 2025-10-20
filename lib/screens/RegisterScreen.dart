import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:billetera/models/user_model.dart';
import 'package:billetera/services/auth_service.dart';
import 'package:billetera/constants/app_colors.dart';
import 'package:billetera/constants/app_styles.dart';
import 'package:billetera/constants/app_common_widget.dart';

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nombresController = TextEditingController();
  final _apellidosController = TextEditingController();
  final _emailController = TextEditingController();
  final _cedulaController = TextEditingController();
  final _telefonoController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  final AuthService _authService = AuthService();
  bool _isLoading = false;
  String? _errorMessage;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  Future<void> _register() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    if (_formKey.currentState!.validate()) {
      try {
        UserModel user = UserModel(
          uid: '',
          nombres: _nombresController.text.trim(),
          apellidos: _apellidosController.text.trim(),
          email: _emailController.text.trim().toLowerCase(),
          cedula: _cedulaController.text.trim(),
          telefono: _telefonoController.text.trim(),
        );

        User? result = await _authService.registerWithCedulaAndPassword(
            user, _passwordController.text);

        if (result != null) {
          // Mostrar mensaje de éxito
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.white),
                  SizedBox(width: 8),
                  Expanded(child: Text('¡Cuenta creada exitosamente!')),
                ],
              ),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 3),
            ),
          );
          
          Navigator.pushReplacementNamed(context, '/home');
        } else {
          setState(() {
            _errorMessage = '❌ No se pudo completar el registro. Inténtalo de nuevo.';
          });
        }
      } on FirebaseAuthException catch (e) {
        print('FirebaseAuthException: ${e.code} - ${e.message}');
        
        setState(() {
          switch (e.code) {
            case 'email-already-in-use':
              _errorMessage = '⚠️ Este correo electrónico ya está registrado.\n'
                            'Usa un correo diferente o inicia sesión.';
              break;
            case 'weak-password':
              _errorMessage = '🔒 La contraseña debe tener al menos 6 caracteres.';
              break;
            case 'invalid-email':
              _errorMessage = '📧 El formato del correo electrónico no es válido.';
              break;
            case 'cedula-already-in-use':
              _errorMessage = '🆔 Ya existe un usuario registrado con esta cédula.';
              break;
            case 'user-not-found':
              _errorMessage = '👤 No se encontró el usuario.';
              break;
            case 'network-request-failed':
              _errorMessage = '🌐 Error de conexión. Verifica tu internet.';
              break;
            case 'too-many-requests':
              _errorMessage = '⏰ Demasiados intentos. Espera un momento e intenta de nuevo.';
              break;
            default:
              _errorMessage = '❌ Error: ${e.message ?? 'Error de autenticación desconocido'}';
          }
        });
      } catch (e) {
        print('Error general: $e');
        
        setState(() {
          _errorMessage = '❌ Error inesperado. Inténtalo de nuevo.\n'
                        'Si el problema persiste, contacta soporte.';
        });
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.primaryColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Crear cuenta',
          style: AppStyles.headingMedium,
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Logo central
                // Center(
                //   // child: Image.asset(
                //   //   'assets/Logo.png',
                //   //   height: 250,
                //   // ),
                // ),
                SizedBox(height: 24),

                // Mensaje explicativo
                Text(
                  'Completa tus datos',
                  style: AppStyles.headingMedium,
                ),
                SizedBox(height: 8),
                Text(
                  'Crea tu cuenta para administrar tus finanzas',
                  style: AppStyles.subheadingMedium,
                ),
                SizedBox(height: 24),

                // Mensaje de error (si existe)
                if (_errorMessage != null)
                  Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.errorColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.errorColor),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.error_outline, color: AppColors.errorColor),
                        SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            _errorMessage!,
                            style: TextStyle(color: AppColors.errorColor),
                          ),
                        ),
                      ],
                    ),
                  ),
                if (_errorMessage != null) SizedBox(height: 24),

                // Campos de formulario
                _buildTextField(
                  controller: _nombresController,
                  label: 'Nombres',
                  icon: Icons.person_outline,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor ingresa tus nombres';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),

                _buildTextField(
                  controller: _apellidosController,
                  label: 'Apellidos',
                  icon: Icons.person_outline,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor ingresa tus apellidos';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),

                _buildTextField(
                  controller: _emailController,
                  label: 'Correo Electrónico',
                  icon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor ingresa tu correo electrónico';
                    }
                    final emailRegex =
                        RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                    if (!emailRegex.hasMatch(value)) {
                      return 'Ingresa un correo electrónico válido';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),

                _buildTextField(
                  controller: _cedulaController,
                  label: 'Cédula',
                  icon: Icons.badge_outlined,
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor ingresa tu cédula';
                    }
                    if (value.length < 8) {
                      return 'La cédula debe tener al menos 8 caracteres';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),

                _buildTextField(
                  controller: _telefonoController,
                  label: 'Número de Teléfono',
                  icon: Icons.phone_outlined,
                  keyboardType: TextInputType.phone,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor ingresa tu número de teléfono';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),

                _buildPasswordField(
                  controller: _passwordController,
                  label: 'Contraseña',
                  obscureText: _obscurePassword,
                  toggleObscure: () {
                    setState(() {
                      _obscurePassword = !_obscurePassword;
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor ingresa una contraseña';
                    }
                    if (value.length < 6) {
                      return 'La contraseña debe tener al menos 6 caracteres';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),

                _buildPasswordField(
                  controller: _confirmPasswordController,
                  label: 'Confirmar Contraseña',
                  obscureText: _obscureConfirmPassword,
                  toggleObscure: () {
                    setState(() {
                      _obscureConfirmPassword = !_obscureConfirmPassword;
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor confirma tu contraseña';
                    }
                    if (value != _passwordController.text) {
                      return 'Las contraseñas no coinciden';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 32),

                // Botón de registro
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _register,
                    child: _isLoading
                        ? SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2.0,
                            ),
                          )
                        : Text(
                            'Crear cuenta',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                    style: AppStyles.primaryButtonStyle,
                  ),
                ),
                SizedBox(height: 24),

                // Enlace para iniciar sesión
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '¿Ya tienes una cuenta?',
                      style: AppStyles.subheadingMedium,
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pushReplacementNamed(context, '/');
                      },
                      child: Text(
                        'Inicia sesión',
                        style: TextStyle(
                          color: AppColors.accentColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required String? Function(String?) validator,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: AppStyles.inputDecoration(
        label: label,
        icon: icon,
      ),
      validator: validator,
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String label,
    required bool obscureText,
    required Function() toggleObscure,
    required String? Function(String?) validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(Icons.lock_outline, color: AppColors.primaryColor),
        suffixIcon: IconButton(
          icon: Icon(
            obscureText ? Icons.visibility_off : Icons.visibility,
            color: AppColors.textSecondaryColor,
          ),
          onPressed: toggleObscure,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.accentColor, width: 2),
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: EdgeInsets.symmetric(vertical: 16),
      ),
      validator: validator,
    );
  }
}
