import 'package:flutter/material.dart';

class NotificationOverlay {
  static void show(OverlayState overlay, String message) {
    final entry = OverlayEntry(
      builder: (context) => _NotificationBanner(message: message),
    );

    overlay.insert(entry);

    // Remove after 4 seconds
    Future.delayed(const Duration(seconds: 4), () {
      if (entry.mounted) {
        entry.remove();
      }
    });
  }
}

class _NotificationBanner extends StatefulWidget {
  final String message;

  const _NotificationBanner({required this.message});

  @override
  State<_NotificationBanner> createState() => _NotificationBannerState();
}

class _NotificationBannerState extends State<_NotificationBanner> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _offsetAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _offsetAnimation = Tween<Offset>(
      begin: const Offset(0.0, -1.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack,
    ));

    _controller.forward();
    
    // Auto reverse
    Future.delayed(const Duration(milliseconds: 3500), () {
      if (mounted) {
        _controller.reverse();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 16,
      left: 16,
      right: 16,
      child: Material(
        color: Colors.transparent,
        child: SlideTransition(
          position: _offsetAnimation,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Row(
              children: [
                Icon(
                  Icons.notifications_active,
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    widget.message,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                      fontWeight: FontWeight.w600,
                    ),
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
