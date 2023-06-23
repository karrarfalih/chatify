# Chatify

Chatify is a Flutter package that provides a chat screen and functionality for starting conversations between users in your Flutter applications. It allows users to send text messages, audio recordings, images, and supports customization for additional message types such as videos. The package integrates with Firestore, Firebase Storage, and Firebase Messaging to enable real-time updates, storage, and notifications.
<div align="center">
  <img src="https://hackmd.io/_uploads/SJV6bF7dh.png" alt="Image 1" style="margin: 10px;" width="300" />
  <img src="https://hackmd.io/_uploads/B1fTbtX_h.png" alt="Image 2" style="margin: 10px;" width="300" />
  <img src="https://hackmd.io/_uploads/S1Ba-FXuh.png" alt="Image 3" style="margin: 10px;" width="300" />
<img src="https://hackmd.io/_uploads/rJ2KNFmd2.jpg" alt="Image 3" style="margin: 10px;" width="300" />
</div>



## Features
- User-friendly chat screen with a familiar interface similar to popular messaging apps.
- Send and receive text messages, audio recordings, and images.
- Customizable support for additional message types like videos (requires manual configuration).
- User suggestions based on the strength of connections between users.
- Caching mechanism for audio messages and images.
- View and download images to the gallery.
- Integration with Firebase for sending notifications (requires Firebase Messaging configuration).
- Essential message management features: delete, forward, and reply to messages.

## Dependencies

Chatify relies on the following dependencies:

- Firestore: Provides real-time database functionality for storing and retrieving user data and chat messages.
- Firebase Storage: Enables storing and retrieving audio recordings, images, and other media files.
- Firebase Messaging: Supports sending push notifications to users (requires configuration in your app).

## Installation

To use Chatify in your Flutter application, follow these steps:

1. Add the following dependency to your `pubspec.yaml` file:

   ```yaml
   dependencies:
     Chatify: ^0.0.1
     ```
2. Run the following command to install the package:
```bash
flutter pub get
```
3. Import the package in your Dart file:

```dart
import 'package:chatify/chatify.dart';
```
4. Configure Firebase in your application by following the Firebase setup documentation for Flutter.

## Usage
### Initializing the Chatify
Before using Chatify functionality, you need to initialize it with the appropriate options. Use the init method to initialize the chat with the desired options:
```dart
ChatifyController.init(ChatifyOptions(
  // Provide the necessary options here
));
```
The init method initializes the chat functionality by providing the necessary options. Let's go through each field in the ChatifyOptions example and explain its purpose:
```dart
ChatifyController.init(ChatifyOptions(
  usersCollectionName: 'users'
  userData: UserData(
    id: 'id', //required
    name: 'name', //required
    clientNotificationId: 'clientNotificationId', //optional
    profileImage: 'profileImage', //optional
    uid: 'uid', //optional
    searchTerms: 'searchTerms' //optional
  ),
  chatBackground: 'assets/png/chat.png',
  notificationKey: 'notificationKeyFromFirebase',
  onUserClick: (user) {
    Get.to(UserProfile(user: Account.fromJson(user.data)));
  },
  customMessages: [
    MessageWidget(
      key: 'reel',
      builder: (ctx, msg) => ReelCard(message: msg, width: 300),
    ),
  ],
));
```
Let's go through each field and its purpose:
1. **usersCollectionName (required)**: The firestore collection of your users data.
2. **userData (required)**: It represents the mapping model for user data in Firestore collection. In this example, the UserData class is used, which has properties like id, name, clientNotificationId, profileImage, searchTerms, and uid. You need to provide appropriate values for these properties based on your Firestore user data model. If you have searchTerms in your model you can specify to add the ablity to search for users.
3. **chatBackground**: It specifies the chat background image. In this example, the path to the chat background image is set to 'assets/png/chat.png'. You can provide the path to your own image asset or leave it as null if you don't want to set a custom background. 
4. **notificationKey**: It is used to send notifications using Firebase Messaging. In this example, the value 'notificationKeyFromFirebase' is provided. You need to configure Firebase Messaging in your app and obtain the appropriate notification key to use here. If you don't want to send notifications, you can leave this field as null.
5. **onUserClick**: It is a callback function that is invoked when a user's image is clicked. In this example, it navigates to a user profile screen using the Get.to method from the GetX package. You can customize this callback function to perform any action you want when a user is clicked.

6. **customMessages**: It allows you to add custom message types to the chat. In this example, a custom message widget is added with the key 'reel' and a builder function that returns a ReelCard widget. You can add your own custom message types by providing a unique key and a builder function that returns the widget for that message type.

By providing the appropriate values for each field in the ChatifyOptions object, you can customize and configure the chat functionality according to your specific requirements.
### Implement the recent chats screen
To implement the recent chat screen in your Flutter application, follow the example below:

```dart
import 'package:flutter/material.dart';
import 'package:chatify/chatify.dart';

void main() {
  ChatifyController.init(ChatifyOptions(
      usersCollectionName: 'users'
      userData: UserData(
          id: 'id',
          name: 'name',
          clientNotificationId: 'clientNotificationId',
          profileImage: 'profileImage',
          uid: 'uid'),
    ));
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Chat App',
      home: ChatScreen(),
    );
  }
}

```

or you can simply navigate to the recent chat screen by calling this method:
```dart
ChatifyController.showRecentChats(currentUser);
```

### Additional Functionality
Chatify package provides more functionality such as sending messages manually, adding scores, stream unread message counts, and more.

```dart
// To start a chat with a user and add them to recent chats, use the startChat method
ChatifyController.startChat(user);

///to manually send messasges
ChatifyController.sendTo(user, message, type);

///To add a score to a user, you can use the addScore method:
ChatifyController.addScore(value: 5, user: user);

//To get the stream of unread messages count, use the unReadMessagesCount method:
Stream<int> unreadCountStream = ChatifyController.unReadMessagesCount(currentUser);
```

