import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ScreenHeight extends ChangeNotifier {
  ScreenHeight({this.initialHeight = 0, this.smallSize = 500});

  /// the height of opened keyboard
  double keyboardHeight = 0;

  /// initial screen height
  double initialHeight;

  /// set the small size, default is 500
  double smallSize;

  /// getter for small screens
  bool get isSmall => (initialHeight - keyboardHeight) < smallSize;

  /// getter for keyboard status
  bool get isOpen => keyboardHeight > 1;

  /// getter for full screen height
  double get screenHeight => initialHeight;

  void change(double a) {
    keyboardHeight = a;
    notifyListeners();
  }
}

class KeyboardSizeProvider extends StatelessWidget {
  final Widget child;

  /// set the size of small screens
  final double smallSize;

  KeyboardSizeProvider({this.child = const SizedBox(), this.smallSize = 500});

  @override
  Widget build(BuildContext context) {
    ScreenHeight _screenHeight = ScreenHeight(
      initialHeight: MediaQuery.of(context).size.height,
      smallSize: smallSize,
    );
    _screenHeight.change(MediaQuery.of(context).viewInsets.bottom);
    return ChangeNotifierProvider.value(value: _screenHeight, child: child);
  }
}
