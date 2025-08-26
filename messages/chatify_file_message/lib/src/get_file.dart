import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';

class ChatifyFile {
  final Uint8List file;
  final String name;
  final String extension;
  final int size;

  ChatifyFile({
    required this.file,
    required this.name,
    required this.extension,
    required this.size,
  });
}

Future<List<ChatifyFile>> pickFiles() async {
  List<ChatifyFile> results = [];
  final result = await FilePicker.platform.pickFiles(
    type: FileType.any,
    allowMultiple: true,
    withData: true,
  );
  if (result == null) return [];
  final files = result.files;

  for (final file in files) {
    final size = file.size;
    final name = file.name;
    final extension = file.name.split('.').last;

    results.add(
      ChatifyFile(
        file: file.bytes!,
        extension: extension,
        name: name,
        size: size,
      ),
    );
  }
  return results;
}
