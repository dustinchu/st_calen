import '../../repo/repo.dart';
import 'about_dets_page.dart';
import 'package:flutter/material.dart';

class AboutAnimatorScreen extends StatefulWidget {
  @override
  _AboutAnimatorScreenState createState() => new _AboutAnimatorScreenState();
}

class _AboutAnimatorScreenState extends State<AboutAnimatorScreen>
    with SingleTickerProviderStateMixin {
  AnimationController _controller;
  TextEditingController titleTextEditingController;
  TextEditingController bodyTextEditingController;
  TextEditingController contactTextEditingController;
  @override
  void initState() {
    super.initState();
    _controller = new AnimationController(
        duration: const Duration(milliseconds: 1800), vsync: this);
    titleTextEditingController = TextEditingController();
    bodyTextEditingController = TextEditingController();
    contactTextEditingController = TextEditingController();
    _controller.forward();
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return new AboutDetailsPage(
      company: RepoData.bawp,
      controller: _controller,
      titleTextEditingController: titleTextEditingController,
      bodyTextEditingController: bodyTextEditingController,
      contactTextEditingController: contactTextEditingController,
    );
  }
}
