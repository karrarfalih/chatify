import 'dart:math';

import 'package:chatify/chatify.dart';
import 'package:example/firebase_options.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await Chatify.init(
    config: ChatifyConfig(
      getUserById: (id) async {
        return Future.value(ChatifyUser(
            id: 'id${Random().nextInt(10000)}',
            name: 'name',
            profileImage: 'https://picsum.photos/200'));
      },
      getUsersBySearch: (query) => Future.value([
        ChatifyUser(
            id: 'id${Random().nextInt(10000)}',
            name: 'user name',
            profileImage: 'https://picsum.photos/200'),
      ]),
    ),
    currentUserId: 'id',
  );
  // Chatify.datasource.addchat(Chat(id: 'id2', members: ['id', 'id3']));
  //   Chatify.datasource.addMessage(
  //   Message(
  //     id: 'id2',
  //     message: 'hello!',
  //     chatId: 'id2',
  //     sender: 'id3',
  //     unSeenBy: ['id'],
  //   ),
  // );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Chatify Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chatify Demo'),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: StreamBuilder(
                stream: Chatify.unreadMessagesCount,
                builder: (context, snapshot) {
                  int count = 0;
                  if (snapshot.hasData) {
                    count = snapshot.data as int;
                  }
                  return Badge(
                    label: Text(
                      count.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                      ),
                    ),
                    isLabelVisible: count > 0,
                    padding: EdgeInsets.symmetric(horizontal: 7),
                    largeSize: 20,
                    backgroundColor: Colors.red,
                    offset: Offset(-3, 3),
                    child: IconButton(
                      onPressed: () {
                        Chatify.openAllChats(context);
                      },
                      icon: const Icon(CupertinoIcons.chat_bubble_text),
                    ),
                  );
                }),
          ),
        ],
      ),
    );
  }
}
