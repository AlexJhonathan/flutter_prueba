class LoginResponse {
  final String token;
  final int role;
  final String error;

  LoginResponse({
    this.token = '',
    this.role = 0,
    this.error = '',
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      token: json['token'] ?? '',
      role: json['role'] ?? 0,
      error: '',
    );
  }
}