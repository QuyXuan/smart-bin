import 'package:flutter/material.dart';

class CustomListTileLeading extends StatefulWidget {
  const CustomListTileLeading({
    super.key,
    this.width,
    this.height,
    this.dotSize,
    this.hideTopLine,
    this.hideBottomLine,
    this.color,
    this.dotColor,
  });
  final double? width;
  final double? height;
  final double? dotSize;
  final bool? hideTopLine;
  final bool? hideBottomLine;
  final Color? color;
  final Color? dotColor;

  @override
  State<StatefulWidget> createState() => _CustomListTileLeadingState();
}

class _CustomListTileLeadingState extends State<CustomListTileLeading> {
  double defaultWidth = 20;
  double defaultHeight = 50;
  double defaultDotSize = 10;
  @override
  Widget build(BuildContext context) {
    double lineHeight =
        (widget.height ?? defaultHeight) / 2 - (widget.dotSize ?? defaultDotSize) / 2;
    return SizedBox(
      width: widget.width ?? defaultWidth,
      height: widget.height ?? defaultHeight,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            height: lineHeight,
            width: 2,
            color: widget.hideTopLine ?? false
                ? Colors.transparent
                : widget.color ?? Colors.grey,
          ),
          Container(
            width: widget.dotSize ?? defaultDotSize,
            height: widget.dotSize ?? defaultDotSize,
            decoration: BoxDecoration(
              color: widget.dotColor ?? Colors.black,
              shape: BoxShape.circle,
            ),
          ),
          Container(
            height: lineHeight,
            width: 2,
            color: widget.hideBottomLine ?? false
                ? Colors.transparent
                : widget.color ?? Colors.grey,
          ),
        ],
      ),
    );
  }
}
