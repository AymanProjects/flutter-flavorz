enum EnvironmentType {
  dev(0),
  local(1),
  mock(2),
  prod(3),
  qa(4);

  const EnvironmentType(this.id);
  final int id;

  factory EnvironmentType.fromId(int id) {
    return values.firstWhere((e) => e.id == id);
  }
}
