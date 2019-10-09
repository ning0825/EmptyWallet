import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CusToolbar extends StatelessWidget{
  final String title;
  final IconButton leftIcon;
  final IconButton rightIcon;

  CusToolbar({this.title, this.leftIcon, this.rightIcon}) : super();

  @override
  Widget build(BuildContext context) {
    return Row(//todo 哪些widget的尺寸约束是对自己的，哪些是对子物体的
      children: <Widget>[
        this.leftIcon,
        Expanded(
            child: Text(
              this.title,
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            )),
        this.rightIcon
      ],
    );
  }
}