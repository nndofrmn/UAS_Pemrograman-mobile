import 'package:flutter/foundation.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService;

  AppUser? get user => _authService.currentUser;

  AuthProvider(this._authService);

  Future<bool> signIn(String email, String password) async {
    final u = await _authService.signIn(email, password);
    if (u != null) {
      notifyListeners();
      return true;
    }
    return false;
  }

  Future<void> register(String name, String email, String password) async {
    await _authService.register(name, email, password);
    notifyListeners();
  }

  void signOut() {
    _authService.signOut();
    notifyListeners();
  }
}
