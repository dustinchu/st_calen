import 'dart:math';

import 'package:circular_menu/circular_menu.dart';
import 'package:flutter/material.dart';

class Menu extends StatelessWidget {
  var reset ;
  Menu({@required this.reset});
  @override
  Widget build(BuildContext context) {
    return CircularMenu(
      alignment: Alignment.bottomRight,
      radius: 70,
      startingAngleInRadian: 1.05 * pi,
      endingAngleInRadian: 1.50 * pi,
      // backgroundWidget: Center(
      //   child: RichText(
      //     text: TextSpan(
      //       style: TextStyle(color: Colors.black, fontSize: 28),
      //       children: <TextSpan>[
      //         TextSpan(
      //           text: _colorName,
      //           style: TextStyle(color: _color, fontWeight: FontWeight.bold),
      //         ),
      //         TextSpan(text: ' button is clicked.'),
      //       ],
      //     ),
      //   ),
      // ),
      toggleButtonSize: 20,
      toggleButtonColor: Colors.blue[700],
      items: [
        // CircularMenuItem(
        //     icon: Icons.home, color: Colors.green, onTap: () => print("home")),
        CircularMenuItem(
            icon: Icons.photo_size_select_large,
            color: Colors.purple,
            iconSize: 20,
            onTap: () => Navigator.pushNamed(context, '/type')),
        CircularMenuItem(
            iconSize: 20,
            icon: Icons.person,
            color: Colors.brown,
            onTap: () => Navigator.pushNamed(context, '/about')),
              CircularMenuItem(
            iconSize: 20,
            icon: Icons.restore,
            color: Colors.tealAccent[900],
            onTap: reset),
      ],
    );
  }
}
