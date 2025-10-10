class SalaryRangeDto {
  final int id;
  final double salarioMin;
  final double salarioMax;

  SalaryRangeDto({
    required this.id,
    required this.salarioMin,
    required this.salarioMax,
  });

  factory SalaryRangeDto.fromJson(Map<String, dynamic> json) {
    return SalaryRangeDto(
      id: json['id'] ?? 0,
      salarioMin: (json['salarioMin'] ?? 0).toDouble(),
      salarioMax: (json['salarioMax'] ?? 0).toDouble(),
    );
  }
}
