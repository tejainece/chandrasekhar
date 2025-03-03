import 'package:chandrasekhar/chandrasekhar.dart';
import 'package:ramanujan/ramanujan.dart';

void main() {
  final emitter = DeterministicEmitter(
    surface: LineEmitterSurface(P(0, 0), P(100, 0)),
  );
  for (int i = 0; i < 5; i++) {
    print(emitter.at(Duration(milliseconds: (i * 1000 / 2).toInt())));
  }
}
