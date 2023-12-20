import 'package:animated_typing/animated_typing.dart';
import 'package:example/ui/auth/controllers/wrapper_controller.dart';
import 'package:example/ui/common/loading.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class Wrapper extends GetView<WrapperController> {
  const Wrapper({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
          statusBarBrightness: Brightness.light,
          systemNavigationBarColor: Colors.white,
          systemNavigationBarIconBrightness: Brightness.dark,
          systemNavigationBarDividerColor: Colors.transparent,
        ),
        child: Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(height: 50),
                LoadingWidget(
                  scale: 2,
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 30),
                  child: AnimatedTyping(
                    text: 'IQ Chat',
                    duration: Duration(
                      seconds: 2,
                    ),
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
      ),
    );
  }
}
