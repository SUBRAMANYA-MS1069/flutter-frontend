import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  String _errorMessage = '';

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      // Replace with your actual API endpoint
      final response = await http.post(
        Uri.parse('http://10.0.2.2:5000/api/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': _emailController.text,
          'password': _passwordController.text,
        }),
      );

      final responseData = json.decode(response.body);

      if (response.statusCode == 200) {
        // Save token to shared preferences
        final prefs = await SharedPreferences.getInstance();
        prefs.setString('token', responseData['token']);
        prefs.setString('userId', responseData['user']['_id']);
        prefs.setString('name', responseData['user']['name']);
        prefs.setString('email', responseData['user']['email']);
        prefs.setString('role', responseData['user']['role']);
        prefs.setString('department', responseData['user']['department']);

        // Navigate to home screen
        Navigator.of(context).pushReplacementNamed('/home');
      } else {
        setState(() {
          _errorMessage = responseData['error'] ?? 'Login failed';
        });
      }
    } catch (error) {
      setState(() {
        _errorMessage = 'Could not connect to server. Please try again later.';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Logo or Image
              Container(
                height: 150,
                alignment: Alignment.center,
                child: const Text(
                  'Educational CMS',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              
              const SizedBox(height: 30),
              
              // Email Field
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.email),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 20),
              
              // Password Field
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.lock),
                ),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your password';
                  }
                  return null;
                },
              ),
              
              // Forgot Password Link
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {
                    // Navigate to forgot password screen
                    // Navigator.of(context).pushNamed('/forgot-password');
                  },
                  child: const Text('Forgot Password?'),
                ),
              ),
              
              const SizedBox(height: 20),
              
              // Error Message
              if (_errorMessage.isNotEmpty)
                Container(
                  padding: const EdgeInsets.all(8),
                  color: Colors.red.shade100,
                  child: Text(
                    _errorMessage,
                    style: TextStyle(color: Colors.red.shade900),
                  ),
                ),
              
              const SizedBox(height: 20),
              
              // Login Button
              ElevatedButton(
                onPressed: _isLoading ? null : _login,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator()
                    : const Text('LOGIN', style: TextStyle(fontSize: 16)),
              ),
              
              const SizedBox(height: 20),
              
              // Sign Up Link
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Don\'t have an account?'),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pushReplacementNamed('/signup');
                    },
                    child: const Text('Sign Up'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}