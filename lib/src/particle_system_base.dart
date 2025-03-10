import 'package:ramanujan/ramanujan.dart';

class Particle {
  final int id;

  final P position;

  final double angle;

  final double lifePercentage;

  final P size;

  // TODO trail

  Particle({
    required this.id,
    required this.position,
    required this.angle,
    required this.lifePercentage,
    required this.size,
  });

  @override
  String toString() => '{$id,$position,$angle,$lifePercentage,$size}';
}

extension DurationExt on Duration {
  Duration operator %(Duration other) =>
      Duration(microseconds: inMicroseconds % other.inMicroseconds);
}
