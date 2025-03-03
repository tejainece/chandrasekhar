import 'package:ramanujan/ramanujan.dart';

abstract class EmitterSurface {
  P lerp(double t);

  Radian normalAtPoint(P point);
}

class LineEmitterSurface extends EmitterSurface {
  final P start;
  final P end;

  LineEmitterSurface(this.start, this.end);

  @override
  P lerp(double t) => LineSegment(start, end).lerp(t);

  @override
  Radian normalAtPoint(P point) => LineSegment(start, end).normalAngle;
}