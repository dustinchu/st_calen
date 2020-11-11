import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:device_info/device_info.dart';
import 'package:flutter/material.dart';
import 'package:stock_calendar/common/widget/toast.dart';

class AboutStatus extends ChangeNotifier {
  //按鈕狀態
  bool aboutButtonStatus = false;

  bool get getAboutButtonStatus => aboutButtonStatus;

  DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
  String driverID;
  void aboutClick(String name, String body, String address) async {
    try {
      //得到設備id
      if (Platform.isIOS) {
        IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
        driverID = iosInfo.identifierForVendor;
      } else {
        AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
        driverID = androidInfo.androidId;
      }
      //延遲狀態
      aboutButtonStatus = true;
      notifyListeners();
      //firebase 寫入
       toastInfo("driver=$driverID   name1=$name  body=$body address=$address datetime=${DateTime.now()}");
    
      await FirebaseFirestore.instance.collection("about").add({
        "driver": driverID,
        "name1": name,
        "body": body,
        "address": address,
        "datetime": '${DateTime.now()}'
      });
      toastInfo("driver=$driverID   name1=$name  body=$body address=$address datetime=${DateTime.now()}");
      aboutButtonStatus = false;
      notifyListeners();
    } catch (e) {
      toastInfo("寫入發生錯誤");
      aboutButtonStatus = false;
      notifyListeners();
    }
  }
}
