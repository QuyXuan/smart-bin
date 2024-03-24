import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class CustomSkimmer extends StatelessWidget {
  const CustomSkimmer({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.withOpacity(0.5),
      highlightColor: Colors.grey.withOpacity(0.2),
      period: const Duration(milliseconds: 1000),
      child: child,
    );
  }
}
