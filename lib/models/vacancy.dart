import 'package:swallow_app/models/contract.dart';
import 'package:swallow_app/models/frequency.dart';
import 'package:swallow_app/models/journey.dart';
import 'package:swallow_app/models/keyword.dart';
import 'package:swallow_app/models/location.dart';
import 'package:swallow_app/models/modality.dart';
import 'package:swallow_app/models/requirement.dart';
import 'package:swallow_app/models/salary_range.dart';
import 'package:swallow_app/models/user_role_company_id.dart';

class Vacancy {
  final int id;
  final Location idUbicacion;
  final String tituloVacante;
  final String descripcionCorta;
  final DateTime fechaInicioVacante;
  final DateTime fechaFinVacante;
  final int estadoVacante;
  final List<Keyword> palabrasClaveIds;
  final List<Requirement> requisitoIds;
  final SalaryRange idRangoSalarial;
  final Journey idJornada;
  final Modality idModalidad;
  final Contract idContrato;
  final Frequency idPeriodicidad;
  final UserRoleCompanyId relUsuarioEmpresaId;

  Vacancy({
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

  /*factory Vacancy.fromJson(Map<String, dynamic> json){
    return Vacancy(
      id: json['id'] ?? 0,
      idUbicacion: json['idUbicacion'] ?? 0,
      tituloVacante: json['tituloVacante'] ?? '',
      descripcionCorta: json['descripcionCorta'] ?? '',
      fechaInicioVacante: DateTime.parse(json['fechaInicioVacante']),
      fechaFinVacante: DateTime.parse(json['fechaFinVacante']),
      estadoVacante: json['estadoVacante'] ?? 0,
      palabrasClaveIds: (jsonDecode(json['palabrasClaveIds']) as List<dynamic>).map((arg) => arg as int).toList(),
      requisitoIds: (jsonDecode(json['requisitoIds']) as List<dynamic>).map((arg) => arg as int).toList(),
      idRangoSalarial: json['idRangosalarial'] ?? 0,
      idJornada: json['idJornada'] ?? 0,
      idModalidad: json['idModalidad'] ?? 0,
      idContrato: json['idContrato'] ?? 0,
      idPeriodicidad: json['idPeriodicidad'] ?? 0,
      relUsuarioEmpresaId: UserRoleCompanyId.fromJson(json['relUsuarioEmpresaId']),
    );
  }*/
}