import 'package:flutter/material.dart';

enum PremiumState { loading, isPremium, notPremium }

class PremiumProvider extends ChangeNotifier {
  PremiumState _state = PremiumState.loading;
  DateTime? _premiumExpiryDate;
  int _freeCounter = 0;
  String _planID = "-1";

  // Getters for easy access in the UI
  PremiumState get state => _state;
  bool get isPremium => _state == PremiumState.isPremium;
  DateTime? get premiumExpiryDate => _premiumExpiryDate;
  int get freeCounter => _freeCounter;
  String get planID => _planID;

  void setCounter(int count) {
    _freeCounter = count;
    notifyListeners();
  }

  void decrementCounter() {
    _freeCounter--;
    notifyListeners();
  }

  void updatePremiumStatus({
    required PremiumState newState,
    DateTime? expiryDate,
    String? newPlanID,
  }) {
    _state = newState;
    _premiumExpiryDate = expiryDate;
    _planID = newPlanID ?? "-1";
    notifyListeners();
  }
}