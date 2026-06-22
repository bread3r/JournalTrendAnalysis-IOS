class OpenAlexGroup {
  const OpenAlexGroup({
    required this.key,
    required this.name,
    required this.count,
  });

  final String key;
  final String name;
  final int count;

  int? get year => int.tryParse(key);

  factory OpenAlexGroup.fromJson(Map<String, dynamic> json) {
    return OpenAlexGroup(
      key: (json['key'] ?? '').toString(),
      name: (json['key_display_name'] ?? json['key'] ?? 'Unknown').toString(),
      count: _asInt(json['count']),
    );
  }

  static int _asInt(Object? value) {
    if (value is int) {
      return value;
    }
    if (value is num) {
      return value.toInt();
    }
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }
}
