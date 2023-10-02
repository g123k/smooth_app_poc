extension DoubleExtension on double {
  double progress(num min, num max) {
    return (this - min) / (max - min);
  }

  double progressAndClamp(num min, double max, double clamp) {
    return progress(min, max).clamp(0.0, clamp);
  }

  double progress2(num min, num max) {
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
