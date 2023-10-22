import 'package:example/config.dart';
import 'package:example/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:chatify/chatify.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await _initChat();
  runApp(const MyApp());
}

_initChat() async {
  await Chatify.init(
    config: chatifyConfig,
    currentUserId: _currentUser.id,
  );
}

ChatifyUser _currentUser =
    users.firstWhere((element) => element.id == 'karrar');

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Brightness _brightness = Brightness.light;
  bool isLTR = true;

  @override
  Widget build(BuildContext context) {
    final primary = Colors.deepPurple;
    return MaterialApp(
      title: 'Chatify Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: primary,
          brightness: _brightness,
        ),
        primaryColor: primary,
        useMaterial3: true,
      ),
      localizationsDelegates: [
        GlobalCupertinoLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: [
        Locale("en", "US"),
        Locale("ar", "IQ"), // OR Locale('ar', 'AE') OR Other RTL locales
      ],
      locale: Locale(isLTR ? 'en' : 'ar'),
      home: Scaffold(
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
                },
              ),
            ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SizedBox(height: 20),
              Text('Select Current User'),
              SizedBox(height: 10),
              SizedBox(
                width: double.maxFinite,
                child: Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 10,
                  runSpacing: 10,
                  children: users
                      .map(
                        (e) => _UserButton(
                          user: e,
                          onChanged: () => setState(() {}),
                        ),
                      )
                      .toList(),
                ),
              ),
              SizedBox(height: 20),
              _MainButton(
                onPressed: () {
                  setState(() {
                    _brightness = _brightness == Brightness.dark
                        ? Brightness.light
                        : Brightness.dark;
                  });
                },
                text: 'Change Brightness',
                icon: CupertinoIcons.moon,
              ),
              _MainButton(
                onPressed: () {
                  setState(() {
                    isLTR = !isLTR;
                  });
                },
                text: 'Change Direction',
                icon: Icons.language_outlined,
              ),
              // Builder(
              //   builder: (context) {
              //     return _MainButton(
              //       onPressed: () {
              //         Chatify.openAllChats(context);
              //       },
              //       text: 'Show Recent Chats',
              //       icon: CupertinoIcons.time,
              //     );
              //   },
              // ),
              // Builder(
              //   builder: (context) {
              //     final targetedUser = _currentUser == sara ? karrar : sara;
              //     return _MainButton(
              //       onPressed: () {
              //         Chatify.openChatByUser(
              //           context,
              //           user: targetedUser,
              //         );
              //       },
              //       text: 'Start Chat with ${targetedUser.name}',
              //       icon: CupertinoIcons.paperplane,
              //     );
              //   },
              // ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MainButton extends StatelessWidget {
  const _MainButton({
    required this.onPressed,
    required this.text,
    this.icon,
  });
  final Function() onPressed;
  final String text;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        backgroundColor:
            Theme.of(context).colorScheme.secondary.withOpacity(0.1),
        foregroundColor:
            Theme.of(context).colorScheme.brightness == Brightness.dark
                ? Colors.white
                : Colors.black,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon),
            SizedBox(width: 10),
          ],
          Text(text),
        ],
      ),
    );
  }
}

class _UserButton extends StatelessWidget {
  const _UserButton({
    required this.user,
    required this.onChanged,
  });

  final ChatifyUser user;
  final Function() onChanged;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () {
        _currentUser = user;
        _initChat();
        onChanged();
      },
      style: TextButton.styleFrom(
        backgroundColor: _currentUser == user
            ? Theme.of(context).primaryColor
            : Theme.of(context).colorScheme.secondary.withOpacity(0.1),
        foregroundColor: _currentUser == user
            ? Colors.white
            : Theme.of(context).colorScheme.brightness == Brightness.dark
                ? Colors.white
                : Colors.black,
        padding: EdgeInsetsDirectional.only(
          start: 6,
          end: 20,
          top: 6,
          bottom: 6,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(50),
            child: Image.network(
              user.profileImage!,
              height: 50,
              width: 50,
              fit: BoxFit.cover,
            ),
          ),
          SizedBox(width: 10),
          Text(user.name),
        ],
      ),
    );
  }
}
