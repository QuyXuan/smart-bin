import 'package:eco_app/common/utils/common_colors.dart';
import 'package:flutter/material.dart';

class CustomElevatedButton extends StatelessWidget {
  final double? buttonWidth;
  final VoidCallback onPressed;
  final String text;
  final bool isEnable;
  final String? image;
  final Color? backgroundColor;
  final ButtonStyle? buttonStyle;
  final TextStyle? textStyle;

  const CustomElevatedButton({
    super.key,
    this.buttonWidth,
    required this.onPressed,
    required this.text,
    this.image,
    this.backgroundColor,
    this.buttonStyle,
    this.textStyle,
    this.isEnable = true,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.topCenter,
      children: [
        SizedBox(
          width: buttonWidth ?? MediaQuery.of(context).size.width - 100,
          child: ElevatedButton(
            onPressed: isEnable ? onPressed : null,
            style: buttonStyle ??
                ElevatedButton.styleFrom(
                  backgroundColor: isEnable
                      ? backgroundColor ?? CommonColors.greenDark
                      : Colors.grey,
                  disabledForegroundColor: Colors.grey.withOpacity(0.5),
                  disabledBackgroundColor: Colors.grey.withOpacity(0.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
            child: Padding(
              padding: const EdgeInsets.all(15.0),
              child: Text(
                text,
                style: textStyle,
              ),
            ),
          ),
        ),
        if (image != null && image!.isNotEmpty)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            bottom: 0,
            child: GestureDetector(
              onTap: onPressed,
              child: Container(
                alignment: Alignment.centerLeft,
                height: 42,
                decoration: BoxDecoration(
                  border: Border.all(
                    width: 6,
                    color: backgroundColor!,
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Image.asset(
                  image!,
                  fit: BoxFit.cover,
                  height: 42,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
