import 'package:civils_gpt/constants/AppConstants.dart';
import 'package:civils_gpt/main.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/ConstantsProvider.dart';
import '../providers/PremiumProvider.dart';
import '../services/helper.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final premiumProvider = PremiumProvider();
  final constantsProvider = ConstantsProvider();

  @override
  void initState() {
    LoadConstants().loadConstantsFromFirebase(constantsProvider);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    new Future.delayed(const Duration(seconds: 1), () {
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => MultiProvider(providers: [
                    ChangeNotifierProvider<PremiumProvider>(
                        create: (context) => premiumProvider),
                    ChangeNotifierProvider<ConstantsProvider>(
                        create: (context) => constantsProvider)
                  ], child: const MyApp())));
    });
    return Scaffold(
      backgroundColor: AppConstants.primaryColour,
      body: const Padding(
        padding: EdgeInsets.all(30.0),
        child: Center(
          child: ClipOval(
              child: Image(
                  image: AssetImage("assets/images/icon.png"),
                  fit: BoxFit.cover)),
        ),
      ),
    );
  }
}
