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
  final phoneController = TextEditingController();
  final otpController = TextEditingController();
  bool firstTimeLogin = true;
  late SharedPreferences sharedPreferences;

  void popDialog() {
    Navigator.of(context).pop(); // Function to pop the dialog programmatically
  }

  @override
  void initState() {
    SharedPreferences.getInstance().then((value) {
      setState(() {
        sharedPreferences = value;
        firstTimeLogin = (value.getBool("firstTime") ?? true);
        if (firstTimeLogin == true) {
          value.setBool("firstTime", false);
        }
      });
    });
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(64),
        child: AppBar(
          backgroundColor: Colors.transparent,
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              alignment: Alignment.topLeft,
              child: Text(
                'Lets Sign you in!',
                style: TextStyle(
                    fontSize: 35,
                    fontWeight: FontWeight.w700,
                    color: AppConstants.secondaryColour),
              ),
            ),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              alignment: Alignment.topLeft,
              child: Text(
                !firstTimeLogin
                    ? 'Welcome back,\nYou have been missed!'
                    : 'Your path to civil service\n success begins now!',
                style: TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade700),
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.only(left: 20, right: 20, top: 50),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(40),
                  border: Border.all(color: Colors.black, width: 2),
                ),
                margin: const EdgeInsets.symmetric(horizontal: 10),
                alignment: Alignment.topLeft,
                child: TextField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    icon: Icon(
                      Icons.email,
                    ),
                    alignLabelWithHint: true,
                    hintText: 'Email',
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(40),
                  border: Border.all(color: Colors.black, width: 2),
                ),
                margin: const EdgeInsets.symmetric(horizontal: 10),
                alignment: Alignment.topLeft,
                child: TextField(
                  controller: passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    icon: Icon(
                      Icons.password,
                    ),
                    alignLabelWithHint: true,
                    hintText: 'Password',
                  ),
                ),
              ),
            ),
            const SizedBox(height: 25),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
              child: ElevatedButton(
                  onPressed: () {
                    signInWithEmail(
                        emailController.text, passwordController.text, context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(40),
                    ),
                  ),
                  child: const Text('Sign In',
                      style: TextStyle(fontSize: 20, color: Colors.white))),
            ),
            const SizedBox(
              height: 10,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Don\'t have an account? '),
                GestureDetector(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const SignUpPage(),
                          ));
                    },
                    child: const Text(
                      'Sign Up',
                      style: TextStyle(
                          color: Colors.blue, fontWeight: FontWeight.w600),
                    )),
              ],
            ),
            const SizedBox(height: 20),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 35),
              child: Divider(
                color: Colors.grey.shade600,
                height: 2,
              ),
            ),
            const SizedBox(height: 10),

          ],
        ),
      ),
    );
  }
}

void signInWithGoogle(BuildContext context) async {
  GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
  GoogleSignInAuthentication? googleAuth = await googleUser?.authentication;
  try {
    AuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleAuth?.accessToken,
      idToken: googleAuth?.idToken,
    );

    showCupertinoDialog(
      context: context,
      builder: (context) {
        return const CupertinoAlertDialog(
          title: Text('Signing in'),
          content: CupertinoActivityIndicator(),
        );
      },
    );
    await FirebaseAuth.instance
        .signInWithCredential(credential)
        .whenComplete(() {
      Navigator.pop(context);
    });
  } catch (e) {
    print(e);
  }
}

void signInWithEmail(String email, String password, BuildContext context) async {
  BuildContext _context = context;
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text('Signing In .....'), duration: Duration(seconds: 1),),
  );
  try {
    // Attempt sign-in
    await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    if (Navigator.canPop(_context)) Navigator.pop(_context);
    Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const HomePage()));
  } on FirebaseAuthException catch (e) {
    print(e);
    if (Navigator.canPop(_context)) Navigator.pop(_context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Invalid Email or Password')),
    );

  } catch (e) {
    print(e);
    // Dismiss the dialog and show error message for other errors
    if (Navigator.canPop(_context)) Navigator.pop(_context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(e.toString())),
    );
    print(e);
  }
}

