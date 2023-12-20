import 'package:chatify/chatify.dart';
import 'package:example/firebase/datasource.dart';
import 'package:example/models/user.dart';
import 'package:example/routing/app_pages.dart';
import 'package:example/ui/auth/view/otp.dart';
import 'package:example/ui/common/confirm.dart';
import 'package:example/ui/common/toast.dart';
import 'package:example/utilz/extensions.dart';
import 'package:firebase_auth/firebase_auth.dart' hide User;
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:phone_number/phone_number.dart';

import 'package:get/get.dart';

class AuthController extends GetxController {
  final user = Rx<User?>(null);
  final Datasource _datasource;

  AuthController(this._datasource);

  bool get isAuthorised => FirebaseAuth.instance.currentUser != null;
  List<ChatifyUser> contatcUsers = [];

  @override
  void onReady() {
    FirebaseAuth.instance.authStateChanges().listen(_authChangeListener);
    super.onReady();
  }

  bool wait = false;

  void _authChangeListener(user) {
    if (user == null) {
      this.user.value = null;
    } else {
      _datasource.get<User>(user.uid).then((value) async {
        this.user.value = value;
      });
    }
  }

  PhoneAuthCredential? phoneAuthCredential;
  String? verificationId;
  bool passwordSubmitted = false;
  RxBool verifying = false.obs;

  init([bool addSavedMessages = false]) async {
    final user = await Get.find<Datasource>()
        .get<User>(FirebaseAuth.instance.currentUser!.uid);
    if (user == null) {
      Get.offAllNamed(Routes.info);
    } else {
      final permission = await Permission.contacts.request();
      if (permission.isGranted) {
        FlutterContacts.addListener(() => print('Contact DB changed'));
        final contacts =
            await FlutterContacts.getContacts(withProperties: true);
        final phones = contacts
            .where((e) => e.phones.isNotEmpty)
            .map(
              (a) => a.phones.map(
                (e) => ChatifyUser(
                  id: e.number.replaceAll(RegExp(r'[^0-9]'), ''),
                  name: a.displayName,
                ),
              ),
            )
            .expand((e) => e);

        final users = await Future.wait(
          phones.map((e) => _datasource.getUserByPhoneNumber(e.id)),
        );
        contatcUsers = users
            .where((e) => e != null)
            .map((e) => e!.toChatifyUser())
            .toList();
      }

      final chatifyConfig = ChatifyConfig(
        getUserById: (id) async {
          return (await _datasource.getUserById(id))!.toChatifyUser();
        },
        getUsersBySearch: (query) async {
          if (query.isEmpty) return contatcUsers;
          return (await _datasource.getUsers(query))
              .map((e) => e.toChatifyUser())
              .toList();
        },
      );
      await Chatify.init(config: chatifyConfig, currentUserId: user.id);
      if (addSavedMessages) {
        await Chatify.createSavedMessages();
      }

      Get.offAllNamed(Routes.home);
    }
  }

  Future<bool> submitPhoneNumber(String phone, [bool isRetry = false]) async {
    if (!phone.isIraqiPhoneNumber || phone.phoneLocally.length != 11) {
      return false;
    }
    late PhoneNumber phoneNumber;
    try {
      phoneNumber = await PhoneNumberUtil().parse(phone.phoneUniversal);
    } catch (e) {
      return showToast('Invalid phone number');
    }
    wait = true;
    await FirebaseAuth.instance.verifyPhoneNumber(
      verificationCompleted: (x) {
        submitCode(credential: x);
      },
      timeout: Duration(minutes: 2),
      verificationFailed: (e) {
        wait = false;
        if (e.code == 'quota-exceeded') {
          showToast('Limit exceeded. Try again later.');
        } else {
          print(e);
          print(e.code);
          print(e.message);
          showToast(e.toString());
        }
      },
      codeSent: (String id, int? resendToken) {
        verificationId = id;
        wait = false;
        if (isRetry) {
          Get.off(
            () => OtpScreen(
              phone: phone,
            ),
          );
        } else {
          Get.to(
            () => OtpScreen(
              phone: phone,
            ),
          );
        }
      },
      codeAutoRetrievalTimeout: (String verificationId) {},
      phoneNumber: phoneNumber.international,
    );
    while (wait) {
      await Future.delayed(const Duration(seconds: 1));
    }
    return true;
  }

  submitCode({String? code, PhoneAuthCredential? credential}) async {
    try {
      phoneAuthCredential = credential ??
          PhoneAuthProvider.credential(
            verificationId: verificationId!,
            smsCode: code!,
          );
      await FirebaseAuth.instance.signInWithCredential(phoneAuthCredential!);
      await init();
    } catch (e) {
      FirebaseAuth.instance.signOut();
      if (e is FirebaseAuthException && e.code == 'invalid-verification-code') {
        showToast('The sms verification code is invalid.');
      } else
        showToast(e.toString());
      return false;
    }
    verifying.value = false;
    return true;
  }

  resendCode(String phoneNumber) {
    submitPhoneNumber(phoneNumber, true);
  }

  submitUserInfo({
    required String firstName,
    required String lastName,
    required String? image,
  }) async {
    if (image != null) FirebaseAuth.instance.currentUser!.updatePhotoURL(image);
    await _datasource.put(
      User(
        id: FirebaseAuth.instance.currentUser!.uid,
        firstName: firstName,
        lastName: lastName,
        phone: FirebaseAuth.instance.currentUser!.phoneNumber,
        image: image,
      ),
    );
    await init(true);
  }

  updateUserInfo({
    String? firstName,
    String? lastName,
    String? image,
  }) async {
    if (image != null) FirebaseAuth.instance.currentUser!.updatePhotoURL(image);
    await _datasource.put(
      User(
        id: FirebaseAuth.instance.currentUser!.uid,
        firstName: user.value!.firstName,
        lastName: user.value!.lastName,
        phone: FirebaseAuth.instance.currentUser!.phoneNumber,
        image: image,
      ),
    );
  }

  void logOut() async {
    final logOut = await showConfirmDialog(
      context: Get.context!,
      message: 'Are you sure you want to log out?',
      title: 'Logout',
      textOK: 'Logout',
      textCancel: 'Cancel',
      showDeleteForAll: true,
    );
    if (logOut == true) {
      await FirebaseAuth.instance.signOut();
      Get.offAllNamed(Routes.login);
    }
  }

  Future resetPassword(String email) async {
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      showToast('تم ارسال الرابط');
      Get.back();
    } catch (e) {
      showToast(
        e.toString(),
      );
    }
  }
}
