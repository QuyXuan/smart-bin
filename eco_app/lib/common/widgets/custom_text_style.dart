// ignore_for_file: constant_identifier_names
import 'package:eco_app/common/extensions/custom_theme_extension.dart';
import 'package:flutter/material.dart';

const double DEFAULT_TITLE_FONT_SIZE = 28;
const double DEFAULT_HEADLINE_FONT_SIZE = 20;
const double DEFAULT_CONTENT_FONT_SIZE = 16;

class TitleText extends BaseText {
  const TitleText(
    super.text, {
    super.key,
    double? fontSize,
    FontWeight? fontWeight,
    super.color,
    TextAlign? textAlign,
    TextOverflow? overflow,
    super.maxLines,
  }) : super(
          fontSize: fontSize ?? DEFAULT_TITLE_FONT_SIZE,
          fontWeight: fontWeight ?? FontWeight.w900,
          textAlign: textAlign ?? TextAlign.left,
          overflow: overflow ?? TextOverflow.visible,
        );
}

class HeadlineText extends BaseText {
  const HeadlineText(
    super.text, {
    super.key,
    double? fontSize,
    FontWeight? fontWeight,
    super.color,
    TextAlign? textAlign,
    TextOverflow? overflow,
    super.maxLines,
  }) : super(
          fontSize: fontSize ?? DEFAULT_HEADLINE_FONT_SIZE,
          fontWeight: fontWeight ?? FontWeight.w700,
          textAlign: textAlign ?? TextAlign.left,
          overflow: overflow ?? TextOverflow.visible,
        );
}

class ContentText extends BaseText {
  const ContentText(
    super.text, {
    super.key,
    double? fontSize,
    FontWeight? fontWeight,
    super.color,
    TextAlign? textAlign,
    TextOverflow? overflow,
    super.maxLines,
  }) : super(
          fontSize: fontSize ?? DEFAULT_CONTENT_FONT_SIZE,
          fontWeight: fontWeight ?? FontWeight.w500,
          textAlign: textAlign ?? TextAlign.left,
          overflow: overflow ?? TextOverflow.visible,
        );
}

class BaseText extends StatefulWidget {
  final String text;
  final double fontSize;
  final FontWeight fontWeight;
  final Color? color;
  final TextAlign textAlign;
  final TextOverflow overflow;
  final int? maxLines;

  const BaseText(
    this.text, {
    super.key,
    required this.fontSize,
    required this.fontWeight,
    this.color,
    required this.textAlign,
    required this.overflow,
    this.maxLines,
  });

  @override
  State<BaseText> createState() => _BaseTextState();
}

class _BaseTextState extends State<BaseText> {
  @override
  Widget build(BuildContext context) {
    return Text(
      widget.text,
      style: TextStyle(
        fontSize: widget.fontSize,
        fontWeight: widget.fontWeight,
        color: widget.color ?? context.theme.textColor,
      ),
      textAlign: widget.textAlign,
      overflow: widget.overflow,
      maxLines: widget.maxLines,
    );
  }
}
