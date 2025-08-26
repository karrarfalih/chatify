import 'package:chatify/chatify.dart';
import 'package:flutter/widgets.dart';
import 'package:iconsax/iconsax.dart';

import 'model.dart';
import 'widget.dart';
import 'get_file.dart';

class FileMessageProvider extends MediaMessageProvider<FileMessage> {
  @override
  FileMessage fromJson(Map<String, dynamic> data, String id) {
    return FileMessage.fromJson(data, id);
  }

  @override
  Widget build(BuildContext context, MessageState message) {
    return FileMessageWidget(
      key: Key(message.message.content.url ?? ''),
      message: message.message,
      isFailed: message.isFailed,
      isSending: message.isPending,
    );
  }

  @override
  List<ComposerAction<MediaComposerResult>> get composerActions => [
        ComposerAction(
          title: 'File',
          icon: Iconsax.document,
          onPick: (context) async {
            final files = await pickFiles();
            return files
                .map((e) => MediaComposerResult(
                      message: FileMessage(
                        url: '',
                        name: e.name,
                        extension: e.extension,
                        size: e.size,
                      ),
                      bytes: e.file,
                      storageFolder: 'files',
                      fileName: e.name,
                    ))
                .toList();
          },
        ),
      ];
}
