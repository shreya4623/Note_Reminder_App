class AppUser {
  AppUser({
    required this.id,
    required this.name,
    required this.email,
    required this.passwordHash,
    required this.salt,
    required this.createdAt,
  });

  final String id;
  String name;
  final String email;
  String passwordHash;
  final String salt;
  final DateTime createdAt;

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        'passwordHash': passwordHash,
        'salt': salt,
        'createdAt': createdAt.toIso8601String(),
      };

  factory AppUser.fromJson(Map<String, dynamic> json) => AppUser(
        id: json['id'] as String,
        name: json['name'] as String,
        email: json['email'] as String,
        passwordHash: json['passwordHash'] as String,
        salt: json['salt'] as String,
        createdAt: DateTime.parse(json['createdAt'] as String),
      );
}
