import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:stock_calendar/common/status/image_status.dart';

class UrlText extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var imageState = Provider.of<ImageStatus>(context);
    return imageState.getImageUrl == ""
        ? Container()
        : Padding(
            padding: EdgeInsets.only(left: 10, right: 10, bottom: 20, top: 20),
            child: Row(
              children: [
                Expanded(child: Container()),
                Text("圖片網址："),
                SelectableText(imageState.getImageUrl),
                Expanded(child: Container()),
              ],
            ),
          );
  }
}
