import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:stock_calendar/common/status/image_status.dart';

class ButtonRow extends StatelessWidget {
  Uint8List imageInMemory;
  ButtonRow({this.imageInMemory});
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Container(),
          ),
          FlatButton(
            color: Colors.pink[400],
            child: Text("得到網址"),
            onPressed: () async {
              Provider.of<ImageStatus>(context, listen: false)
                  .imageUpload(imageInMemory);
              // context.read<ImageStatus>().imageUpload(_imageInMemory);
            },
          ),
          SizedBox(
            width: 20,
          ),
          FlatButton(
            color: Colors.cyan[400],
            child: Text("儲存本機"),
            onPressed: () async {
              bool success = false;
              try {
                // var filePath =
                //     await ImagePickerSaver.saveFile(fileData: imageInMemory);
                // print(filePath);
              } catch (e) {
                print(e);
              }
              print(success);
              // Provider.of<ImageStatus>(context, listen: false)
              //     .saveImage(imageInMemory);
              // context.read<ImageStatus>().imageUpload(_imageInMemory);
            },
          ),
          Expanded(
            child: Container(),
          ),
        ],
      ),
    );
  }
}
