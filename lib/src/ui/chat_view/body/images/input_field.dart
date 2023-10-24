import 'dart:ui';

import 'package:chatify/src/core/chatify.dart';
import 'package:chatify/src/ui/chat_view/body/images/controller.dart';
import 'package:chatify/src/ui/chat_view/controllers/chat_controller.dart';
import 'package:chatify/src/utils/value_notifiers.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:photo_gallery/photo_gallery.dart';

class GalleryInputField extends StatefulWidget {
  const GalleryInputField({
    super.key,
    required this.controller,
    this.isSubmit = true,
    required this.chatController,
  });

  final GalleryController controller;
  final ChatController chatController;
  final bool isSubmit;

  @override
  State<GalleryInputField> createState() => _GalleryInputFieldState();
}

class _GalleryInputFieldState extends State<GalleryInputField> {
  final isSubmit = false.obs;

  @override
  void dispose() {
    isSubmit.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: ValueListenableBuilder<List<Medium>>(
          valueListenable: widget.controller.selected,
          builder: (context, images, child) {
            if (images.isEmpty) return SizedBox.shrink();
            return Align(
              key: ValueKey('image_send_bottom_bar'),
              alignment: Alignment.bottomCenter,
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(30),
                          child: Stack(
                            alignment: Alignment.bottomCenter,
                            children: [
                              Positioned.fill(
                                child: IgnorePointer(
                                  child: BackdropFilter(
                                    filter: ImageFilter.blur(
                                      sigmaX: 5,
                                      sigmaY: 5,
                                    ),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: Colors.transparent,
                                        borderRadius: BorderRadius.circular(
                                          30,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Focus(
                                onFocusChange: (x) {
                                  if (!widget.isSubmit) return;
                                  isSubmit.value = x;
                                },
                                // focusNode: textFocus,
                                child: TextField(
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.white,
                                  ),
                                  onTapOutside: (event) =>
                                      FocusScope.of(context).unfocus(),
                                  maxLines: 8,
                                  minLines: 1,
                                  decoration: InputDecoration(
                                    hintText: 'Add caption',
                                    hintStyle: TextStyle(
                                      fontSize: 16,
                                      color: Colors.white54,
                                    ),
                                    fillColor:
                                        Color(0xff666666).withOpacity(0.6),
                                    filled: true,
                                    isDense: true,
                                    contentPadding: EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 12,
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(
                                        30,
                                      ),
                                      borderSide: BorderSide(
                                        width: 0,
                                        color: Colors.transparent,
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(
                                        30,
                                      ),
                                      borderSide: BorderSide(
                                        width: 0,
                                        color: Colors.transparent,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      TextButton(
                        style: TextButton.styleFrom(
                          backgroundColor: Chatify.theme.primaryColor,
                          minimumSize: Size.zero,
                          padding: EdgeInsets.all(10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        onPressed: () {
                          if (!isSubmit.value) {
                            widget.chatController.sendImages(
                              widget.controller.selected.value,
                            );
                            Navigator.of(context).pop();
                          }
                        },
                        child: ValueListenableBuilder<bool>(
                          valueListenable: isSubmit,
                          builder: (context, isSubmit, child) {
                            return Icon(
                              isSubmit ? Icons.check : Iconsax.send_1,
                              color: Colors.white,
                            );
                          },
                        ),
                      )
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
