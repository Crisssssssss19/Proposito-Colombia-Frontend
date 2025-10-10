import 'package:swallow_app/dtos/user_role_company_id_dto.dart';

class VacancyDto {
  final int id;
  final int idUbicacion;
  final String tituloVacante;
  final String descripcionCorta;
  final String fechaInicioVacante;
  final String fechaFinVacante;
  final int estadoVacante;
  final List<int> palabrasClaveIds;
  final List<int> requisitoIds;
  final int idRangoSalarial;
  final int idJornada;
  final int idModalidad;
  final int idContrato;
  final int idPeriodicidad;
  final UserRoleCompanyIdDto relUsuarioEmpresaId;

  VacancyDto({
    required this.id,
    required this.idUbicacion,
    required this.tituloVacante,
    required this.descripcionCorta,
    required this.fechaInicioVacante,
    required this.fechaFinVacante,
    required this.estadoVacante,
    required this.palabrasClaveIds,
    required this.requisitoIds,
    required this.idRangoSalarial,
    required this.idJornada,
    required this.idModalidad,
    required this.idContrato,
    required this.idPeriodicidad,
    required this.relUsuarioEmpresaId,
  });

  factory VacancyDto.fromJson(Map<String, dynamic> json) {
    return VacancyDto(
      id: json['id'] ?? 0,
      idUbicacion: json['idUbicacion'] ?? 0,
      tituloVacante: json['tituloVacante'] ?? '',
      descripcionCorta: json['descripcionCorta'] ?? '',
      fechaInicioVacante: json['fechaInicioVacante'] ?? '',
      fechaFinVacante: json['fechaFinVacante'] ?? '',
      estadoVacante: json['estadoVacante'] ?? 0,
      palabrasClaveIds: (json['palabrasClaveIds'] as List<dynamic>? ?? []).map((e) => e as int).toList(),
      requisitoIds: (json['requisitoIds'] as List<dynamic>? ?? []).map((e) => e as int).toList(),
      idRangoSalarial: json['idRangoSalarial'] ?? 0,
      idJornada: json['idJornada'] ?? 0,
      idModalidad: json['idModalidad'] ?? 0,
      idContrato: json['idContrato'] ?? 0,
      idPeriodicidad: json['idPeriodicidad'] ?? 0,
      relUsuarioEmpresaId: UserRoleCompanyIdDto.fromJson(json['relUsuarioEmpresaId'] ?? {}),
    );
  }
}
