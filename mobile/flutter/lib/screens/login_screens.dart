// lib/screens/login_screen.dart

import 'package:flutter/material.dart';
import '../components/input_field.dart';
import '../components/custom_button.dart';
import '../services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool isLoading = false;

  void login() async {
    setState(() { isLoading = true; });
    bool success = await AuthService.login(emailController.text, passwordController.text);
    setState(() { isLoading = false; });
    if (success) {
      Navigator.pushReplacementNamed(context, '/home');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Credenciales incorrectas')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Iniciar Sesión')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            InputField(controller: emailController, label: 'Correo'),
            SizedBox(height: 16),
            InputField(controller: passwordController, label: 'Contraseña', isPassword: true),
            SizedBox(height: 32),
            isLoading ? CircularProgressIndicator() : CustomButton(text: 'Ingresar', onPressed: login),
            SizedBox(height: 16),
            TextButton(
              onPressed: () => Navigator.pushNamed(context, '/register'),
              child: Text('¿No tienes cuenta? Regístrate'),
            ),
          ],
        ),
      ),
    );
  }
}
