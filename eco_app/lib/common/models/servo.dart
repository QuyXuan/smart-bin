class Servo {
  final String name;
  final int state;

  Servo({
    required this.name,
    required this.state,
  });

  factory Servo.fromMap(String name, dynamic value) {
    return Servo(name: name, state: value ?? 0);
  }
}
