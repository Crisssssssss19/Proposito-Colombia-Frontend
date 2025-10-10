import 'package:swallow_app/models/location.dart';

class User {
  final int idUsuario;
  final String nombresUsuario;
  final String apellidosUsuario;
  final int estadoUsuario;
  final String documentoUsuario;
  final Location? ubicacionResponseDto;

  User({
    required this.idUsuario,
    required this.nombresUsuario,
    required this.apellidosUsuario,
    required this.estadoUsuario,
    required this.documentoUsuario,
    required this.ubicacionResponseDto,
  });

  /*factory User.fromJson(Map<String, dynamic> json){
    return User(
      id: json['id'] ?? 0,
      nombre: json['nombreUsuario'] ?? '',
    );
  }*/
}