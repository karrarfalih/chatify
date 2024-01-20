import 'package:chatify/chatify.dart';
import 'package:example/firebase/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_app_check/firebase_app_check.dart';

init() async {
  await Future.wait([
    Future.delayed(Duration(seconds: 3)),
    _initFirebase(),
  ]);
}

Future _initFirebase() async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
    name: 'chatify',
  );
  await FirebaseAppCheck.instance.activate(
    androidProvider: AndroidProvider.playIntegrity,
    appleProvider: AppleProvider.debug,
  );
  final chatifyConfig = ChatifyConfig(
    getUserById: (id) async {
      return ChatifyUser(id: id, name: 'Saved messages');
    },
    getUsersBySearch: (query) async {
      return [];
    },
  );
  await Chatify.init(config: chatifyConfig, currentUserId: 'Karrar');
}
