double width = 0;

/// This extention help us to make widget responsive.
extension NumberParsing on num {
  double w() => this * width / 100;
}
