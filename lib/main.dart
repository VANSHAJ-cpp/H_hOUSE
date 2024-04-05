// ignore_for_file: unused_local_variable

import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:flutter/material.dart';
import 'package:hostelapplication/firebase_options.dart';
import 'package:hostelapplication/logic/provider/complaint_provider.dart';
import 'package:hostelapplication/logic/provider/leave_provider.dart';
import 'package:hostelapplication/logic/provider/notice_provider.dart';
import 'package:hostelapplication/logic/provider/service_provider.dart';
import 'package:hostelapplication/logic/provider/slider_images_provider.dart';
import 'package:hostelapplication/logic/provider/userData_provider.dart';
import 'package:hostelapplication/logic/service/auth_services/auth_service.dart';
import 'package:hostelapplication/logic/service/fireStoreServices/complaint_firestore_service.dart';
import 'package:hostelapplication/logic/service/fireStoreServices/leave_firestore_service.dart';
import 'package:hostelapplication/logic/service/fireStoreServices/notice_firestore_service.dart';
import 'package:hostelapplication/logic/service/fireStoreServices/service_firestore_service.dart';
import 'package:hostelapplication/logic/service/fireStoreServices/user_firestore_services.dart';
import 'package:hostelapplication/presentation/router/route.dart';
import 'package:hostelapplication/presentation/screen/onBordingScreen.dart';
import 'package:hostelapplication/presentation/screen/onboard_model.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_core/firebase_core.dart';

Future<void> main() async {
  int? initScreen;

  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferences prefs = await SharedPreferences.getInstance();
  initScreen = prefs.getInt("initScreen");
  await prefs.setInt("initScreen", 1);
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await FirebaseAppCheck.instance.activate(
    webProvider: ReCaptchaV3Provider('recaptcha-v3-site-key'),
    androidProvider: AndroidProvider.debug,
    appleProvider: AppleProvider.appAttest,
  );
  runApp(
    MultiProvider(
      providers: [
        StreamProvider.value(
          value: ServiceFirestoreService().getService(),
          initialData: null,
        ),
        StreamProvider.value(
          value: LeaveFirestoreService().getLeave(),
          initialData: null,
        ),
        StreamProvider.value(
          value: NoticeFirestoreService().getNotice(),
          initialData: null,
        ),
        StreamProvider.value(
          value: ComplaintFirestoreService().getComplaintForAdmin(),
          initialData: null,
        ),
        StreamProvider.value(
          value: UserDataFirestoreService().getUserData(),
          initialData: null,
        ),
        ChangeNotifierProvider.value(
          value: NoticeProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => SliderImagesProvider(),
        ),
        ChangeNotifierProvider.value(
          value: ComplaintProvider(),
        ),
        ChangeNotifierProvider.value(
          value: UsereDataProvider(),
        ),
        ChangeNotifierProvider.value(
          value: LeaveProvider(),
        ),
        ChangeNotifierProvider.value(
          value: ServiceProvider(),
        ),
        Provider<AuthService>(
          create: (_) => AuthService(),
        ),
        Provider<UserDataFirestoreService>(
          create: (_) => UserDataFirestoreService(),
        ),
        Provider(create: (_) => const OnboardingScreen()),
        Provider(create: (_) => SplashModel())
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primaryColor: Colors.blue.shade900,
        fontFamily: "Brazila",
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: AppBarTheme(
          color: Colors.blue.shade900,
          elevation: 0.0,
          iconTheme: const IconThemeData(color: Colors.white),
          toolbarTextStyle:
              Theme.of(context).textTheme.bodyText2, // Use toolbarTextStyle
          titleTextStyle:
              Theme.of(context).textTheme.headline6, // Use titleTextStyle
        ),
        buttonTheme: ButtonThemeData(
          buttonColor: Colors.blue.shade900,
          textTheme: ButtonTextTheme.primary,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.orange,
          ),
        ),
        colorScheme: ColorScheme.fromSwatch()
            .copyWith(
              secondary: Colors.orange,
            )
            .copyWith(secondary: Colors.orange),
      ),
      debugShowCheckedModeBanner: false,
      onGenerateRoute:
          Routes.generateRoute, // If you have route generation logic
    );
  }
}
