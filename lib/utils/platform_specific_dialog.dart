import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class PlatformSpecificDialog extends StatelessWidget {
  const PlatformSpecificDialog(
      {Key? key, this.title, this.actions, this.content})
      : super(key: key);
  final Widget? title;
  final List<Widget>? actions;
  final Widget? content;

  @override
  Widget build(BuildContext context) {
    return Platform.isIOS
        ? CupertinoAlertDialog(
            title: title,
            actions: actions ?? [],
            content: content,
          )
        : AlertDialog(
            title: title,
            actions: actions,
            content: content,
          );
  }
}
