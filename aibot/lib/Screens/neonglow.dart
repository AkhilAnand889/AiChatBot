import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

class NeonGlowButton extends StatefulWidget {
  final VoidCallback onPressed;

  NeonGlowButton({required this.onPressed});

  @override
  _NeonGlowButtonState createState() => _NeonGlowButtonState();
}

class _NeonGlowButtonState extends State<NeonGlowButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 800),
    )..repeat(reverse: true);
    _animation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
    super.initState();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (BuildContext context, Widget? child) {
        return Container(
          width: 90,
          height: 48,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.green,
            boxShadow: [
              BoxShadow(
                color: Colors.green.withOpacity(0.6),
                blurRadius: 7.0 * _animation.value,
                spreadRadius: 4.0 * _animation.value,
              ),
            ],
          ),
          child: Transform.scale(
            scale: _animation.value,
            child: IconButton(
              icon: Icon(
                Iconsax.send_24,
                color: Colors.white,
              ),
              onPressed: widget.onPressed,
            ),
          ),
        );
      },
    );
  }
}
