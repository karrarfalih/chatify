## Chatify File Message

File message provider for Chatify. Defines `FileMessage` content and a `FileMessageProvider` that renders files and provides a composer action to pick and upload arbitrary files.

### Installation

```bash
flutter pub add chatify_file_message
```

### Usage

Register the provider when initializing Chatify:

```dart
import 'package:chatify/chatify.dart';
import 'package:chatify_file_message/chatify_file_message.dart';

await Chatify.init(
  currentUser: currentUser,
  chatRepo: chatRepo,
  messageRepoFactory: (chat) => messageRepoFor(chat),
  uploaderFactory: (attachment) => uploaderFor(attachment),
  messageProviders: [
    FileMessageProvider(),
  ],
);
```

The provider adds a composer action labelled “File” that returns `MediaComposerResult` with file metadata and bytes. Chatify uploads using your `AttachmentUploader`, then calls `MessageRepo.add(...)` with the final URL.

### API

- `FileMessage` extends `MessageContent` with: `name`, `extension`, `size`
- `FileMessageProvider` extends `MediaMessageProvider<FileMessage>` and exposes a composer action
- `FileMessageWidget` displays a file bubble; tapping downloads/opens the file where supported
