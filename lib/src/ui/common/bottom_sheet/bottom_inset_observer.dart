// Copyright (c) 2019-present,  SurfStudio LLC
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import 'package:flutter/widgets.dart';

/// Callback events onChange
typedef BottomInsetChangeListener = Function(BottomInsetChanges change);

/// Observer of bottom view inset changes usually changed by keyboard
class BottomInsetObserver extends WidgetsBindingObserver {
  final _changeListeners = <BottomInsetChangeListener>[];
  double? _currentInset;

  BottomInsetObserver() {
    _init();
  }

  /// Callback on changing metrics
  @override
  void didChangeMetrics() {
    _listener();
  }

  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _changeListeners.clear();
  }

  /// Add bottom inset listener
  void addListener(
    BottomInsetChangeListener onChange,
  ) {
    _changeListeners.add(onChange);
    if (_currentInset! > 0) {
      onChange(
        BottomInsetChanges(
          currentInset: _currentInset!,
          delta: 0,
        ),
      );
    }
  }

  /// Delete onChange listener
  void removeListener(BottomInsetChangeListener listener) {
    _changeListeners.remove(listener);
  }

  void _init() {
    WidgetsBinding.instance.addObserver(this);
    // ignore: deprecated_member_use
    final window = WidgetsBinding.instance.window;
    _currentInset = window.viewInsets.bottom / window.devicePixelRatio;
  }

  /// Calculate changes in bottom insets
  void _listener() {
    // ignore: deprecated_member_use
    final window = WidgetsBinding.instance.window;
    final newInset = window.viewInsets.bottom / window.devicePixelRatio;
    final delta = newInset - (_currentInset ?? newInset);
    if (delta == 0) return;
    _onChange(
      BottomInsetChanges(
        currentInset: newInset,
        delta: delta,
      ),
    );
    _currentInset = newInset;
  }

  /// Call listeners on change insets
  void _onChange(BottomInsetChanges change) {
    for (final listener in _changeListeners) {
      listener(change);
    }
  }
}

/// Representation of changes in bottom view inset
/// [delta] difference in values between previous and new
/// [currentInset] current inset value
class BottomInsetChanges {
  final double delta;

  final double currentInset;

  const BottomInsetChanges({
    required this.delta,
    required this.currentInset,
  });
}
