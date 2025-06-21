import 'package:flutter/material.dart';

class PremiumProvider extends ChangeNotifier {
  String premium = "false";
  int counter = 0;
  String planID = "-1";

  void setCounter(int count) {
    counter = count;
    notifyListeners();
  }

  void decrementCounter() {
    counter--;
    notifyListeners();
  }

  void changePremium(String status, String planID) {
    this.premium = status;
    this.planID = planID;
    notifyListeners();
  }
}
