import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

void showCupertinoDialog(BuildContext context, String contentText) {
  var dialog = CupertinoAlertDialog(
    content: Text(
      contentText,
      style: TextStyle(fontSize: 15),
    ),
    actions: <Widget>[
      // CupertinoButton(
      //   child: Text("取消"),
      //   onPressed: () {
      //     Navigator.pop(context);
      //   },
      // ),
      CupertinoButton(
        child: Text("确定"),
        onPressed: () {
          Navigator.pop(context);
        },
      ),
    ],
  );

  showDialog(context: context, builder: (_) => dialog);
}
