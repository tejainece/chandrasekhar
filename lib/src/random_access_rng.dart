import 'dart:math';

import 'package:chandrasekhar/chandrasekhar.dart';
import 'package:ramanujan/ramanujan.dart';

class SeedBucket {
  final _seeds = <dynamic, int>{};

  final _random = Random.secure();

  void clear() => _seeds.clear();

  void set(instance, [int? value]) {
    _seeds[instance] = value ?? _random.nextInt(1 << 32);
  }

  int getSeed(instance, {Random? random}) {
    int? seed = _seeds[instance];
    if (seed == null) {
      seed = (random ?? _random).nextInt(1 << 32);
      _seeds[instance] = seed;
    }
    return seed;
  }
}

abstract class RandomAccessRng {
  double doubleAt(int index, {int? seed});

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
  double doubleAt(int index, {int? seed}) {
    return Random((seed ?? this.seed) + alterer(index)).nextDouble();
  }
}

abstract class RandomRange<T> {
  T get min;

  T get max;

  NormalizedMapper get pdf;

  T lerp(double t);

  // RandomAccessRng get rng;

  // T randomLerp(int index, Random) => lerp(pdf(rng.nextDoubleAt(index)));
}

class NormalizedDoubleRange extends RandomRange<double> {
  @override
  final double min;

  @override
  final double max;

  @override
  final NormalizedMapper pdf;

  NormalizedDoubleRange(
    this.min,
    this.max, {
    this.pdf = identityNormalizedMapper,
  }) {
    assert(min <= max);
    assert(min >= 0);
    assert(max <= 1);
  }

  @override
  double lerp(double t) => min + (max - min) * pdf(t);
}

class DoubleRange extends RandomRange<double> {
  @override
  final double min;

  @override
  final double max;

  @override
  final NormalizedMapper pdf;

  DoubleRange(this.min, this.max, {this.pdf = identityNormalizedMapper}) {
    assert(min <= max);
  }

  @override
  double lerp(double t) => min + (max - min) * pdf(t);
}

class IntRange extends RandomRange<int> {
  @override
  final int min;

  @override
  final int max;

  @override
  final NormalizedMapper pdf;

  IntRange(this.min, this.max, {this.pdf = identityNormalizedMapper}) {
    assert(min <= max);
  }

  @override
  int lerp(double t) => (min + (max - min) * pdf(t)).round();
}

class DurationRange extends RandomRange<Duration> {
  @override
  final Duration min;

  @override
  final Duration max;

  @override
  final NormalizedMapper pdf;

  DurationRange(this.min, this.max, {this.pdf = identityNormalizedMapper}) {
    assert(min <= max);
  }

  @override
  Duration lerp(double t) => min + (max - min) * pdf(t);
}

abstract class RandomValue<T> {
  T get value;

  T at(double random);
}

class RandomDouble implements RandomValue<double> {
  @override
  final double value;

  final DoubleRange? randomize;

  const RandomDouble(this.value, {this.randomize});

  @override
  double at(double random) {
    double ret = value;
    if (randomize != null) {
      ret += randomize!.lerp(random);
    }
    return ret;
  }

  static const zero = RandomDouble(0);
}

class RandomInt implements RandomValue<int> {
  @override
  final int value;

  final IntRange? randomize;

  const RandomInt(this.value, {this.randomize});

  int get max {
    if(randomize == null) return value;
    return value + randomize!.max;
  }

  @override
  int at(double random) {
    int ret = value;
    if (randomize != null) {
      ret += randomize!.lerp(random);
    }
    return ret;
  }
}

class RandomScaledDuration implements RandomValue<Duration> {
  @override
  final Duration value;

  final NormalizedDoubleRange? randomize;

  const RandomScaledDuration(this.value, {this.randomize});

  @override
  Duration at(double random) {
    Duration ret = value;
    if (randomize != null) {
      ret *= randomize!.lerp(random);
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
  P at(double random) {
    P ret = value;
    if (randomizeX != null) {
      ret += P(randomizeX!.lerp(random), 0);
    }
    if (randomizeY != null) {
      ret += P(0, randomizeY!.lerp(random));
    }
    return ret;
  }

  static const zero = RandomPoint(P.zero);
}
