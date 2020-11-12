import 'dart:async';

import 'package:circular_check_box/circular_check_box.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stock_calendar/common/status/home_status.dart';

class TypeScreen extends StatefulWidget {
  TypeScreen({Key key}) : super(key: key);

  @override
  _TypeScreenState createState() => _TypeScreenState();
}

bool status = false;

class _TypeScreenState extends State<TypeScreen> {
  @override
  void initState() {
    
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var homeState = Provider.of<HomeStatus>(context);
    return Scaffold(
      backgroundColor: Colors.black,
      body: Container(
        padding: EdgeInsets.only(top: 25, bottom: 20),
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.only(left: 10, right: 10),
              child: Row(
                children: <Widget>[
                  new IconButton(
                      icon: Icon(
                        Icons.arrow_back_ios,
                        color: Colors.white,
                      ),
                      onPressed: () {
                        // Provider.of<HomeStatus>(context, listen: false)
                        //     .homeClick();
                        Navigator.pop(context);
                      }),
                  Text(
                    "樣式選擇",
                    style: new TextStyle(fontSize: 19, color: Colors.white70),
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.only(left: 10, right: 10),
              child: Row(children: <Widget>[
                Expanded(
                  child: InkWell(
                    onTap: () => {
                      Provider.of<HomeStatus>(context, listen: false)
                          .setCalendarModel(1),
                      Provider.of<HomeStatus>(context, listen: false)
                          .setCalendarIndex('1')
                    },
                    child: Column(children: <Widget>[
                      Image.asset(
                        'assets/img_def.png',
                        height: 200,
                      ),
                      CircularCheckBox(
                          checkColor: Colors.white,
                          activeColor: Colors.blue[800],
                          inactiveColor: Colors.white60,
                          disabledColor: Colors.grey,
                          value: homeState.getCalendarIndexType == '1',
                          materialTapTargetSize: MaterialTapTargetSize.padded,
                          onChanged: (bool x) {
                            Provider.of<HomeStatus>(context, listen: false)
                                .setCalendarModel(1);
                            Provider.of<HomeStatus>(context, listen: false)
                                .setCalendarIndex('1');
                          }),
                      // IndexCircular(color: Colors.white54)
                    ]),
                  ),
                ),
                SizedBox(
                  width: 20,
                ),
                Expanded(
                  child: InkWell(
                    onTap: () => {
                      Provider.of<HomeStatus>(context, listen: false)
                          .setCalendarModel(2),
                      Provider.of<HomeStatus>(context, listen: false)
                          .setCalendarIndex('2'),
                    },
                    child: Column(
                      children: <Widget>[
                        Image.asset(
                          'assets/img_black.png',
                          height: 200,
                        ),
                        CircularCheckBox(
                            checkColor: Colors.white,
                            activeColor: Colors.blue[800],
                            inactiveColor: Colors.white60,
                            disabledColor: Colors.grey,
                            value: homeState.getCalendarIndexType == '2',
                            materialTapTargetSize: MaterialTapTargetSize.padded,
                            onChanged: (bool x) {
                              Provider.of<HomeStatus>(context, listen: false)
                                  .setCalendarModel(2);
                              Provider.of<HomeStatus>(context, listen: false)
                                  .setCalendarIndex('2');
                              // setState(() {
                              //   status = !status;
                              // });
                              // print(status);
                            }),
                      ],
                    ),
                  ),
                ),
              ]),
            )
          ],
        ),
      ),
    );
  }
}
