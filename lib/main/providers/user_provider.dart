import 'package:flutter/material.dart';

class UserProvider with ChangeNotifier {
  String? username;
  bool isSuperuser = false;

  void setUser(String? username, bool isSuperuser) {
    this.username = username;
    this.isSuperuser = isSuperuser;
    notifyListeners();
  }

  void logout() {
    username = null;
    isSuperuser = false;
    notifyListeners();
  }

  
}
