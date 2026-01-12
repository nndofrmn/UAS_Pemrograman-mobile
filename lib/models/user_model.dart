enum UserRole { user, admin }

class AppUser {
  final String id;
  final String name;
  final String email;
  final UserRole role;

  AppUser({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
  });

  factory AppUser.fromMap(Map<String, dynamic> m) => AppUser(
    id: m['id'] as String,
    name: m['name'] as String,
    email: m['email'] as String,
    role: m['role'] == 'admin' ? UserRole.admin : UserRole.user,
  );

  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'email': email,
    'role': role == UserRole.admin ? 'admin' : 'user',
  };
}
