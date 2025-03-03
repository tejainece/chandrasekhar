import 'dart:math';

abstract class RandomAccessRng {
  double nextAt(int index);
}

class RandomerImpl implements RandomAccessRng {
  const RandomerImpl();

  @override
  double nextAt(int index) => Random(index).nextDouble();
}