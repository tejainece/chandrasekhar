import 'dart:math';

import 'package:chandrasekhar/chandrasekhar.dart';
import 'package:ramanujan/ramanujan.dart';

abstract class DeterministicParticleCurve {
  P positionAtT(
    Duration at,
    double t, {
    P initialPosition = P.origin,
    double angle = 0,

    /// Controls the speed of the particle while keeping the trajectory the same
    required double speedMultiplier,
    required double speed,
  });
}

class SimpleDeterministicParticleCurve implements DeterministicParticleCurve {
  final NormalizedMapper initialVelocityXEasing;
  final NormalizedMapper initialVelocityYEasing;

  const SimpleDeterministicParticleCurve({
    this.initialVelocityXEasing = oneNormalizedMapper,
    this.initialVelocityYEasing = oneNormalizedMapper,
  });

  // TODO turbulence

  @override
  P positionAtT(
    Duration at,
    double t, {
    P initialPosition = P.origin,
    required double speed,
    required double speedMultiplier,
    double angle = 0,
  }) {
    final time = at.inMicroseconds / Duration.microsecondsPerSecond;
    P velocity = P(
      cos(angle) * speed * initialVelocityXEasing(t),
      sin(angle) * speed * initialVelocityYEasing(t),
    );
    P position = initialPosition + velocity * speedMultiplier * time;
    return position;
  }
}

class NewtonianDeterministicParticleCurve
    implements DeterministicParticleCurve {
  final double gravity;
  final P wind;
  final List<P> _forces;
  final NormalizedMapper initialVelocityXEasing;
  final NormalizedMapper initialVelocityYEasing;
  final NormalizedMapper angularVelocityXEasing;
  final NormalizedMapper angularVelocityYEasing;

  NewtonianDeterministicParticleCurve({
    this.gravity = 0,
    this.wind = const P(0, 0),
    List<P> forces = const [],
    this.initialVelocityXEasing = oneNormalizedMapper,
    this.initialVelocityYEasing = oneNormalizedMapper,
    this.angularVelocityXEasing = oneNormalizedMapper,
    this.angularVelocityYEasing = oneNormalizedMapper,
  }) : _forces = forces.toList();

  late final P acceleration = () {
    P ret = P(0, gravity) + wind;
    for (final force in _forces) {
      ret += force;
    }
    return ret;
  }();

  // TODO turbulence

  @override
  P positionAtT(
    Duration at,
    double t, {
    P initialPosition = P.origin,
    required double speed,
    required double speedMultiplier,
    double angle = 0,
  }) {
    final double time = at.inMicroseconds / Duration.microsecondsPerSecond;
    final double time2 = time * time;
    final speed2 = speedMultiplier * speedMultiplier;
    P offset = P(
      cos(angle) * speed * initialVelocityXEasing(t) * speedMultiplier * time +
          acceleration.x * speed2 * time2 / 2,
      sin(angle) * speed * initialVelocityYEasing(t) * speedMultiplier * time +
          acceleration.y * speed2 * time2 / 2,
    );
    P position = initialPosition + offset;
    return position;
  }
}
