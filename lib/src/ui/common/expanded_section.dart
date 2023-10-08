import 'package:flutter/material.dart';

class KrExpandedSection extends StatefulWidget {
  final Widget child;
  final bool expand;
  final Function? onFinish;
  const KrExpandedSection({
    Key? key,
    this.expand = false,
    required this.child,
    this.onFinish,
  }) : super(key: key);

  @override
  State<KrExpandedSection> createState() => _KrExpandedSectionState();
}

class _KrExpandedSectionState extends State<KrExpandedSection>
    with SingleTickerProviderStateMixin {
  late AnimationController expandController;
  late Animation<double> animation;
  @override
  void initState() {
    super.initState();
    prepareAnimations();
    _runExpandCheck(false);
  }

  ///Setting up the animation
  void prepareAnimations() {
    expandController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    animation = CurvedAnimation(
      parent: expandController,
      curve: Curves.fastOutSlowIn,
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
  void didUpdateWidget(KrExpandedSection oldWidget) {
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
      axisAlignment: 1.0,
      sizeFactor: animation,
      child: widget.child,
    );
  }
}
