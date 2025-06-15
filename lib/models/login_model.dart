class LoginResponse {
  final String token;
  final int role;
  final int branchId;
  final String error;

  LoginResponse({
    required this.token,
    required this.role,
    required this.branchId,
    this.error = '',
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      token: json['token'],
      role: json['user']['role'], // Extraer el rol desde el objeto user
      branchId: json['user']['branchId'], // Extraer el branchId desde el objeto user
      error: '',
    );
  }
}