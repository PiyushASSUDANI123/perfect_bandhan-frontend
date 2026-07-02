import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class CustomLoader extends StatefulWidget {
  final Color? color;
  final double size;

  const CustomLoader({super.key, this.color, this.size = 12.0});

  @override
  State<CustomLoader> createState() => _CustomLoaderState();
}

class _CustomLoaderState extends State<CustomLoader> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _anim1;
  late Animation<double> _anim2;
  late Animation<double> _anim3;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat();

    _anim1 = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.3, end: 1.0), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.3), weight: 1),
      TweenSequenceItem(tween: ConstantTween(0.3), weight: 2),
    ]).animate(CurvedAnimation(parent: _controller, curve: const Interval(0.0, 1.0)));

    _anim2 = TweenSequence<double>([
      TweenSequenceItem(tween: ConstantTween(0.3), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 0.3, end: 1.0), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.3), weight: 1),
      TweenSequenceItem(tween: ConstantTween(0.3), weight: 1),
    ]).animate(CurvedAnimation(parent: _controller, curve: const Interval(0.0, 1.0)));

    _anim3 = TweenSequence<double>([
      TweenSequenceItem(tween: ConstantTween(0.3), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 0.3, end: 1.0), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.3), weight: 1),
    ]).animate(CurvedAnimation(parent: _controller, curve: const Interval(0.0, 1.0)));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _buildBox(Animation<double> animation) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return Opacity(
          opacity: animation.value,
          child: Transform.scale(
            scale: 0.8 + (animation.value * 0.2),
            child: Container(
              width: widget.size,
              height: widget.size,
              decoration: BoxDecoration(
                color: widget.color ?? AppTheme.accentGold,
                borderRadius: BorderRadius.circular(2.0),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildBox(_anim1),
        const SizedBox(width: 6),
        _buildBox(_anim2),
        const SizedBox(width: 6),
        _buildBox(_anim3),
      ],
    );
  }
}
