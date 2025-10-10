class LocationDto {
  final int idUbicacion;
  final int? idPadreUbicacion;
  final String nombreUbicacion;
  final String idDaneUbicaicon;
  final String longitudUbicacion;
  final String latitudUbicacion;

  LocationDto({
    required this.idUbicacion,
    this.idPadreUbicacion,
    required this.nombreUbicacion,
    required this.idDaneUbicaicon,
    required this.longitudUbicacion,
    required this.latitudUbicacion,
  });

  factory LocationDto.fromJson(Map<String, dynamic> json) {
    return LocationDto(
      idUbicacion: json['idUbicacion'] ?? 0,
      idPadreUbicacion: json['idPadreUbicacion'],
      nombreUbicacion: json['nombreUbicacion'] ?? '',
      idDaneUbicaicon: json['idDaneUbicaicon'] ?? '',
      longitudUbicacion: json['longitudUbicacion'] ?? '',
      latitudUbicacion: json['latitudUbicacion'] ?? '',
    );
  }
}
