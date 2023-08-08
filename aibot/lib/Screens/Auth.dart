import 'dart:convert';

import 'package:aibot/ChatGptApi/urls.dart';
import 'package:aibot/Screens/chat_page.dart';
import 'package:aibot/Screens/snackbars.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class RegistrationScreen extends StatefulWidget {
  @override
  _RegistrationScreenState createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _firstnameController = TextEditingController();
  final TextEditingController _lastnameController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String? _emailErrorText;
  String? _passwordErrorText;
  bool _obscurePassword = true;

  AndroidOptions _getAndroidOptions() => const AndroidOptions(
        encryptedSharedPreferences: true,
      );

  Future<void> _registerUser() async {
    final email = _emailController.text;
    final password = _passwordController.text;
    final firstname = _firstnameController.text;
    final lastname = _lastnameController.text;
    final urls = ApiConstants.signUpUrl;
    bool isLoading = false;
    final body = jsonEncode({
      'email': email,
      'password': password,
      'firstName': firstname,
      'lastName': lastname
    });

    try {
      final response = await http.post(Uri.parse(urls), body: body);
      if (response.statusCode == 200) {
        print('User registration successful');
        await storage.write(key: 'email', value: email);
        await storage.write(key: 'firstname', value: firstname);

        SnackbarUtils.showSuccessSnackbar(
            context, 'User Registration Successfull');

        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => VerificationScreen(email)),
        );
      } else {
        SnackbarUtils.showErrorSnackbar(context, 'User Registration Failed');
      }
    } catch (error) {
      print('Error registering user: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error registering user: $error'),
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  void _togglePasswordVisibility() {
    setState(() {
      _obscurePassword = !_obscurePassword;
    });
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty || !value.contains('@')) {
      return 'Please enter a valid email';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty || value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Account'),
        centerTitle: true,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue, Colors.teal],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: Card(
            elevation: 8.0,
            margin: EdgeInsets.symmetric(horizontal: 32.0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.0),
            ),
            child: Padding(
              padding: EdgeInsets.all(24.0),
              child: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Create Account',
                        style: TextStyle(
                          fontSize: 24.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 24.0),
                      TextFormField(
                        controller: _emailController,
                        decoration: InputDecoration(
                          labelText: 'Email',
                          prefixIcon: Icon(Icons.email),
                          errorText: _emailErrorText,
                        ),
                        keyboardType: TextInputType.emailAddress,
                        validator: _validateEmail,
                        onChanged: (value) {
                          setState(() {
                            _emailErrorText = _validateEmail(value);
                          });
                        },
                      ),
                      SizedBox(height: 16.0),
                      TextFormField(
                        controller: _passwordController,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          prefixIcon: Icon(Icons.lock),
                          errorText: _passwordErrorText,
                          suffixIcon: GestureDetector(
                            onTap: _togglePasswordVisibility,
                            child: Icon(
                              _obscurePassword
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                            ),
                          ),
                        ),
                        obscureText: _obscurePassword,
                        validator: _validatePassword,
                        onChanged: (value) {
                          setState(() {
                            _passwordErrorText = _validatePassword(value);
                          });
                        },
                      ),
                      SizedBox(height: 16.0),
                      TextFormField(
                        controller: _firstnameController,
                        decoration: InputDecoration(
                          labelText: 'First Name',
                          prefixIcon: Icon(Icons.person),
                        ),
                      ),
                      SizedBox(height: 16.0),
                      TextFormField(
                        controller: _lastnameController,
                        decoration: InputDecoration(
                          labelText: 'Last Name',
                          prefixIcon: Icon(Icons.person_outline),
                        ),
                      ),
                      SizedBox(height: 24.0),
                      GestureDetector(
                        onTap: () {
                          if (_formKey.currentState!.validate()) {
                            _registerUser();
                          }
                        },
                        child: Container(
                          width: 240,
                          height: 40,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(25),
                            gradient: LinearGradient(
                              colors: [
                                Color.fromARGB(255, 54, 220, 148),
                                Color.fromARGB(255, 91, 229, 107),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomCenter,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Color.fromARGB(255, 161, 183, 74)
                                    .withOpacity(0.5),
                                offset: Offset(0, 4),
                                blurRadius: 5,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: Center(
                            child: Text(
                              'Sign In',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                                letterSpacing: 6.0,
                              ),
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class VerificationScreen extends StatefulWidget {
  final String email;

  VerificationScreen(this.email);

  @override
  _VerificationScreenState createState() => _VerificationScreenState();
}

class _VerificationScreenState extends State<VerificationScreen> {
  final TextEditingController _confirmationCodeController =
      TextEditingController();

  Future<void> _verifyUser() async {
    final confirmationCode = _confirmationCodeController.text;
    final email = widget.email;
    final url =
        'https://hmwx95k5yi.execute-api.ap-south-1.amazonaws.com/dev/user/confirm';
    final body =
        jsonEncode({'email': email, 'confirmationcode': confirmationCode});

    try {
      final response = await http.post(Uri.parse(url), body: body);
      if (response.statusCode == 200) {
        print('User verification completed');
        SnackbarUtils.showSuccessSnackbar(
            context, "Email Verified SuccessFully");
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => LoginScreen()),
        );
      } else {
        SnackbarUtils.showErrorSnackbar(context, "Email Verification Failed");
        print('Error verifying user');
      }
    } catch (error) {
      print('Error verifying user: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Verification'),
        centerTitle: true,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue, Colors.teal],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: Card(
            elevation: 8.0,
            margin: EdgeInsets.symmetric(horizontal: 32.0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.0),
            ),
            child: Padding(
              padding: EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Verification for ${widget.email}',
                    style: TextStyle(
                      fontSize: 24.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 24.0),
                  TextField(
                    controller: _confirmationCodeController,
                    decoration: InputDecoration(
                      labelText: 'Confirmation Code',
                      prefixIcon: Icon(Icons.code),
                    ),
                  ),
                  SizedBox(height: 24.0),
                  ElevatedButton(
                    onPressed: _verifyUser,
                    child: Text('Verify'),
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 16.0),
                      minimumSize: Size(double.infinity, 0),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({Key? key}) : super(key: key);

  @override
  _ForgotPasswordScreenState createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _confirmationCodeController =
      TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  bool _showConfirmationStep = false;
  String? _emailErrorText;
  String? _emailErrorTexts;
  String? _passwordErrorText;
  bool _obscurePassword = true;

  Future<void> _sendForgotPasswordRequest() async {
    final email = _emailController.text;
    final url =
        'https://hmwx95k5yi.execute-api.ap-south-1.amazonaws.com/dev/user/forgotpassword';

    try {
      final response = await http.post(
        Uri.parse(url),
        body: jsonEncode({'email': email}),
      );
      if (response.statusCode == 200) {
        setState(() {
          _showConfirmationStep = true;
        });
        print('Forgot password request sent successfully');
      } else {
        print('Error sending forgot password request');
      }
    } catch (error) {
      print('Error sending forgot password request: $error');
    }
  }

  Future<void> _resetPassword() async {
    final email = _emailController.text;
    final confirmationCode = _confirmationCodeController.text;
    final newPassword = _newPasswordController.text;
    bool _isloading = false;
    final url =
        'https://hmwx95k5yi.execute-api.ap-south-1.amazonaws.com/dev/user/confirmPassword';

    try {
      final response = await http.post(
        Uri.parse(url),
        body: jsonEncode({
          'email': email,
          'confirmationcode': confirmationCode,
          'newPassword': newPassword,
        }),
      );
      if (response.statusCode == 200) {
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => LoginScreen()));
        print('Password reset successful');
      } else {
        print('Error resetting password');
      }
    } catch (error) {
      print('Error resetting password: $error');
    }
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty || !value.contains('@')) {
      return 'Please enter a valid email';
    }
    return null;
  }

  void _togglePasswordVisibility() {
    setState(() {
      _obscurePassword = !_obscurePassword;
    });
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty || value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'Forgot Password',
          style: TextStyle(),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue, Colors.teal],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: Card(
            elevation: 8.0,
            margin: const EdgeInsets.symmetric(horizontal: 32.0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.0),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Forgot Password',
                    style: TextStyle(
                      fontSize: 24.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 24.0),
                  if (!_showConfirmationStep)
                    Column(
                      children: [
                        TextFormField(
                          controller: _emailController,
                          decoration: InputDecoration(
                            labelText: 'Email',
                            prefixIcon: Icon(
                                Icons.email), // Remove the trailing comma here
                            errorText: _emailErrorText,
                          ),
                          onChanged: (value) {
                            setState(() {
                              _emailErrorText = _validateEmail(value);
                            });
                          },
                          validator: _validateEmail,
                        ),
                        const SizedBox(height: 16.0),
                        GestureDetector(
                          onTap: _sendForgotPasswordRequest,
                          child: Container(
                            width: 140,
                            height: 40,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(25),
                              gradient: LinearGradient(
                                colors: [
                                  Color.fromARGB(255, 54, 184, 220),
                                  Color.fromARGB(255, 96, 91, 229),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomCenter,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Color.fromARGB(255, 74, 145, 183)
                                      .withOpacity(0.5),
                                  offset: Offset(0, 4),
                                  blurRadius: 5,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                            child: Center(
                              child: Text(
                                'Send',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 17,
                                  letterSpacing: 3.0,
                                ),
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                  if (_showConfirmationStep)
                    Column(
                      children: [
                        TextFormField(
                          controller: _emailController,
                          decoration: InputDecoration(
                            labelText: 'Email',
                            prefixIcon: Icon(Icons.email),
                            errorText: _emailErrorTexts
                          ),
                          validator: _validateEmail,
                          onChanged: (value) {
                            setState(() {
                              _emailErrorTexts = _validateEmail(value);
                            });
                          },
                        ),
                        SizedBox(height: 16.0),
                        TextField(
                          controller: _confirmationCodeController,
                          decoration: InputDecoration(
                            labelText: 'Confirmation Code',
                            prefixIcon: Icon(Icons.lock),
                          ),
                        ),
                        SizedBox(height: 16.0),
                        TextFormField(
                          controller: _newPasswordController,
                          decoration: InputDecoration(
                            labelText: 'New Password',
                            prefixIcon: Icon(Icons.lock),
                            errorText: _passwordErrorText,
                            suffixIcon: GestureDetector(
                              onTap: _togglePasswordVisibility,
                              child: Icon(
                                _obscurePassword
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                              ),
                            ),
                          ),
                          obscureText: _obscurePassword,
                          validator: _validatePassword,
                          onChanged: (value) {
                            setState(() {
                              _passwordErrorText = _validatePassword(value);
                            });
                          },
                        ),
                        SizedBox(height: 24.0),
                        GestureDetector(
                          onTap: _resetPassword,
                          child: Container(
                            width: 300,
                            height: 40,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(25),
                              gradient: LinearGradient(
                                colors: [
                                  Color(0xFF36D1DC),
                                  Color(0xFF5B86E5),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomCenter,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Color.fromARGB(255, 74, 145, 183)
                                      .withOpacity(0.5),
                                  offset: Offset(0, 4),
                                  blurRadius: 5,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                            child: Center(
                              child: Text(
                                'Reset Password',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 17,
                                  letterSpacing: 3.0,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool isLoading = false;
  String errorMessage = '';
  bool _obscurePassword = true;

  AndroidOptions _getAndroidOptions() => const AndroidOptions(
        encryptedSharedPreferences: true,
      );

  Future<void> _authenticateUser() async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    final email = _emailController.text;
    final password = _passwordController.text;
    final urls = ApiConstants.loginUrl;
    final body = jsonEncode({'email': email, 'password': password});

    try {
      final response = await http.post(Uri.parse(urls), body: body);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final idToken = data['idToken'];
        final accessToken = data['accessToken'];
        print(idToken);
        print(accessToken);

        final storage = FlutterSecureStorage();
        await storage.write(key: 'idToken', value: idToken);
        await storage.write(key: 'accessToken', value: accessToken);
        SnackbarUtils.showSuccessSnackbar(context, "User Login SuccessFull");
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ChatPage()),
        );
      } else if (response.statusCode == 401) {
        SnackbarUtils.showErrorSnackbar(context, "User Login Failed");
        setState(() {
          errorMessage = 'Incorrect email or password.';
        });
      } else {
        SnackbarUtils.showErrorSnackbar(context, "User Login Failed");
        print('Error logging in');
      }
    } catch (error) {
      SnackbarUtils.showErrorSnackbar(context, "User Login Failed");
      print('Error logging in: $error');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _navigateToRegistration() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => RegistrationScreen()),
    );
  }

  void _navigateToForgotPassword() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ForgotPasswordScreen()),
    );
  }

  void _togglePasswordVisibility() {
    setState(() {
      _obscurePassword = !_obscurePassword;
    });
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty || !value.contains('@')) {
      return 'Please enter a valid email';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty || value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: Text(
          'B.r.a.i.n.W.a.v.e',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            letterSpacing: 7.0,
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue, Colors.teal],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: Card(
            elevation: 8.0,
            margin: EdgeInsets.symmetric(horizontal: 32.0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.0),
            ),
            child: Padding(
              padding: EdgeInsets.all(24.0),
              child: ListView(
                shrinkWrap: true,
                children: [
                  Text(
                    'Login',
                    style: TextStyle(
                      fontSize: 24.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 24.0),
                  TextFormField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      prefixIcon: Icon(Icons.email),
                      errorText: _validateEmail(_emailController.text),
                    ),
                    validator: _validateEmail,
                    onChanged: (value) {
                      setState(() {
                        //_emailErrorText = _validateEmail(value);
                      });
                    },
                  ),
                  SizedBox(height: 16.0),
                  TextFormField(
                    controller: _passwordController,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      prefixIcon: Icon(Icons.lock),
                      errorText: _validatePassword(_passwordController.text),
                      suffixIcon: GestureDetector(
                        onTap: _togglePasswordVisibility,
                        child: Icon(
                          _obscurePassword
                              ? Icons.visibility_off
                              : Icons.visibility,
                        ),
                      ),
                    ),
                    obscureText: _obscurePassword,
                    validator: _validatePassword,
                    onChanged: (value) {
                      setState(() {
                        //_passwordErrorText = _validatePassword(value);
                      });
                    },
                  ),
                  SizedBox(height: 24.0),
                  GestureDetector(
                    onTap: () {
                      if (_validateEmail(_emailController.text) == null &&
                          _validatePassword(_passwordController.text) == null) {
                        _authenticateUser();
                      }
                    },
                    child: Container(
                      width: 140,
                      height: 40,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(25),
                        gradient: LinearGradient(
                          colors: [
                            Color(0xFF36D1DC),
                            Color(0xFF5B86E5),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomCenter,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Color.fromARGB(255, 74, 145, 183)
                                .withOpacity(0.5),
                            offset: Offset(0, 4),
                            blurRadius: 5,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: Center(
                        child: isLoading
                            ? SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.0,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white),
                                ),
                              )
                            : Text(
                                'Login',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 17,
                                  letterSpacing: 3.0,
                                ),
                              ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  GestureDetector(
                    onTap: _navigateToRegistration,
                    child: Container(
                      width: 140,
                      height: 40,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(25),
                        gradient: const LinearGradient(
                          colors: [
                            Color.fromARGB(255, 54, 220, 101),
                            Color.fromARGB(255, 91, 229, 217),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color.fromARGB(255, 74, 145, 183)
                                .withOpacity(0.5),
                            spreadRadius: 2,
                            blurRadius: 5,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          'Create Account',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  TextButton(
                    onPressed: _navigateToForgotPassword,
                    child: Text(
                      'Forgotten Password?',
                      style: TextStyle(
                        color: Colors.blue,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
