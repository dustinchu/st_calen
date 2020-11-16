import 'dart:ui' as ui;

import 'package:provider/provider.dart';
import 'package:stock_calendar/common/status/about_status.dart';
import 'package:stock_calendar/common/widget/dialog.dart';

import '../../common/model/company.dart';
import 'about_dets_intro_animation.dart';
import 'package:flutter/material.dart';

class AboutDetailsPage extends StatelessWidget {
  AboutDetailsPage({
    @required this.company,
    @required AnimationController controller,
    @required this.titleTextEditingController,
    @required this.bodyTextEditingController,
    @required this.contactTextEditingController,
  }) : animation = new AboutDetsIntroAnimation(controller);

  final Company company;
  final AboutDetsIntroAnimation animation;
  final TextEditingController titleTextEditingController;
  final TextEditingController bodyTextEditingController;
  final TextEditingController contactTextEditingController;
  Widget _createAnimation(BuildContext context, Widget child) {
    return new Stack(fit: StackFit.expand, children: <Widget>[
      // new Opacity(
      //     opacity: animation.bgdropOpacity.value,
      //     child: new Image.asset(
      //       company.backdropPhoto,
      //       fit: BoxFit.cover,
      //     )),
      new BackdropFilter(
        filter: new ui.ImageFilter.blur(
            sigmaX: animation.bgdropBlur.value,
            sigmaY: animation.bgdropBlur.value),
        child: new Container(
          // color: Colors.black.withOpacity(0.3),
          color: Colors.black,
          child: _createContent(context),
        ),
      ),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      body: new AnimatedBuilder(
          animation: animation.controller, builder: _createAnimation),
    );
  }

  Widget _createLogoAvatar(BuildContext context) {
    return new Transform(
      transform: new Matrix4.diagonal3Values(
          animation.avatarSize.value, animation.avatarSize.value, 1.0),
      alignment: Alignment.center,
      child: new Container(
        width: double.infinity,
        height: 110.0,

//        decoration: new BoxDecoration(
//            shape: BoxShape.circle,
//            border: new Border.all(color: Colors.white24)),
        margin: const EdgeInsets.only(top: 10.0, left: 10.0),

        child: Row(
          children: <Widget>[
            new IconButton(
                icon: Icon(
                  Icons.arrow_back_ios,
                  color: Colors.white,
                ),
                onPressed: () => Navigator.pop(context)),
            Text(
              "意見反饋",
              style: new TextStyle(
                  fontSize: 19 * animation.avatarSize.value + 2.0,
                  color: Colors.white70),
            ),
          ],
        ),
//        child: new ClipOval(
//           child: new Image.asset(company.logo),
//        ),
      ),
    );
  }

  Widget _createContent(BuildContext context) {
    var aboutState = Provider.of<AboutStatus>(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        _createLogoAvatar(context),
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _createAboutCompany(),
                _createCourseScroller(),
              ],
            ),
          ),
        ),
        SizedBox(height: 10),
        Center(
            child: aboutState.getAboutButtonStatus
                ? CircularProgressIndicator()
                : OutlineButton(
                    onPressed: () {
                      //判斷填寫資料
                      if (titleTextEditingController.text == "") {
                        showCupertinoDialog(context, "稱呼 不可空白！！");
                      } else if (bodyTextEditingController.text == "") {
                        showCupertinoDialog(context, "問題描述 不可空白！！");
                      } else {
                        Provider.of<AboutStatus>(context, listen: false)
                            .aboutClick(
                                titleTextEditingController.text,
                                bodyTextEditingController.text,
                                contactTextEditingController.text);
                        // showCupertinoDialog(context, "謝謝您的建議，會盡快回覆您");
                        titleTextEditingController.clear();
                        bodyTextEditingController.clear();
                        contactTextEditingController.clear();
                      }
                    },
                    child: Text(
                      "送出",
                      style: TextStyle(fontSize: 15),
                    ),
                    textColor: Colors.blue[200],
                    splashColor: Colors.white38,
                    borderSide: new BorderSide(color: Colors.white60),
                  )),
        SizedBox(height: 80),
      ],
    );
  }

  Widget _createAboutCompany() {
    return new Padding(
      padding: const EdgeInsets.only(left: 14.0, right: 14.0),
      child: new Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          new Text(
            company.name,
            style: new TextStyle(
                color: Colors.white.withOpacity(animation.nameOpacity.value),
                fontWeight: FontWeight.bold,
                fontSize: 30.0 * animation.avatarSize.value + 2.0),
          ),
          new Text(
            company.location,
            style: new TextStyle(
              color: Colors.white.withOpacity(animation.locationOpacity.value),
              fontWeight: FontWeight.w500,
            ),
          ),
          //Line/divider across
          Container(
            color: Colors.white.withOpacity(0.85),
            //decoration: new BoxDecoration(shape: BoxShape.rectangle, color: Colors.black.withOpacity(0.8)),
            margin: const EdgeInsets.symmetric(vertical: 14.0),
            width: animation.dividerWidth.value,
            height: 1.0,
          ),
          Text(
            company.about,
            style: TextStyle(
                color:
                    Colors.white.withOpacity(animation.biographyOpacity.value),
                height: 1.4),
          )
        ],
      ),
    );
  }

  Widget _createCourseScroller() {
    return new Padding(
      padding: const EdgeInsets.only(top: 14.0, left: 14, right: 14),
      child: Transform(
          transform: new Matrix4.translationValues(
              animation.courseScrollerXTranslation.value, 0.0, 0.0),
          child: new Opacity(
              opacity: animation.courseScrollerOpacity.value,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "稱呼:",
                    style: TextStyle(color: Colors.white, fontSize: 15),
                  ),
                  SizedBox(height: 10),
                  TextFormField(
                    controller: titleTextEditingController,
                    style: TextStyle(color: Colors.white),
                    keyboardType: TextInputType.text,
                    decoration: InputDecoration(
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors.white, //边线颜色为黄色
                          width: 0.5, //边线宽度为2
                        ),
                      ),
                      labelStyle: TextStyle(color: Colors.white),
                      counterText: '',
                      border: const OutlineInputBorder(),
                      hintText: "該如何稱呼您，建議填寫",
                      hintStyle: TextStyle(color: Colors.white54),
                    ),
                    maxLength: 20,
                    maxLines: 1,
                    // controller: titleClickController,
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Text(
                    "問題描述:",
                    style: TextStyle(color: Colors.white, fontSize: 15),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  TextFormField(
                    controller: bodyTextEditingController,
                    style: TextStyle(color: Colors.white),
                    keyboardType: TextInputType.text,
                    decoration: InputDecoration(
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors.white, //边线颜色为黄色
                          width: 0.5, //边线宽度为2
                        ),
                      ),
                      labelStyle: TextStyle(color: Colors.white),
                      counterText: '',
                      border: const OutlineInputBorder(),
                      hintText: "點擊填寫詳細內容",
                      hintStyle: TextStyle(color: Colors.white54),
                    ),
                    maxLines: 5,
                    // controller: titleClickController,
                  ),
                  SizedBox(height: 10),
                  Text(
                    "聯絡方式:",
                    style: TextStyle(color: Colors.white, fontSize: 15),
                  ),
                  SizedBox(height: 10),
                  TextFormField(
                    controller: contactTextEditingController,
                    style: TextStyle(color: Colors.white),
                    keyboardType: TextInputType.text,
                    decoration: InputDecoration(
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors.white, //边线颜色
                          width: 0.5, //边线宽度为2
                        ),
                      ),
                      labelStyle: TextStyle(color: Colors.white),
                      counterText: '',
                      border: const OutlineInputBorder(),
                      hintText: "為方便我們聯繫您，建議填寫",
                      hintStyle: TextStyle(color: Colors.white54),
                    ),
                    maxLength: 20,
                    maxLines: 1,
                    // controller: titleClickController,
                  ),
                ],
              ))),
    );
  }
}
