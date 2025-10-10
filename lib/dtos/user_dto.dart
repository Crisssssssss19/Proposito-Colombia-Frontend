import 'package:swallow_app/dtos/location_dto.dart';

class UserDto {
  final int idUsuario;
  final String nombresUsuario;
  final String apellidosUsuario;
  final int estadoUsuario;
  final String documentoUsuario;
  final LocationDto ubicacion;

  UserDto({
    required this.idUsuario,
    required this.nombresUsuario,
    required this.apellidosUsuario,
    required this.estadoUsuario,
    required this.documentoUsuario,
    required this.ubicacion,
  });

  factory UserDto.fromJson(Map<String, dynamic> json) {
    return UserDto(
      idUsuario: json['idUsuario'] ?? 0,
      nombresUsuario: json['nombresUsuario'] ?? '',
      apellidosUsuario: json['apellidosUsuario'] ?? '',
      estadoUsuario: json['estadoUsuario'] ?? 0,
      documentoUsuario: json['documentoUsuario'] ?? '',
      ubicacion: LocationDto.fromJson(json['ubicacionResponseDTO'] ?? {}),
    );
  }
}
