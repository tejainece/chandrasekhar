import 'package:chandrasekhar/chandrasekhar.dart';
import 'package:ramanujan/ramanujan.dart';

export 'deterministic_curve.dart';

class DeterministicEmitter {
  final EmitterSurface surface;

  final Duration emissionInterval;
  final DeterministicParticleCurve curve;
  final RandomInt particlesPerInterval;

  /// Controls the speed of the particle while keeping the trajectory the same
  final RandomDouble speed;
  final RandomDouble speedMultiplier;

  final RandomScaledDuration lifetime;

  final bool useEmittedAngle;
  final RandomDouble angle;

  final RandomPoint size;

  // TODO turbulence

  // TODO multiple particles per interval?
  final RandomAccessRng _random;

  final _seeds = SeedBucket();

  // TODO explosiveness with multi-particle

  DeterministicEmitter({
    RandomAccessRng random = const RandomAccessRng(),
    this.surface = const PointEmitterSurface.origin(),
    this.emissionInterval = const Duration(seconds: 1),
    this.particlesPerInterval = const RandomInt(1),
    this.curve = const SimpleDeterministicParticleCurve(),
    this.lifetime = const RandomScaledDuration(Duration(seconds: 3)),
    this.speed = const RandomDouble(400),
    this.speedMultiplier = const RandomDouble(1),
    this.size = const RandomPoint(P(5, 5)),
    this.useEmittedAngle = true,
    this.angle = RandomDouble.zero,
  }) : _random = random;

  Iterable<Particle> at(Duration at) sync* {
    Duration from = at - lifetime.value;
    from = Duration(
      microseconds:
          (from.inMicroseconds / emissionInterval.inMicroseconds).ceil() *
          emissionInterval.inMicroseconds,
    );
    for (; from <= at; from += emissionInterval) {
      if (from.isNegative) continue;
      final intervalNumber =
          from.inMicroseconds ~/ emissionInterval.inMicroseconds;
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
        final position = curve.positionAtT(
          myLifetime * t,
          t,
          initialPosition: initialPosition,
          speed: speed.at(_random.doubleAt(id, seed: _seeds.getSeed('speed'))),
          speedMultiplier: speedMultiplier.at(
            _random.doubleAt(id, seed: _seeds.getSeed('speedMultiplier')),
          ),
          angle: angle.value,
        );
        final previousPos = curve.positionAtT(
          myLifetime * t - Duration(microseconds: 50),
          t,
          initialPosition: initialPosition,
          speed: speed.at(_random.doubleAt(id, seed: _seeds.getSeed('speed'))),
          speedMultiplier: speedMultiplier.at(
            _random.doubleAt(id, seed: _seeds.getSeed('speedMultiplier')),
          ),
          angle: angle.value,
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
