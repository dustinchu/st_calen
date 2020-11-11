import 'dart:ui' as ui;

import 'package:flutter/material.dart';

class AboutPageAnimator extends StatefulWidget {
  @override
  _AboutPageAnimatorState createState() => new _AboutPageAnimatorState();
}

class _AboutPageAnimatorState extends State<AboutPageAnimator>
    with SingleTickerProviderStateMixin {
  AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = new AnimationController(
        duration: const Duration(milliseconds: 2000),
        vsync: this);
    _controller.forward();
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return new AboutPageAnimator();
  }
}



