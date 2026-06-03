import 'usuario.dart';

class LoginResponse {
  const LoginResponse({required this.token, required this.usuario});

  final String token;
  final Usuario usuario;

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      token: json['token']?.toString() ?? '',
      usuario: Usuario.fromJson(json['usuario'] as Map<String, dynamic>),
    );
  }
}
