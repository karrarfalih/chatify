import 'dart:ui';


extension DarkenColor on Color {
  Color darken(double factor) {

  final _red = (red * (1 - factor)).round();
  final _green = (green * (1 - factor)).round();
  final _blue = (blue * (1 - factor)).round();

  return Color.fromRGBO(_red, _green, _blue, 1.0);
  }
}
