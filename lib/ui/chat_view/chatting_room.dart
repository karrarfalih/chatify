import 'dart:math';
import 'package:chatify/models/controller.dart';
import 'package:chatify/models/theme.dart';
import 'package:chatify/models/user.dart';
import 'package:chatify/ui/common/user_image.dart';
import 'package:confirm_dialog/confirm_dialog.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_keyboard_size/flutter_keyboard_size.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttericon/entypo_icons.dart';
import 'package:get/get.dart';
import 'package:chatify/models/image.dart';
import 'package:chatify/ui/chat_view/date.dart';
import 'package:chatify/ui/chat_view/record.dart';
import 'package:chatify/ui/chat_view/voice_message.dart';
import 'package:kr_expanded_section/kr_expanded_section.dart';
import 'package:kr_paginate_firestore/paginate_firestore.dart';
import 'package:kr_pull_down_button/pull_down_button.dart';
import 'package:chatify/models/chats.dart';
import 'package:chatify/models/message.dart';
import 'package:chatify/ui/chat_view/message_card.dart';
import 'package:chatify/assets/circular_button.dart';

bool isKeyboardOpen = false;

class ChatView extends StatefulWidget {
  const ChatView({
    Key? key,
    required this.chat,
    required this.user,
  }) : super(key: key);
  final ChatModel chat;
  final ChatUser user;
  @override
  State<ChatView> createState() => _ChatViewState();
}

class _ChatViewState extends State<ChatView> {
  var controller = TextEditingController();
  final FocusNode focus = FocusNode();
  RxBool isTyping = false.obs;
  RxBool isRecording = false.obs;
  String name = '';
  String message = '';
  IconData icon = Icons.edit;

  @override
  dispose() {
    controller.dispose();
    focus.dispose();
    ChatModel.currentId = '';
    lastMsgIsMine.close();
    isTyping.close();
    isRecording.close();
    super.dispose();
  }

  submit(String msg, ChatModel chat) {
    msg = msg.trim();
    if (msg != '') {
      for (int i = 0; i <= (msg.length ~/ 1000); i++) {
        if (chat.editedMessage.value == null) {
          chat.sendMessage(
              message: msg.substring(i * 1000, min(msg.length, (i + 1) * 1000)),
              reply: chat.replyMessage.value);
          widget.chat.replyMessage.value = null;
          ChatifyController.addScore(
              value: options.messageConnentionWeight, user: widget.user);
        } else if (chat.editedMessage.value != null) {
          widget.chat.editedMessage.value!
              .update(msg.substring(i * 1000, min(msg.length, (i + 1) * 1000)));
          widget.chat.editedMessage.value = null;
        }
      }
    }
    isTyping.value = false;
  }

  RxBool lastMsgIsMine = false.obs;

  @override
  Widget build(BuildContext context) {
    ChatModel? chat = widget.chat;

    return KeyboardSizeProvider(
        smallSize: 500.0,
        child: Consumer<ScreenHeight>(
          builder: (context, _res, child) {
            isKeyboardOpen = _res.isOpen;
            return child!;
          },
          child: Scaffold(
            appBar: AppBar(
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              elevation: 0,
              systemOverlayStyle: SystemUiOverlayStyle.dark,
              toolbarHeight: 0,
            ),
            resizeToAvoidBottomInset: true,
            body: Container(
              decoration: options.chatBackground == null
                  ? null
                  : BoxDecoration(
                      image: DecorationImage(
                          image: AssetImage(options.chatBackground!),
                          fit: BoxFit.fitWidth)),
              child: Column(
                children: [
                  Row(
                    children: [
                      InkWell(
                        highlightColor: Colors.transparent,
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: Container(
                            padding: const EdgeInsetsDirectional.only(
                                start: 16, end: 16, top: 16, bottom: 16),
                            child: const Icon(
                              CupertinoIcons.back,
                              color: Colors.black,
                            )),
                      ),
                      UserAvatar(
                        uid: widget.user.id,
                        onTap: options.onUserClick,
                      ),
                      const Spacer(),
                      PullDownButton(
                          routeTheme: const PullDownMenuRouteTheme(width: 140),
                          itemBuilder: (context) => [
                                PullDownMenuItem(
                                    title: 'Delete'.tr,
                                    icon: Icons.delete,
                                    iconColor: Colors.red,
                                    onTap: () async {
                                      if (await confirm(
                                        Get.context!,
                                        title: Text('Confirm'.tr),
                                        content: Text(
                                            'All messages will be deleted. Are you sure?'
                                                .tr),
                                        textOK: Text('Yes'.tr),
                                        textCancel: Text('No'.tr),
                                      )) {
                                        await widget.chat.delete();
                                        Get.back();
                                      }
                                    }),
                              ],
                          position: PullDownMenuPosition.automatic,
                          applyOpacity: false,
                          buttonBuilder: (context, showMenu) => CircularButton(
                                icon: const Icon(Icons.more_vert),
                                onPressed: showMenu,
                              )),
                    ],
                  ),
                  const SizedBox(
                    height: 4,
                  ),
                  const Divider(
                    height: 1,
                    color: Colors.black12,
                    thickness: 1,
                  ),
                  Expanded(
                      child: NotificationListener<ScrollNotification>(
                    onNotification: (x) {
                      preventEmoji = true;
                      return false;
                    },
                    child: KrPaginateFirestore(
                      key: ValueKey('chat'),
                      physics: const BouncingScrollPhysics(),
                      itemBuilder: (context, docs, i) {
                        MessageModel msg =
                            docs.elementAt(i).data() as MessageModel;
                        msg.markAsSeen();
                        MessageModel? prevMsg;
                        MessageModel? nextMsg;
                        if (docs.length != i + 1) {
                          prevMsg =
                              docs.elementAt(i + 1).data() as MessageModel;
                        }
                        if (i != 0) {
                          nextMsg =
                              docs.elementAt(i - 1).data() as MessageModel;
                        }
                        DateTime? date = msg.sendAt;
                        DateTime? prevDate = prevMsg?.sendAt;
                        bool showTime = false;
                        if (date != null) {
                          DateTime d =
                              DateTime(date.year, date.month, date.day);
                          DateTime prevD = prevDate == null
                              ? DateTime(19000)
                              : DateTime(
                                  prevDate.year, prevDate.month, prevDate.day);
                          showTime = d.toString() != prevD.toString();
                        }
                        return Column(
                          children: [
                            if (showTime)
                              ChatDateWidget(date: date ?? DateTime.now()),
                            Obx(() {
                              return MessageCard(
                                chat: widget.chat,
                                message: msg,
                                textController: controller,
                                user: widget.user,
                                linkedWithBottom: (chat.audios.isNotEmpty &&
                                        i == 0) ||
                                    (nextMsg != null &&
                                        nextMsg.sender == msg.sender &&
                                        nextMsg.sendAt?.day == msg.sendAt?.day),
                                linkedWithTop: !showTime &&
                                    prevMsg != null &&
                                    prevMsg.sender == msg.sender,
                              );
                            }),
                            if (i == 0)
                              Obx(() {
                                return Directionality(
                                  textDirection: TextDirection.rtl,
                                  child: Column(
                                    children: [
                                      ...chat.images.map((element) => Row(
                                            children: [
                                              Container(
                                                margin:
                                                    const EdgeInsetsDirectional
                                                            .only(
                                                        bottom: 4,
                                                        end: 12,
                                                        start: 12),
                                                constraints:
                                                    BoxConstraints.tightFor(
                                                        width: Get.width - 100,
                                                        height:
                                                            Get.width - 100),
                                                decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            12),
                                                    color: Theme.of(context)
                                                        .scaffoldBackgroundColor),
                                                child: Center(
                                                    child: SpinKitRing(
                                                  color: Theme.of(context)
                                                      .primaryColor,
                                                  size: 32,
                                                  lineWidth: 5,
                                                )),
                                              ),
                                            ],
                                          )),
                                      ...List.generate(
                                          chat.audios.length,
                                          (i) => Row(
                                                children: [
                                                  Padding(
                                                    padding:
                                                        const EdgeInsetsDirectional
                                                                .only(
                                                            bottom: 4,
                                                            end: 12,
                                                            start: 12),
                                                    child: Obx(() {
                                                      return MyVoiceMessageBloc(
                                                          linkedWithTop: (i ==
                                                                      0 &&
                                                                  msg.isMine) ||
                                                              i != 0,
                                                          linkedWithBottom: (i !=
                                                              chat.audios
                                                                      .length -
                                                                  1));
                                                    }),
                                                  ),
                                                ],
                                              )),
                                    ],
                                  ),
                                );
                              })
                          ],
                        );
                      },
                      query: chat.messages,
                      onEmpty: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Say Hi'.tr,
                              style: currentTheme.titleStyle,
                            ),
                          ],
                        ),
                      ),
                      header: SliverList(
                          delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          return const SizedBox(
                            height: 5,
                          );
                        },
                        childCount: 1,
                      )),
                      itemBuilderType: PaginateBuilderType.listView,
                      initialLoader: ListView(
                        children: [],
                      ),
                      reverse: true,
                      isLive: true,
                    ),
                  )),
                  Obx(() {
                    name = (widget.chat.editedMessage.value?.isMine ??
                            widget.chat.replyMessage.value?.isMine ??
                            (name == ChatUser.current?.name))
                        ? ChatUser.current!.name
                        : widget.user.name;
                    message = widget.chat.editedMessage.value?.message ??
                        widget.chat.replyMessage.value?.message ??
                        message;
                    icon = widget.chat.replyMessage.value != null
                        ? Icons.reply
                        : widget.chat.editedMessage.value != null
                            ? Icons.edit
                            : icon;
                    return Directionality(
                        textDirection: TextDirection.ltr,
                        child: KrExpandedSection(
                          expand: (widget.chat.editedMessage.value != null ||
                              widget.chat.replyMessage.value != null),
                          onFinish: () {
                            widget.chat.editedMessage.value = null;
                            widget.chat.replyMessage.value = null;
                          },
                          child: Container(
                            width: double.maxFinite,
                            color: Colors.grey.shade300,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 10),
                            child: Row(
                              children: [
                                Icon(icon),
                                const SizedBox(
                                  width: 10,
                                ),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        name,
                                        style: const TextStyle(fontSize: 14),
                                      ),
                                      Text(
                                        message,
                                        style: const TextStyle(
                                            fontSize: 14,
                                            color: Colors.black54),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                                CircularButton(
                                    icon: const Icon(Icons.close),
                                    onPressed: () {
                                      if (widget.chat.editedMessage.value !=
                                          null) {
                                        controller.text = '';
                                      }
                                      widget.chat.editedMessage.value = null;
                                      widget.chat.replyMessage.value = null;
                                    })
                              ],
                            ),
                          ),
                        ));
                  }),
                  Container(
                    color: Colors.grey.shade200,
                    // height: 80,
                    child: SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.only(
                          // bottom: 10,
                          left: 16,
                          right: 16,
                          // top: 10,
                        ),
                        child: Obx(() {
                          return isRecording.value
                              ? AudioRecordWidget(
                                  onClose: () => isRecording.value = false,
                                  chat: widget.chat,
                                )
                              : Row(
                                  children: [
                                    Expanded(
                                      child: TextFormField(
                                        controller: controller,
                                        maxLines: 5,
                                        minLines: 1,
                                        style: TextStyle(
                                            color: Theme.of(context)
                                                .textTheme
                                                .headline1!
                                                .color),
                                        onFieldSubmitted: (x) {
                                          submit(x, chat);
                                          controller.clear();
                                          focus.requestFocus();
                                        },
                                        onChanged: (x) {
                                          isTyping.value = x.isNotEmpty;
                                        },
                                        focusNode: focus,
                                        textInputAction:
                                            TextInputAction.newline,
                                        decoration: InputDecoration(
                                          fillColor: Colors.transparent,
                                          filled: true,
                                          hintText: 'Type a message ......'.tr,
                                          isDense: true,
                                          enabledBorder:
                                              const OutlineInputBorder(
                                            borderRadius: BorderRadius.all(
                                              Radius.circular(30),
                                            ),
                                            borderSide: BorderSide(
                                                color: Colors.transparent),
                                          ),
                                          focusedBorder:
                                              const OutlineInputBorder(
                                            borderRadius: BorderRadius.all(
                                              Radius.circular(30),
                                            ),
                                            borderSide: BorderSide(
                                                color: Colors.transparent),
                                          ),
                                        ),
                                      ),
                                    ),
                                    Container(
                                      decoration: const BoxDecoration(
                                          shape: BoxShape.circle),
                                      margin: const EdgeInsetsDirectional.only(
                                          start: 10),
                                      child: Obx(() {
                                        return isTyping.value
                                            ? CircularButton(
                                                onPressed: () {
                                                  submit(controller.text, chat);
                                                  controller.clear();
                                                },
                                                size: 60,
                                                icon: Padding(
                                                  padding:
                                                      const EdgeInsets.all(3),
                                                  child: Icon(
                                                    Icons.send,
                                                    color: currentTheme.primary,
                                                    size: 26,
                                                  ),
                                                ))
                                            : Row(
                                                children: [
                                                  CircularButton(
                                                      onPressed: () {
                                                        ImageMessage.upload(
                                                            widget.chat);
                                                      },
                                                      size: 60,
                                                      icon: Icon(
                                                        Entypo.attach,
                                                        color: currentTheme
                                                            .subTitleStyle
                                                            .color,
                                                        size: 20,
                                                      )),
                                                  CircularButton(
                                                      onPressed: () =>
                                                          isRecording.value =
                                                              true,
                                                      size: 60,
                                                      icon: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(3),
                                                        child: Icon(
                                                          Icons.mic_none,
                                                          color: currentTheme
                                                              .subTitleStyle
                                                              .color,
                                                          size: 26,
                                                        ),
                                                      )),
                                                ],
                                              );
                                      }),
                                    )
                                  ],
                                );
                        }),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ));
  }
}
