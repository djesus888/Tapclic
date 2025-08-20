// lib/models/user.dart

class User {
  final int id;
  final String name;
  final String email;
  final String role;
  final double tokenBalance;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.tokenBalance,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      role: json['role'],
      tokenBalance: (json['token_balance'] as num).toDouble(),
    );
  }
}
