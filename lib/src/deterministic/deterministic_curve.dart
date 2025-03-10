import 'dart:math';

import 'package:chandrasekhar/chandrasekhar.dart';
import 'package:ramanujan/ramanujan.dart';

abstract class DeterministicParticleCurve {
  P positionAtT(
    Duration at,
    double t, {
    P initialPosition = P.origin,
    P initialVelocity = P.zero,
    P angleVelocity = P.zero,
    double angle = 0,
  });
}

class SimpleDeterministicParticleCurve implements DeterministicParticleCurve {
  final NormalizedMapper initialVelocityXEasing;
  final NormalizedMapper initialVelocityYEasing;
  final NormalizedMapper angleVelocityXEasing;
  final NormalizedMapper angleVelocityYEasing;

  const SimpleDeterministicParticleCurve({
    this.initialVelocityXEasing = oneNormalizedMapper,
    this.initialVelocityYEasing = oneNormalizedMapper,
    this.angleVelocityXEasing = oneNormalizedMapper,
    this.angleVelocityYEasing = oneNormalizedMapper,
  });

  // TODO turbulence

  @override
  P positionAtT(
    Duration at,
    double t, {
    P initialPosition = P.origin,
    P initialVelocity = P.zero,
    P angleVelocity = P.zero,
    double angle = 0,
  }) {
    final time = at.inMicroseconds;
    P velocity = P(
      initialVelocity.x * initialVelocityXEasing(t),
      initialVelocity.y * initialVelocityYEasing(t),
    );
    velocity += P(
      cos(angle) * angleVelocity.x * angleVelocityXEasing(t),
      sin(angle) * angleVelocity.y * angleVelocityYEasing(t),
    );
    P position = initialPosition + P(velocity.x * time, velocity.y * time);
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
    P initialVelocity = P.zero,
    P angleVelocity = P.zero,
    double angle = 0,
  }) {
    final time = at.inMicroseconds;
    final t2 = time * time;
    P offset = P(
      initialVelocity.x * initialVelocityXEasing(t) * time +
          acceleration.x * t2 / 2,
      initialVelocity.y * initialVelocityYEasing(t) * time +
          acceleration.x * t2 / 2,
    );
    offset += P(
      cos(angle) * angleVelocity.x * angularVelocityXEasing(t),
      sin(angle) * angleVelocity.y * angularVelocityYEasing(t),
    );
    P position = initialPosition + offset;
    return position;
  }
}
