// lib/pages/SignUpPage.dart

import 'package:civils_gpt/pages/HomePage.dart';
import 'package:civils_gpt/pages/LoginPage.dart';
import 'package:civils_gpt/services/helper.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:email_validator/email_validator.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../constants/AppConstants.dart';
import 'OtpVerificationPage.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final phoneController = TextEditingController();
  var loading = false;
  var googleLoading = false;

  void _signUpWithEmail(BuildContext context) async {
    if (_formKey.currentState!.validate()) {
      setState(() => loading = true);
      try {
        await FirebaseAuth.instance.verifyPhoneNumber(
          phoneNumber: phoneController.text.trim(),
          verificationCompleted: (PhoneAuthCredential credential) {},
          verificationFailed: (FirebaseAuthException e) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("Phone verification failed: ${e.message}")),
              );
            }
          },
          codeSent: (String verificationId, int? resendToken) {
            if (mounted) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => OtpVerificationPage(
                    verificationId: verificationId,
                    name: nameController.text.trim(),
                    email: emailController.text.trim(),
                    password: passwordController.text.trim(),
                  ),
                ),
              );
            }
          },
          codeAutoRetrievalTimeout: (String verificationId) {},
        );
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("An error occurred: $e")),
          );
        }
      } finally {
        if (mounted) {
          setState(() => loading = false);
        }
      }
    }
  }

  Future<void> _signUpWithGoogle(BuildContext context) async {
    setState(() => googleLoading = true);
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) {
        setState(() => googleLoading = false);
        return; // User cancelled the flow
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential =
      await FirebaseAuth.instance.signInWithCredential(credential);

      if (userCredential.user != null) {
        await SessionManager.createNewSession(userCredential.user!.uid);

        if (mounted) {
          Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (_) => const HomePage()),
                  (route) => false);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error signing up with Google: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => googleLoading = false);
      }
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    nameController.dispose();
    phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
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
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: IntrinsicHeight(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 40),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            GestureDetector(
                              onTap: () => Navigator.of(context).pop(),
                              child: const Align(
                                alignment: Alignment.centerLeft,
                                child: Icon(FontAwesomeIcons.arrowLeft, size: 24),
                              ),
                            ),
                            const SizedBox(height: 20),
                            Text(
                              'Create Account',
                              style: TextStyle(
                                fontSize: 35,
                                fontWeight: FontWeight.w700,
                                color: AppConstants.secondaryColour,
                                fontFamily: 'Poppins',
                              ),
                            ),
                            const SizedBox(height: 40),
                            _buildTextField(nameController, 'Name', Icons.person),
                            const SizedBox(height: 20),
                            _buildTextField(emailController, 'Email', Icons.email, keyboardType: TextInputType.emailAddress),
                            const SizedBox(height: 20),
                            _buildTextField(phoneController, 'Phone Number (e.g., +91...)' , Icons.phone, keyboardType: TextInputType.phone),
                            const SizedBox(height: 20),
                            _buildTextField(passwordController, 'Password', Icons.lock, obscureText: true),
                            const SizedBox(height: 30),
                            ElevatedButton(
                              onPressed: loading || googleLoading ? null : () => _signUpWithEmail(context),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.black,
                                padding: const EdgeInsets.symmetric(vertical: 15),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(40),
                                ),
                                elevation: 5,
                              ),
                              child: loading
                                  ? const CupertinoActivityIndicator(color: Colors.white)
                                  : const Text(
                                'Get OTP',
                                style: TextStyle(fontSize: 20, color: Colors.white),
                              ),
                            ),
                            const SizedBox(height: 20),
                            _buildOrDivider(),
                            const SizedBox(height: 20),
                            ElevatedButton.icon(
                              onPressed: loading || googleLoading ? null : () => _signUpWithGoogle(context),
                              icon: googleLoading
                                  ? Container(
                                width: 24,
                                height: 24,
                                padding: const EdgeInsets.all(2.0),
                                child: const CircularProgressIndicator(
                                  color: Colors.black,
                                  strokeWidth: 3,
                                ),
                              )
                                  : Image.asset('assets/images/google.png', height: 24.0),
                              label: const Text('Sign Up with Google'),
                              style: ElevatedButton.styleFrom(
                                foregroundColor: Colors.black,
                                backgroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 15),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(40),
                                  side: BorderSide(color: Colors.grey.shade300),
                                ),
                                elevation: 2,
                              ),
                            ),
                            const SizedBox(height: 30),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text('Already have an account? '),
                                GestureDetector(
                                  onTap: () {
                                    Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                            const LoginPage()));
                                  },
                                  child: const Text(
                                    'Sign In',
                                    style: TextStyle(
                                      color: Colors.blue,
                                      fontWeight: FontWeight.w600,
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
            },
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint, IconData icon,
      {bool obscureText = false, TextInputType? keyboardType}) {
    // ... (This function remains the same as before)
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
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          border: InputBorder.none,
          icon: Icon(icon, color: Colors.grey.shade600),
          hintText: hint,
          hintStyle: TextStyle(color: Colors.grey.shade400),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'This field cannot be empty';
          }
          if (hint == 'Email' && !EmailValidator.validate(value)) {
            return 'Please enter a valid email address';
          }
          if (hint == 'Password' && value.length < 6) {
            return 'Password must be at least 6 characters long';
          }
          if (hint.startsWith('Phone') && !value.startsWith('+')) {
            return 'Please include the country code (e.g., +91)';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildOrDivider() {
    return Row(
      children: [
        Expanded(child: Divider(color: Colors.grey.shade400)),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 8.0),
          child: Text('OR'),
        ),
        Expanded(child: Divider(color: Colors.grey.shade400)),
      ],
    );
  }
}