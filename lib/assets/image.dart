import 'dart:typed_data';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class MyImage extends StatelessWidget {
  const MyImage(
      {super.key,
      this.url,
      this.width,
      this.height,
      this.fit,
      this.onError,
      this.isCircle = true,
      this.onPressed,
      this.bytes,
      this.radius});

  final double? width, height;
  final BoxFit? fit;
  final String? url;
  final Uint8List? bytes;
  final Widget? onError;
  final bool isCircle;
  final Function()? onPressed;
  final double? radius;

  @override
  Widget build(BuildContext context) {
    Widget child;
    Widget image = _errorWidget;
    if (bytes != null) {
      image = Image.memory(
        bytes!,
        key: key,
        width: width,
        height: height,
        fit: fit,
        errorBuilder:
            (BuildContext context, Object exception, StackTrace? stackTrace) {
          return _errorWidget;
        },
      );
    } else if (url != null) {
      image = _cachedWidget(url!);
    }
    child = Stack(
      children: [
        Container(
          color: Colors.grey.shade200,
          height: height ?? 0,
          width: width ?? 0,
        ),
        if ((url != null && url!.isNotEmpty) || bytes != null) image
      ],
    );
    if (!((url != null && url!.isNotEmpty) || bytes != null)) {
      child = _errorWidget;
    }
    if (isCircle || radius != null) {
      child = ClipRRect(
        borderRadius: BorderRadius.circular(radius ?? height ?? 200),
        child: child,
      );
    }
    if (onPressed != null) {
      child = InkWell(
        onTap: onPressed!,
        child: child,
      );
    }
    return child;
  }

  Widget get _errorWidget => Container(
        color: Colors.grey.shade200,
        height: height,
        width: width,
        child: Center(
          child: onError ?? const Icon(Icons.error),
        ),
      );
  Widget _cachedWidget(String url) => CachedNetworkImage(
        imageUrl: url,
        key: key,
        width: width,
        height: height,
        fit: fit,
        errorWidget: (BuildContext context, Object exception, stackTrace) {
          return _errorWidget;
        },
        progressIndicatorBuilder: (BuildContext context, String child,
            DownloadProgress loadingProgress) {
          return _loadingWidget;
        },
      );

  Widget get _loadingWidget => Shimmer.fromColors(
        baseColor: Colors.grey.withOpacity(0.2),
        highlightColor: Colors.grey.withOpacity(0.4),
        enabled: true,
        child: Container(
          color: Colors.grey.withOpacity(0.4),
          width: width,
          height: height,
        ),
      );
}
