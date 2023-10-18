double width = 0, height = 0;

/// This extention help us to make widget responsive.
extension NumberParsing on num {
  double w() => this * width / 100;

  double h() => this * height / 100;
}
