import 'package:swallow_app/models/user.dart';
import 'package:swallow_app/models/vacancy.dart';

class Keyword {
  final int id;
  final String textoPalabraClave;
  final List<User> usuarios;
  final List<Vacancy> vacantes;

  Keyword({
    required this.id,
    required this.textoPalabraClave,
    required this.usuarios,
    required this.vacantes,
  });

  /*factory Keyword.fromJson(Map<String, dynamic> json){
    return Keyword(
      id: json['id'] ?? 0,
      textoPalabraClave: json['textoPalabraClave'] ?? '',
      usuarioIds: (jsonDecode(json['usuarioIds']) as List<dynamic>).map((arg) => arg as int)
          .toList(),
      vacanteIds: (jsonDecode(json['vacanteIds']) as List<dynamic>).map((arg) => arg as int)
          .toList(),
    );
  }*/
}