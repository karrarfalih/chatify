import 'package:chatify/src/theme/theme_widget.dart';
import 'package:chatify/src/ui/common/circular_loading.dart';
import 'package:chatify/src/ui/common/shimmer_bloc.dart';
import 'package:flutter/material.dart';
import 'package:optimized_cached_image/optimized_cached_image.dart';

const _kImageMaxWidthCache = 1000;

class CustomImage extends StatelessWidget {
  const CustomImage(
    {
    Key? key,
    this.url,
    this.radius,
    this.onEmptyOrNull,
    this.onLoading,
    this.onError,
    this.width,
    this.height,
    this.padding,
    this.fit,
    this.onTap,
    this.loadingRadius,
    this.shimmerSize,
    this.borderRadius,
  }) : super(key: key);

  final String? url;
  final String? onEmptyOrNull;
  final double? radius;
  final double? loadingRadius;
  final Widget? onLoading;
  final Widget? onError;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final BoxFit? fit;
  final Size? shimmerSize;
  final Function()? onTap;
  final BorderRadiusGeometry? borderRadius;

  @override
  Widget build(BuildContext context) {
    if ((url == null || url!.isEmpty) && (onEmptyOrNull == null || onEmptyOrNull!.isEmpty)) {
      return Padding(
        padding: padding ?? EdgeInsets.zero,
        child: const Center(child: ErrorImage()),
      );
    }
    Widget image = SizedBox(
      width: width,
      height: height,
      child: OptimizedCacheImage(
        imageUrl: url != null && url!.isNotEmpty ? url! : onEmptyOrNull ?? '',
        placeholder: (context, url) => _onLoading(context),
        errorWidget: (context, url, error) {
          return Center(child: onError ?? const ErrorImage());
        },
        memCacheWidth: _kImageMaxWidthCache,
        maxWidthDiskCache: _kImageMaxWidthCache,
        fit: fit,
      ),
    );
    if (onTap != null) {
      image = InkWell(
        onTap: onTap,
        child: image,
      );
    }
    if (radius != null) {
      image = ClipRRect(
        borderRadius: borderRadius ?? BorderRadius.circular(radius!),
        child: image,
      );
    }
    return Padding(
      padding: padding ?? EdgeInsets.zero,
      child: image,
    );
  }

  Size? get _size =>
      shimmerSize ??
      (width != null && height != null ? Size(width!, height!) : null);

  Widget _onLoading(BuildContext context) {
    if (onLoading != null) return onLoading!;
    if (_size == null) {
      return Center(
        child: LoadingWidget(
          color: ChatifyTheme.of(context).primaryColor,
          size: 40,
          lineWidth: 4,
        ),
      );
    }
    return ShimmerBloc(
      size: _size!,
      radius: loadingRadius ?? radius ?? 0,
      borderRadius: borderRadius,
    );
  }
}

class ErrorImage extends StatelessWidget {
  const ErrorImage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Icon(
      Icons.error_outline,
      color: Colors.grey,
      size: 40,
    );
  }
}
