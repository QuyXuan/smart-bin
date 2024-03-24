import 'package:eco_app/common/utils/common_colors.dart';
import 'package:flutter/material.dart';

class CustomProgressBar extends StatelessWidget {
  const CustomProgressBar(
      {super.key,
      required this.width,
      required this.height,
      required this.progress});
  final double width;
  final double height;
  final double progress;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(10),
      ),
      child: Stack(
        children: [
          Container(
            width: width * progress,
            height: height,
            decoration: BoxDecoration(
              color: CommonColors.rubyBlue,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          Align(
            alignment: Alignment.center,
            child: Text(
              '${(progress * 100).toInt()}%',
              style: const TextStyle(
                color: CommonColors.ghostWhite,
                fontWeight: FontWeight.bold,
              ),
            ),
          )
        ],
      ),
    );
  }
}
