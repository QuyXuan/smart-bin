class Servo {
  final String name;
  final int state;

  Servo({
    required this.name,
    required this.state,
  });

  factory Servo.fromMap(String name, Map<String, dynamic> value) {
    final int state = value['state'] ?? 0;
    return Servo(name: name, state: state);
  }
}
