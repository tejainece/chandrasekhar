import 'package:ramanujan/ramanujan.dart';

abstract class EmitterSurface {
  P lerp(double t);

  Radian normalAtPoint(P point);
}

class PointEmitterSurface implements EmitterSurface {
  final P point;

  const PointEmitterSurface(this.point);

  const PointEmitterSurface.origin(): point = P.origin;

  @override
  P lerp(double t) => point;

  @override
  Radian normalAtPoint(P point) => Radian(90);
}

class LineEmitterSurface implements EmitterSurface {
  final P start;
  final P end;

  const LineEmitterSurface(this.start, this.end);

  @override
  P lerp(double t) => LineSegment(start, end).lerp(t);

  @override
  Radian normalAtPoint(P point) => LineSegment(start, end).normalAngle;
}