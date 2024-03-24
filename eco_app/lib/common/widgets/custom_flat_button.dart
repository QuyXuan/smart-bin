import 'package:flutter/material.dart';

class CustomFlatButton extends StatelessWidget {
  final VoidCallback onPressed;
  final Color? backgroundColor;
  final IconData prefixIcon;
  final IconData? suffixIcon;
  final RichText textData;
  final bool hasBorderBottom;

  const CustomFlatButton({
    super.key,
    required this.onPressed,
    this.backgroundColor,
    required this.prefixIcon,
    this.suffixIcon,
    required this.textData,
    this.hasBorderBottom = false,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.topCenter,
      children: [
        SizedBox(
          height: 60,
          width: MediaQuery.of(context).size.width - 20,
          child: ElevatedButton(
            onPressed: onPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: backgroundColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(0),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Icon(
                      prefixIcon,
                      // color: context.theme.purpleColor,
                      size: 30,
                    ),
                    const SizedBox(width: 20),
                    textData,
                  ],
                ),
                suffixIcon != null
                    ? Icon(
                        suffixIcon,
                        // color: context.theme.photoIconColor,
                        size: 30,
                      )
                    : const SizedBox(),
              ],
            ),
          ),
        ),
        hasBorderBottom
            ? Positioned(
                bottom: 0,
                child: Container(
                  width: MediaQuery.of(context).size.width - 20,
                  alignment: Alignment.center,
                  child: SizedBox(
                    height: 2,
                    width: (MediaQuery.of(context).size.width - 20) * 0.95,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                          // color: context.theme.greyColor,
                          ),
                    ),
                  ),
                ),
              )
            : const SizedBox(),
      ],
    );
  }
}
