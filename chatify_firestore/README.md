## Chatify Firestore

Firestore implementation of Chatify's `ChatRepo` and `MessageRepo`. Plug it into the core Chatify UI to get realtime chats and messages with Google Cloud Firestore and presence with Realtime Database.

### Installation

Add dependencies:

```yaml
dependencies:
  chatify: ^0.1.3
  chatify_firestore: ^0.0.1
```

Initialize Firebase in your app before using.

### Usage

```dart
import 'package:flutter/widgets.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:chatify/chatify.dart';
import 'package:chatify_firestore/chatify_firebase.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  final me = const User(id: 'u1', name: 'Me', imageUrl: '');

  await Chatify.init(
    currentUser: me,
    chatRepo: FirestoreChatRepo(userId: me.id),
    messageRepoFactory: (chat) => FirestoreMessageRepo(chat: chat),
    uploaderFactory: (attachment) => /* Your AttachmentUploader implementation */
        throw UnimplementedError(),
    messageProviders: [
      // e.g. TextMessageProvider(), ImageMessageProvider(), ...
    ],
  );
}
```

### What it provides

- `FirestoreChatRepo`: chats pagination, create/find/delete, unread counter
- `FirestoreMessageRepo`: messages pagination, CRUD, reactions, seen/delivered, presence status via Realtime Database

### Notes

- You can combine this with any `AttachmentUploader` implementation (e.g. `chatify_uploader_firebase_storage`).
- Structure and field names used by the repos are defined in the source; migrating existing data may be required.
