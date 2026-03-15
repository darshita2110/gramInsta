// widgets/pinch_to_zoom.dart

import 'package:flutter/material.dart';

/// PinchToZoom renders [child] normally.
/// When the user pinches, it creates a hero-style overlay on top of the entire
/// screen that shows the image scaling smoothly. On release, it animates back
/// with a spring curve and the overlay fades out.
class PinchToZoom extends StatefulWidget {
  final Widget child;

  const PinchToZoom({super.key, required this.child});

  @override
  State<PinchToZoom> createState() => _PinchToZoomState();
}

class _PinchToZoomState extends State<PinchToZoom>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<Offset> _offsetAnimation;

  OverlayEntry? _overlayEntry;
  final GlobalKey _childKey = GlobalKey();

  double _scale = 1.0;
  double _previousScale = 1.0;
  Offset _offset = Offset.zero;
  Offset _previousOffset = Offset.zero;
  bool _isZooming = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
  }

  @override
  void dispose() {
    _removeOverlay();
    _controller.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // Overlay management
  // ---------------------------------------------------------------------------
  void _showOverlay(Offset initialOffset, Size size) {
    _removeOverlay();
    _overlayEntry = OverlayEntry(
      builder: (context) => _ZoomOverlay(
        scale: _scale,
        offset: _offset,
        child: widget.child,
        childSize: size,
        childOffset: initialOffset,
      ),
    );
    Overlay.of(context).insert(_overlayEntry!);
  }

  void _updateOverlay() {
    _overlayEntry?.markNeedsBuild();
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  // ---------------------------------------------------------------------------
  // Get position of [_childKey] on screen
  // ---------------------------------------------------------------------------
  (Offset, Size) _getChildRect() {
    final renderBox =
    _childKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return (Offset.zero, Size.zero);
    final offset = renderBox.localToGlobal(Offset.zero);
    return (offset, renderBox.size);
  }

  // ---------------------------------------------------------------------------
  // Gesture handlers
  // ---------------------------------------------------------------------------
  void _onScaleStart(ScaleStartDetails details) {
    if (details.pointerCount < 2) return;
    setState(() => _isZooming = true);
    _previousScale = _scale;
    _previousOffset = _offset;
    final (offset, size) = _getChildRect();
    _showOverlay(offset, size);
  }

  void _onScaleUpdate(ScaleUpdateDetails details) {
    if (!_isZooming) return;
    setState(() {
      _scale = (_previousScale * details.scale).clamp(1.0, 5.0);
      _offset = _previousOffset + details.focalPointDelta;
    });
    _overlayEntry?.markNeedsBuild();
  }

  void _onScaleEnd(ScaleEndDetails details) {
    if (!_isZooming) return;

    final targetScale = 1.0;
    final targetOffset = Offset.zero;

    _scaleAnimation = Tween<double>(begin: _scale, end: targetScale).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );
    _offsetAnimation =
        Tween<Offset>(begin: _offset, end: targetOffset).animate(
          CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
        );

    _controller.forward(from: 0).then((_) {
      _removeOverlay();
      setState(() {
        _isZooming = false;
        _scale = 1.0;
        _offset = Offset.zero;
      });
    });

    _controller.addListener(() {
      if (_overlayEntry != null) {
        _scale = _scaleAnimation.value;
        _offset = _offsetAnimation.value;
        _overlayEntry?.markNeedsBuild();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onScaleStart: _onScaleStart,
      onScaleUpdate: _onScaleUpdate,
      onScaleEnd: _onScaleEnd,
      child: KeyedSubtree(
        key: _childKey,
        child: widget.child,
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// The overlay that renders on top of everything while zooming
// ---------------------------------------------------------------------------
class _ZoomOverlay extends StatelessWidget {
  final double scale;
  final Offset offset;
  final Widget child;
  final Size childSize;
  final Offset childOffset;

  const _ZoomOverlay({
    required this.scale,
    required this.offset,
    required this.child,
    required this.childSize,
    required this.childOffset,
  });

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Stack(
        children: [
          // Dim background
          Positioned.fill(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 100),
              color:
              Colors.black.withOpacity(((scale - 1) / 4).clamp(0.0, 0.85)),
            ),
          ),
          // Zoomed image positioned at its original screen coordinates
          Positioned(
            left: childOffset.dx + offset.dx,
            top: childOffset.dy + offset.dy,
            width: childSize.width,
            height: childSize.height,
            child: Transform.scale(
              scale: scale,
              child: child,
            ),
          ),
        ],
      ),
    );
  }
}