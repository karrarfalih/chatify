import 'package:chat/assets/image.dart';
import 'package:chat/models/theme.dart';
import 'package:chat/models/user.dart';
import 'package:chat/ui/common/bloc.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kr_builder/future_builder.dart';
import 'package:shimmer/shimmer.dart';

class UserAvatar extends StatelessWidget {
  const UserAvatar({
    Key? key,
    this.onTap,
    this.height,
    this.width,
    required this.uid,
    this.subTitle,
  }) : super(key: key);

  final double? height;
  final double? width;
  final String uid;
  final String? subTitle;
  final Function(ChatUser)? onTap;

  static Widget loading({
    double? height,
    double? width,
  }) =>
      Shimmer.fromColors(
          baseColor: Colors.grey.withOpacity(0.2),
          highlightColor: Colors.grey.withOpacity(0.4),
          enabled: true,
          child: UserAvatarLoading(
            height: height,
            width: width,
          ));

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      child: KrFutureBuilder<ChatUser?>(
          future: ChatUser.getById(uid),
          onLoading: loading(height: height, width: width),
          builder: (user) {
            return InkWell(
              onTap: () async {
                if (onTap != null) onTap!(user);
              },
              highlightColor: Colors.transparent,
              hoverColor: Colors.transparent,
              overlayColor: MaterialStateProperty.all(Colors.transparent),
              child: Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  MyImage(
                      url: user!.profileImage,
                      height: height ?? 40,
                      width: width ?? 40,
                      onError: const Icon(
                        Icons.person,
                        color: Colors.grey,
                      )),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Text(
                          user.name,
                          maxLines: 1,
                          style: currentTheme.titleStyle,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (subTitle != null || user.uid != null)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: Text((subTitle ??('@${user.uid!}')).tr,
                              style: currentTheme.subTitleStyle),
                        ),
                    ],
                  )
                ],
              ),
            );
          }),
    );
  }
}

class UserAvatarLoading extends StatelessWidget {
  const UserAvatarLoading({
    Key? key,
    this.height,
    this.width,
  }) : super(key: key);

  final double? height;
  final double? width;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        MyBlock(
          height: height ?? 40,
          width: width ?? 40,
          radius: 50,
        ),
        const SizedBox(
          width: 10,
        ),
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            MyBlock(height: 15, width: 100, radius: 20, space: 5),
            MyBlock(height: 12, width: 60, radius: 20),
          ],
        ),
        const SizedBox(
          width: 10,
        ),
      ],
    );
  }
}
