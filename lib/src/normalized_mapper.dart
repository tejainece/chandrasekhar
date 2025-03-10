import 'dart:math';

typedef NormalizedMapper = double Function(double x);

double oneNormalizedMapper(double x) => 1;

double identityNormalizedMapper(double x) => x;

double easeInNormalizedMapper(double x) => 1 - cos((x * pi) / 2);

NormalizedMapper glimmerAbs(int count, {double min = 0, double max = 1}) {
  return (double x) =>
      min +
      (max - min) *
          cos(
            x * 2 * pi * count / 2 +
                1 * cos(0.5 * x * 2 * pi * count / 2).abs(),
          ).abs();
}

NormalizedMapper glimmer(int count, {double min = -1, double max = 1}) {
  /*return (double x) =>
      0.5 + 0.5 * cos(x * 2 * pi * count + 1 * cos(0.5 * x * 2 * pi * count));*/
  double midpoint = (min + max) / 2;
  double amplitude = (max - min) / 2;
  return (double x) =>
      midpoint +
      amplitude *
          cos(
            x * 2 * pi * count / 2 +
                1 * cos(0.5 * x * 2 * pi * count / 2).abs(),
          );
}
