import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'screens/home_screen/home_screen_view.dart';
import 'screens/add_medicine_screen/add_medicine_view.dart';
import 'screens/schedule_screen/schedule_view.dart';
import 'screens/home_screen/home_screen_view.dart';
import 'resources/app_colors.dart';
import 'services/local_notification.dart';

@pragma('vm:entry-point')
Future<void> backgroundHandler(RemoteMessage message) async {
  print(message.data.toString());
  print(message.notification!.title);
  // LocalNotificationService.displayNotification(countMedicine: '',day: '',minute: '2',hour: '2',pillName: '',message: message);
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  FirebaseMessaging.onBackgroundMessage(backgroundHandler);
  LocalNotificationService.initialize();
  tz.initializeTimeZones();

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Health App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.appOrange),
        useMaterial3: true,
      ),
      initialRoute: HomeScreenView.routeName,
      //home: HomeScreenView.builder(context),
      routes: {
        HomeScreenView.routeName: (context) => HomeScreenView.builder(context),
        AddMedicineView.routeName: (context) => AddMedicineView.builder(context),
        ScheduleView.routeName: (context) => ScheduleView.builder(context),
      },
    );
  }

  @override
  void initState() {
    initFirebase();
    super.initState();
  }
}

Future<void> initFirebase() async {
  // TODO: implement initState
  final token = await FirebaseMessaging.instance.getToken();
  print(token);

  await FirebaseMessaging.instance.getInitialMessage();

  FirebaseMessaging.onMessage.listen((message) {
    if (message.notification != null) {
      //print(message.notification?.body);
      //print(message.notification?.title);
    }
    LocalNotificationService.displayNotification(countMedicine: '', day: '', minute: '2', hour: '2', pillName: '', message: message);
  });

  FirebaseMessaging.onMessageOpenedApp.listen((message) {
    print(message.notification?.body);
    print(message.notification?.title);
  });
}
