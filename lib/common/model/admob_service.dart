import 'dart:io';

import 'package:firebase_admob/firebase_admob.dart';


String getadMobAppid() {
  if (Platform.isIOS) {
    return 'ca-app-pub-3136608336853382~4599675706';
  } else if (Platform.isAndroid) {
    return 'ca-app-pub-3136608336853382~7636902588';
  }
  return null;
}

String getBannerAdUnitId() {
  if (Platform.isIOS) {
    return 'ca-app-pub-3136608336853382/8673323099';
  } else if (Platform.isAndroid) {
    return 'ca-app-pub-3136608336853382/1043574072';
  }
  return null;
}

String getInterstitialAdUnitId() {
  if (Platform.isIOS) {
    return 'ca-app-pub-3136608336853382/6439370982';
  } else if (Platform.isAndroid) {
    return 'ca-app-pub-3136608336853382/6295900759';
  }
  return null;
}

MobileAdTargetingInfo targetingInfo = MobileAdTargetingInfo(
  keywords: <String>['game', 'words'],
);
BannerAd createBannerAd() {
  return BannerAd(
    // adUnitId: BannerAd.testAdUnitId,
    adUnitId: getBannerAdUnitId(),
    size: AdSize.banner,
    targetingInfo: targetingInfo,
    listener: (MobileAdEvent event) {
      print("BannerAd event $event");
    },
  );
}
// String getRewardBasedVideoAdUnitId() {
//   if (Platform.isIOS) {
//     return 'ca-app-pub-3940256099942544/1712485313';
//   } else if (Platform.isAndroid) {
//     return 'ca-app-pub-3940256099942544/5224354917';
//   }
//   return null;
// }
// }
