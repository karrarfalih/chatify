## Chatify Voice Message

Voice message provider for Chatify. Defines `VoiceMessage` content and a `VoiceMessageProvider` that renders audio messages. The UI component is a placeholder; customize it in your app or extend this package.

### Installation

```bash
flutter pub add chatify_voice_message
```

### Usage

Register the provider when initializing Chatify:

```dart
import 'package:chatify/chatify.dart';
import 'package:chatify_voice_message/chatify_voice_message.dart';

await Chatify.init(
  currentUser: currentUser,
  chatRepo: chatRepo,
  messageRepoFactory: (chat) => messageRepoFor(chat),
  uploaderFactory: (attachment) => uploaderFor(attachment),
  messageProviders: [
    VoiceMessageProvider(),
  ],
);
```

### API

- `VoiceMessage` extends `MessageContent` with: `duration`, `isPlayed`, `samples`
- `VoiceMessageProvider` extends `MediaMessageProvider<VoiceMessage>`
- `VoiceMessageWidget` is currently a placeholder; replace or extend as needed
