// import 'package:admob_flutter/admob_flutter.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'package:stock_calendar/common/status/home_status.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'common/model/preferences_repository_impl.dart';
import 'common/status/about_status.dart';
import 'common/status/image_status.dart';
import 'page/about/about_animator_screen.dart';
import 'page/home/home_screen.dart';
import 'page/image/image_screen.dart';
import 'page/type/type_screen.dart';

// Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
//   // If you're going to use other Firebase services in the background, such as Firestore,
//   // make sure you call `initializeApp` before using other Firebase services.
//   await Firebase.initializeApp();

//   print("Handling a background message: ${message.messageId}");
// }
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  //推播
  FirebaseMessaging messaging = FirebaseMessaging.instance;
  // FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  NotificationSettings settings = await messaging.requestPermission(
    alert: true,
    announcement: false,
    badge: true,
    carPlay: false,
    criticalAlert: false,
    provisional: false,
    sound: true,
  );

  print('User granted permission: ${settings.authorizationStatus}');
  // Admob.initialize();
  final preferencesRepository = PreferencesRepositoryImpl();

  preferencesRepository.getCalendarType.then((calendarModel) {
    initializeDateFormatting().then((_) => runApp(MyApp(calendarModel)));
  });
}

class MyApp extends StatelessWidget {
  var calendarModel;
  MyApp(this.calendarModel);
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: ImageStatus()),
        ChangeNotifierProvider.value(value: HomeStatus(calendarModel)),
        ChangeNotifierProvider.value(value: AboutStatus())
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: '股市行事曆',
        theme: ThemeData(
          primarySwatch: Colors.pink,
        ),
        initialRoute: '/',
        // home: HomeScreen(),
        routes: {
          '/': (context) => HomeScreen(),
          '/about': (context) => AboutAnimatorScreen(),
          '/image': (context) => ImageScreen(),
          '/type': (context) => TypeScreen()
        },
      ),
    );
  }
}
