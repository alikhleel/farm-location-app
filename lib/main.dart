// @dart=2.9

import 'package:farm_location_app/config/firebase_config.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import 'constant/color.dart';
import 'models/region.dart';
import 'models/user.dart';
import 'provider/app_provider.dart';
import 'screens/home_page.dart';
import 'screens/login_page.dart';
import 'screens/wrapper.dart';
import 'services/auth.dart';
import 'services/database.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    // Replace with actual values
    options: firebaseOptions,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final databaseService = DataBaseService();
    final authService = AuthService();

    Stream<bool> locationEventStream =
        Geolocator.isLocationServiceEnabled().asStream();
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(
          value: AppProvider(),
        ),
        FutureProvider<List<Region>>.value(
          value: databaseService.getRegions(),
          initialData: [],
        ),
        StreamProvider<User>.value(
            initialData: User(uid: null),
            value: authService.user), //provider will listen to value object.
        StreamProvider<bool>.value(
          initialData: false,
          value: locationEventStream,
        )
      ],
      child: MaterialApp(
        theme: ThemeData(
          scaffoldBackgroundColor: Colors.white,
          brightness: Brightness.light,
          primaryColor: const Color(ApplicationColor.primarycolor),
          fontFamily: 'Roboto',
          textTheme: const TextTheme(
              headline1: TextStyle(fontSize: 72.0, fontWeight: FontWeight.bold),
              headline5: TextStyle(
                  fontSize: 25.0,
                  fontWeight: FontWeight.bold,
                  fontStyle: FontStyle.normal,
                  color: Colors.black),
              headline6: TextStyle(
                  fontSize: 20.0,
                  fontStyle: FontStyle.normal,
                  fontWeight: FontWeight.bold),
              bodyText2: TextStyle(fontSize: 14.0),
              button: TextStyle(
                  fontSize: 20.0,
                  color: Colors.white,
                  fontWeight: FontWeight.normal,
                  fontStyle: FontStyle.normal),
              caption: TextStyle(color: Colors.black, fontSize: 16)),
          colorScheme: ColorScheme.fromSwatch()
              .copyWith(secondary: const Color(ApplicationColor.accentColor)),
          textSelectionTheme: const TextSelectionThemeData(
            cursorColor: Color(ApplicationColor.primarycolor),
            selectionHandleColor: Color(ApplicationColor.primarycolor),
          ),
        ),
        routes: {
          '/login-page': (context) => LoginPage(),
          '/home-page': (context) => HomePage()
        },
        builder: (context, child) {
          return Directionality(
            textDirection: TextDirection.rtl,
            child: child,
          );
        },
        home: const Wrapper(),
      ),
    );
  }
}
