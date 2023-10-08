import 'package:flutter/material.dart';

class Rx<T> extends ValueNotifier<T> {
  Rx(super.value);

}

extension SingleValueNotifierExt<T> on T {
   Rx<T> get obs {
    return Rx(this);
  }
}


