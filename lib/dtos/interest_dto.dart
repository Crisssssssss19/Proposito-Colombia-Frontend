import 'package:swallow_app/dtos/interest_id_dto.dart';

class InterestDto {
  final InterestIdDto id;
  final int tipoInteres;

  InterestDto({
    required this.id,
    required this.tipoInteres,
  });

  factory InterestDto.fromJson(Map<String, dynamic> json) {
    return InterestDto(
      id: json['id'] ?? 0,
      tipoInteres: json['tipoInteres'] ?? 0,
    );
  }
}
