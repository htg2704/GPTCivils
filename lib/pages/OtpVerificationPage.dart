// lib/pages/OtpVerificationPage.dart

import 'package:civils_gpt/pages/HomePage.dart';
import 'package:civils_gpt/services/helper.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class OtpVerificationPage extends StatefulWidget {
  // These parameters are passed from the SignUpPage
  final String verificationId;
  final String name;
  final String email;
  final String password;

  // The constructor now correctly defines the named parameters
  const OtpVerificationPage({
    Key? key,
    required this.verificationId,
    required this.name,
    required this.email,
    required this.password,
  }) : super(key: key);

  @override
  _OtpVerificationPageState createState() => _OtpVerificationPageState();
}

class _OtpVerificationPageState extends State<OtpVerificationPage> {
  final _otpController = TextEditingController();
  bool _isLoading = false;

  Future<void> _verifyOtpAndSignUp() async {
    if (_otpController.text.isEmpty || _otpController.text.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter a valid 6-digit OTP.")),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // 1. Create the phone credential with the OTP from the user
      final credential = PhoneAuthProvider.credential(
        verificationId: widget.verificationId,
        smsCode: _otpController.text,
      );

      // 2. Create the user account with email and password
      final userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
          email: widget.email, password: widget.password);

      // 3. Link the phone credential to the newly created account
      await userCredential.user!.linkWithCredential(credential);

      // 4. Update the user's display name
      await userCredential.user!.updateDisplayName(widget.name);
      await userCredential.user!.reload();

      // 5. Create a new session for the user to handle single-device login
      await SessionManager.createNewSession(userCredential.user!.uid);

      if (mounted) {
        // Navigate to the HomePage and clear the navigation stack
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const HomePage()),
              (Route<dynamic> route) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to sign up: ${e.toString()}")),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Verify Phone Number'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Enter the 6-digit code sent to your phone',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _otpController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'OTP Code'),
              maxLength: 6,
            ),
            const SizedBox(height: 20),
            _isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton(
              onPressed: _verifyOtpAndSignUp,
              child: const Text('Verify and Sign Up'),
            ),
          ],
        ),
      ),
    );
  }
}