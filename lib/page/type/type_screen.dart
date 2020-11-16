import 'dart:async';

import 'package:circular_check_box/circular_check_box.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
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
// class TypeScreen extends StatefulWidget {
//   @override
//   State<StatefulWidget> createState() => _TypeScreen();
// }

// class _TypeScreen extends State<TypeScreen> {
//   PurchaserInfo _purchaserInfo;
//   Offerings _offerings;

//   @override
//   void initState() {
//     super.initState();
//     initPlatformState();
//     inState();
//     // try {
//     //   Offerings offerings = await Purchases.getOfferings();
//     //   if (offerings.current != null &&
//     //       offerings.current.availablePackages.isNotEmpty) {
//     //         print(offerings.current.monthly);
//     //     // Display packages for sale
//     //   }
//     // } on PlatformException catch (e) {
//     //   // optional error handling
//     // }
//   }

//   Future<void> inState() async {
//     try {
//       Offerings offerings = await Purchases.getOfferings();
//       if (offerings
//           .getOffering("stock_calendar")
//           .availablePackages
//           .isNotEmpty) {
//             print("yYY");
//         // Display packages for sale
//       }
//     } on PlatformException catch (e) {
//       // optional error handling
//     }
//   }

//   Future<void> initPlatformState() async {
//     await Purchases.setDebugLogsEnabled(true);
//     await Purchases.setup("tJXZSxVMyVLFWiLfMdiZcccHpPdOEnkZ");
//     PurchaserInfo purchaserInfo = await Purchases.getPurchaserInfo();
//     Offerings offerings = await Purchases.getOfferings();
//     // If the widget was removed from the tree while the asynchronous platform
//     // message was in flight, we want to discard the reply rather than calling
//     // setState to update our non-existent appearance.
//     if (!mounted) return;

//     setState(() {
//       _purchaserInfo = purchaserInfo;
//       _offerings = offerings;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     if (_purchaserInfo == null) {
//       return Scaffold(
//         appBar: AppBar(title: Text("RevenueCat Sample App")),
//         body: Center(
//           child: Text("Loading..."),
//         ),
//       );
//     } else {
//       var isPro = _purchaserInfo.entitlements.active.containsKey("pro_cat");
//       if (isPro) {
//         return CatsScreen();
//       } else {
//         return UpsellScreen(
//           offerings: _offerings,
//         );
//       }
//     }
//   }
// }

// class UpsellScreen extends StatelessWidget {
//   final Offerings offerings;

//   UpsellScreen({Key key, @required this.offerings}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     if (offerings != null) {
//       final offering = offerings.current;
//       if (offering != null) {
//         final monthly = offering.monthly;
//         final lifetime = offering.lifetime;
//         if (monthly != null && lifetime != null) {
//           return Scaffold(
//               appBar: AppBar(title: Text("Upsell Screen")),
//               body: Center(
//                   child: Column(
//                 mainAxisSize: MainAxisSize.min,
//                 children: <Widget>[
//                   PurchaseButton(package: monthly),
//                   PurchaseButton(package: lifetime)
//                 ],
//               )));
//         }
//       }
//     }
//     return Scaffold(
//         appBar: AppBar(title: Text("Upsell Screen")),
//         body: Center(
//           child: Text("Loading..."),
//         ));
//   }
// }

// class PurchaseButton extends StatelessWidget {
//   final Package package;

//   PurchaseButton({Key key, @required this.package}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return RaisedButton(
//       onPressed: () async {
//         try {
//           PurchaserInfo purchaserInfo =
//               await Purchases.purchasePackage(package);
//           var isPro = purchaserInfo.entitlements.all["pro_cat"].isActive;
//           if (isPro) {
//             return CatsScreen();
//           }
//         } on PlatformException catch (e) {
//           var errorCode = PurchasesErrorHelper.getErrorCode(e);
//           if (errorCode == PurchasesErrorCode.purchaseCancelledError) {
//             print("User cancelled");
//           } else if (errorCode == PurchasesErrorCode.purchaseNotAllowedError) {
//             print("User not allowed to purchase");
//           }
//         }
//         return TypeScreen();
//       },
//       child: Text("Buy - (${package.product.priceString})"),
//     );
//   }
// }

// class CatsScreen extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//         appBar: AppBar(title: Text("Cats Screen")),
//         body: Center(
//           child: Text("User is pro"),
//         ));
//   }
// }
