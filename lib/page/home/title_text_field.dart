import 'package:flutter/material.dart';

class TitleTextField extends StatelessWidget {
  final TextEditingController titleFieldController;

  TitleTextField({@required this.titleFieldController});
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      width: double.infinity,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        // mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: Container(
              width: double.infinity,
              height: 60,
              child: TextFormField(
                style: TextStyle(color: Colors.white),
                keyboardType: TextInputType.text,
                decoration: InputDecoration(
                  counterText: '',
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Colors.white, //边线颜色
                      width: 0.5, //边线宽度为2
                    ),
                  ),
                //      labelText: "请输入内容",//输入框内无文字时提示内容，有内容时会自动浮在内容上方
                // helperText: "随便输入文字或数字", //输入框底部辅助性说明文字
                  labelStyle: TextStyle(color: Colors.white54),
                  labelText: "請輸入標題",
                ),
                maxLength: 20,
                controller: titleFieldController,
              ),
            ),
          ),
          
          // SizedBox(
          //   width: 20,
          // ),
        ],
      ),
    );
  }
}
