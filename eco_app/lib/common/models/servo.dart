class Compartment {
  final String name;
  final bool isOpen;

  Compartment({
    required this.name,
    required this.isOpen,
  });

  factory Compartment.fromMap(String name, Map<String, dynamic> value) {
    final bool isOpen = value['is_open'] ?? 0;
    return Compartment(name: name, isOpen: isOpen);
  }
}
