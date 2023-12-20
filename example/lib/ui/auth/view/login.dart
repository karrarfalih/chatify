import 'package:example/theme/app_colors.dart';
import 'package:example/ui/auth/controllers/auth_controller.dart';
import 'package:example/ui/auth/view/keyboard.dart';
import 'package:example/ui/auth/view/locales.dart';
import 'package:flutter/material.dart';
import 'package:flutter_shakemywidget/flutter_shakemywidget.dart';
import 'package:get/get.dart';
import 'package:kr_button/kr_button.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController textEditingController = TextEditingController();
  final TextEditingController localeController =
      TextEditingController(text: '964');
  final FocusNode phoneFocus = FocusNode();
  final FocusNode localeFocus = FocusNode();
  final shakeKey = GlobalKey<ShakeWidgetState>();

  @override
  void dispose() {
    phoneFocus.dispose();
    localeFocus.dispose();
    textEditingController.dispose();
    localeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var outlineInputBorder = OutlineInputBorder(
      borderSide: BorderSide(
        color: Colors.grey.shade300,
      ),
    );
    return Scaffold(
      body: SafeArea(
        child: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.max,
            children: [
              Spacer(),
              Text(
                'Your phone number',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              SizedBox(
                width: 240,
                child: Text(
                  'Please confirm your country code and enter your phone number',
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                  textAlign: TextAlign.center,
                ),
              ),
              SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: Column(
                  children: [
                    InkWell(
                      onTap: () async {
                        final locale = await Get.to(LocalesScreen());
                        if (locale is String) {
                          localeController.text = locale;
                          setState(() {});
                        }
                      },
                      focusColor: Colors.transparent,
                      highlightColor: Colors.transparent,
                      child: IgnorePointer(
                        child: TextFormField(
                          readOnly: true,
                          enableInteractiveSelection: false,
                          smartDashesType: SmartDashesType.enabled,
                          decoration: InputDecoration(
                            isDense: true,
                            prefixIcon: Row(
                              children: [
                                SizedBox(width: 10),
                                if (locales
                                        .firstWhereOrNull(
                                          (e) =>
                                              e.code == localeController.text,
                                        )
                                        ?.image !=
                                    null)
                                  Padding(
                                    padding: const EdgeInsetsDirectional.only(
                                      end: 10,
                                      top: 0,
                                    ),
                                    child: Image.asset(
                                      locales
                                          .firstWhereOrNull(
                                            (e) =>
                                                e.code == localeController.text,
                                          )!
                                          .image,
                                      height: 13,
                                    ),
                                  ),
                                Text(
                                  locales
                                          .firstWhereOrNull(
                                            (e) =>
                                                e.code == localeController.text,
                                          )
                                          ?.name ??
                                      'Select country',
                                ),
                              ],
                            ),
                            suffixIcon: Icon(Icons.arrow_forward_ios),
                            border: outlineInputBorder,
                            enabledBorder: outlineInputBorder,
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                width: 1,
                                color: Theme.of(context).primaryColor,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    ShakeMe(
                      key: shakeKey,
                      shakeCount: 3,
                      shakeOffset: 10,
                      shakeDuration: Duration(milliseconds: 500),
                      child: Focus(
                        child: Stack(
                          children: [
                            if (phoneFocus.hasFocus ||
                                textEditingController.text.isNotEmpty)
                              PositionedDirectional(
                                top: 15,
                                start: 86,
                                child: Text(
                                  textEditingController.text +
                                      ('0' *
                                          (11 -
                                              textEditingController
                                                  .text.length)),
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 16,
                                    fontWeight: FontWeight.normal,
                                    inherit: false,
                                    textBaseline: TextBaseline.alphabetic,
                                  ),
                                ),
                              ),
                            Focus(
                              onFocusChange: (value) => setState(() {}),
                              child: TextField(
                                controller: textEditingController,
                                focusNode: phoneFocus,
                                readOnly: true,
                                showCursor: true,
                                autofocus: true,
                                onTap: () => setState(() {}),
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 16,
                                  fontWeight: FontWeight.normal,
                                  inherit: false,
                                  textBaseline: TextBaseline.alphabetic,
                                  backgroundColor: Colors.white,
                                ),
                                decoration: InputDecoration(
                                  isDense: true,
                                  prefixIcon: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      SizedBox(width: 10),
                                      SizedBox(
                                        width: 50,
                                        height: 47,
                                        child: Row(
                                          children: [
                                            Text(
                                              '+',
                                              style: TextStyle(
                                                color: Colors.black,
                                                fontSize: 16,
                                                height: 1,
                                                fontWeight: FontWeight.normal,
                                                inherit: false,
                                                textBaseline:
                                                    TextBaseline.alphabetic,
                                                backgroundColor: Colors.white,
                                              ),
                                            ),
                                            Expanded(
                                              child: TextFormField(
                                                controller: localeController,
                                                readOnly: true,
                                                showCursor: true,
                                                focusNode: localeFocus,
                                                onTap: () => setState(() {}),
                                                style: TextStyle(
                                                  color: Colors.black,
                                                  fontSize: 16,
                                                  height: 1,
                                                  fontWeight: FontWeight.normal,
                                                  inherit: false,
                                                  textBaseline:
                                                      TextBaseline.alphabetic,
                                                  backgroundColor: Colors.white,
                                                ),
                                                decoration: InputDecoration(
                                                  isDense: false,
                                                  contentPadding:
                                                      EdgeInsets.zero,
                                                  enabledBorder:
                                                      InputBorder.none,
                                                  focusedBorder:
                                                      InputBorder.none,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Padding(
                                        padding:
                                            const EdgeInsetsDirectional.only(
                                          end: 10,
                                        ),
                                        child: SizedBox(
                                          height: 20,
                                          child: VerticalDivider(),
                                        ),
                                      ),
                                    ],
                                  ),
                                  labelText: 'Phone number',
                                  labelStyle:
                                      TextStyle(color: Colors.grey.shade500),
                                  border: outlineInputBorder,
                                  enabledBorder: outlineInputBorder,
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      width: 1,
                                      color: Theme.of(context).primaryColor,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Spacer(),
              Align(
                alignment: AlignmentDirectional.centerEnd,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: KrTextButton(
                    style: TextButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: EdgeInsets.symmetric(
                        vertical: 20,
                      ),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(50),
                      ),
                    ),
                    onPressed: () async {
                      if (!await Get.find<AuthController>()
                          .submitPhoneNumber(textEditingController.text)) {
                        shakeKey.currentState?.shake();
                      }
                    },
                    onLoading: SizedBox(
                      height: 24,
                      width: 24,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    ),
                    child: Icon(
                      Icons.arrow_forward,
                      size: 24,
                    ),
                  ),
                ),
              ),
              NumericKeyboard(
                onChanged: (x) {
                  TextEditingController? controller;
                  int length = 0;
                  if (phoneFocus.hasFocus) {
                    controller = textEditingController;
                    length = 11;
                  }
                  if (localeFocus.hasFocus) {
                    controller = localeController;
                    length = 3;
                  }
                  if (controller != null) {
                    if (x == 'x') {
                      if (controller.text.isEmpty) return;
                      controller.text = controller.text
                          .substring(0, controller.text.length - 1);
                      setState(() {});
                      return;
                    }
                    if (controller.text.length == length) return;
                    controller.text = controller.text + x;
                    if (localeFocus.hasFocus &&
                        controller.text.length == length) {
                      phoneFocus.requestFocus();
                    }
                    setState(() {});
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
