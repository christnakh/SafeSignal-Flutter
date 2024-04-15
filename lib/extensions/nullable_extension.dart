extension NullableString on String? {
  String get orEmpty => this ?? '';
  String orElse(String defaultValue) => this ?? defaultValue;
}

extension NullableInt on int? {
  int get orZero => this ?? 0;
  int orElse(int defaultValue) => this ?? defaultValue;
  String get str => this?.toString() ?? '';
}
