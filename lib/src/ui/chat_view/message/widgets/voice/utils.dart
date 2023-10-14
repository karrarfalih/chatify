
double width = 0, height = 0;


/// This extention help us to make widget responsive.
extension NumberParsing on num {
  double w() => this * width / 100;

  double h() => this * height / 100;
}

/// document will be added
class VoiceDuration {
  /// document will be added
  static String getDuration(int duration) => duration < 60
      ? '00:' + (duration.toString())
      : (duration ~/ 60).toString() + ':' + (duration % 60).toString();
}
