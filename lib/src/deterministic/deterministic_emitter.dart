import 'package:chandrasekhar/chandrasekhar.dart';
import 'package:ramanujan/ramanujan.dart';

export 'deterministic_curve.dart';

class DeterministicEmitter {
  final EmitterSurface surface;
  final Duration interval;
  final DeterministicParticleCurve curve;

  final RandomScaledDuration lifetime;

  final RandomPoint initialVelocity;

  final bool useEmittedAngle;
  final RandomDouble angle;
  final RandomPoint angleVelocity;

  // TODO turbulence

  // TODO multiple particles per interval?
  final RandomAccessRng _random;

  DeterministicEmitter({
    RandomAccessRng random = const RandomAccessRng(),
    required this.surface,
    this.interval = const Duration(seconds: 1),
    this.curve = const LinearDeterministicParticleCurve(),
    this.lifetime = const RandomScaledDuration(Duration(seconds: 5)),
    this.initialVelocity = RandomPoint.zero,
    this.angleVelocity = RandomPoint.zero,
    this.useEmittedAngle = true,
    this.angle = RandomDouble.zero,
  }) : _random = random;

  Iterable<Particle> at(Duration at) sync* {
    Duration from = at - lifetime.value;
    from = Duration(
      microseconds:
          (from.inMicroseconds / interval.inMicroseconds).ceil() *
          interval.inMicroseconds,
    );
    for (; from <= at; from += interval) {
      if (from.isNegative) continue;
      final id = from.inMicroseconds ~/ interval.inMicroseconds;
      Duration myLifetime = lifetime.at(id);
      final t = (at - from).inMilliseconds / myLifetime.inMilliseconds;
      if (t > 1) {
        continue;
      }
      final initialPosition = surface.lerp(_random.nextDoubleAt(id));
      var angle = Radian(0);
      if (useEmittedAngle) {
        final emittedAngle = surface.normalAtPoint(initialPosition);
        angle += emittedAngle;
      }
      angle += this.angle.at(id);
      P initialVelocity = this.initialVelocity.at(id);
      P angleVelocity = this.angleVelocity.at(id);
      final position = curve.positionAtT(
        myLifetime * t,
        t,
        initialPosition: initialPosition,
        initialVelocity: initialVelocity,
        angleVelocity: angleVelocity,
        angle: angle.value, // angle.value,
      );
      yield Particle(
        id: id,
        // TODO
        coId: 0,
        position: position,
        // TODO this should be returned from curve
        angle: 0,
        lifePercentage: t,
      );
    }
  }
}
