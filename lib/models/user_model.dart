class User {
  final int id;
  final String name;
  final String email;
  final String password;
  final int role;
  final int branchId;
  final bool status;  // Agregado el campo status

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.password,
    required this.role,
    required this.branchId,
    required this.status,  // Agregado en el constructor
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      password: json['password'].toString(),
      role: json['role'],
      branchId: json['branchId'],
      status: json['status'] ?? false,  // Agregado con valor por defecto false si es null
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'password': password,
      'role': role,
      'branchId': branchId,
      'status': status,  // Agregado en la serialización
    };
  }
}