import 'package:flutter/material.dart';

class PremiumProvider extends ChangeNotifier {
  bool premium = false;
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

  void changePremium(bool status, String planID) {
    this.premium = status;
    this.planID = planID;
    notifyListeners();
  }
}
