import 'package:chandrasekhar/chandrasekhar.dart';
import 'package:ramanujan/ramanujan.dart';

export 'deterministic_curve.dart';

class DeterministicEmitter {
  final EmitterSurface surface;

  // TODO make interval a curve to simulate explosion
  final Duration interval;
  final DeterministicParticleCurve curve;
  final RandomInt particlesPerInterval;

  final RandomScaledDuration lifetime;

  final RandomPoint initialVelocity;

  final bool useEmittedAngle;
  final RandomDouble angle;
  final RandomPoint angleVelocity;

  final RandomPoint size;

  // TODO turbulence

  // TODO multiple particles per interval?
  final RandomAccessRng _random;

  final _seeds = SeedBucket();

  DeterministicEmitter({
    RandomAccessRng random = const RandomAccessRng(),
    this.surface = const PointEmitterSurface.origin(),
    this.interval = const Duration(seconds: 1),
    this.particlesPerInterval = const RandomInt(1),
    this.curve = const SimpleDeterministicParticleCurve(),
    this.lifetime = const RandomScaledDuration(Duration(seconds: 3)),
    this.initialVelocity = RandomPoint.zero,
    this.angleVelocity = RandomPoint.zero,
    this.size = const RandomPoint(P(5, 5)),
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
      final intervalNumber = from.inMicroseconds ~/ interval.inMicroseconds;
      final count = particlesPerInterval.at(
        _random.doubleAt(
          intervalNumber,
          seed: _seeds.getSeed('particlesPerInterval'),
        ),
      );
      if (count <= 0) continue;
      for (int particleNum = 0; particleNum < count; particleNum++) {
        final id = intervalNumber * particlesPerInterval.max + particleNum;
        Duration myLifetime = lifetime.at(
          _random.doubleAt(id, seed: _seeds.getSeed('lifetime')),
        );
        final t = (at - from).inMilliseconds / myLifetime.inMilliseconds;
        if (t > 1) {
          continue;
        }
        final initialPosition = surface.lerp(
          _random.doubleAt(id, seed: _seeds.getSeed('initialPosition')),
        );
        var angle = Radian(0);
        if (useEmittedAngle) {
          final emittedAngle = surface.normalAtPoint(initialPosition);
          angle += emittedAngle;
        }
        final angleRandom = _random.doubleAt(id, seed: _seeds.getSeed('angle'));
        angle += this.angle.at(angleRandom);
        P initialVelocity = this.initialVelocity.at(
          _random.doubleAt(id, seed: _seeds.getSeed('initialVelocity')),
        );
        P angleVelocity = this.angleVelocity.at(
          _random.doubleAt(id, seed: _seeds.getSeed('angleVelocity')),
        );
        final position = curve.positionAtT(
          myLifetime * t,
          t,
          initialPosition: initialPosition,
          initialVelocity: initialVelocity,
          angleVelocity: angleVelocity,
          angle: angle.value, // angle.value,
        );
        final previousPos = curve.positionAtT(
          myLifetime * t - Duration(microseconds: 50),
          t,
          initialPosition: initialPosition,
          initialVelocity: initialVelocity,
          angleVelocity: angleVelocity,
          angle: angle.value, // angle.value,
        );
        final curveAngle = LineSegment(previousPos, position).angle;
        yield Particle(
          id: id,
          position: position,
          angle: curveAngle.value,
          lifePercentage: t,
          size: size.at(_random.doubleAt(id, seed: _seeds.getSeed('size'))),
        );
      }
    }
  }
}
