import 'package:eco_app/common/widgets/custom_text_style.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class CustomElevatedButton extends StatelessWidget {
  final double? buttonWidth;
  final VoidCallback onPressed;
  final String text;
  final bool isEnable;
  final FaIcon? icon;

  const CustomElevatedButton({
    super.key,
    this.buttonWidth,
    required this.onPressed,
    required this.text,
    this.isEnable = true,
    this.icon,
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
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(15.0),
              child: ContentText(text, color: Colors.white),
            ),
          ),
        ),
        if (icon != null)
          Positioned(
            top: 0,
            left: 10,
            right: 0,
            bottom: 0,
            child: GestureDetector(
              onTap: onPressed,
              child: Container(
                alignment: Alignment.centerLeft,
                height: 42,
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: icon,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
