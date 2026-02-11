import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pdc/Providers/auth_provider.dart';
import 'package:pdc/Providers/receiving_provider.dart';
import 'package:pdc/Screens/Authentication/auth_1_screen.dart';
import 'package:pdc/Screens/landing_screen.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  WidgetsFlutterBinding.ensureInitialized();

  runApp(MyApp());
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  configLoading();
}

void configLoading() {
  EasyLoading.instance
    ..displayDuration = const Duration(milliseconds: 2000)
    ..indicatorType = EasyLoadingIndicatorType.hourGlass
    ..loadingStyle = EasyLoadingStyle.dark
    ..indicatorSize = 45.0
    ..radius = 10.0
    ..progressColor = Colors.yellow
    ..backgroundColor = Colors.green
    ..indicatorColor = Colors.yellow
    ..textColor = Colors.yellow
    ..maskColor = Colors.blue.withOpacity(0.5)
    ..userInteractions = false
    ..dismissOnTap = false;
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => AuthProvider()),
        ChangeNotifierProvider(create: (context) => ReceivingProvider()),
      ],
      child: ScreenUtilInit(
        builder: (context, child) {
          return MaterialApp(
            theme: ThemeData(primarySwatch: Colors.blue),
            home: NavigationScreen(),
            debugShowCheckedModeBanner: false,
            builder: EasyLoading.init(),
          );
        },
        designSize: const Size(720, 1280),
      ),
    );
  }
}

class NavigationScreen extends StatefulWidget {
  @override
  _NavigationState createState() => _NavigationState();
}

class _NavigationState extends State<NavigationScreen> {
  void navigationPage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("userToken");
    final userId = prefs.getString("usrid");
    print(token);
    // await prefs.clear();
    // SharedPreferences prefs = await SharedPreferences.getInstance();
    // final token = prefs.getString("userToken");

    // log("$token tanay123token");

    if (token == null) {
      Navigator.of(
        context,
      ).pushReplacement(MaterialPageRoute(builder: (context) => AuthScreen()));
    } else {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => LandingPageScreen(userId: userId.toString()),
        ),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    navigationPage();
  }

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
