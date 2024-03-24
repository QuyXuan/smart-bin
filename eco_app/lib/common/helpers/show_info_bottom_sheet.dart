import 'package:eco_app/common/extensions/custom_theme_extension.dart';
import 'package:eco_app/common/widgets/custom_text_style.dart';
import 'package:flutter/material.dart';

showInfoBottomSheet(BuildContext context, String info) {
  showModalBottomSheet(
    context: context,
    backgroundColor: context.theme.modalBackgroundColor,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(10),
        topRight: Radius.circular(10),
      ),
    ),
    builder: (BuildContext context) {
      return Container(
        height: 100,
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(10),
            topRight: Radius.circular(10),
          ),
        ),
        child: Column(
          children: [
            const SizedBox(height: 10),
            ListTile(
              leading: Icon(
                Icons.info,
                color: context.theme.darkGreen!,
                size: 30,
              ),
              title: HeadlineText(info),
            ),
          ],
        ),
      );
    },
  );
}
