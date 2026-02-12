import 'dart:async';
import 'dart:developer';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';

import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:pdc/Providers/auth_provider.dart';
import 'package:pdc/Providers/receiving_provider.dart';
import 'package:pdc/Resuable%20components/loading.dart';
import 'package:pdc/Resuable%20components/text_field.dart';
import 'package:pdc/Screens/Receiving_screen.dart/add_receiving_screen.dart';
import 'package:pdc/Screens/Receiving_screen.dart/receiving_screen.dart';
import 'package:pdc/main.dart';
import 'package:vpn_connection_detector/vpn_connection_detector.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ignore: must_be_immutable
class LandingPageScreen extends StatefulWidget {
  String userId;
  LandingPageScreen({required this.userId});
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<LandingPageScreen> {
  bool _isLoading = false;
  String valueSelect = "";
  String forwardValue = "";
  String erName = "";
  bool _isLoadingInside = false;
  late StreamSubscription<ConnectivityResult> subscription;
  final vpnDetector = VpnConnectionDetector();

  bool errorShow = false;
  final _formKey = GlobalKey<FormState>();

  TextEditingController locationController = TextEditingController();
  TextEditingController oldPasswordController = TextEditingController();
  TextEditingController newPasswordController = TextEditingController();
  String userId = "";

  void initState() {
    super.initState();

    setState(() {
      _isLoading = true;
    });

    Provider.of<AuthProvider>(context, listen: false)
        .getLocation(context)
        .then((value) {
          valueSelect = Provider.of<AuthProvider>(
            context,
            listen: false,
          ).locationList[0].locationDesc;

          forwardValue = Provider.of<AuthProvider>(
            context,
            listen: false,
          ).locationList[0].locationCode;
          erName = Provider.of<AuthProvider>(
            context,
            listen: false,
          ).locationList[0].locationDesc;
          setState(() {
            _isLoading = false;
          });
        })
        .then((value) {
          Provider.of<ReceivingProvider>(
            // ignore: use_build_context_synchronously
            context,
            listen: false,
          ).getPurposes(context).then((value) {
            Provider.of<ReceivingProvider>(
              // ignore: use_build_context_synchronously
              context,
              listen: false,
            ).fetchModules(context, forwardValue);
          });
          setState(() {
            _isLoading = false;
          });
        });
  }

  void clear() {
    oldPasswordController.clear();
    newPasswordController.clear();
    setState(() {});
  }

  @override
  dispose() {
    subscription.cancel();
    super.dispose();
  }

  Future showChangePasswordDialog(BuildContext context) async {
    await showDialog(
      context: context,
      builder: (context) {
        final height = MediaQuery.of(context).size.height;
        final width = MediaQuery.of(context).size.width;
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState1) {
            return Stack(
              children: [
                Dialog(
                  backgroundColor: Colors.transparent,

                  // insetPadding: EdgeInsets.all(10),
                  child: Form(
                    key: _formKey,
                    child: Container(
                      height: height * 0.49,
                      width: width * 0.28,
                      decoration: BoxDecoration(
                        color: Color.fromARGB(255, 14, 73, 161),
                        border: Border.all(color: Colors.white, width: 4),
                      ),
                      padding: EdgeInsets.symmetric(
                        vertical: 30.h,
                        horizontal: 30.w,
                      ),
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: width * 0.01),
                        child: SingleChildScrollView(
                          child: Column(
                            children: [
                              SizedBox(height: 15.0),
                              Text(
                                'CHANGE PASSWORD',
                                style: textFieldStyle(
                                  color: Colors.white,
                                  fontSize: 38.sp,
                                  weight: FontWeight.w700,
                                ),
                              ),
                              SizedBox(height: 20.0),
                              Container(
                                // width: width * 0.2,
                                child: TextFormField(
                                  controller: oldPasswordController,
                                  obscureText: true,
                                  onSaved: (newValue) {
                                    setState(() {});
                                  },
                                  validator: (value) {
                                    if (value!.isEmpty) {
                                      return "Employee code can't be empty";
                                    } else if (value.length < 3) {
                                      return "Can't be less than 3 words";
                                    } else {
                                      return null;
                                    }
                                  },
                                  style: textFieldStyle(color: Colors.white),
                                  decoration: InputDecoration(
                                    filled: true,
                                    fillColor: Colors.transparent,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10.0),
                                      borderSide: const BorderSide(
                                        color: Colors.white,
                                        width: 3,
                                      ),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10.0),
                                      borderSide: const BorderSide(
                                        color: Colors.white,
                                        width: 3,
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10.0),
                                      borderSide: const BorderSide(
                                        color: Colors.white,
                                        width: 3,
                                      ),
                                    ),
                                    labelText: "Old Password",
                                    labelStyle: const TextStyle(
                                      color: Colors.white,
                                    ),
                                  ),
                                  keyboardType: TextInputType.name,
                                  textInputAction: TextInputAction.next,
                                ),
                              ),
                              SizedBox(height: height * 0.03),
                              SizedBox(
                                // width: width * 0.2,
                                child: TextFormField(
                                  controller: newPasswordController,
                                  obscureText: true,
                                  style: textFieldStyle(color: Colors.white),
                                  validator: (value) {
                                    if (value!.isEmpty) {
                                      return "Password can't be empty";
                                    } else if (value.length < 3) {
                                      return "Can't be less than 3 words";
                                    } else {
                                      return null;
                                    }
                                  },
                                  onSaved: (newValue) {
                                    setState(() {});
                                  },
                                  decoration: InputDecoration(
                                    filled: true,
                                    fillColor: Colors.transparent,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10.0),
                                      borderSide: const BorderSide(
                                        color: Colors.white,
                                        width: 3,
                                      ),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10.0),
                                      borderSide: const BorderSide(
                                        color: Colors.white,
                                        width: 3,
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10.0),
                                      borderSide: const BorderSide(
                                        color: Colors.white,
                                        width: 3,
                                      ),
                                    ),
                                    labelText: 'New Password',
                                    labelStyle: const TextStyle(
                                      color: Colors.white,
                                    ),
                                  ),
                                  keyboardType: TextInputType.name,
                                  textInputAction: TextInputAction.done,
                                ),
                              ),
                              SizedBox(height: height * 0.03),
                              Container(
                                height: height * 0.049,
                                width: double.infinity,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(
                                        12,
                                      ), // <-- Radius
                                    ),
                                  ),
                                  onPressed: () async {
                                    bool? validate = _formKey.currentState!
                                        .validate();

                                    if (validate == true) {
                                      _formKey.currentState!.save();

                                      setState1(() {
                                        _isLoadingInside = true;
                                      });

                                      bool check =
                                          await Provider.of<AuthProvider>(
                                            context,
                                            listen: false,
                                          ).changePassword(
                                            oldPasswordController.value.text,
                                            newPasswordController.value.text,
                                            context,
                                          );

                                      setState1(() {
                                        _isLoadingInside = false;
                                      });

                                      if (check) {
                                        EasyLoading.showToast(
                                          "Password Changed Successfully",
                                          maskType: EasyLoadingMaskType.black,
                                          dismissOnTap: true,
                                        );
                                        Navigator.pop(context);
                                      }
                                    }
                                  },
                                  child: Text(
                                    "Submit",
                                    style: textFieldStyle(
                                      color: Colors.black,
                                      weight: FontWeight.w700,
                                      fontSize: 15,
                                    ),
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
                if (_isLoadingInside)
                  Center(child: LoaderTransparent(color: Colors.white)),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final item = Provider.of<AuthProvider>(context, listen: true);
    final itemReceiving = Provider.of<ReceivingProvider>(context, listen: true);

    print(item.usrid);
    return errorShow
        ? Stack(
            children: [
              Scaffold(
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
                        onPressed: () {
                          // restart();
                        },
                        child: Text(
                          "Retry",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 32.sp,
                          ),
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
              ),
              if (_isLoading)
                Center(child: LoaderTransparent(color: Colors.white)),
            ],
          )
        : Stack(
            children: [
              Scaffold(
                backgroundColor: Colors.white,
                appBar: AppBar(
                  backgroundColor: Color.fromARGB(255, 14, 73, 161),
                  titleSpacing: -10,
                  elevation: 0,
                  leading: SizedBox(),
                  title: InkWell(
                    onDoubleTap: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text("Device Id"),
                            content: Text(item.deviceId),
                            actions: <Widget>[
                              TextButton(
                                child: Text("OK"),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                              ),
                            ],
                          );
                        },
                      );
                    },
                    child: Text(
                      'PDC',
                      style: textFieldStyle(
                        color: Colors.orange,
                        fontSize: 42.sp,
                        weight: FontWeight.w700,
                      ),
                    ),
                  ),
                  actions: [
                    TextButton(
                      child: Text(
                        "Change Password",
                        style: textFieldStyle(
                          color: Colors.white,
                          fontSize: 26.sp,
                          weight: FontWeight.w700,
                        ),
                      ),
                      onPressed: () async {
                        clear();
                        showChangePasswordDialog(context);
                      },
                    ),

                    IconButton(
                      icon: Icon(Icons.logout),
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

                    const SizedBox(width: 8),
                    //     ],
                    //   ),
                    // ],
                  ],
                ),
                body: SingleChildScrollView(
                  child: Column(
                    children: [
                      Container(
                        height: 240.h,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Color.fromARGB(255, 14, 73, 161),
                          borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(70),
                          ),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Image.asset(
                              "assets/hometyre.gif",
                              fit: BoxFit.cover,
                              height: 180.h,
                              width: 180.w,
                            ),
                            SizedBox(width: 10.w),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.userId,
                                  style: textFieldStyle(
                                    color: Colors.white,
                                    fontSize: 30.sp,
                                    weight: FontWeight.w700,
                                  ),
                                ),
                                SizedBox(height: 10.w),
                                Container(
                                  color: Color.fromARGB(255, 14, 73, 161),
                                  child: Container(
                                    padding: const EdgeInsets.only(
                                      left: 0.0,
                                      right: 10.0,
                                    ),
                                    child: DropdownButtonHideUnderline(
                                      child: new DropdownButton<String>(
                                        dropdownColor: Color.fromARGB(
                                          255,
                                          14,
                                          73,
                                          161,
                                        ),
                                        iconEnabledColor: Colors.white,
                                        focusColor: Colors.white,
                                        value: valueSelect,
                                        style: new TextStyle(
                                          color: Colors.white,
                                          fontSize: 26.0,
                                        ),
                                        items: item.locationList.map((
                                          LocationClass value,
                                        ) {
                                          return DropdownMenuItem<String>(
                                            value: value.locationDesc,
                                            child: Text(
                                              value.locationDesc,
                                              maxLines: 2,
                                              style: textFieldStyle(
                                                color: Colors.white,
                                                fontSize: 26.sp,
                                                weight: FontWeight.w700,
                                              ),
                                            ),
                                          );
                                        }).toList(),
                                        onChanged: (value) async {
                                          valueSelect = value ?? "";

                                          log("$valueSelect valueetanay");

                                          LocationClass txerName = item
                                              .locationList
                                              .firstWhere(
                                                (element) =>
                                                    element.locationDesc ==
                                                    valueSelect,
                                              );
                                          forwardValue = txerName.locationCode;

                                          String text =
                                              Provider.of<AuthProvider>(
                                                context,
                                                listen: false,
                                              ).locationList[0].locationDesc;
                                          String firstChar = text[0];

                                          userId = firstChar;

                                          setState(() {});
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.only(top: 20.h, left: 10.w),
                        height: 250.h,
                        width: double.infinity,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            ...(itemReceiving.modules).map((element) {
                              return Row(
                                children: [
                                  SizedBox(width: 5.w),
                                  InkWell(
                                    onTap: () {
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (context) {
                                            return ReceivingScreen(
                                              location: forwardValue,
                                              type: element.moduleCode,
                                            );
                                          },
                                        ),
                                      );
                                    },
                                    child: gridCustom(
                                      element.moduleName == "Transfer"
                                          ? "assets/MM.svg"
                                          : element.moduleName == "Receive"
                                          ? "assets/return.svg"
                                          : "assets/inward.svg",
                                      element.moduleName,
                                      show: element.moduleName == "Transfer"
                                          ? false
                                          : true,
                                      size: element.moduleName == "Transfer"
                                          ? false
                                          : true,
                                    ),
                                  ),
                                  SizedBox(width: 5.w),
                                ],
                              );
                            }),

                            // SizedBox(width: 20.w),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (_isLoading)
                Center(child: LoaderTransparent(color: Colors.white)),
            ],
          );
  }
}

Widget gridCustom(
  String imagePath,
  String name, {
  bool size = false,
  bool disable = false,
  bool show = false,
  bool detailShow = false,
}) {
  return Container(
    width: 220.w,
    height: 230.h,
    padding: EdgeInsets.only(top: detailShow ? 30.h : 10.h),
    decoration: BoxDecoration(
      color: disable
          ? Colors.grey.shade400
          : Color.fromARGB(255, 215, 237, 255),
      borderRadius: BorderRadius.circular(6),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          child: SvgPicture.asset(
            imagePath,
            fit: BoxFit.cover,
            height: size ? 130.h : 90.h,
            width: size ? 130.h : 90.w,
            // ignore: deprecated_member_use
            color: Colors.black,
          ),
        ),
        if (!show) SizedBox(height: 30.h),
        if (detailShow) SizedBox(height: 10.h),
        Container(
          alignment: Alignment.center,
          padding: EdgeInsets.symmetric(horizontal: 38.w),
          child: Text(
            name,
            style: textFieldStyle(
              color: Color.fromARGB(255, 7, 70, 122),
              fontSize: 28.sp,
              weight: FontWeight.w700,
            ),
          ),
        ),
        SizedBox(height: 10.h),
      ],
    ),
  );
}
