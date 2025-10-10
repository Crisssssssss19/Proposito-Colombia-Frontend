class SalaryRange {
  final int id;
  final double salarioMin;
  final double salarioMax;

  SalaryRange({
    required this.id,
    required this.salarioMin,
    required this.salarioMax,
  });

  factory SalaryRange.fromJson(Map<String, dynamic> json) {
    return SalaryRange(
      id: json['id'] ?? 0,
      salarioMin: (json['salarioMin'] ?? 0).toDouble(),
      salarioMax: (json['salarioMax'] ?? 0).toDouble(),
    );
  }
}