import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class Rx<T> extends ValueNotifier<T> {
  Rx(super.value);
}

extension SingleValueNotifierExt<T> on T {
  Rx<T> get obs {
    return Rx(this);
  }
}

class MultiValuesListenableBuilder extends StatelessWidget {
  const MultiValuesListenableBuilder({
    Key? key,
    required this.builder,
    required this.valueListenables,
  }) : super(key: key);

  final Widget Function(BuildContext, Null, Widget?) builder;
  final List<ValueListenable> valueListenables;

  @override
  Widget build(BuildContext context) {
    return _buildRecursive(0, context, null);
  }

  Widget _buildRecursive(int index, BuildContext context, Widget? child) {
    if (index == valueListenables.length) {
      return builder(context, null, child);
    }

    return ValueListenableBuilder<dynamic>(
      valueListenable: valueListenables[index],
      builder: (context, value, child) {
        return _buildRecursive(index + 1, context, child);
      },
    );
  }
}



class Debouncer {
  final int milliseconds;
  VoidCallback? action;
  Timer? _timer;

  Debouncer({required this.milliseconds});

  void debounce(VoidCallback action) {
    this.action = action;
    _timer?.cancel();
    _timer = Timer(Duration(milliseconds: milliseconds), _fire);
  }

  void _fire() {
    if (action != null) {
      action!();
      action = null;
    }
  }
}
