import 'package:flutter/material.dart';

class AnimatedSection extends StatelessWidget {
  final int delay;
  final Widget child;

  const AnimatedSection({
    super.key,
    required this.delay,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: Future.delayed(Duration(milliseconds: delay)),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Opacity(opacity: 0, child: child);
        }
        return AnimatedOpacity(
          opacity: 1,
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeOut,
          child: AnimatedSlide(
            offset: snapshot.connectionState == ConnectionState.done
                ? Offset.zero
                : const Offset(0, 0.1),
            duration: const Duration(milliseconds: 600),
            curve: Curves.easeOutCubic,
            child: child,
          ),
        );
      },
    );
  }
}
