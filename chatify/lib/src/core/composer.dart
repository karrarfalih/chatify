import 'dart:typed_data';

import '../../chatify.dart';
import 'package:flutter/widgets.dart';

class ComposerAction<T extends ComposerResult> {
  final String title;
  final IconData icon;
  final Future<List<ComposerResult>> Function(BuildContext context) onPick;

  const ComposerAction({
    required this.title,
    required this.icon,
    required this.onPick,
  });
}

abstract class ComposerResult {
  final MessageContent message;

  const ComposerResult({
    required this.message,
  });
}

class BasicComposerResult extends ComposerResult {
  const BasicComposerResult({
    required super.message,
  });
}

class MediaComposerResult extends ComposerResult {
  final Uint8List bytes;
  final String? storageFolder;
  final String? fileName;

  const MediaComposerResult({
    required super.message,
    required this.bytes,
    this.storageFolder,
    this.fileName,
  });
}
