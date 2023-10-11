// Copyright 2014 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

/// A sliver widget that paints a [Decoration] either before or after its child
/// paints.
///
/// Unlike [DecoratedBox], this widget expects its child to be a sliver, and
/// must be placed in a widget that expects a sliver.
///
/// If the child sliver has infinite [SliverGeometry.scrollExtent], then we only
/// draw the decoration down to the bottom [SliverGeometry.cacheExtent], and
/// it is necessary to ensure that the bottom border does not creep
/// above the top of the bottom cache. This can happen if the bottom has a
/// border radius larger than the extent of the cache area.
///
/// Commonly used with [BoxDecoration].
///
/// The [child] is not clipped. To clip a child to the shape of a particular
/// [ShapeDecoration], consider using a [ClipPath] widget.
///
/// {@tool dartpad}
/// This sample shows a radial gradient that draws a moon on a night sky:
///
/// ** See code in examples/api/lib/widgets/sliver/decorated_sliver.0.dart **
/// {@end-tool}
///
/// See also:
///
///  * [DecoratedBox], the version of this class that works with RenderBox widgets.
///  * [Decoration], which you can extend to provide other effects with
///    [DecoratedSliver].
///  * [CustomPaint], another way to draw custom effects from the widget layer.
class DecoratedSliver extends SingleChildRenderObjectWidget {
  /// Creates a widget that paints a [Decoration].
  ///
  /// The [decoration] and [position] arguments must not be null. By default the
  /// decoration paints behind the child.
  const DecoratedSliver({
    super.key,
    required this.decoration,
    this.position = DecorationPosition.background,
    Widget? sliver,
  }) : super(child: sliver);

  /// What decoration to paint.
  ///
  /// Commonly a [BoxDecoration].
  final Decoration decoration;

  /// Whether to paint the box decoration behind or in front of the child.
  final DecorationPosition position;

  @override
  RenderDecoratedSliver createRenderObject(BuildContext context) {
    return RenderDecoratedSliver(
      decoration: decoration,
      position: position,
      configuration: createLocalImageConfiguration(context),
    );
  }

  @override
  void updateRenderObject(
    BuildContext context,
    RenderDecoratedSliver renderObject,
  ) {
    renderObject
      ..decoration = decoration
      ..position = position
      ..configuration = createLocalImageConfiguration(context);
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    final String label;
    switch (position) {
      case DecorationPosition.background:
        label = 'bg';
        break;
      case DecorationPosition.foreground:
        label = 'fg';
    }
    properties.add(
      EnumProperty<DecorationPosition>(
        'position',
        position,
        level: DiagnosticLevel.hidden,
      ),
    );
    properties.add(DiagnosticsProperty<Decoration>(label, decoration));
  }
}

/// Paints a [Decoration] either before or after its child paints.
///
/// If the child has infinite scroll extent, then the [Decoration] paints itself up to the
/// bottom cache extent.
class RenderDecoratedSliver extends RenderProxySliver {
  /// Creates a decorated sliver.
  ///
  /// The [decoration], [position], and [configuration] arguments must not be
  /// null. By default the decoration paints behind the child.
  ///
  /// The [ImageConfiguration] will be passed to the decoration (with the size
  /// filled in) to let it resolve images.
  RenderDecoratedSliver({
    required Decoration decoration,
    DecorationPosition position = DecorationPosition.background,
    ImageConfiguration configuration = ImageConfiguration.empty,
  })  : _decoration = decoration,
        _position = position,
        _configuration = configuration;

  /// What decoration to paint.
  ///
  /// Commonly a [BoxDecoration].
  Decoration get decoration => _decoration;
  Decoration _decoration;
  set decoration(Decoration value) {
    if (value == decoration) {
      return;
    }
    _decoration = value;
    _painter?.dispose();
    _painter = decoration.createBoxPainter(markNeedsPaint);
    markNeedsPaint();
  }

  /// Whether to paint the box decoration behind or in front of the child.
  DecorationPosition get position => _position;
  DecorationPosition _position;
  set position(DecorationPosition value) {
    if (value == position) {
      return;
    }
    _position = value;
    markNeedsPaint();
  }

  /// The settings to pass to the decoration when painting, so that it can
  /// resolve images appropriately. See [ImageProvider.resolve] and
  /// [BoxPainter.paint].
  ///
  /// The [ImageConfiguration.textDirection] field is also used by
  /// direction-sensitive [Decoration]s for painting and hit-testing.
  ImageConfiguration get configuration => _configuration;
  ImageConfiguration _configuration;
  set configuration(ImageConfiguration value) {
    if (value == configuration) {
      return;
    }
    _configuration = value;
    markNeedsPaint();
  }

  BoxPainter? _painter;

  @override
  void attach(covariant PipelineOwner owner) {
    _painter = decoration.createBoxPainter(markNeedsPaint);
    super.attach(owner);
  }

  @override
  void detach() {
    _painter?.dispose();
    _painter = null;
    super.detach();
  }

  @override
  void dispose() {
    _painter?.dispose();
    _painter = null;
    super.dispose();
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    if (child != null && child!.geometry!.visible) {
      final SliverPhysicalParentData childParentData =
          child!.parentData! as SliverPhysicalParentData;
      final Size childSize;
      final Offset scrollOffset;

      // In the case where the child sliver has infinite scroll extent, the decoration
      // should only extend down to the bottom cache extent.
      final double cappedMainAxisExtent =
          child!.geometry!.scrollExtent.isInfinite
              ? constraints.scrollOffset +
                  child!.geometry!.cacheExtent +
                  constraints.cacheOrigin
              : child!.geometry!.scrollExtent;
      switch (constraints.axis) {
        case Axis.vertical:
          childSize = Size(constraints.crossAxisExtent, cappedMainAxisExtent);
          scrollOffset = Offset(0.0, -constraints.scrollOffset);
          break;
        case Axis.horizontal:
          childSize = Size(cappedMainAxisExtent, constraints.crossAxisExtent);
          scrollOffset = Offset(-constraints.scrollOffset, 0.0);
      }
      final Offset childOffset = offset + childParentData.paintOffset;
      if (position == DecorationPosition.background) {
        _painter!.paint(
          context.canvas,
          childOffset + scrollOffset,
          configuration.copyWith(size: childSize),
        );
      }
      context.paintChild(child!, childOffset);
      if (position == DecorationPosition.foreground) {
        _painter!.paint(
          context.canvas,
          childOffset + scrollOffset,
          configuration.copyWith(size: childSize),
        );
      }
    }
  }
}
