## Chatify Reply Addon

Reply-to messages for Chatify chats. This addon adds:

- Swipe-to-reply gesture on messages
- "Reply" action in message options
- Preview of the message you’re replying to above the input field
- Reply snippet rendered above message bubbles
- Automatic clearing of the reply state after sending
- Outgoing metadata attached to messages so the reply can be rendered elsewhere

### Requirements

- Dart SDK: ^3.8.1
- Flutter: >=1.17.0
- chatify: ^0.1.5

### Installation

Add to your `pubspec.yaml`:

```yaml
dependencies:
  chatify_reply: ^0.0.1
```

### Quick start

Register the addon when initializing Chatify:

```dart
import 'package:chatify/chatify.dart';
import 'package:chatify_reply/chatify_reply.dart';

await Chatify.init(
  currentUser: currentUser,
  chatRepo: chatRepo,
  messageRepoFactory: (chat) => messageRepoFor(chat),
  uploaderFactory: (attachment) => uploaderFor(attachment),
  messageProviders: [/* your message providers */],
  chatAddons: const [
    ReplyAddon(),
  ],
);
```

That’s it. The addon will:

- Wrap each message to enable swipe-to-reply
- Add a "Reply" option in the message options menu
- Show a `ReplyPreview` widget above the input field when replying
- Inject a reply snippet above message bubbles when metadata is present
- Clear the reply state after a message is sent

### What metadata is sent?

When replying, outgoing messages include a `reply` map in `metadata`:

```json
{
  "reply": {
    "id": "<message id>",
    "message": "<message text>",
    "sender": "<sender id>",
    "senderName": "<sender name>",
    "isMine": true
  }
}
```

This is parsed automatically to render the reply snippet via `ReplyedMessageWidget`.

### Widgets provided

- `ReplyPreview`: shown above the input field while replying
- `ReplyedMessageWidget`: small preview displayed above a message bubble

You normally don’t need to use these directly; the addon wires them in through Chatify addon hooks.

### License

MIT
