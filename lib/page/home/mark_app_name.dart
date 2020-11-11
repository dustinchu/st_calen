import 'package:flutter/material.dart';
import 'package:stock_calendar/common/model/calendar.dart';
import 'package:stock_calendar/common/color/hex_color.dart';
class MarkAppName extends StatelessWidget {
  var homeState;
  MarkAppName(this.homeState);
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          color: '${homeState.getCalendarModel['calendar_background']}'.toColor(),
          borderRadius:
              new BorderRadius.vertical(bottom: Radius.elliptical(8, 8))),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text(
            "by 股市行事曆",
            style: TextStyle(color: Colors.blue[800]),
          ),
          SizedBox(width: 10),
        ],
      ),
    );
  }
}
