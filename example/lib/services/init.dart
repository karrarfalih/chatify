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
}
