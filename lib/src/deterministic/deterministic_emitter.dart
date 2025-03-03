import 'dart:math';

import 'package:chandrasekhar/chandrasekhar.dart';
import 'package:chandrasekhar/src/random_access_rng.dart';
import 'package:ramanujan/ramanujan.dart';

export 'deterministic_curve.dart';

class DeterministicEmitter {
  final EmitterSurface surface;
  final Duration interval;
  // TODO make this a curve
  final Duration lifetime;
  final DeterministicParticleCurve curve;
  // TODO make this a curve
  final P initialVelocity;
  // TODO spread angle
  // TODO use normal angle

  // TODO multiple particles per interval?
  final RandomAccessRng _random;

  DeterministicEmitter({
    RandomAccessRng? random,
    required this.surface,
    this.interval = const Duration(seconds: 1),
    this.lifetime = const Duration(seconds: 5),
    this.initialVelocity = const P(200/1e6, 200 / 1e6),
    DeterministicParticleCurve? curve,
  }) : _random = random ?? RandomerImpl(),
       curve = curve ?? LinearDeterministicParticleCurve();

  Iterable<Particle> at(Duration at) sync* {
    Duration from = at - lifetime;
    from = Duration(
      microseconds:
          (from.inMicroseconds / interval.inMicroseconds).ceil() *
          interval.inMicroseconds,
    );
    for (; from <= at; from += interval) {
      final id = from.inMicroseconds ~/ interval.inMicroseconds;
      if (from.isNegative) continue;
      final t = (at - from).inMilliseconds / lifetime.inMilliseconds;
      final initialPosition = surface.lerp(_random.nextAt(from.inMicroseconds));
      final angle = surface.normalAtPoint(initialPosition);
      final position = curve.positionAtT(
        initialPosition,
        initialVelocity,
        lifetime * t,
        t,
        pi/2.5,
      );
      yield Particle(
        id: id,
        // TODO
        coId: 0,
        // TODO
        position: position,
        angle: angle.value,
        lifePercentage: t,
      );
    }
  }
}
