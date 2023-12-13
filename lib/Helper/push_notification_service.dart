import 'dart:convert';
import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import '../Provider/SettingsProvider.dart';
import '../Widget/api.dart';
import '../Widget/jwtkeySecurity.dart';
import '../Widget/parameterString.dart';
import 'constant.dart';

FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();
FirebaseMessaging messaging = FirebaseMessaging.instance;

class PushNotificationService {
  final BuildContext context;

  PushNotificationService({required this.context});

  Future initialise() async {
    permission();
    messaging.getToken().then(
      (token) async {
        SettingProvider settingProvider = Provider.of<SettingProvider>(context, listen: false);
        CUR_USERID = await settingProvider.getPrefrence(ID);
        if (CUR_USERID != null && CUR_USERID != "") _registerToken(token);
      },
    );
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('ic_launcher');
    final DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings();
    final DarwinInitializationSettings initializationSettingsMacOS =
        DarwinInitializationSettings();
    final InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
      macOS: initializationSettingsMacOS,
    );

    flutterLocalNotificationsPlugin.initialize(initializationSettings);

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      var data = message.notification!;

      var title = data.title.toString();
      var body = data.body.toString();
      var image = message.data['image'] ?? '';
      var type ='';
      type=message.data['type'] ?? '';
      if (image != null && image != 'null' && image != '') {
        generateImageNotication(title, body, image, type);
      } else {
        generateSimpleNotication(title, body, type);
      }
    });

  }

  void permission() async {
    await messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );
    await messaging.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );
  }

  void _registerToken(String? token) async {
    var parameter = {USER_ID: CUR_USERID, FCM_ID: token};

    Response response =
        await post(updateFcmApi, body: parameter, headers: headers)
            .timeout(Duration(seconds: timeOut));

    var getdata = json.decode(response.body);
  }

  static Future<String> _downloadAndSaveImage(
      String url, String fileName) async {
    var directory = await getApplicationDocumentsDirectory();
    var filePath = '${directory.path}/$fileName';
    var response = await http.get(Uri.parse(url));

    var file = File(filePath);
    await file.writeAsBytes(response.bodyBytes);
    return filePath;
  }

  // static Future<void> generateImageNotication(
  //     String title, String msg, String image, String type) async {
  //   var largeIconPath = await _downloadAndSaveImage(image, 'largeIcon');
  //   var bigPicturePath = await _downloadAndSaveImage(image, 'bigPicture');
  //   var bigPictureStyleInformation = BigPictureStyleInformation(
  //       FilePathAndroidBitmap(bigPicturePath),
  //       hideExpandedLargeIcon: true,
  //       contentTitle: title,
  //       htmlFormatContentTitle: true,
  //       summaryText: msg,
  //       htmlFormatSummaryText: true);
  //   var androidPlatformChannelSpecifics = AndroidNotificationDetails(
  //       // 'big text channel id', 'big text channel name',
  //       // channelDescription: 'big text channel description',
  //       // icon: '@mipmap/ic_launcher',
  //       // largeIcon: FilePathAndroidBitmap(largeIconPath),
  //       // styleInformation: bigPictureStyleInformation,
  //       // playSound: true,
  //       // enableVibration: true,
  //       // enableLights: true,
  //       // sound: RawResourceAndroidNotificationSound('test')
  //
  //       'big text channel id', 'big text channel name',
  //       channelDescription: 'big text channel description',
  //       icon: '@mipmap/ic_launcher',
  //       largeIcon: FilePathAndroidBitmap(largeIconPath),
  //       styleInformation: bigPictureStyleInformation,
  //       playSound: true,
  //       enableVibration: true,
  //       enableLights: true,
  //       sound: RawResourceAndroidNotificationSound('test')
  //   );
  //   var platformChannelSpecifics =
  //       NotificationDetails(android: androidPlatformChannelSpecifics);
  //   await flutterLocalNotificationsPlugin
  //       .show(0, title, msg, platformChannelSpecifics, payload: type);
  // }

  // static Future<void> generateSimpleNotication(
  //     String title, String msg, String type) async {
  //   var androidPlatformChannelSpecifics = AndroidNotificationDetails(
  //     'your channel id',
  //     'your channel name',
  //     channelDescription: 'your channel description',
  //     importance: Importance.max,
  //     priority: Priority.high,
  //       icon: '@mipmap/ic_launcher',
  //     ticker: 'ticker',
  //     playSound: true,
  //     enableVibration: true,
  //     enableLights: true,
  //     sound: RawResourceAndroidNotificationSound('test')
  //   );
  //
  //   var platformChannelSpecifics =
  //       NotificationDetails(android: androidPlatformChannelSpecifics);
  //   await flutterLocalNotificationsPlugin
  //       .show(0, title, msg, platformChannelSpecifics, payload: type);
  // }
  static Future<void> generateImageNotication(
      String title, String msg, String image,String type) async {
    print('__________surendra_________');
    var largeIconPath = await _downloadAndSaveImage(image, 'largeIcon');
    var bigPicturePath = await _downloadAndSaveImage(image, 'bigPicture');
    var bigPictureStyleInformation = BigPictureStyleInformation(

        FilePathAndroidBitmap(bigPicturePath),
        hideExpandedLargeIcon: true,
        contentTitle: title,
        htmlFormatContentTitle: true,
        summaryText: msg,
        htmlFormatSummaryText: true);
    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
        'big text channel id',
        'big text channel name',
        channelDescription:'big text channel description',
        largeIcon: FilePathAndroidBitmap(largeIconPath),
        // playSound: true,
        // sound: RawResourceAndroidNotificationSound('test'),

        styleInformation: bigPictureStyleInformation);
    var platformChannelSpecifics =
    NotificationDetails(android: androidPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.show(
        0, title, msg, platformChannelSpecifics,payload: type);
  }
  static Future<void> generateSimpleNotication(String title, String msg,String type) async {
    print('__________hhhhhhhh_________');
    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
        'default_notification_channel', 'your channel name', channelDescription:'your channel description',
        importance: Importance.max, priority: Priority.high,
        playSound: true,
        enableVibration: true,
        enableLights: true,
        color: const Color.fromARGB(255, 255, 0, 0),
        ledColor: const Color.fromARGB(255, 255, 0, 0),
        ledOnMs: 1000,
        ledOffMs: 500,
        sound: RawResourceAndroidNotificationSound('test'),
        ticker: 'ticker'
    );
    var platformChannelSpecifics =
    NotificationDetails(android: androidPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin
        .show(0, title, msg, platformChannelSpecifics, payload:type );
  }
}

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print('Handling a background message ${message.messageId}');
}
