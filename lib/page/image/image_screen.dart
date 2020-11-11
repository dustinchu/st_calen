import 'package:firebase_admob/firebase_admob.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:stock_calendar/common/model/admob_service.dart';
import 'package:stock_calendar/common/status/home_status.dart';
import 'package:stock_calendar/common/status/image_status.dart';
import 'package:provider/provider.dart';

class ImageScreen extends StatefulWidget {
  ImageScreen({Key key}) : super(key: key);

  @override
  _ImageScreenState createState() => _ImageScreenState();
}

class _ImageScreenState extends State<ImageScreen> {
  // MobileAdTargetingInfo targetingInfo = MobileAdTargetingInfo(
  //   keywords: <String>['game', 'words'],
  // );
  BannerAd _bannerAd;

  @override
  void initState() {
    FirebaseAdMob.instance.initialize(appId: getadMobAppid());
    InterstitialAd _interstitialAd;
    _interstitialAd?.dispose();
    _interstitialAd = createInterstitialAd()..load();
    _interstitialAd?.show();
    //廣告

    // BannerAd _bannerAd;
    // _bannerAd = createBannerAd()
    //   ..load()
    //   ..show();
    super.initState();
  }

  InterstitialAd createInterstitialAd() {
    return InterstitialAd(
      adUnitId: getInterstitialAdUnitId(),
      // adUnitId: InterstitialAd.testAdUnitId,
      targetingInfo: targetingInfo,
      listener: (MobileAdEvent event) {
        print("InterstitialAd event $event");
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    _bannerAd ??= createBannerAd();
    _bannerAd
      ..load()
      ..show();
    var imageState = Provider.of<ImageStatus>(context);
    var _imageInMemory = ModalRoute.of(context).settings.arguments;
    // var model = Provider.of<ImageStatus>(context);
    return Scaffold(
      // backgroundColor: Color.fromRGBO(220, 225, 231, 1.00),
      backgroundColor: Colors.black,
      body: Stack(
        alignment: Alignment.bottomCenter,
        fit: StackFit.expand, //未定位widget占满Stack整个空间
        children: [
          new Container(
            padding: EdgeInsets.only(top: 25, bottom: 20),
            width: double.infinity,
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
                            Provider.of<HomeStatus>(context, listen: false)
                                .homeClick();
                            Navigator.pop(context);
                          }),
                      Text(
                        "圖片預覽",
                        style:
                            new TextStyle(fontSize: 19, color: Colors.white70),
                      ),
                    ],
                  ),
                ),
                Expanded(child: Container()),
                Padding(
                  padding: EdgeInsets.only(left: 10, right: 10),
                  child: Image.memory(_imageInMemory),
                ),
                // UrlText(),
                Padding(
                  padding: EdgeInsets.only(top: 50),
                  child: imageState.getImageButtonStatus
                      ? CircularProgressIndicator(
                          backgroundColor: Colors.blue[800],
                        )
                      : OutlineButton(
                          onPressed: () async {
                            Provider.of<ImageStatus>(context, listen: false)
                                .saveImage(_imageInMemory);
                          },
                          child: Text(
                            "保存",
                            style: TextStyle(fontSize: 15),
                          ),
                          textColor: Colors.blue[200],
                          splashColor: Colors.white38,
                          borderSide: new BorderSide(color: Colors.white60),
                        ),
                ),
                // : ButtonRow(
                //     imageInMemory: _imageInMemory,
                //   ),
                Expanded(child: Container()),
              ],
            ),
          ),
          // Positioned(
          //   bottom: 20,
          //   child: BannerAd(
          //     bannerSize: bannerSize,
          //   ),
          // ),
        ],
      ),
    );
    // return Container(
    //     child: Image.memory(imageInMemory), margin: EdgeInsets.all(10));
  }
}

// class ImageScreen extends StatelessWidget {
//   // AdmobBannerSize bannerSize = AdmobBannerSize.BANNER;
//   @override
//   Widget build(BuildContext context) {
//     var imageState = Provider.of<ImageStatus>(context);
//     var _imageInMemory = ModalRoute.of(context).settings.arguments;
//     // var model = Provider.of<ImageStatus>(context);
//     return Scaffold(
//       // backgroundColor: Color.fromRGBO(220, 225, 231, 1.00),
//       backgroundColor: Colors.black,
//       body: Stack(
//         alignment: Alignment.bottomCenter,
//         fit: StackFit.expand, //未定位widget占满Stack整个空间
//         children: [
//           new Container(
//             padding: EdgeInsets.only(top: 40, bottom: 20),
//             width: double.infinity,
//             child: Column(
//               children: [
//                 Padding(
//                   padding: EdgeInsets.only(left: 10, right: 10),
//                   child: Row(
//                     children: <Widget>[
//                       new IconButton(
//                           icon: Icon(
//                             Icons.arrow_back_ios,
//                             color: Colors.white,
//                           ),
//                           onPressed: () => Navigator.pop(context)),
//                       Text(
//                         "圖片預覽",
//                         style: new TextStyle(fontSize: 19, color: Colors.white),
//                       ),
//                     ],
//                   ),
//                 ),
//                 Expanded(child: Container()),
//                 Padding(
//                   padding: EdgeInsets.only(left: 10, right: 10),
//                   child: Image.memory(_imageInMemory),
//                 ),
//                 // UrlText(),
//                 Padding(
//                   padding: EdgeInsets.only(top: 50),
//                   child: imageState.getImageButtonStatus
//                       ? CircularProgressIndicator()
//                       : OutlineButton(
//                           onPressed: () => print("click"),
//                           child: Text(
//                             "保存",
//                             style: TextStyle(fontSize: 15),
//                           ),
//                           textColor: Colors.blue[200],
//                           splashColor: Colors.white38,
//                           borderSide: new BorderSide(color: Colors.white60),
//                         ),
//                 ),
//                 // : ButtonRow(
//                 //     imageInMemory: _imageInMemory,
//                 //   ),
//                 Expanded(child: Container()),
//               ],
//             ),
//           ),
//           // Positioned(
//           //   bottom: 20,
//           //   child: BannerAd(
//           //     bannerSize: bannerSize,
//           //   ),
//           // ),
//         ],
//       ),
//     );
//     // return Container(
//     //     child: Image.memory(imageInMemory), margin: EdgeInsets.all(10));
//   }
// }
