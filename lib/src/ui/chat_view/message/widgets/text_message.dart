import 'package:any_link_preview/any_link_preview.dart';
import 'package:chatify/chatify.dart';
import 'package:chatify/src/ui/chat_view/message/message_card.dart';
import 'package:chatify/src/ui/common/circular_loading.dart';
import 'package:chatify/src/ui/chat_view/controllers/chat_controller.dart';
import 'package:chatify/src/ui/chat_view/message/widgets/bubble.dart';
import 'package:chatify/src/ui/chat_view/message/widgets/send_at.dart';
import 'package:chatify/src/ui/common/kr_builder.dart';
import 'package:chatify/src/utils/extensions.dart';
import 'package:flutter/material.dart';

class TextMessageCard extends StatefulWidget {
  const TextMessageCard({
    super.key,
    required this.widget,
    required this.bkColor,
    required this.textColor,
    required this.controller,
    required this.isMine,
    required this.isSending,
  });

  final Color bkColor;
  final Color textColor;
  final bool isMine;
  final MessageCard widget;
  final ChatController controller;
  final bool isSending;

  @override
  State<TextMessageCard> createState() => _TextMessageCardState();
}

class _TextMessageCardState extends State<TextMessageCard> {
  Message? repliedMsg;

  @override
  Widget build(BuildContext context) {
    final hasLink = widget.widget.message.message.urls.length > 1;
    final mergeWithSendAt = widget.widget.message.message.length < 35 &&
        !widget.widget.message.message.contains('\n') &&
        !hasLink;
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Stack(
        alignment: AlignmentDirectional.bottomEnd,
        children: [
          Padding(
            padding: EdgeInsets.only(
              bottom: widget.widget.message.emojis.isEmpty ? 0 : 14,
            ),
            child: MyBubble(
              message: widget.widget.message,
              bkColor: widget.bkColor,
              linkedWithBottom: widget.widget.linkedWithBottom,
              linkedWithTop: widget.widget.linkedWithTop,
              child: Padding(
                padding: EdgeInsets.only(
                  right: 12,
                  left: 12,
                  top: 6,
                  bottom: 6,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (widget.widget.message.replyId != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 5),
                        child: SizedBox(
                          height: 37,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                height: 27,
                                width: 2,
                                decoration: BoxDecoration(
                                  color: widget.isMine
                                      ? Colors.white70
                                      : Chatify.theme.primaryColor,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                              const SizedBox(
                                width: 10,
                              ),
                              Flexible(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      widget.widget.message.replyUid ==
                                              Chatify.currentUserId
                                          ? 'Me'
                                          : widget.widget.user.name,
                                      style: TextStyle(
                                        color:
                                            widget.textColor.withOpacity(0.8),
                                        fontSize: 14,
                                      ),
                                    ),
                                    Expanded(
                                      child: repliedMsg != null
                                          ? Text(
                                              repliedMsg?.message ?? '',
                                              style: TextStyle(
                                                color: widget.textColor
                                                    .withOpacity(0.8),
                                                fontSize: 12,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            )
                                          : KrFutureBuilder<Message?>(
                                              future: Chatify.datasource
                                                  .readMessage(
                                                widget.widget.message.replyId!,
                                              ),
                                              onEmpty: Text(
                                                'An error occured!',
                                                style: TextStyle(
                                                  color: widget.textColor
                                                      .withOpacity(0.8),
                                                  fontSize: 12,
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              onError: (_) => Text(
                                                'An error occured!',
                                                style: TextStyle(
                                                  color: widget.textColor
                                                      .withOpacity(0.8),
                                                  fontSize: 12,
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              onLoading: SizedBox(
                                                width: 20,
                                                child: Center(
                                                  child: LoadingWidget(
                                                    size: 10,
                                                    lineWidth: 1,
                                                    color: widget.isMine
                                                        ? Colors.white
                                                        : Chatify
                                                            .theme.primaryColor,
                                                  ),
                                                ),
                                              ),
                                              builder: (message) {
                                                repliedMsg = message;
                                                return Text(
                                                  message?.message ?? '',
                                                  style: TextStyle(
                                                    color: widget.textColor
                                                        .withOpacity(0.8),
                                                    fontSize: 12,
                                                  ),
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                );
                                              },
                                            ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Flexible(
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 2),
                            child: Wrap(
                              children: widget.widget.message.message.urls
                                  .map(
                                    (e) => Text(
                                      e,
                                      textAlign: TextAlign.right,
                                      style: TextStyle(
                                        decoration: e.isURL
                                            ? TextDecoration.underline
                                            : null,
                                        decorationColor: widget.textColor,
                                        color: widget.textColor,
                                      ),
                                    ),
                                  )
                                  .toList(),
                            ),
                          ),
                        ),
                        if (mergeWithSendAt)
                          SendAtWidget(
                            message: widget.widget.message,
                            isSending: widget.isSending,
                          ),
                      ],
                    ),
                    if (hasLink)
                      Stack(
                        children: [
                          Positioned.fill(
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: LayoutBuilder(
                                builder: (context, size) {
                                  return Container(
                                    width: 2,
                                    margin: EdgeInsetsDirectional.symmetric(
                                      vertical: size.maxHeight > 20 ? 10 : 0,
                                    ),
                                    color: widget.textColor,
                                  );
                                },
                              ),
                            ),
                          ),
                          Padding(
                            padding:
                                const EdgeInsetsDirectional.only(start: 10),
                            child: AnyLinkPreview(
                              link: widget.widget.message.message.urls
                                  .firstWhere((e) => e.isURL)
                                  .urlFormat,
                              displayDirection: UIDirection.uiDirectionVertical,
                              showMultimedia: true,
                              bodyMaxLines: 5,
                              bodyTextOverflow: TextOverflow.ellipsis,
                              titleStyle: TextStyle(
                                color: widget.textColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                              bodyStyle: TextStyle(
                                color: widget.textColor.withOpacity(0.8),
                                fontSize: 12,
                              ),
                              errorWidget: SizedBox.shrink(),
                              placeholderWidget: SizedBox.shrink(),
                              cache: Duration(days: 360),
                              backgroundColor: Colors.transparent,
                              removeElevation: true,
                              previewHeight: 200,
                            ),
                          ),
                        ],
                      ),
                    if (!mergeWithSendAt)
                      SendAtWidget(
                        message: widget.widget.message,
                        isSending: widget.isSending,
                      ),
                  ],
                ),
              ),
            ),
          ),
          if (widget.widget.message.emojis.isNotEmpty)
            Container(
              margin: const EdgeInsetsDirectional.only(end: 10),
              padding: const EdgeInsets.all(1),
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                decoration: BoxDecoration(
                  color: widget.bkColor.withOpacity(widget.isMine ? 0.2 : 1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: widget.widget.message.emojis
                      .map(
                        (e) => Text(
                          e.emoji,
                          style: const TextStyle(height: 1.3),
                        ),
                      )
                      .toList(),
                ),
              ),
            )
        ],
      ),
    );
  }
}
