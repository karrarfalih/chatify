import 'package:chatify/models/controller.dart';
import 'package:chatify/models/icons.dart';
import 'package:chatify/models/user.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:chatify/ui/chats/new_message.dart';
import 'chats/recent_chats.dart';

class ChatScreen extends StatelessWidget {
  ChatScreen({Key? key, required ChatUser currentUser})
      : assert(ChatifyController.isInititialized,
            'initialize the chat options. use init method in the main entry.'),
        super(key: key) {
    ChatUser.current = currentUser;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        shadowColor: Colors.transparent,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        title: Text(
          'Messages'.tr,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w500,
            color: Colors.black,
          ),
        ),
        leading: InkWell(
          onTap: () {
            Navigator.pop(context);
          },
          child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 22),
              child: const Icon(
                CupertinoIcons.back,
                color: Colors.black,
                opticalSize: 1,
              )),
        ),
        centerTitle: true,
        actionsIconTheme: const IconThemeData(
          color: Colors.black,
          size: 24,
          // weight: 100,
        ),
        actions: [
          // InkWell(
          //   onTap: () {
          //     Get.to(const NewMessages());
          //   },
          //   child: Container(
          //       padding: const EdgeInsets.symmetric(horizontal: 10),
          //       child: SvgPicture.asset(
          //         SVG.searchIcon,
          //         package: 'chatify',
          //         height: 24,
          //         color: Colors.black,
          //       )),
          // ),
          if (options.newMessage)
            InkWell(
              onTap: () {
                Get.to(const NewMessages());
              },
              child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: SvgPicture.asset(
                    SVG.newMessage,
                    package: 'chatify',
                    height: 24,
                    color: Colors.black,
                  )),
            ),
          const SizedBox(
            width: 12,
          ),
        ],
      ),
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: const Padding(
        padding: EdgeInsetsDirectional.only(top: 10),
        child: RecentChats(),
      ),
    );
  }
}
