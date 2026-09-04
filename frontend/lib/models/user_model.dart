class UserModel {
  final int id;
  final String nome;
  final String email;

  UserModel({
    required this.id,
    required this.nome,
    required this.email,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as int,
      nome: json['nome'] as String,
      email: json['email'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nome': nome,
      'email': email,
    };
  }
}

class AuthResponseModel {
  final String token;
  final DateTime expiracao;
  final UserModel usuario;

  AuthResponseModel({
    required this.token,
    required this.expiracao,
    required this.usuario,
  });

  factory AuthResponseModel.fromJson(Map<String, dynamic> json) {
    return AuthResponseModel(
      token: json['token'] as String,
      expiracao: DateTime.parse(json['expiracao'] as String),
      usuario: UserModel.fromJson(json['usuario'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'token': token,
      'expiracao': expiracao.toIso8601String(),
      'usuario': usuario.toJson(),
    };
  }
}
