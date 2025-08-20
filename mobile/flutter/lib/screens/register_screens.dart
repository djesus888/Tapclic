// lib/screens/register_screen.dart

import 'package:flutter/material.dart';
import '../components/input_field.dart';
import '../components/custom_button.dart';
import '../services/auth_service.dart';

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  String role = 'cliente';
  bool isLoading = false;

  void register() async {
    setState(() { isLoading = true; });
    bool success = await AuthService.register(
      nameController.text,
      emailController.text,
      passwordController.text,
      role
    );
    setState(() { isLoading = false; });
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Usuario registrado')));
      Navigator.pushReplacementNamed(context, '/login');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error al registrar')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Registrarse')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            InputField(controller: nameController, label: 'Nombre'),
            SizedBox(height: 16),
            InputField(controller: emailController, label: 'Correo'),
            SizedBox(height: 16),
            InputField(controller: passwordController, label: 'Contraseña', isPassword: true),
            SizedBox(height: 16),
            DropdownButton<String>(
              value: role,
              onChanged: (value) {
                if (value != null) setState(() { role = value; });
