class KeywordDto {
  final int id;
  final String textoPalabraClave;
  final List<int> usuarioIds;
  final List<int> vacanteIds;

  KeywordDto({
    required this.id,
    required this.textoPalabraClave,
    required this.usuarioIds,
    required this.vacanteIds,
  });

  factory KeywordDto.fromJson(Map<String, dynamic> json) {
    return KeywordDto(
      id: json['id'] ?? 0,
      textoPalabraClave: json['textoPalabraClave'] ?? '',
      usuarioIds: (json['usuarioIds'] as List<dynamic>? ?? []).map((e) => e as int).toList(),
      vacanteIds: (json['vacanteIds'] as List<dynamic>? ?? []).map((e) => e as int).toList(),
    );
  }
}
