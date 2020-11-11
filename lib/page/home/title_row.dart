import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:stock_calendar/common/model/calendar.dart';
import 'package:stock_calendar/common/color/hex_color.dart';

class TitleRow extends StatelessWidget {
  final String title;

  TitleRow({
    @required this.title,
  });
  @override
  Widget build(BuildContext context) {
    var def = calendarType('black');
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(left: 10, top: 10, bottom: 10),
            child: AutoSizeText(
              title,
              style: TextStyle(
                color: '${def['title_text']}'.toColor(),
                fontSize: 20,
                fontFamily: 'Montserrat',
                fontWeight: FontWeight.w400,
                letterSpacing: 3,
              ),
              minFontSize: 15,
              stepGranularity: 5,
              maxLines: 1,
            ),
          ),
        ),
      ],
    );
  }
}
