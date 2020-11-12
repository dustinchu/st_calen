import 'package:flutter/material.dart';

class TodayClick extends StatelessWidget {
  final TextEditingController todayClickController;
  final onClickBtn1;
  final onClickBtn2;
  final bool markStatus;

  TodayClick(
      {@required this.todayClickController,
      @required this.onClickBtn1,
      @required this.onClickBtn2,
      @required this.markStatus});
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      width: double.infinity,
      // decoration: BoxDecoration(
      // borderRadius: new BorderRadius.circular(30)
      // ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        // mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: Container(
              width: double.infinity,
              height: 50,
              child: TextFormField(
                style: TextStyle(color: Colors.white),
                keyboardType: TextInputType.numberWithOptions(
                    signed: true, decimal: true),
                decoration: InputDecoration(
                  counterText: '',
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Colors.white, //边线颜色
                      width: 0.5, //边线宽度为2
                    ),
                  ),
                  labelStyle: TextStyle(color: Colors.white54),
                  labelText: "輸入預估價格 <6字",
                ),
                maxLength: 6,
                controller: todayClickController,
              ),
            ),
          ),
          SizedBox(
            width: 20,
          ),
          SizedBox(
            width: 50,
            child: OutlineButton(
              onPressed: onClickBtn1,
              color: Colors.pink,
              child: Text(
                "漲",
                style: TextStyle(fontSize: 15),
              ),
              textColor: Colors.red[400],
              splashColor: Colors.white38,
              borderSide: new BorderSide(
                color: markStatus ? Colors.red[800] : Colors.white60,
              ),
            ),
          ),
          // ),
          SizedBox(
            width: 20,
          ),
          SizedBox(
            width: 50,
            child: OutlineButton(
              onPressed: onClickBtn2,
              color: Colors.pink,
              child: Text(
                "跌",
                style: TextStyle(fontSize: 15),
              ),
              textColor: Colors.green[800],
              splashColor: Colors.white38,
              borderSide: new BorderSide(
                  color: markStatus ? Colors.white60 : Colors.green[800]),
            ),
          ),
        ],
      ),
    );
  }
}
