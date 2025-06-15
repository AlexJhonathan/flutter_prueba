class Branch {
  final int? id; // Hacer opcional
  final String name;
  final String address;
  final int phone;

  Branch({
    this.id, // Hacer opcional
    required this.name,
    required this.address,
    required this.phone,
  });

  factory Branch.fromJson(Map<String, dynamic> json) {
    return Branch(
      id: json['id'],
      name: json['name'],
      address: json['address'],
      phone: json['phone'] is String ? int.parse(json['phone']) : json['phone'], // Asegurarse de que sea un entero
    );
  }
}