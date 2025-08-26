import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';

class OptionsBuilder extends StatefulWidget {
  const OptionsBuilder({
    super.key,
    required this.builder,
    required this.options,
    this.topWidget,
    this.onCanceled,
    this.applyOpacity = true,
    this.onShow,
  });

  final Widget Function(VoidCallback showOptions) builder;
  final List<OptionsItem> options;
  final Widget? topWidget;
  final VoidCallback? onCanceled;
  final bool applyOpacity;
  final Function(bool isShown)? onShow;

  @override
  State<OptionsBuilder> createState() => _OptionsBuilderState();
}

class _OptionsBuilderState extends State<OptionsBuilder> {
  bool isPressed = false;

  void _showOptions() async {
    if (widget.options.isEmpty) return;
    widget.onShow?.call(true);

    setState(() => isPressed = true);

    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    final position = renderBox.localToGlobal(Offset.zero);

    final result = await showDialog<OptionsItem>(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.transparent,
      builder: (context) => _OptionsDialog(
        position: position,
        size: renderBox.size,
        options: widget.options,
        topWidget: widget.topWidget,
      ),
    );

    widget.onShow?.call(false);
    if (!mounted) return;

    setState(() => isPressed = false);

    if (result != null) {
      result.onSelect?.call();
    } else {
      widget.onCanceled?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    final childWidget = widget.builder(_showOptions);

    if (!widget.applyOpacity) return childWidget;

    return AnimatedOpacity(
      opacity: isPressed ? 0.4 : 1.0,
      duration: const Duration(milliseconds: 150),
      child: childWidget,
    );
  }
}

class OptionsItem {
  const OptionsItem({
    required this.title,
    this.icon,
    this.iconColor,
    this.isDestructive = false,
    this.onSelect,
  });

  final String title;

  final IconData? icon;

  final Color? iconColor;

  final bool isDestructive;

  final VoidCallback? onSelect;
}

class _OptionsDialog extends StatelessWidget {
  const _OptionsDialog({
    required this.position,
    required this.size,
    required this.options,
    this.topWidget,
  });

  final Offset position;
  final Size size;
  final List<OptionsItem> options;
  final Widget? topWidget;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: GestureDetector(
        onTap: () => Navigator.of(context).pop(),
        child: Container(
          color: Colors.transparent,
          child: Stack(
            children: [
              Positioned(
                left: position.dx.clamp(0, Get.width - 230),
                top: (position.dy - (_estimateMenuHeight() / 2))
                    .clamp(0, Get.height - _estimateMenuHeight()),
                child: _OptionsMenu(
                  options: options,
                  topWidget: topWidget,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  double _estimateMenuHeight() {
    const optionHeight = 44.0;
    const topWidgetHeight = 40.0;

    double totalHeight = options.length * optionHeight;

    if (topWidget != null) {
      totalHeight += topWidgetHeight;
    }

    totalHeight += 20;

    return totalHeight;
  }
}

class _OptionsMenu extends StatelessWidget {
  const _OptionsMenu({
    required this.options,
    this.topWidget,
  });

  final List<OptionsItem> options;
  final Widget? topWidget;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 250),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (topWidget != null) ...[
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                ),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 10,
                      spreadRadius: 0,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: topWidget!,
              ),
              const SizedBox(height: 8),
            ],
            DecoratedBox(
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 10,
                    spreadRadius: 0,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: IntrinsicWidth(
                child: Column(
                  children: options
                      .map((option) => _OptionsMenuItem(
                            option: option,
                            onTap: () {
                              Navigator.of(context).pop(option);
                            },
                          ))
                      .toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OptionsMenuItem extends StatelessWidget {
  const _OptionsMenuItem({
    required this.option,
    required this.onTap,
  });

  final OptionsItem option;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDestructive = option.isDestructive;

    return Material(
      color: Colors.transparent,
      child: SizedBox(
        height: 44,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              mainAxisSize: MainAxisSize.max,
              children: [
                if (option.icon != null) ...[
                  Icon(
                    option.icon,
                    size: 18,
                    color: option.iconColor ??
                        (isDestructive
                            ? Colors.red
                            : theme.colorScheme.onSurface),
                  ),
                  const SizedBox(width: 12),
                ],
                Text(
                  option.title,
                  style: TextStyle(
                    fontSize: 14,
                    color: isDestructive
                        ? Colors.red
                        : theme.colorScheme.onSurface,
                    fontWeight:
                        isDestructive ? FontWeight.w500 : FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
