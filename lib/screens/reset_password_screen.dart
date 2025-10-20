import 'package:flutter/material.dart';
import 'package:billetera/services/auth_service.dart';
import 'package:billetera/constants/app_colors.dart';
import 'package:billetera/constants/app_styles.dart';

class ResetPasswordScreen extends StatefulWidget {
  @override
  _ResetPasswordScreenState createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final AuthService _authService = AuthService();
  bool _isLoading = false;

  Future<void> _resetPassword() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        await _authService.resetPassword(_emailController.text);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Se ha enviado un enlace de recuperación a su correo'),
            backgroundColor: AppColors.successColor,
          ),
        );
        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al enviar el correo de recuperación'),
            backgroundColor: AppColors.errorColor,
          ),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.primaryColor),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image.asset('assets/Logo.png', height: 200),
                // SizedBox(height: 32),
                Text(
                  'Recuperar contraseña',
                  style: AppStyles.headingMedium,
                ),
                SizedBox(height: 8),
                Text(
                  'Ingresa tu correo electrónico para recuperar tu contraseña',
                  style: AppStyles.subheadingMedium,
                ),
                SizedBox(height: 32),
                TextFormField(
                  controller: _emailController,
                  decoration: AppStyles.inputDecoration(
                    label: 'Correo Electrónico',
                    icon: Icons.email_outlined,
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor ingresa tu correo electrónico';
                    }
                    if (!value.contains('@')) {
                      return 'Ingresa un correo electrónico válido';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: AppStyles.primaryButtonStyle,
                    onPressed: _isLoading ? null : _resetPassword,
                    child: _isLoading
                        ? CircularProgressIndicator(color: Colors.white)
                        : Text(
                            'Recuperar Contraseña',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}