import 'package:flutter/material.dart';

class SideBarProvider extends ChangeNotifier {
  int _val = 0;

  int getIndex() => _val;

  void changeIndex(int ind) {
    _val = ind;
    notifyListeners();
  }
}
