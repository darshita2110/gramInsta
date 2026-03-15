// widgets/pinch_to_zoom.dart

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class PinchToZoom extends StatefulWidget {
  final Widget child;

  const PinchToZoom({super.key, required this.child});

  @override
  State<PinchToZoom> createState() => _PinchToZoomState();
}

class _PinchToZoomState extends State<PinchToZoom>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _scaleAnim;
  late Animation<Offset> _offsetAnim;

  OverlayEntry? _overlayEntry;
  final GlobalKey _key = GlobalKey();

  double _scale = 1.0;
  double _baseScale = 1.0;
  Offset _offset = Offset.zero;
  Offset _baseOffset = Offset.zero;
  bool _isZooming = false;
  int _pointerCount = 0;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
  }

  @override
  void dispose() {
    _removeOverlay();
    _animController.dispose();
    super.dispose();
  }

  Rect _getGlobalRect() {
    final rb = _key.currentContext?.findRenderObject() as RenderBox?;
    if (rb == null) return Rect.zero;
    return rb.localToGlobal(Offset.zero) & rb.size;
  }

  void _insertOverlay(Rect rect) {
    _overlayEntry = OverlayEntry(
      builder: (_) => _ZoomOverlayWidget(
        rect: rect,
        scale: _scale,
        offset: _offset,
        child: widget.child,
      ),
    );
    Overlay.of(context, rootOverlay: true).insert(_overlayEntry!);
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  void _onScaleStart(ScaleStartDetails d) {
    if (_pointerCount < 2) return;
    _animController.stop();
    _baseScale = _scale;
    _baseOffset = _offset;
    _isZooming = true;
    final rect = _getGlobalRect();
    if (rect == Rect.zero) return;
    if (_overlayEntry == null) _insertOverlay(rect);
  }

  void _onScaleUpdate(ScaleUpdateDetails d) {
    if (!_isZooming) return;
    _scale = (_baseScale * d.scale).clamp(1.0, 6.0);
    _offset = _baseOffset + d.focalPointDelta;
    _overlayEntry?.markNeedsBuild();
  }

  void _onScaleEnd(ScaleEndDetails d) {
    if (!_isZooming) return;
    _isZooming = false;

    final startScale = _scale;
    final startOffset = _offset;

    _scaleAnim = Tween<double>(begin: startScale, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.elasticOut),
    );
    _offsetAnim = Tween<Offset>(begin: startOffset, end: Offset.zero).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic),
    );

    void listener() {
      _scale = _scaleAnim.value;
      _offset = _offsetAnim.value;
      _overlayEntry?.markNeedsBuild();
    }

    _animController.addListener(listener);
    _animController.forward(from: 0).then((_) {
      _animController.removeListener(listener);
      _removeOverlay();
      _scale = 1.0;
      _offset = Offset.zero;
    });
  }

  @override
  Widget build(BuildContext context) {
    return RawGestureDetector(
      gestures: {
        _ConditionalScaleRecognizer:
        GestureRecognizerFactoryWithHandlers<_ConditionalScaleRecognizer>(
              () => _ConditionalScaleRecognizer(
            pointerCountProvider: () => _pointerCount,
          ),
              (instance) {
            instance
              ..onStart = _onScaleStart
              ..onUpdate = _onScaleUpdate
              ..onEnd = _onScaleEnd;
          },
        ),
      },
      // translucent so single-finger swipes fall through to PageView/ScrollView
      behavior: HitTestBehavior.translucent,
      child: Listener(
        onPointerDown: (_) {
          _pointerCount++;
          if (_pointerCount >= 2) _animController.stop();
        },
        onPointerUp: (_) => _pointerCount = (_pointerCount - 1).clamp(0, 10),
        onPointerCancel: (_) => _pointerCount = (_pointerCount - 1).clamp(0, 10),
        behavior: HitTestBehavior.translucent,
        child: KeyedSubtree(
          key: _key,
          child: widget.child,
        ),
      ),
    );
  }
}

// Only wins the gesture arena when 2+ fingers are down.
// Single-finger drags pass through to PageView and ScrollView.
class _ConditionalScaleRecognizer extends ScaleGestureRecognizer {
  final int Function() pointerCountProvider;

  _ConditionalScaleRecognizer({required this.pointerCountProvider});

  @override
  void addAllowedPointer(PointerDownEvent event) {
    super.addAllowedPointer(event);
    if (pointerCountProvider() >= 2) {
      resolve(GestureDisposition.accepted);
    }
  }
}

class _ZoomOverlayWidget extends StatelessWidget {
  final Rect rect;
  final double scale;
  final Offset offset;
  final Widget child;

  const _ZoomOverlayWidget({
    required this.rect,
    required this.scale,
    required this.offset,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final dimAmount = ((scale - 1.0) / 5.0).clamp(0.0, 0.88);
    return Stack(
      children: [
        Positioned.fill(
          child: IgnorePointer(
            child: ColoredBox(
              color: Colors.black.withOpacity(dimAmount),
            ),
          ),
        ),
        Positioned(
          left: rect.left + offset.dx,
          top: rect.top + offset.dy,
          width: rect.width,
          height: rect.height,
          child: IgnorePointer(
            child: Transform.scale(
              scale: scale,
              child: child,
            ),
          ),
        ),
      ],
    );
  }
}