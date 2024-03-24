import 'package:eco_app/common/extensions/custom_theme_extension.dart';
import 'package:eco_app/common/utils/common_colors.dart';
import 'package:flutter/material.dart';

class CustomAlertDialog extends StatefulWidget {
  final Widget contentWidget;
  final double? width;
  final double? height;
  final Widget? titleWidget;
  final bool? hasCloseButton;
  final bool? hasOKButton;
  final String? closeButtonText;
  final String? okButtonText;
  final VoidCallback? onCloseButtonPressed;
  final VoidCallback? onOKButtonPressed;

  const CustomAlertDialog({
    super.key,
    required this.contentWidget,
    this.titleWidget,
    this.hasCloseButton,
    this.hasOKButton,
    this.closeButtonText,
    this.okButtonText,
    this.onCloseButtonPressed,
    this.onOKButtonPressed,
    this.width,
    this.height,
  });

  @override
  State<CustomAlertDialog> createState() => _CustomAlertDialogState();
}

class _CustomAlertDialogState extends State<CustomAlertDialog> {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: context.theme.modalBackgroundColor,
      shadowColor: context.theme.modalBackgroundColor,
      surfaceTintColor: context.theme.modalBackgroundColor,
      insetPadding: const EdgeInsets.symmetric(horizontal: 0),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      title: widget.titleWidget,
      content: Container(
        color: context.theme.modalBackgroundColor,
        width: widget.width ?? MediaQuery.of(context).size.width * 0.8,
        height: widget.height,
        child: widget.contentWidget,
      ),
      actions: [
        (widget.hasCloseButton ?? false)
            ? GestureDetector(
                onTap: widget.onCloseButtonPressed ??
                    () {
                      Navigator.of(context).pop();
                    },
                child: Container(
                  width: (MediaQuery.of(context).size.width * 0.8 - 40) / 2,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(5),
                    border: Border.all(color: CommonColors.greenDark, width: 2),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Center(
                    child: Text(
                      widget.closeButtonText ?? 'Close',
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ),
              )
            : const SizedBox(),
        (widget.hasOKButton ?? false)
            ? GestureDetector(
                onTap: widget.onOKButtonPressed ?? () {},
                child: Container(
                  height: 40,
                  width: (MediaQuery.of(context).size.width * 0.8 - 20) / 2,
                  decoration: BoxDecoration(
                    color: CommonColors.greenDark,
                    borderRadius: BorderRadius.circular(5),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Center(
                    child: Text(
                      widget.okButtonText ?? 'OK',
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ),
              )
            : const SizedBox()
      ],
    );
  }
}
