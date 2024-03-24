import 'package:eco_app/common/extensions/custom_theme_extension.dart';
import 'package:eco_app/common/utils/common_colors.dart';
import 'package:flutter/material.dart';

showLoadingDialog({
  required BuildContext context,
  required String message,
}) async {
  return await showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                const CircularProgressIndicator(color: CommonColors.greenDark),
                const SizedBox(width: 20),
                Expanded(
                  child: Text(
                    message,
                    style: TextStyle(
                      fontSize: 15,
                      color: context.theme.greyColor,
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    },
  );
}
