// widgets/pinch_to_zoom.dart

import 'package:flutter/material.dart';

/// PinchToZoom wraps any widget and allows pinch-to-zoom using an Overlay.
/// When the user starts pinching, a full-screen overlay captures the gesture
/// and renders the scaled image above all other UI. On release, it springs
/// back with an elastic animation and the overlay is removed.
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

  // ---------------------------------------------------------------------------
  // Get the widget's bounding rect in global coordinates
  // ---------------------------------------------------------------------------
  Rect _getGlobalRect() {
    final rb = _key.currentContext?.findRenderObject() as RenderBox?;
    if (rb == null) return Rect.zero;
    final pos = rb.localToGlobal(Offset.zero);
    return pos & rb.size;
  }

  // ---------------------------------------------------------------------------
  // Overlay helpers
  // ---------------------------------------------------------------------------
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

  // ---------------------------------------------------------------------------
  // Gesture callbacks
  // ---------------------------------------------------------------------------
  void _onScaleStart(ScaleStartDetails d) {
    // Only activate on a true pinch (2 fingers)
    if (d.pointerCount < 2) return;

    _animController.stop();
    _baseScale = _scale;
    _baseOffset = _offset;
    _isZooming = true;

    final rect = _getGlobalRect();
    if (rect == Rect.zero) return;

    if (_overlayEntry == null) {
      _insertOverlay(rect);
    }
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

    // Animate scale back to 1 and offset back to zero
    final startScale = _scale;
    final startOffset = _offset;

    _scaleAnim = Tween<double>(begin: startScale, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.elasticOut),
    );
    _offsetAnim = Tween<Offset>(
      begin: startOffset,
      end: Offset.zero,
    ).animate(
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
    return Listener(
      // Listener ensures we see pointer events even inside a ScrollView
      onPointerDown: (_) {},
      child: GestureDetector(
        onScaleStart: _onScaleStart,
        onScaleUpdate: _onScaleUpdate,
        onScaleEnd: _onScaleEnd,
        // behavior: opaque so the gesture arena picks this up reliably
        behavior: HitTestBehavior.opaque,
        child: KeyedSubtree(
          key: _key,
          child: widget.child,
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Overlay widget — floats above everything and renders the zoomed image
// ---------------------------------------------------------------------------
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
        // Dimming backdrop
        Positioned.fill(
          child: IgnorePointer(
            child: ColoredBox(
              color: Colors.black.withOpacity(dimAmount),
            ),
          ),
        ),
        // The zoomed image, anchored to its original position
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