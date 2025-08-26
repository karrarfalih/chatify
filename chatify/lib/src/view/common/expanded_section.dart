import 'package:flutter/material.dart';

class ExpandedSection extends StatefulWidget {
  final Widget child;
  final bool expand;
  final Function? onFinish;
  final Duration? duration;
  final Axis axis;
  final bool reverse;

  const ExpandedSection({
    super.key,
    this.expand = false,
    required this.child,
    this.onFinish,
    this.duration,
    this.axis = Axis.vertical,
    this.reverse = false,
  });

  @override
  State<ExpandedSection> createState() => _ExpandedSectionState();
}

class _ExpandedSectionState extends State<ExpandedSection>
    with SingleTickerProviderStateMixin {
  late AnimationController expandController;
  late Animation<double> animation;
  @override
  void initState() {
    super.initState();
    prepareAnimations();
    _runExpandCheck(false);
  }

  void prepareAnimations() {
    expandController = AnimationController(
      vsync: this,
      duration: widget.duration ?? const Duration(milliseconds: 300),
    );
    animation = CurvedAnimation(
      parent: expandController,
      curve: Curves.easeInOut,
    );
  }

  void _runExpandCheck(bool check) {
    if (widget.expand) {
      expandController.forward();
    } else {
      expandController.reverse().then((value) {
        if (check && widget.onFinish != null) widget.onFinish!();
      });
    }
  }

  @override
  void didUpdateWidget(ExpandedSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    _runExpandCheck(oldWidget.expand);
  }

  @override
  void dispose() {
    expandController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizeTransition(
      axis: widget.axis,
      axisAlignment: widget.reverse ? -1.0 : 1.0,
      sizeFactor: animation,
      child: widget.child,
    );
  }
}
