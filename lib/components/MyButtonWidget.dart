import 'package:flutter/material.dart';
import 'package:mighty_notes/utils/Colors.dart';
import 'package:mighty_notes/utils/Common.dart';
import 'package:nb_utils/nb_utils.dart';
import '../main.dart';

class MyButtonWidget extends StatelessWidget {
  final Function onTap;
  final String text;
  final Color color;
  final Color textColor;

  MyButtonWidget({
    @required this.onTap,
    @required this.text,
    this.color,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return  Container(
      width: context.width(),
      child: TextButton(
        style: ButtStyle(),
        child: Padding(
          padding: EdgeInsets.all(9),
          child: Text(text, style: boldTextStyle(color: appStore.isDarkMode ? scaffoldColorDark : Colors.white)),
        ),
        onPressed: onTap,
      ),
    );
  }
}
