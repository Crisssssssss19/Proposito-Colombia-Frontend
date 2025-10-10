class CompanyTypeDto {
  final int id;
  final String nombreTipoEmpresa;
  final int estadoTipoEmpresa;

  CompanyTypeDto({
    required this.id,
    required this.nombreTipoEmpresa,
    required this.estadoTipoEmpresa,
  });

  factory CompanyTypeDto.fromJson(Map<String, dynamic> json) {
    return CompanyTypeDto(
      id: json['id'] ?? 0,
      nombreTipoEmpresa: json['nombreTipoEmpresa'] ?? '',
      estadoTipoEmpresa: json['estadoTipoEmpresa'] ?? 0,
    );
  }
}
