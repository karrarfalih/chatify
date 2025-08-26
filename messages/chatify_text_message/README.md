## Chatify Text Message

Text message provider for Chatify. Implements a `TextMessage` content model and a `TextMessageProvider` that renders messages and supports composing from text input.

### Installation

```yaml
dependencies:
  chatify: ^0.1.3
  chatify_text_message: ^0.0.1
```

### Usage

Register the provider when initializing Chatify:

```dart
import 'package:chatify/chatify.dart';
import 'package:chatify_text_message/chatify_text_message.dart';

await Chatify.init(
  currentUser: currentUser,
  chatRepo: chatRepo,
  messageRepoFactory: (chat) => messageRepoFor(chat),
  uploaderFactory: (attachment) => uploaderFor(attachment),
  messageProviders: [
    TextMessageProvider(),
  ],
);
```

### API

- `TextMessage` extends `MessageContent` and serializes to/from JSON
- `TextMessageProvider` extends `BasicMessageProvider<TextMessage>` and:
  - supports text input (`supportsTextInput = true`)
  - builds `TextMessageWidget` for display
