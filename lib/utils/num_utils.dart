extension DoubleExtension on double {
  double progress(double min, double max) {
    return (this - min) / (max - min);
  }

  double progressAndClamp(double min, double max, double clamp) {
    return progress(min, max).clamp(0.0, clamp);
  }

  double progress2(double min, double max) {
    return this * (max - min) + min;
  }

  double positive() {
    return this < 0 ? -this : this;
  }
}

extension IntExtension on int {
  double progress(int min, int max) {
    return (this - min) / (max - min);
  }
}
