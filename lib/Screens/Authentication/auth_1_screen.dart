import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pdc/Resuable%20components/loading.dart';
import 'package:pdc/Screens/landing_screen.dart';
import 'package:pdc/main.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vpn_connection_detector/vpn_connection_detector.dart';

import '../../Providers/auth_provider.dart';

class AuthScreen extends StatefulWidget {
  @override
  _AuthScreenState createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  String email = "";
  String password = "";
  String otp = "";
  var focusNode = FocusNode();
  bool enter = false;
  late StreamSubscription<ConnectivityResult> subscription;

  bool errorShow = false;
  final vpnDetector = VpnConnectionDetector();

  @override
  void initState() {
    super.initState();
  }

  // save

  Future logintodashboard() async {
    if (_formKey.currentState!.validate() == true) {
      _formKey.currentState!.save();

      setState(() {
        _isLoading = true;
      });
      Provider.of<AuthProvider>(context, listen: false)
          .login(email, password)
          .then((value) async {
            setState(() {
              _isLoading = false;
            });
            if (value == true) {
              SharedPreferences prefs = await SharedPreferences.getInstance();

              final userId = prefs.getString("usrid");

              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (context) =>
                      LandingPageScreen(userId: userId.toString()),
                ),
              );
            } else {}
          })
          .onError((error, stackTrace) {});
    } else {
      return;
    }
  }

  /// save end
  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    return errorShow
        ? Scaffold(
            backgroundColor: Colors.grey.shade400,
            body: Container(
              width: double.infinity,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Spacer(),
                  Text(
                    "No Connection Please try again",
                    style: TextStyle(
                      color: Colors.red,
                      fontSize: 34.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 30.h),
                  Icon(Icons.signal_wifi_connected_no_internet_4),
                  SizedBox(height: 30.h),
                  ElevatedButton(
                    onPressed: () {},
                    child: Text(
                      "Retry",
                      style: TextStyle(color: Colors.white, fontSize: 32.sp),
                    ),
                  ),
                  Spacer(),
                  IconButton(
                    icon: Icon(Icons.logout, color: Colors.white),
                    color: Colors.white,
                    onPressed: () async {
                      SharedPreferences prefs =
                          await SharedPreferences.getInstance();
                      await prefs.clear();
                      if (context.mounted) {
                        Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(
                            builder: (context) {
                              return MyApp();
                            },
                          ),
                          (route) => false,
                        );
                      }
                    },
                  ),
                ],
              ),
            ),
          )
        : Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomCenter,
                    colors: <Color>[
                      Color.fromARGB(255, 143, 182, 240),
                      Color.fromARGB(255, 3, 38, 91),
                      Color.fromARGB(255, 3, 38, 91),
                    ],
                  ),
                ),

                // child: BackdropFilter(
                //   filter: ImageFilter.blur(sigmaX: 6.0, sigmaY: 6.0),
                //   child: Container(
                //     decoration: BoxDecoration(color: Colors.white.withOpacity(0.0)),
                //   ),
                // ),
              ),
              Scaffold(
                backgroundColor: Colors.transparent,
                body: Padding(
                  padding: EdgeInsets.symmetric(horizontal: width * 0.03),
                  child: Form(
                    key: _formKey,
                    child: SingleChildScrollView(
                      child: Container(
                        height: 800.h,
                        padding: EdgeInsets.symmetric(
                          horizontal: 20.w,
                          vertical: 30.h,
                        ),
                        margin: EdgeInsets.only(
                          top: 220.h,
                          left: 40.w,
                          right: 40.w,
                        ),
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.white),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // SizedBox(height: height * 0.13),
                            // SizedBox(height: height * 0.1),
                            SizedBox(height: 20.h),

                            Image.asset("assets/jklogoo.png", fit: BoxFit.fill),
                            SizedBox(height: 50.h),

                            TextFormField(
                              obscureText: false,
                              cursorColor: Color.fromARGB(255, 3, 38, 91),
                              onSaved: (newValue) {
                                email = newValue.toString();
                                setState(() {});
                              },
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return "Employee code can't be empty";
                                } else {
                                  return null;
                                }
                              },
                              style: const TextStyle(color: Colors.black),
                              decoration: InputDecoration(
                                filled: true,
                                isDense: true,
                                fillColor: Colors.transparent,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                  borderSide: const BorderSide(
                                    color: Colors.grey,
                                    width: 2,
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                  borderSide: const BorderSide(
                                    color: Colors.grey,
                                    width: 2,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                  borderSide: const BorderSide(
                                    color: Color.fromARGB(255, 85, 132, 203),
                                    width: 2,
                                  ),
                                ),
                                labelText: "Enter Username",
                              ),
                              keyboardType: TextInputType.name,
                              textInputAction: TextInputAction.next,
                            ),

                            SizedBox(height: height * 0.02),

                            Padding(
                              padding: EdgeInsets.zero,
                              child: TextFormField(
                                obscureText: true,
                                cursorColor: Color.fromARGB(255, 3, 38, 91),
                                onSaved: (newValue) {
                                  password = newValue.toString();
                                  setState(() {});
                                },
                                validator: (value) {
                                  if (value!.isEmpty) {
                                    return "Employee code can't be empty";
                                  } else {
                                    return null;
                                  }
                                },
                                style: const TextStyle(color: Colors.black),
                                decoration: InputDecoration(
                                  filled: true,
                                  isDense: true,
                                  fillColor: Colors.transparent,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                    borderSide: const BorderSide(
                                      color: Colors.grey,
                                      width: 2,
                                    ),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                    borderSide: const BorderSide(
                                      color: Colors.grey,
                                      width: 2,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                    borderSide: const BorderSide(
                                      color: Color.fromARGB(255, 85, 132, 203),
                                      width: 2,
                                    ),
                                  ),
                                  labelText: "Enter Password",
                                ),
                                keyboardType: TextInputType.name,
                                textInputAction: TextInputAction.next,
                              ),
                            ),
                            SizedBox(height: 40.h),
                            SizedBox(
                              width: double.infinity,
                              height: 80.h,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Color.fromARGB(
                                    255,
                                    11,
                                    65,
                                    144,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                      8,
                                    ), // <-- Radius
                                  ),
                                ),
                                onPressed: () {
                                  logintodashboard();
                                },
                                child: Text(
                                  "Login",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontFamily: "NotoSans",
                                    fontWeight: FontWeight.w700,
                                    fontSize: 15,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: 40.h),

                            Container(
                              alignment: Alignment.center,
                              child: Text(
                                "Version 1",
                                style: TextStyle(
                                  color: Color.fromARGB(255, 19, 77, 163),
                                  fontFamily: "NotoSans",
                                  fontWeight: FontWeight.w600,
                                  fontSize: 19,
                                ),
                              ),
                            ),
                            SizedBox(height: 40.h),

                            Container(
                              alignment: Alignment.center,
                              child: Text(
                                "JKTyre copyright @All Right Resevered 2026",
                                style: TextStyle(
                                  color: Colors.black,
                                  fontFamily: "NotoSans",
                                  fontWeight: FontWeight.w600,
                                  fontSize: 26.sp,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              if (_isLoading)
                Center(child: LoaderTransparent(color: Colors.white)),
            ],
          );
  }
}
