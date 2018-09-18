library highlighter_coachmark;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/animation.dart';

import 'dart:async';
import 'dart:ui' as ui;

/// CoachMark blurs background of the whole screen and highlights target element.
/// It does this in Overlay. So the whole screen is covered by CoachMark's layer.
/// Methods [show] and [close] insert and remove coachMark's layer from the screen.
/// Tap anywhere on the screen closes CoachMark and calls callback [onClose].
/// Even tap (any touch down) on the target element closes CoachMark. So it should
/// work with any gesture for target element.
/// Hints, usage explanations are provided by [children] Widgets. Internally they
/// are children of Stack. So it can be Positioned widgets.
/// If [duration] is provided then CoachMark automatically closes after
/// the given [duration] has passed. There is no difference for [close] -
/// was is close by timer or by user's touch.
///
/// ```dart
///  CoachMark coachMark = CoachMark();
///  RenderBox target = targetGlobalKey.currentContext.findRenderObject();
///  Rect markRect = target.localToGlobal(Offset.zero) & target.size;
///  markRect = Rect.fromCircle(center: markRect.center, radius: markRect.longestSide * 0.6);
///  coachMark.show(
///      targetContext: targetGlobalKey.currentContext,
///      markRect: markRect,
///      children: [
///        Positioned(
///            top: markRect.top + 5.0,
///            right: 10.0,
///            child: Text("Long tap on button to see options",
///                style: const TextStyle(
///                  fontSize: 24.0,
///                  fontStyle: FontStyle.italic,
///                  color: Colors.white,
///                )))
///      ],
///      duration: null,
///      onClose: () {
///         appState.setCoachMarkIsShown(true);
///      });
/// ```
class CoachMark {

  CoachMark({this.bgColor = const Color(0xB2212121)});

  /// Global key to get an access for CoachMark's State
  GlobalKey<_HighlighterCoachMarkState> globalKey;

  /// Background color
  Color bgColor;

  /// State visibility of CoachMark
  bool _isVisible = false;

  /// Returns is CoachMark is visible at the moment
  bool get isVisible => _isVisible;

  /// Called when CoachMark is closed
  VoidCallback _onClose;

  /// Contains OverlayEntry with CoachMark's Widget
  OverlayEntry _overlayEntryBackground;

  /// Brings out CoachMark's widget with animation on the whole screen
  ///
  /// [targetContext] is a context for target element, for which CoachMark is needed
  ///
  /// [children] are children of Stack, they are hints and usage explanation
  ///
  /// [marcRect] is Rect for highlighted area. Usually is should be a bit bigger than
  /// Rect of target element. It can be achieved like this:
  /// ```dart
  /// Rect markRect = targetRenderBox.localToGlobal(Offset.zero) & target.size;
  /// var circleMarkRect = Rect.fromCircle(center: markRect.center, radius: markRect.longestSide * 0.6);
  /// //or like this
  /// var rectangleMarkRect = markRect.inflate(5.0);
  /// ```
  /// [markShape] is shape of highlighted area
  ///
  /// [duration] if provided then after it passes CoachMark is closed automatically
  ///
  /// Callback [onClose] is called when CoachMark is closed
  void show({
    @required BuildContext targetContext,
    @required List<Widget> children,
    @required Rect markRect,
    BoxShape markShape = BoxShape.circle,
    Duration duration,
    VoidCallback onClose,
  }) async {
    // Prevent from showing multiple marks at the same time
    if (_isVisible) {
      return;
    }

    _isVisible = true;

    _onClose = _onClose ?? onClose;

    globalKey = globalKey ?? GlobalKey<_HighlighterCoachMarkState>();

    _overlayEntryBackground = _overlayEntryBackground ??
        new OverlayEntry(
          builder: (BuildContext context) => new _HighlighterCoachMarkWidget(
                key: globalKey,
                bgColor: bgColor,
                markRect: markRect,
                markShape: markShape,
                doClose: close,
                children: children,
              ),
        );

    OverlayState overlayState = Overlay.of(targetContext);
    overlayState.insert(_overlayEntryBackground);

    if (duration != null) {
      await new Future.delayed(duration).then((_) => close());
    }
  }

  /// Closes CoachMark and callback optional [onClose]
  Future close() async {
    if (_isVisible) {
      await globalKey?.currentState?.reverse();
      _overlayEntryBackground.remove();

      _isVisible = false;
      if (_onClose != null) {
        _onClose();
      }
    }
  }
}

/// This widget creates dark blurred backgound with highlighted hole in place of
/// [markRect]
class _HighlighterCoachMarkWidget extends StatefulWidget {
  _HighlighterCoachMarkWidget({
    Key key,
    @required this.markRect,
    @required this.markShape,
    @required this.children,
    @required this.doClose,
    @required this.bgColor,
  }) : super(key: key);

  final Rect markRect;
  final BoxShape markShape;
  final List<Widget> children;
  final VoidCallback doClose;
  final Color bgColor;

  @override
  _HighlighterCoachMarkState createState() => new _HighlighterCoachMarkState();
}

class _HighlighterCoachMarkState extends State<_HighlighterCoachMarkWidget>
    with SingleTickerProviderStateMixin {
  AnimationController _controller;
  Animation<double> _blurAnimation;
  Animation<double> _opacityAnimation;

  //Does reverse animation, called when coachMark is closing.
  Future reverse() {
    return _controller.reverse();
  }

  @override
  void initState() {
    super.initState();
    _controller = new AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _blurAnimation = new Tween(begin: 0.0, end: 3.0).animate(
      new CurvedAnimation(
        parent: _controller,
        curve: new Interval(
          0.5,
          1.0,
          curve: Curves.ease,
        ),
      ),
    );
    _opacityAnimation = new Tween(begin: 0.0, end: 0.8).animate(
      new CurvedAnimation(
        parent: _controller,
        curve: new Interval(
          0.0,
          1.0,
          curve: Curves.ease,
        ),
      ),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Rect position = widget.markRect;
    final clipper = _CoachMarkClipper(position);

    return AnimatedBuilder(
        animation: _controller,
        builder: (BuildContext context, Widget child) {
          return Stack(
            children: <Widget>[
              ClipPath(
                clipper: clipper,
                child: BackdropFilter(
                  filter: ui.ImageFilter.blur(
                      sigmaX: _blurAnimation.value,
                      sigmaY: _blurAnimation.value),
                  child: Container(
                    color: Colors.transparent,
                  ),
                ),
              ),
              _CoachMarkLayer(
                behavior: HitTestBehavior.translucent,
                onPointerDown: _onPointer,
                onPointerMove: _onPointer,
                onPointerUp: _onPointer,
                onPointerCancel: _onPointer,
                markPosition: position,
                child: CustomPaint(
                  child: Opacity(
                      opacity: _opacityAnimation.value,
                      child: Material(
                          type: MaterialType.transparency,
                          child: Stack(
                            fit: StackFit.expand,
                            children: widget.children,
                          ))),
                  painter: _CoachMarkPainter(
                    rect: position,
                    shadow: BoxShadow(
                        color:
                            widget.bgColor.withOpacity(_opacityAnimation.value),
                        blurRadius: 8.0),
                    clipper: clipper,
                    coachMarkShape: widget.markShape,
                  ),
                ),
              ),
            ],
          );
        });
  }

  void _onPointer(PointerEvent p) {
    widget.doClose();
  }
}

/// This widget creates _RenderPointerListenerWithExceptRegion which
/// overrides a special hitTest
class _CoachMarkLayer extends Listener {
  const _CoachMarkLayer(
      {Key key,
      onPointerDown,
      onPointerMove,
      onPointerUp,
      onPointerCancel,
      behavior,
      this.markPosition,
      Widget child})
      : super(
            key: key,
            onPointerDown: onPointerDown,
            onPointerMove: onPointerMove,
            onPointerUp: onPointerUp,
            onPointerCancel: onPointerCancel,
            child: child);

  final Rect markPosition;

  @override
  RenderPointerListener createRenderObject(BuildContext context) {
    return new _RenderPointerListenerWithExceptRegion(
      onPointerDown: onPointerDown,
      onPointerMove: onPointerMove,
      onPointerUp: onPointerUp,
      onPointerCancel: onPointerCancel,
      behavior: behavior,
      exceptRegion: markPosition,
    );
  }

  @override
  void updateRenderObject(
      BuildContext context, RenderPointerListener renderObject) {
    renderObject
      ..onPointerDown = onPointerDown
      ..onPointerMove = onPointerMove
      ..onPointerUp = onPointerUp
      ..onPointerCancel = onPointerCancel
      ..behavior = behavior;
  }
}

/// It overrides [hitTest] in a way that if position of touch is inside of
/// Rect [exceptRegion], this class is added to [HitTestResult] and return false,
/// so framework continues traverse the tree. It makes possible for CoachMark
/// to process touch (to close itself) and for targetElement to process touch.
class _RenderPointerListenerWithExceptRegion extends RenderPointerListener {
  _RenderPointerListenerWithExceptRegion(
      {onPointerDown,
      onPointerMove,
      onPointerUp,
      onPointerCancel,
      HitTestBehavior behavior,
      this.exceptRegion,
      RenderBox child})
      : super(
            onPointerDown: onPointerDown,
            onPointerMove: onPointerMove,
            onPointerUp: onPointerUp,
            onPointerCancel: onPointerCancel,
            behavior: behavior,
            child: child);

  final Rect exceptRegion;

  @override
  bool hitTest(HitTestResult result, {Offset position}) {
    bool hitTarget = false;
    if (exceptRegion.contains(position)) {
      result.add(new BoxHitTestEntry(this, position));
      return false;
    }
    if (size.contains(position)) {
      hitTarget =
          hitTestChildren(result, position: position) || hitTestSelf(position);
      if (hitTarget || behavior == HitTestBehavior.translucent)
        result.add(new BoxHitTestEntry(this, position));
    }
    return hitTarget;
  }
}

class _CoachMarkClipper extends CustomClipper<Path> {
  final Rect rect;

  _CoachMarkClipper(this.rect);

  @override
  Path getClip(Size size) {
    return Path.combine(ui.PathOperation.difference,
        Path()..addRect(Offset.zero & size), Path()..addOval(rect));
  }

  @override
  bool shouldReclip(_CoachMarkClipper old) => rect != old.rect;
}

///This class makes edges of hole blurred.
class _CoachMarkPainter extends CustomPainter {
  _CoachMarkPainter({
    @required this.rect,
    @required this.shadow,
    this.clipper,
    this.coachMarkShape = BoxShape.circle,
  });

  final Rect rect;
  final BoxShadow shadow;
  final _CoachMarkClipper clipper;
  final BoxShape coachMarkShape;

  void paint(Canvas canvas, Size size) {
    final circle = rect.inflate(shadow.spreadRadius);
    canvas.saveLayer(Offset.zero & size, Paint());
    canvas.drawColor(shadow.color, BlendMode.dstATop);
    var paint = shadow.toPaint()..blendMode = BlendMode.clear;

    switch (coachMarkShape) {
      case BoxShape.rectangle:
        canvas.drawRRect(
            RRect.fromRectAndRadius(rect, Radius.circular(circle.width * 0.3)),
            paint);
        break;
      case BoxShape.circle:
      default:
        canvas.drawCircle(circle.center, circle.longestSide * 0.5, paint);
        break;
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(_CoachMarkPainter old) => old.rect != rect;

  @override
  bool shouldRebuildSemantics(_CoachMarkPainter oldDelegate) => false;
}
