import 'package:eco_app/common/extensions/custom_theme_extension.dart';
import 'package:eco_app/common/models/function_item.dart';
import 'package:eco_app/common/utils/common_colors.dart';
import 'package:eco_app/common/widgets/custom_text_style.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:popover/popover.dart';

class CustomPopover extends StatelessWidget {
  const CustomPopover({super.key, required this.items});
  final List<FunctionItem> items;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => showPopover(
        context: context,
        bodyBuilder: (context) {
          return ListView.builder(
            physics: const NeverScrollableScrollPhysics(),
            padding: EdgeInsets.zero,
            itemCount: items.length,
            itemBuilder: (context, index) {
              return Container(
                height: 50,
                color: index.isEven
                    ? CommonColors.green.withOpacity(0.9)
                    : CommonColors.greenDark.withOpacity(0.8),
                child: ListTile(
                  title: ContentText(
                    items[index].title,
                    color: CommonColors.textColor,
                  ),
                  leading: items[index].icon,
                  onTap: items[index].onTap,
                ),
              );
            },
          );
        },
        width: 250,
        height: items.length * 50,
        backgroundColor: CommonColors.green.withOpacity(0.9),
      ),
      child: Container(
        width: 35,
        height: 35,
        decoration: BoxDecoration(
          color: context.theme.darkGreen,
          shape: BoxShape.circle,
        ),
        child: const Center(
            child: FaIcon(
          FontAwesomeIcons.ellipsisVertical,
          color: CommonColors.textColor,
        )),
      ),
    );
  }
}
