import 'package:civils_gpt/pages/HomePage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:email_validator/email_validator.dart'; // Add email validator package

import '../constants/AppConstants.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _formKey = GlobalKey<FormState>(); // Form key for validation
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  var loading = false;

  void signUpWithEmailID(
      String name,
      String email,
      String password,
      BuildContext context,
      ) async
  {
    setState(() {
      loading = true;
    });
    try {
      BuildContext tempContext = context;

      showDialog(
        context: tempContext,
        builder: (tempContext) {
         Future.delayed(Duration(seconds: 5), (){
           Navigator.of(tempContext).pop();
         });
          return const AlertDialog(
              content: Text('Hang On while we signup you up!!')
          );
        },
      );
      await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);
      User? user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        await user.updateDisplayName(name);
        await user.reload();
        showDialog(
          context: context,
          builder: (_context) {
            return AlertDialog(
              content: const Text('User created Successfully'),
              actions: <Widget>[
                TextButton(
                  child: const Text('OK'),
                  onPressed: () {
                    Navigator.of(_context).pop();

                    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomePage()));
                  },
                ),
              ],
            );

          },
        );
      } else {

        Navigator.of(tempContext).pop();
      }
      setState(() {
        loading = false;
      });
    } catch (e) {
      // Show error message in dialog
      print(e);
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Sign Up Failed'),
            content: Text(e.toString()), // Display Firebase error message
            actions: <Widget>[
              TextButton(
                child: const Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
      setState(() {
        loading = false;
      });
    }
  }


  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    emailController.dispose();
    passwordController.dispose();
    nameController.dispose();
    super.dispose();
  }

  // Validation method for sign-up form
  void _signUp(BuildContext context) {
    if (_formKey.currentState!.validate()) {
      signUpWithEmailID(
        nameController.text,
        emailController.text,
        passwordController.text,
        context,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(64),
        child: AppBar(
          backgroundColor: Colors.transparent,
          leading: GestureDetector(
              onTap: () {
                Navigator.of(context).pop();
              },
              child: const Icon(FontAwesomeIcons.arrowLeft, size: 24)),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Form(
            key: _formKey, // Assign form key
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Sign Up',
                  style: TextStyle(
                    fontSize: 35,
                    fontWeight: FontWeight.w700,
                    color: AppConstants.secondaryColour,
                  ),
                ),
                const SizedBox(height: 20),
                // Name Text Field
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(40),
                    border: Border.all(color: Colors.black, width: 2),
                  ),
                  margin: const EdgeInsets.symmetric(horizontal: 10),
                  child: TextFormField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      icon: Icon(Icons.person),
                      hintText: 'Name',
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your name';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(height: 20),
                // Email Text Field
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(40),
                    border: Border.all(color: Colors.black, width: 2),
                  ),
                  margin: const EdgeInsets.symmetric(horizontal: 10),
                  child: TextFormField(
                    controller: emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      icon: Icon(Icons.email),
                      hintText: 'Email',
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your email';
                      } else if (!EmailValidator.validate(value)) {
                        return 'Please enter a valid email address';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(height: 20),
                // Password Text Field
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(40),
                    border: Border.all(color: Colors.black, width: 2),
                  ),
                  margin: const EdgeInsets.symmetric(horizontal: 10),
                  child: TextFormField(
                    controller: passwordController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      icon: Icon(Icons.password),
                      hintText: 'Password',
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your password';
                      } else if (value.length < 6) {
                        return 'Password must be at least 6 characters long';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(height: 50),
                // Sign Up Button
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 10),
                  child: ElevatedButton(
                    onPressed: () {
                      if(loading == false) {
                        _signUp(context);
                      }
                    },
                    // Call the validation and sign-up method
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(40),
                      ),
                    ),
                    child: loading ? const Center(child: CupertinoActivityIndicator(color: Colors.white,)) : const Text(
                      'Sign Up',
                      style: TextStyle(fontSize: 20, color: Colors.white),
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


