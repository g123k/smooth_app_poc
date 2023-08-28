extension DoubleExtension on double {
  double progress(double min, double max) {
    return (this - min) / (max - min);
  }

  double progress2(double min, double max) {
    return this * (max - min) + min;
  }
}
