import 'dart:convert';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:imgur/imgur.dart' as imgur;
import 'package:stock_calendar/common/widget/toast.dart';
import 'package:uuid/uuid.dart';

class ImageStatus extends ChangeNotifier {
  //按鈕狀態
  bool imageButtonStatus = false;
  //圖片url
  String uploadImageLike = "";

  bool get getImageButtonStatus => imageButtonStatus;
  String get getImageUrl => uploadImageLike;
  final client = imgur.Imgur(imgur.Authentication.fromToken(
      'ac37315b94bedc89848063d0fdae81ddb8efe870'));

  void imageUpload(Uint8List _imageInMemory) async {
    imageButtonStatus = true;
    notifyListeners();
    var uuid = Uuid();
    String uid = uuid.v1();
    //firebase store

    try {
      //圖片上傳 得到url
      uploadGetImgUrl(uid, _imageInMemory).then((String url) async {
        uploadImageLike = url;
        notifyListeners();
      });
      await Firestore.instance
          .collection("images")
          .add({"url": uploadImageLike, "name": uid});
    } catch (e) {
      print(e);
    }
    imageButtonStatus = false;
    notifyListeners();
    // }
    // )
  }

  void saveImage(Uint8List _imageInMemory) async {
    imageButtonStatus = true;
    notifyListeners();
    try {
      final result = await ImageGallerySaver.saveImage(_imageInMemory);
      toastInfo("儲存完成");
    } catch (e) {
      toastInfo("儲存失敗");
    }

    imageButtonStatus = false;
    notifyListeners();
  }

  Image imageFromBase64String(String base64String) {
    return Image.memory(base64Decode(base64String));
  }

  Uint8List dataFromBase64String(String base64String) {
    return base64Decode(base64String);
  }

  String base64String(Uint8List data) {
    return base64Encode(data);
  }

  Future<String> uploadGetImgUrl(String uid, Uint8List _imageInMemory) async {
    firebase_storage.Reference ref =
        firebase_storage.FirebaseStorage.instance.ref('$uid.png');
    //上傳
    await ref.putData(_imageInMemory);
    //得到URL
    String url = await firebase_storage.FirebaseStorage.instance
        .ref('$uid.png')
        .getDownloadURL();
    print(url);
    return url;
  }
}
