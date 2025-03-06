import 'dart:math';

import 'package:chandrasekhar/chandrasekhar.dart';
import 'package:ramanujan/ramanujan.dart';

abstract class RandomAccessRng {
  double nextDoubleAt(int index);

  const factory RandomAccessRng() = RandomAccessRngImpl;
}

int identityIndexMapper(int i) => i;

class RandomAccessRngImpl implements RandomAccessRng {
  final int seed;
  final int Function(int) alterer;

  const RandomAccessRngImpl({
    this.seed = 0,
    this.alterer = identityIndexMapper,
  });

  @override
  double nextDoubleAt(int index) => Random(seed + alterer(index)).nextDouble();
}

abstract class RandomRange<T> {
  T get min;

  T get max;

  RandomAccessRng get rng;

  NormalizedMapper get pdf;

  T lerp(double t);

  T randomLerp(int index) => lerp(pdf(rng.nextDoubleAt(index)));
}

class NormalizedDoubleRange extends RandomRange<double> {
  @override
  final double min;

  @override
  final double max;

  @override
  final RandomAccessRng rng;

  @override
  final NormalizedMapper pdf;

  NormalizedDoubleRange(
    this.min,
    this.max, {
    this.pdf = identityNormalizedMapper,
    this.rng = const RandomAccessRng(),
  }) {
    assert(min <= max);
    assert(min >= 0);
    assert(max <= 1);
  }

  double lerp(double t) => min + (max - min) * t;
}

class DoubleRange extends RandomRange<double> {
  @override
  final double min;

  @override
  final double max;

  @override
  final RandomAccessRng rng;

  @override
  final NormalizedMapper pdf;

  DoubleRange(
    this.min,
    this.max, {
    this.pdf = identityNormalizedMapper,
    this.rng = const RandomAccessRng(),
  }) {
    assert(min <= max);
  }

  double lerp(double t) => min + (max - min) * t;
}

class DurationRange extends RandomRange<Duration> {
  @override
  final Duration min;

  @override
  final Duration max;

  @override
  final RandomAccessRng rng;

  @override
  final NormalizedMapper pdf;

  DurationRange(
    this.min,
    this.max, {
    this.pdf = identityNormalizedMapper,
    this.rng = const RandomAccessRng(),
  }) {
    assert(min <= max);
  }

  Duration lerp(double t) => min + (max - min) * t;
}

abstract class RandomValue<T> {
  T get value;

  T at(int index);
}

class RandomDouble implements RandomValue<double> {
  @override
  final double value;

  final DoubleRange? randomize;

  const RandomDouble(this.value, {this.randomize});

  @override
  double at(int index) {
    double ret = value;
    if (randomize != null) {
      ret += randomize!.randomLerp(index);
    }
    return ret;
  }

  static const zero = RandomDouble(0);
}

class RandomScaledDuration implements RandomValue<Duration> {
  @override
  final Duration value;

  final NormalizedDoubleRange? randomize;

  const RandomScaledDuration(this.value, {this.randomize});

  @override
  Duration at(int index) {
    Duration ret = value;
    if (randomize != null) {
      ret *= randomize!.randomLerp(index);
    }
    return ret;
  }
}

class RandomPoint implements RandomValue<P> {
  @override
  final P value;

  final RandomRange<double>? randomizeX;
  final RandomRange<double>? randomizeY;

  const RandomPoint(this.value, {this.randomizeX, this.randomizeY});

  @override
  P at(int index) {
    P ret = value;
    if (randomizeX != null) {
      ret += P(randomizeX!.randomLerp(index), 0);
    }
    if (randomizeY != null) {
      ret += P(0, randomizeY!.randomLerp(index));
    }
    return ret;
  }

  static const zero = RandomPoint(P.zero);
}
