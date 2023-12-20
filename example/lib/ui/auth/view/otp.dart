import 'dart:math';

import 'package:example/theme/app_colors.dart';
import 'package:example/ui/auth/controllers/auth_controller.dart';
import 'package:example/ui/auth/view/keyboard.dart';
import 'package:example/ui/common/toast.dart';
import 'package:example/utilz/extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_shakemywidget/flutter_shakemywidget.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:otp_autofill/otp_autofill.dart';
import 'package:stop_watch_timer/stop_watch_timer.dart';

class OtpScreen extends StatefulWidget {
  const OtpScreen({super.key, required this.phone});

  final String phone;

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final shakeKey = GlobalKey<ShakeWidgetState>();

  int focusedIndex = 0;
  List<String> numbers = List.generate(6, (index) => '');
  RxBool isSahking = false.obs;
  RxBool isLoading = false.obs;

  final StopWatchTimer _stopWatchTimer = StopWatchTimer(
    mode: StopWatchMode.countDown,
    presetMillisecond: StopWatchTimer.getMilliSecFromMinute(2),
  );

  late OTPTextEditController controller;

  @override
  void initState() {
    super.initState();
    _stopWatchTimer.onStartTimer();
    final otpInteractor = OTPInteractor()..getAppSignature();
    controller = OTPTextEditController(
      codeLength: 5,
      otpInteractor: otpInteractor,
      onCodeReceive: (code) async {
        numbers = code.split('');
        isLoading.value = true;
        Get.find<AuthController>()
            .submitCode(code: numbers.join())
            .then((value) {
          isLoading.value = false;
          if (!value) {
            showToast('Invalid activation code');
            shakeKey.currentState?.shake();
            isSahking.value = true;
            numbers = List.generate(6, (index) => '');
            focusedIndex = 0;
            Future.delayed(Duration(seconds: 1))
                .then((value) => isSahking.value = false);
          }
        });
        await Get.find<AuthController>().submitCode(code: code);
      },
    )..startListenUserConsent(
        (code) {
          final exp = RegExp(r'(\d{6})');
          return exp.stringMatch(code ?? '') ?? '';
        },
        senderNumber: widget.phone.phoneUniversal,
      );
  }

  @override
  void dispose() async {
    super.dispose();
    await _stopWatchTimer.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Obx(
        () {
          return IgnorePointer(
            ignoring: isLoading.value,
            child: Opacity(
              opacity: isLoading.value ? 0.5 : 1,
              child: SafeArea(
                child: SizedBox(
                  width: double.maxFinite,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      SizedBox(
                        height: 80,
                        child: Lottie.asset(
                          'assets/lottie/otp.json',
                          fit: BoxFit.fitHeight,
                          repeat: false,
                        ),
                      ),
                      Text(
                        'Enter Code',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 10),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 30),
                        child: Text(
                          "we've sent an SMS with an activation code to your phone +964 ${widget.phone}",
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      SizedBox(height: 20),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 30),
                        child: Column(
                          children: [
                            SizedBox(height: 20),
                            ConstrainedBox(
                              constraints: BoxConstraints.tightFor(width: 250),
                              child: ShakeMe(
                                key: shakeKey,
                                shakeCount: 5,
                                shakeOffset: 10,
                                shakeDuration: Duration(milliseconds: 1000),
                                child: Obx(
                                  () => Row(
                                    children: List.generate(
                                      6,
                                      (index) => OtpText(
                                        value:
                                            numbers.elementAt(index).toString(),
                                        isFocused: focusedIndex == index,
                                        isError: isSahking.value,
                                        onPressed: () {
                                          focusedIndex = index;
                                          setState(() {});
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 20),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 30),
                        child: StreamBuilder<int>(
                          stream: _stopWatchTimer.rawTime,
                          initialData: 0,
                          builder: (context, snap) {
                            final value = snap.data;
                            final displayTime = StopWatchTimer.getDisplayTime(
                              value ?? 0,
                              milliSecond: false,
                              hours: false,
                            );
                            if (value == 0) {
                              return TextButton(
                                onPressed: () {
                                  Get.find<AuthController>()
                                      .resendCode(widget.phone);
                                },
                                child: Text('Resend code'),
                              );
                            }
                            return Text.rich(
                              TextSpan(
                                children: [
                                  TextSpan(
                                    text: 'The activation code is expired on ',
                                  ),
                                  TextSpan(
                                    text: displayTime,
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.normal,
                              ),
                            );
                          },
                        ),
                      ),
                      Spacer(),
                      NumericKeyboard(
                        onChanged: (x) async {
                          if (x == 'x') {
                            if (numbers[focusedIndex].isEmpty) {
                              numbers[max(focusedIndex - 1, 0)] = '';
                              focusedIndex--;
                              if (focusedIndex < 0) {
                                focusedIndex = 0;
                              }
                            } else
                              numbers[focusedIndex] = '';
                          } else {
                            numbers[focusedIndex] = x;
                            if (focusedIndex != 5) {
                              focusedIndex++;
                            }
                            if (numbers.every(
                              (e) => e.isNotEmpty && focusedIndex == 5,
                            )) {
                              isLoading.value = true;
                              Get.find<AuthController>()
                                  .submitCode(code: numbers.join())
                                  .then((value) {
                                isLoading.value = false;
                                if (!value) {
                                  showToast('Invalid activation code');
                                  shakeKey.currentState?.shake();
                                  isSahking.value = true;
                                  numbers = List.generate(6, (index) => '');
                                  focusedIndex = 0;
                                  Future.delayed(Duration(seconds: 1))
                                      .then((value) => isSahking.value = false);
                                }
                              });
                            }
                          }
                          setState(() {});
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class OtpText extends StatelessWidget {
  const OtpText({
    super.key,
    required this.value,
    required this.onPressed,
    required this.isFocused,
    required this.isError,
  });

  final String value;
  final bool isFocused;
  final Function() onPressed;
  final bool isError;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2),
        child: SizedBox(
          height: 50,
          child: TextButton(
            onPressed: onPressed,
            child: AnimatedSwitcher(
              duration: Duration(milliseconds: 300),
              transitionBuilder: (child, animation) {
                return ScaleTransition(
                  scale: animation,
                  child: FadeTransition(
                    opacity: animation,
                    child: child,
                  ),
                );
              },
              child: Text(
                value,
                key: ValueKey(value),
                style: TextStyle(fontSize: 20, color: Colors.black),
              ),
            ),
            style: TextButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
                side: BorderSide(
                  color: isError
                      ? Colors.red
                      : isFocused
                          ? AppColors.primary
                          : Colors.grey.shade300,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
