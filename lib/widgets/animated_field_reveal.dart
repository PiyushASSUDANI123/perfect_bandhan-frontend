import 'package:flutter/material.dart';

class AnimatedFieldReveal extends StatelessWidget {
  final bool isVisible;
  final Widget child;
  final Duration duration;

  const AnimatedFieldReveal({
    super.key,
    required this.isVisible,
    required this.child,
    this.duration = const Duration(milliseconds: 400),
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedSize(
      duration: duration,
      curve: Curves.easeOutCubic,
      child: AnimatedOpacity(
        opacity: isVisible ? 1.0 : 0.0,
        duration: duration,
        curve: Curves.easeOutCubic,
        child: isVisible
            ? Padding(
                padding: const EdgeInsets.only(bottom: 24.0), // Consistent spacing
                child: child,
              )
            : const SizedBox(width: double.infinity, height: 0),
      ),
    );
  }
}
