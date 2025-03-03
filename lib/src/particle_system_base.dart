import 'package:chandrasekhar/src/emitter_surface.dart';
import 'package:chandrasekhar/src/normalized_mapper.dart';
import 'package:chandrasekhar/src/random_access_rng.dart';
import 'package:ramanujan/ramanujan.dart';

class Particle {
  final int id;

  final int coId;

  final P position;

  final double angle;

  final double lifePercentage;

  // TODO trail

  Particle({
    required this.id,
    required this.coId,
    required this.position,
    required this.angle,
    required this.lifePercentage,
  });

  @override
  String toString() => '{$id,$position,$angle}';
}

extension DurationExt on Duration {
  Duration operator %(Duration other) =>
      Duration(microseconds: inMicroseconds % other.inMicroseconds);
}
