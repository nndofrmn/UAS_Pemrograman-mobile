import '../models/user_model.dart';

/// Simple mock auth service for demo/UAS.
class AuthService {
  AppUser? _currentUser;

  AppUser? get currentUser => _currentUser;

  /// A very simple mock sign in. In real assignment, swap with SQLite/Firestore.
  Future<AppUser?> signIn(String email, String password) async {
    await Future.delayed(const Duration(milliseconds: 400));

    // demo accounts
    if (email == 'admin@example.com' && password == 'admin123') {
      _currentUser = AppUser(
        id: 'admin-1',
        name: 'Admin',
        email: email,
        role: UserRole.admin,
      );
      return _currentUser;
    }

    if (email == 'user@example.com' && password == 'user123') {
      _currentUser = AppUser(
        id: 'user-1',
        name: 'Regular User',
        email: email,
        role: UserRole.user,
      );
      return _currentUser;
    }

    // fallback: fail
    return null;
  }

  Future<AppUser> register(String name, String email, String password) async {
    await Future.delayed(const Duration(milliseconds: 400));
    // For demo, all new users are regular users
    _currentUser = AppUser(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      email: email,
      role: UserRole.user,
    );
    return _currentUser!;
  }

  void signOut() {
    _currentUser = null;
  }
}
