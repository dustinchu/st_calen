import 'package:flutter/material.dart';

class IndexCircular extends StatelessWidget {
  Color _color;
  IndexCircular({Key key, Color color})
      : _color = color,
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 10, right: 2, left: 2),
      child: Container(
        decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.blue),
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: true
                ? Icon(
                    Icons.check,
                    size: 30.0,
                    color: Colors.white,
                  )
                : Icon(
                    Icons.check_box_outline_blank,
                    size: 30.0,
                    color: Colors.blue,
                  ),
          ),
        // child: new ClipRRect(
        //   borderRadius: const BorderRadius.all(const Radius.circular(30.0)),
        //   child: new Container(
        //     width: 15.0,
        //     height: 15.0,
        //     color: _color,
        //   ),
        // ),
      ),
    );
  }
}
