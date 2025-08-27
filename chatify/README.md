## Chatify

Composable Flutter chat UI toolkit. Bring your own data layer and storage; Chatify renders chats, messages, input, selection, and statuses with minimal glue code.

### Features
- **Chats list**: paginated list with last message, time, unseen count
- **Messages view**: animated list, pending/failed queues, day separators
- **Interactions**: swipe-to-reply, edit, copy, delete, selection mode
- **Input**: text, recording UI, pluggable attachments (composer actions)
- **Statuses**: typing, recording, sending media
- **Extensible**: custom `MessageProvider`s, `AttachmentUploader`, and addons
- **Localization**: EN/AR maps included (GetX `.tr` ready)
- **Platforms**: mobile, web, desktop (uses `universal_html` defensively)

### Requirements
- Dart SDK: >=3.2.3 <4.0.0
- Flutter: >=3.27.0

### Install
```bash
flutter pub add chatify
```

### Quick start

1) Implement your repositories

Chatify is UI-only; you plug in your own data layer by implementing `ChatRepo` and `MessageRepo`.

```dart
import 'package:chatify/chatify.dart';

class MyChatRepo extends ChatRepo {
  MyChatRepo({required super.userId});

  final _controller = StreamController<PaginatedResult<Chat>>.broadcast();

  @override
  Stream<PaginatedResult<Chat>> chatsStream() => _controller.stream;

  @override
  void loadMore() {
    // Fetch next page and emit:
    // _controller.add(PaginatedResult.success([...], hasReachedEnd));
  }

  @override
  FutureResult<Chat> create(List<User> members) async {
    // Create a chat and return Result.success(chat)
    throw UnimplementedError();
  }

  @override
  FutureResult<Chat> findById(String id) async {
    throw UnimplementedError();
  }

  @override
  FutureResult<Chat?> findByUser(String receiverId) async {
    throw UnimplementedError();
  }

  @override
  FutureResult<bool> delete(String id) async {
    throw UnimplementedError();
  }

  @override
  Stream<int> get unreadCountStream => const Stream.empty();

  @override
  void dispose() {
    _controller.close();
  }
}

class MyMessageRepo extends MessageRepo {
  MyMessageRepo({required super.chat});

  final _controller = StreamController<PaginatedResult<Message>>.broadcast();

  @override
  Stream<PaginatedResult<Message>> messagesStream() => _controller.stream;

  @override
  void loadMore() {
    // Fetch next page and emit:
    // _controller.add(PaginatedResult.success([...], hasReachedEnd));
  }

  @override
  FutureResult<bool> add(
    MessageContent message,
    ReplyMessage? reply, {
    String? attachmentUrl,
  }) async {
    // Persist message; return Result.success(true/false)
    throw UnimplementedError();
  }

  @override
  FutureResult<bool> update(String content, String messageId) async {
    throw UnimplementedError();
  }

  @override
  FutureResult<Message> getById(String messageId) async {
    throw UnimplementedError();
  }

  @override
  FutureResult<bool> addReaction(String messageId, String emoji) async {
    throw UnimplementedError();
  }

  @override
  FutureResult<bool> removeReaction(String messageId, String emoji) async {
    throw UnimplementedError();
  }

  @override
  FutureResult<bool> delete(String id, bool forMe) async {
    throw UnimplementedError();
  }

  @override
  FutureResult<bool> markAsSeen(String id) async {
    throw UnimplementedError();
  }

  @override
  FutureResult<bool> markAsDelivered(String id) async {
    throw UnimplementedError();
  }

  @override
  FutureResult<bool> updateStatus(ChatStatus status) async {
    throw UnimplementedError();
  }

  @override
  Stream<ChatStatus> getStatus() => const Stream.empty();

  @override
  void dispose() {
    _controller.close();
  }
}
```

2) Provide an attachment uploader

Upload bytes and report progress via a stream.

```dart
import 'package:chatify/chatify.dart';

class MyUploader extends AttachmentUploader {
  MyUploader({required super.attachment});

  final _progress = StreamController<TaskProgress>.broadcast();

  @override
  Stream<TaskProgress> get getTaskStream => _progress.stream;

  @override
  Future<UploadResult> upload() async {
    // Upload attachment.bytes → storage, emit progress with _progress.add(...)
    // Return final public URL
    return UploadResult(url: 'https://example.com/file.jpg', isCanceled: false);
  }

  @override
  void cancel() {
    _progress.add(TaskProgress(state: TaskStatus.canceled, progress: null));
  }
}
```

3) Register message providers

Define a `MessageContent` and a matching `MessageProvider` that renders it and optionally integrates with the composer.

```dart
import 'package:chatify/chatify.dart';
import 'package:flutter/material.dart';

class TextMessage extends MessageContent {
  TextMessage({required String text}) : super(content: text);

  TextMessage.fromJson(Map<String, dynamic> json, String id)
      : super.fromJson(json, id);

  @override
  Map<String, dynamic> toJson() => super.toJson();
}

class TextMessageProvider extends BasicMessageProvider<TextMessage> {
  @override
  bool get supportsTextInput => true;

  @override
  TextMessage fromJson(Map<String, dynamic> data, String id) =>
      TextMessage.fromJson(data, id);

  @override
  TextMessage? createFromText(String text) => TextMessage(text: text);

  @override
  Widget build(BuildContext context, MessageState state) {
    return Text(
      state.message.content.content,
      style: Theme.of(context).textTheme.bodyLarge,
      textDirection: TextDirection.ltr,
      softWrap: true,
    );
  }
}
```

- Your repos should create `Message` objects that include your `MessageContent` instances.
- For media, extend `MediaMessageProvider` and return `MediaComposerResult` from `composerActions`. Chatify uploads via your `AttachmentUploader` then calls `MessageRepo.add(...)` with the resulting URL.

4) Initialize Chatify

```dart
import 'package:chatify/chatify.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final me = const User(id: 'u1', name: 'Me', imageUrl: '');

  await Chatify.init(
    currentUser: me,
    chatRepo: MyChatRepo(userId: me.id),
    messageRepoFactory: (chat) => MyMessageRepo(chat: chat),
    uploaderFactory: (attachment) => MyUploader(attachment: attachment),
    messageProviders: [
      TextMessageProvider(),
      // ImageMessageProvider(), VoiceMessageProvider(), ...
    ],
  );

  runApp(const MyApp());
}
```

### Addons (new)

Chatify supports optional addons that hook into the chat UI without forking the core package. Addons can provide headers, wrap the messages list, inject per-message behavior, extend the input bar, and add custom options.

- Addon API: see `ChatAddon` in `src/core/addons.dart`
- Registry: `ChatAddonsRegistry` for registering chat-level addons
- First-party addon: `chatify_selection` (multi-select header, drag-to-select, per-message highlight)

Usage example:

```dart
import 'package:chatify_selection/chatify_selection.dart';

await Chatify.init(
  currentUser: me,
  chatRepo: MyChatRepo(userId: me.id),
  messageRepoFactory: (chat) => MyMessageRepo(chat: chat),
  uploaderFactory: (att) => MyUploader(attachment: att),
  messageProviders: [TextMessageProvider()],
  chatAddons: const [SelectionAddon()],
);
```

Selection has been extracted from core into the separate `chatify_selection` package to keep the core lean and enable opt-in usage.

### Use the UI

- Chats list with built-in navigation to a messages page:

```dart
import 'package:chatify/chatify.dart';
import 'package:flutter/material.dart';

class ChatsScreen extends StatelessWidget {
  const ChatsScreen({super.key, required this.currentUserId});
  final String currentUserId;

  @override
  Widget build(BuildContext context) {
    return ChatsPage(
      userId: currentUserId,
      chatsLayout: ChatsLayout(
        bodyBuilder: (context, body) => Scaffold(body: SafeArea(child: body)),
        chatBuilder: (context, chat) => ListTile(
          title: Text(chat.receiver.name),
          subtitle: Text(chat.lastMessage ?? 'Say hi!'),
          onTap: () => MessagesPage.showWithNavigator(context: context, chat: chat),
        ),
      ),
      chatConfig: ChatLayout(
        bodyBuilder: (context, body, chat) => Scaffold(
          appBar: AppBar(title: Text(chat.receiver.name)),
          body: SafeArea(child: body),
        ),
      ),
    );
  }
}
```

- Open a chat programmatically

```dart
await Chatify().openChatById(context, chatId: 'chat_123');
// or
await Chatify().openChatByUser(context, receiverUser: someUser);
```

Tip: If you’re pushing from outside `ChatsPage`, pass a `navigatorKey` that points to its nested `Navigator`.

### Composer and attachments

- The “+” attachment menu is populated from `MessageProviderRegistry.instance.composerActions`, which aggregates `composerActions` from all registered providers.
- To add media, return `MediaComposerResult` with bytes; Chatify’s flow uploads via your `AttachmentUploader` and then calls `MessageRepo.add(...)` with the resulting URL.

### Localization (optional)

Default strings are English; `.tr` is used throughout. If you use GetX, you can merge the provided maps:

```dart
import 'package:get/get.dart';
import 'package:chatify/src/localization/en.dart' as chatify_en;
import 'package:chatify/src/localization/ar.dart' as chatify_ar;

class AppTranslations extends Translations {
  @override
  Map<String, Map<String, String>> get keys => {
    'en': chatify_en.chatifyEn,
    'ar': chatify_ar.chatifyAr,
  };
}
```

### Models and helpers
- `Chat`, `User`, `Message`, `MessageContent`
- `Result<T>` and `PaginatedResult<T>` helpers for async/results
- `ChatStatus`: `typing`, `recording`, `sendingMedia`, etc.

### Assets

Package-bundled assets are used by the UI (e.g., sent/seen icons). No extra app-level pubspec entries are needed.

### Official add-ons

Use these ready-made implementations or create your own:

- Data layer:
  - `chatify_firestore`: Firestore repos (`FirestoreChatRepo`, `FirestoreMessageRepo`)
- Uploaders:
  - `chatify_uploader_firebase_storage`: Firebase Storage uploader (`FirebaseStorageUploader`)
- Message types:
  - `chatify_text_message`: `TextMessageProvider`
  - `chatify_image_message`: `ImageMessageProvider`
  - `chatify_file_message`: `FileMessageProvider`
  - `chatify_voice_message`: `VoiceMessageProvider`

You can implement your own backends and message types by implementing `ChatRepo`, `MessageRepo`, `AttachmentUploader`, and `MessageProvider`s; see the examples above for the contracts.

### License

BSD-3-Clause. See LICENSE.

### Links
- Homepage: `https://github.com/karrarfalih/chatify`