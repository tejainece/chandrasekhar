import 'dart:math';

typedef NormalizedMapper = double Function(double x);

double oneNormalizedMapper(double x) => 1;

double identityNormalizedMapper(double x) => x;

double easeInNormalizedMapper(double x) => 1 - cos((x * pi) / 2);
