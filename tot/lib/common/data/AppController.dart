import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:tot/NavigationService.dart';
import 'package:tot/common/data/API.dart';
import 'package:tot/common/data/BookmarkCache.dart';
import 'package:tot/common/data/cache.dart';
import 'package:tot/common/view/notify_view.dart';

class AppController extends GetxController {
  static AppController get to => Get.find<AppController>();
  static const storage = FlutterSecureStorage();
  final Rxn<RemoteMessage> message = Rxn<RemoteMessage>();

  Future<bool> initialize() async {
    NotificationSettings authStatus =
        await FirebaseMessaging.instance.requestPermission(
      alert: true,
      announcement: true,
      badge: true,
      carPlay: true,
      criticalAlert: true,
      provisional: true,
      sound: true,
    );

    // IOS foreground 알림 활성화
    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    // 안드로이드 기본 알림 채널 활성화
    const AndroidNotificationChannel androidNotificationChannel =
        AndroidNotificationChannel(
      'high_importance_channel', // id
      'High Importance Notifications', // name
      importance: Importance.max,
      description: 'This channel is used for important notifications.',
    );

    final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
        FlutterLocalNotificationsPlugin();
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(androidNotificationChannel);

    // 안드로이드 foreground 알림 활성화
    await flutterLocalNotificationsPlugin.initialize(
        InitializationSettings(
            android: AndroidInitializationSettings('@mipmap/ic_launcher'),
            iOS: DarwinInitializationSettings()),
        onDidReceiveNotificationResponse: (payload) async {
          print(payload.payload);
          NavigationService().navigateToScreen(const NotifyView());
        });
    // foreground 알림 생성
    FirebaseMessaging.onMessage.listen((RemoteMessage rm) {
      message.value = rm;
      RemoteNotification? notification = rm.notification;
      AndroidNotification? android = rm.notification?.android;

      if (notification != null && android != null) {
        flutterLocalNotificationsPlugin.show(
          0,
          notification.title,
          notification.body,
          const NotificationDetails(
            android: AndroidNotificationDetails(
              'high_importance_channel', // 채널 id
              'High Importance Notifications', // 채널 name
              channelDescription:
                  'This channel is used for important notifications.',
            ),
          ),
          payload: rm.data['argument'],
        );
      }
    });

    // background 상태 터치시
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage rm) {
      print(rm.data['argument']);
      NavigationService().navigateToScreen(const NotifyView());
    });

    final fcmToken = await FirebaseMessaging.instance.getToken();
    if (kDebugMode) {
      print(fcmToken);
    }

    if (FirebaseAuth.instance.currentUser != null &&
        !FirebaseAuth.instance.currentUser!.isAnonymous) {
      await API.changeDioToken();
      await BookmarkCache.to.loadBookmark();
      await getBookmarkByLoad();
      await getKeywordRankByLoad();
      await getFilterKeywordByLoad();
      await getUsersFavoritesByLoad();
      if (kDebugMode) {
        print(
            "is Anonymous? : ${FirebaseAuth.instance.currentUser!.isAnonymous}");
      }
    }
    if (FirebaseAuth.instance.currentUser == null ||
        FirebaseAuth.instance.currentUser!.isAnonymous) {
      await FirebaseAuth.instance.signInAnonymously();
      await API.changeDioToken();
      await getKeywordRankByLoad();
      await getFilterKeywordByLoad();
      if (kDebugMode) {
        print(
            "is Anonymous? : ${FirebaseAuth.instance.currentUser!.isAnonymous}");
      }
    }

    // 종료 상태에서 알림 터치시
    RemoteMessage? initialMessage =
    await FirebaseMessaging.instance.getInitialMessage();
    print("initMessage");
    if (initialMessage != null) {
      print(initialMessage.data['argument']);
      NavigationService().navigateToScreen(const NotifyView());
    }
    return true;
  }
}

Future<void> getBookmarkByLoad() async {
  final bookmark = await tokenCheck(() => API.getUserBookmark());
  if (bookmark != null) {
    userBookmark = bookmark.map((e) => e.id).toList();
  } else {
    userBookmark = [];
  }
}

Future<void> getKeywordRankByLoad() async {
  final temp = List<String>.from(await tokenCheck(() => API.getKeywordRank()));
  keywordListRank.addAll(temp!);
}

Future<void> getFilterKeywordByLoad() async {
  final temp = await tokenCheck(() => API.getFilterKeyword());
  filterKeyword = temp;
}

Future<void> getUsersFavoritesByLoad() async {
  final temp = await tokenCheck(() => API.getUserFavorites());
  userFilterKey = temp;
}
