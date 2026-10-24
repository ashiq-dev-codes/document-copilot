import 'package:flutter/material.dart';

class CustomOverlayMessage {
  static OverlayEntry? _currentOverlay;

  static void show(
    BuildContext context,
    String message, {
    Color? backgroundColor,
    Duration duration = const Duration(seconds: 2),
  }) {
    // Remove old message if still showing
    _removeCurrent();

    final overlay = Overlay.of(context, rootOverlay: true);

    _currentOverlay = OverlayEntry(
      builder: (context) => Positioned(
        left: 10,
        right: 10,
        bottom: MediaQuery.of(context).padding.bottom + 20,
        child: Material(
          color: Colors.transparent,
          child: _BottomSwipeDismissWrapper(
            onDismissed: _removeCurrent,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
                color: backgroundColor ?? Colors.grey.shade900,
              ),
              child: Text(
                message,
                textAlign: TextAlign.start,
                style: const TextStyle(color: Colors.white, fontSize: 14),
              ),
            ),
          ),
        ),
      ),
    );

    overlay.insert(_currentOverlay!);

    // Auto-remove after duration
    Future.delayed(duration, () => _removeCurrent());
  }

  static void _removeCurrent() {
    _currentOverlay?.remove();
    _currentOverlay = null;
  }

  static void message(BuildContext context, String title) {
    show(context, title, duration: const Duration(seconds: 5));
  }

  static void success(BuildContext context, String title) {
    show(context, title, backgroundColor: Colors.green);
  }

  static void error(BuildContext context, String title) {
    show(
      context,
      title,
      backgroundColor: Colors.red,
      duration: const Duration(seconds: 7),
    );
  }
}

class _BottomSwipeDismissWrapper extends StatefulWidget {
  final Widget child;
  final VoidCallback onDismissed;

  const _BottomSwipeDismissWrapper({
    required this.child,
    required this.onDismissed,
  });

  @override
  State<_BottomSwipeDismissWrapper> createState() =>
      _BottomSwipeDismissWrapperState();
}

class _BottomSwipeDismissWrapperState
    extends State<_BottomSwipeDismissWrapper> {
  double _offsetY = 0;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onVerticalDragUpdate: (details) {
        if (details.delta.dy > 0) {
          // Only allow downward drag
          setState(() {
            _offsetY += details.delta.dy;
          });
        }
      },
      onVerticalDragEnd: (details) {
        if (_offsetY > 15) {
          widget.onDismissed();
        } else {
          setState(() {
            _offsetY = 0;
          });
        }
      },
      child: Transform.translate(
        offset: Offset(0, _offsetY),
        child: widget.child,
      ),
    );
  }
}
