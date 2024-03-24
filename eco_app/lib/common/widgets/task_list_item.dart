import 'package:eco_app/common/extensions/custom_theme_extension.dart';
import 'package:eco_app/common/widgets/custom_text_style.dart';
import 'package:flutter/material.dart';

class TaskListItem extends StatefulWidget {
  const TaskListItem({
    super.key,
    required this.text,
    this.onTap,
    this.trailing,
  });

  final String text;
  final Widget? trailing;
  final Function()? onTap;

  @override
  State<StatefulWidget> createState() => _TaskListItemState();
}

class _TaskListItemState extends State<TaskListItem> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      key: widget.key,
      padding: const EdgeInsets.symmetric(
        vertical: 5,
      ),
      child: Container(
        decoration: BoxDecoration(
          border: Border(
            left: BorderSide(
              color: context.theme.darkGreen!,
              width: 5,
            ),
          ),
          borderRadius: BorderRadius.circular(5),
        ),
        child: ListTile(
          tileColor: context.theme.modalBackgroundColor,
          trailing: widget.trailing,
          contentPadding: const EdgeInsets.only(left: 16, right: 0),
          title: ContentText(widget.text),
          onTap: widget.onTap,
        ),
      ),
    );
  }
}
