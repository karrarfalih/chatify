## Chatify Image Message

Image message provider for Chatify. Defines `ImageMessage` content and an `ImageMessageProvider` that renders images and provides a composer action to pick images and upload them using your configured `AttachmentUploader`.

### Installation

```yaml
dependencies:
  chatify: ^0.1.3
  chatify_image_message: ^0.0.1
```

### Usage

Register the provider when initializing Chatify:

```dart
import 'package:chatify/chatify.dart';
import 'package:chatify_image_message/chatify_image_message.dart';

await Chatify.init(
  currentUser: currentUser,
  chatRepo: chatRepo,
  messageRepoFactory: (chat) => messageRepoFor(chat),
  uploaderFactory: (attachment) => uploaderFor(attachment),
  messageProviders: [
    ImageMessageProvider(),
  ],
);
```

The provider adds a composer action labelled “Image” that returns `MediaComposerResult` items with thumbnail, dimensions, and bytes. Chatify uploads using your `AttachmentUploader`, then calls `MessageRepo.add(...)` with the final URL.

### API

- `ImageMessage` extends `MessageContent` with: `thumbnail` (bytes), `width`, `height`
- `ImageMessageProvider` extends `MediaMessageProvider<ImageMessage>` and exposes a composer action
- `ImageMessageWidget` displays image with upload/download progress, cancel/retry, and full-screen preview
