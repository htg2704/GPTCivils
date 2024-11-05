import 'package:flutter/cupertino.dart';

class ConstantsProvider extends ChangeNotifier {
  Map<String, dynamic> values = Map();

  void updateConstants(Map<String, dynamic> values) {
    this.values = values;
    notifyListeners();
  }
}
