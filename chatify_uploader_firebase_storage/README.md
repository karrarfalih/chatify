## Chatify Uploader - Firebase Storage

Firebase Storage implementation of Chatify's `AttachmentUploader` for uploading message attachments to Google Cloud Storage via `firebase_storage`.

### Installation

Add the dependency:

```bash
flutter pub add chatify_uploader_firebase_storage
```

Then configure Firebase in your app (GoogleService-Info.plist / google-services.json) and initialize Firebase before using Chatify.

### Usage

Provide the Firebase uploader to Chatify via `Chatify.init` using the `uploaderFactory` parameter.

```dart
import 'package:flutter/widgets.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:chatify/chatify.dart';
import 'package:chatify_uploader_firebase_storage/chatify_uploader_firebase_storage.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  await Chatify.init(
    currentUser: currentUser, // Your implementation of User
    chatRepo: chatRepo, // Your ChatRepo implementation
    messageRepoFactory: (chat) => messageRepoFor(chat), // Your MessageRepo factory
    uploaderFactory: (attachment) => FirebaseStorageUploader(attachment: attachment),
    messageProviders: [
      // Your MessageProviders
    ],
  );

  runApp(MyApp());
}
```

The uploader builds a storage path like:
`chatify/{chatId}/{storageFolder}/{fileName}` and uploads `attachment.bytes`, emitting progress via `getTaskStream` and returning the public download URL upon completion.

### API

`FirebaseStorageUploader` implements Chatify's `AttachmentUploader`:

- `FirebaseStorageUploader({ required Attachment attachment })`
- `Future<UploadResult> upload()` – resolves with `UploadResult(url, isCanceled)`
- `Stream<TaskProgress> get getTaskStream` – progress and task state
- `void cancel()` – cancels the underlying upload task

### Notes

- Ensure proper Firebase rules and security are configured for your Storage bucket.
- The package does not initialize Firebase for you; call `Firebase.initializeApp()` before `Chatify.init`.
