extension DoubleExtension on double {
  double progress(double min, double max) {
    return (this - min) / (max - min);
  }
}
