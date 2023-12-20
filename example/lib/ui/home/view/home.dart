import 'package:chatify/chatify.dart';
import 'package:example/theme/app_colors.dart';
import 'package:example/ui/auth/controllers/auth_controller.dart';
import 'package:example/ui/common/image.dart';
import 'package:chatify/src/ui/chats/new_chat/new_chat.dart';
import 'package:example/utilz/extensions.dart';
import 'package:example/utilz/upload_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:flutter_contacts/flutter_contacts.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  static final GlobalKey<ScaffoldState> _key = GlobalKey();

  @override
  Widget build(BuildContext context) {
    final theme = ChatifyThemeData(
      recentChatsBrightness: Brightness.light,
      chatBrightness: Brightness.light,
      primaryColor: AppColors.primary,
    );
    return ChatifyWraper(
      theme: theme,
      child: Scaffold(
        key: _key,
        body: ChatScreen(
          leading: Padding(
            padding: const EdgeInsetsDirectional.only(start: 6),
            child: IconButton(
              onPressed: () {
                _key.currentState?.openDrawer();
              },
              icon: Container(
                decoration: BoxDecoration(
                  color: theme.recentChatsForegroundColor.withOpacity(0.05),
                  shape: BoxShape.circle,
                ),
                padding: EdgeInsets.all(8),
                child: Icon(
                  Iconsax.menu_1,
                  size: 20,
                ),
              ),
            ),
          ),
          actionButton: FutureBuilder<List<Contact>>(
            initialData: [],
            future: FlutterContacts.getContacts(),
            builder: (context, contacts) {
              return IconButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const NewChat(),
                    ),
                  );
                },
                icon: Container(
                  decoration: BoxDecoration(
                    color: theme.recentChatsForegroundColor.withOpacity(0.05),
                    shape: BoxShape.circle,
                  ),
                  padding: EdgeInsets.all(8),
                  child: Icon(
                    Iconsax.message_add_1,
                    size: 20,
                  ),
                ),
              );
            },
          ),
          isCenter: false,
          title: 'Chatify',
        ),
        drawer: Container(
          width: Get.width * 0.8,
          color: Colors.white,
          child: GetBuilder<AuthController>(
            builder: (_) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    color: Colors.grey.shade200,
                    width: double.maxFinite,
                    padding: EdgeInsetsDirectional.only(
                      start: 16,
                      end: 20,
                      bottom: 20,
                      top: 10,
                    ),
                    child: SafeArea(
                      bottom: false,
                      child: Obx(
                        () {
                          String? imageUrl = _.user.value?.image;
                          bool isUploading = false;
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              StatefulBuilder(
                                builder: (context, setState) {
                                  return GestureDetector(
                                    onTap: () async {
                                      setState(() => isUploading = true);
                                      try {
                                        final url = await getPhoto();
                                        _.updateUserInfo(image: url);
                                        FirebaseAuth.instance.currentUser!
                                            .updatePhotoURL(imageUrl);
                                        if (url != null) {
                                          setState(() {
                                            imageUrl = url;
                                          });
                                        }
                                      } finally {
                                        setState(() => isUploading = false);
                                      }
                                    },
                                    child: Stack(
                                      children: [
                                        Container(
                                          height: 90,
                                          width: 90,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: Colors.grey.shade300,
                                          ),
                                          child: imageUrl == null
                                              ? Icon(
                                                  Iconsax.camera,
                                                  size: 32,
                                                )
                                              : CustomImage(
                                                  fit: BoxFit.cover,
                                                  radius: 90,
                                                  url: imageUrl,
                                                  onLoading: SizedBox(),
                                                ),
                                        ),
                                        if (isUploading)
                                          SizedBox(
                                            width: 90,
                                            height: 90,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                            ),
                                          ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                              SizedBox(height: 10),
                              Text(
                                (_.user.value?.firstName ?? '') +
                                    ' ' +
                                    (_.user.value?.lastName ?? ''),
                                style: TextStyle(
                                  fontSize: 16,
                                ),
                              ),
                              Text(
                                _.user.value?.phone?.phoneLocally ?? '',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  Column(
                    children: [
                      DrawerButton(
                        text: 'Contacts',
                        icon: Iconsax.user,
                        onPressed: () {},
                      ),
                      DrawerButton(
                        text: 'Invite Friends',
                        icon: Iconsax.share,
                        onPressed: () {},
                      ),
                      DrawerButton(
                        text: 'Settings',
                        icon: Iconsax.setting_2,
                        onPressed: () {},
                      ),
                      DrawerButton(
                        text: 'Terms and condition',
                        icon: Iconsax.document,
                        onPressed: () {},
                      ),
                      DrawerButton(
                        text: 'Logout',
                        icon: Iconsax.logout,
                        onPressed: _.logOut,
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class DrawerButton extends StatelessWidget {
  const DrawerButton({
    super.key,
    required this.text,
    required this.icon,
    required this.onPressed,
  });

  final String text;
  final IconData icon;
  final Function() onPressed;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        foregroundColor: Colors.black,
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: Colors.grey.shade600,
          ),
          SizedBox(width: 20),
          Text(text),
        ],
      ),
    );
  }
}
