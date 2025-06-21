import 'package:civils_gpt/pages/SignUpPage.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants/AppConstants.dart';
import 'HomePage.dart';


class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool firstTimeLogin = true;
  late SharedPreferences sharedPreferences;

  @override
  void initState() {
    SharedPreferences.getInstance().then((value) {
      setState(() {
        sharedPreferences = value;
        firstTimeLogin = (value.getBool("firstTime") ?? true);
        if (firstTimeLogin) {
          value.setBool("firstTime", false);
        }
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true, // ensures content adjusts when keyboard opens
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFE0F7FA), Color(0xFFFFFFFF)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: constraints.maxHeight,
                  ),
                  child: IntrinsicHeight(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 40),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            'Let\'s Sign you in!',
                            style: TextStyle(
                              fontSize: 35,
                              fontWeight: FontWeight.w700,
                              color: AppConstants.secondaryColour,
                              fontFamily: 'Poppins',
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            !firstTimeLogin
                                ? 'Welcome back,\nYou have been missed!'
                                : 'Your path to civil service\nsuccess begins now!',
                            style: TextStyle(
                              fontSize: 25,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey.shade700,
                              fontFamily: 'Poppins',
                            ),
                          ),
                          const SizedBox(height: 40),
                          _buildTextField(emailController, 'Email', Icons.email),
                          const SizedBox(height: 20),
                          _buildTextField(passwordController, 'Password', Icons.lock,
                              obscureText: true),
                          const SizedBox(height: 30),
                          ElevatedButton(
                            onPressed: () {
                              signInWithEmail(
                                  emailController.text,
                                  passwordController.text,
                                  context);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.black,
                              padding: const EdgeInsets.symmetric(vertical: 15),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(40),
                              ),
                              elevation: 5,
                            ),
                            child: const Text(
                              'Sign In',
                              style: TextStyle(fontSize: 20, color: Colors.white),
                            ),
                          ),
                          const SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text('Don\'t have an account? '),
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                          const SignUpPage()));
                                },
                                child: const Text(
                                  'Sign Up',
                                  style: TextStyle(
                                    color: Colors.blue,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 30),
                          Divider(
                            color: Colors.grey.shade600,
                            thickness: 1,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint,
      IconData icon, {bool obscureText = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(40),
        border: Border.all(color: Colors.grey.shade300, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: hint == 'Email'
            ? TextInputType.emailAddress
            : TextInputType.text,
        decoration: InputDecoration(
          border: InputBorder.none,
          icon: Icon(icon, color: Colors.grey.shade600),
          hintText: hint,
          hintStyle: TextStyle(color: Colors.grey.shade400),
        ),
      ),
    );
  }
}

void signInWithEmail(String email, String password, BuildContext context) async {
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(
      content: Text('Signing In .....'),
      duration: Duration(seconds: 1),
    ),
  );
  try {
    await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const HomePage()));
  } on FirebaseAuthException catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Invalid Email or Password')),
    );
    print(e);
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(e.toString())),
    );
    print(e);
  }
}