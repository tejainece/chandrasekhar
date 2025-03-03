import 'dart:math';

import 'package:chandrasekhar/chandrasekhar.dart';
import 'package:ramanujan/ramanujan.dart';

abstract class DeterministicParticleCurve {
  // TODO get normal angle
  P positionAtT(
    P initialPosition,
    P initialVelocity,
    Duration at,
    double t,
    double angle,
  );
}

class LinearDeterministicParticleCurve implements DeterministicParticleCurve {
  final NormalizedMapper velocityX;
  final NormalizedMapper velocityY;

  LinearDeterministicParticleCurve({
    this.velocityX = oneNormalizedMapper,
    this.velocityY = oneNormalizedMapper,
  });

  @override
  P positionAtT(
    P initialPosition,
    P initialVelocity,
    Duration at,
    double t,
    double angle,
  ) {
    final time = at.inMicroseconds;
    P velocity = P(
      initialVelocity.x * velocityX(t) * cos(angle),
      initialVelocity.y * velocityY(t) * sin(angle),
    );
    P position = initialPosition + P(velocity.x * time, velocity.y * time);
    return position;
  }
}

class NewtonianDeterministicParticleCurve
    implements DeterministicParticleCurve {
  final P gravity;
  final P wind;
  final P drag;
  final List<P> _forces;

  NewtonianDeterministicParticleCurve({
    this.gravity = const P(0, 0),
    this.wind = const P(0, 0),
    this.drag = const P(0, 0),
    List<P> forces = const [],
  }) : _forces = forces.toList();

  late final P acceleration = () {
    P ret = gravity + wind + drag;
    for (final force in _forces) {
      ret += force;
    }
    return ret;
  }();

  // TODO turbulence

  @override
  P positionAtT(
    P initialPosition,
    P initialVelocity,
    Duration at,
    double t,
    double angle,
  ) {
    final time = at.inMicroseconds;
    final t2 = time * time;
    final double x =
        initialPosition.x + initialVelocity.x * time + acceleration.x * t2 / 2;
    final double y =
        initialPosition.y + initialVelocity.y * time + acceleration.x * t2 / 2;
    return P(x, y);
  }
}
