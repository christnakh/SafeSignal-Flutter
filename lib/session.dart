import 'package:flutter/foundation.dart';

class Session with ChangeNotifier {
  String? _userId;

  String? get userId => _userId;

  bool get isLoggedIn => _userId != null;

  void setUserId(String userId) {
    _userId = userId;
    notifyListeners();
  }
}
