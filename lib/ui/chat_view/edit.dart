import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:chatify/models/message.dart';

class EditMessage extends StatelessWidget {
  const EditMessage(
      {Key? key,
      required this.message,
      required this.offset,
      required this.card})
      : super(key: key);
  final Offset offset;
  final MessageModel message;
  final Widget card;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          left: offset.dx,
          top: offset.dy - 45,
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
            child: Material(
              color: Colors.transparent,
              elevation: 0,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 5),
                    child: Row(
                      children: [
                        TextButton(
                            onPressed: () {
                              // message.delete();
                              Get.back();
                            },
                            style: TextButton.styleFrom(
                                minimumSize: const Size(0, 0),
                                fixedSize: const Size(40, 40),
                                backgroundColor: Theme.of(context)
                                    .backgroundColor
                                    .withOpacity(0.1),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12))),
                            child: Icon(
                              Iconsax.message_remove,
                              color: Theme.of(context).primaryColor,
                              size: 16,
                            )),
                        // Padding(
                        //   padding: const EdgeInsetsDirectional.only(start: 5),
                        //   child: TextButton(
                        //       onPressed: (){
                        //         Get.back();
                        //       },
                        //       style: TextButton.styleFrom(
                        //           minimumSize: const Size(0,0),
                        //           fixedSize: const Size(40, 40),
                        //           padding: EdgeInsets.zero,
                        //           backgroundColor: Theme.of(context).backgroundColor.withOpacity(0.1),
                        //           shape: RoundedRectangleBorder(
                        //               borderRadius: BorderRadius.circular(12)
                        //           )
                        //       ),
                        //       child: Icon(Iconsax.edit, color: Theme.of(context).backgroundColor, size: 16,)
                        //   ),
                        // )
                      ],
                    ),
                  ),
                  card,
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
