class User {
  final int id;
  final String name;
  final String email;
  final String password;
  final int role; // Cambiado a int

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.password,
    required this.role,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      password: json['password'].toString(), // Convertir a String si es necesario
      role: json['role'], // Cambiado a int
    );
  }
}