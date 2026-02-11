import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';

import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:http/http.dart';
import 'package:pdc/Modules/homepage_model.dart';
import 'package:pdc/Modules/plant.dart';
import 'package:pdc/Urls/url_holder_loan.dart';
import 'package:pdc/main.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vibration/vibration.dart';

class AuthProvider with ChangeNotifier {
  AuthClass? authinfo;
  String? txtoken;
  String? usrid;
  String? baseLoc;
  List<String> enterOption = [];
  String exist = "";
  String resetTokenss = "";
  String errorMessage = "";
  bool captureImage = false;
  List<LocationClass> locationList = [];
  List<PlantModal> plantList = [];
  List<String> modulesList = [];
  ModuleResponse? purposesResponse;
  final player = AudioPlayer();
  String deviceId = "";

  // authentication for login

  Future<bool> login(String email, String password) async {
    try {
      const url = '${UrlHolderLoan.baseUrl}${UrlHolderLoan.login}';
      print("$url urllllllll");
      var headers = {'Content-Type': 'application/json'};
      var request = Request('POST', Uri.parse(url));
      request.body = json.encode({
        "userName": email.trimRight(),
        "password": password.trimRight(),
      });
      request.headers.addAll(headers);

      StreamedResponse response = await request.send().timeout(
        Duration(seconds: 60),
      );

      print("${response.statusCode} statuscode");

      if (response.statusCode == 200) {
        final xyz = await response.stream.bytesToString();

        authinfo = AuthClass(
          token: json.decode(xyz)["token"],
          baseLoc: json.decode(xyz)["user"]["BaseLoc"],
          usrid: json.decode(xyz)["user"]["Usrid"],
        );

        final prefs = await SharedPreferences.getInstance();

        await prefs.setString("userToken", authinfo!.token.toString());
        await prefs.setString("baseLoc", json.decode(xyz)["user"]["BaseLoc"]);
        await prefs.setString("usrid", json.decode(xyz)["user"]["Usrid"]);

        print("${authinfo!.token.toString()} authtanay");
        notifyListeners();
        return true;
      } else {
        bool? checkVibrate = await Vibration.hasVibrator();
        final xyz = await response.stream.bytesToString();
        if (checkVibrate!) Vibration.vibrate();
        AudioPlayer().play(AssetSource('audio/error.wav'));

        final responseData = json.decode(xyz)["message"];
        EasyLoading.showToast(
          responseData.toString(),
          maskType: EasyLoadingMaskType.black,
        );
        return false;
      }
    } catch (e) {
      EasyLoading.showToast(
        "Connectivity issue, Please try again",
        maskType: EasyLoadingMaskType.black,
        dismissOnTap: true,
        duration: Duration(seconds: 4),
      );
      return false;
    }
  }

  // Future<AndroidDeviceInfo?> getId() async {
  //   var deviceInfo = DeviceInfoPlugin();
  //   if (Platform.isAndroid) {
  //     var androidDeviceInfo = await deviceInfo.androidInfo;
  //     deviceId = androidDeviceInfo.androidId ?? "";
  //     log("${androidDeviceInfo.androidId} android");
  //     return androidDeviceInfo; // unique ID on Android
  //   }
  //   return null;
  // }

  Future filldetails() async {
    final prefs = await SharedPreferences.getInstance();

    txtoken = prefs.getString("userToken");
    usrid = prefs.getString("usrid");
    baseLoc = prefs.getString("baseLoc");
    notifyListeners();
  }

  Future getLocation(BuildContext context) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("userToken");
      var headers = {'Authorization': 'Bearer $token'};
      log('$token token');
      var request = Request(
        'GET',
        Uri.parse('${UrlHolderLoan.baseUrl}${UrlHolderLoan.locaton}'),
      );

      log("${UrlHolderLoan.baseUrl}${UrlHolderLoan.locaton} checking");

      request.headers.addAll(headers);
      List<LocationClass> demoLocationList = [];

      StreamedResponse response = await request.send().timeout(
        Duration(seconds: 60),
      );

      if (response.statusCode == 200) {
        final xyz = await response.stream.bytesToString();

        log(xyz);

        final List responseData = json.decode(xyz)["data"];
        responseData.forEach((element) {
          return demoLocationList.add(
            LocationClass(
              locationCode: element["locationCode"] ?? "",
              locationDesc: element["locationName"] ?? "",
            ),
          );
        });
        locationList = demoLocationList;
        log("${locationList.length} item");
        log("${locationList[0].locationDesc} item");
        log("${locationList[0].locationCode} item");
        notifyListeners();
      } else {
        if (response.statusCode == 401) {
          await prefs.clear();
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(
              builder: (context) {
                return MyApp();
              },
            ),
            (route) => false,
          );
        } else {
          print("asdasds else");
          bool? checkVibrate = await Vibration.hasVibrator();
          final xyz = await response.stream.bytesToString();
          if (checkVibrate) Vibration.vibrate();
          AudioPlayer().play(AssetSource('audio/error.wav'));

          final responseData = json.decode(xyz)["message"];
          EasyLoading.showToast(
            responseData.toString(),
            maskType: EasyLoadingMaskType.black,
          );
          return false;
        }
      }
    } catch (e) {
      print(e.toString() + "asdasds");
      return false;
    }
  }

  Future getPlants(BuildContext context) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("userToken");
      var headers = {'Authorization': 'Bearer $token'};
      var request = Request(
        'GET',
        Uri.parse('${UrlHolderLoan.baseUrl}${UrlHolderLoan.plants}'),
      );

      request.headers.addAll(headers);

      List<PlantModal> demoPlantList = [];

      StreamedResponse response = await request.send().timeout(
        Duration(seconds: 60),
      );

      if (response.statusCode == 200) {
        final xyz = await response.stream.bytesToString();
        final List responseData = json.decode(xyz)["plants"];

        responseData.forEach((element) {
          return demoPlantList.add(
            PlantModal(
              id: element["_id"],
              code: element["code"],
              identifiers: element["identifier"],
              description: element["description"],
            ),
          );
        });
        plantList = demoPlantList;
        notifyListeners();
      } else {
        if (response.statusCode == 401) {
          await prefs.clear();
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(
              builder: (context) {
                return MyApp();
              },
            ),
            (route) => false,
          );
        } else {
          bool? checkVibrate = await Vibration.hasVibrator();
          final xyz = await response.stream.bytesToString();
          if (checkVibrate) Vibration.vibrate();
          AudioPlayer().play(AssetSource('audio/error.wav'));
          final responseData = json.decode(xyz)["message"];
          EasyLoading.showToast(
            responseData.toString(),
            maskType: EasyLoadingMaskType.black,
          );
        }
      }
    } catch (e) {}
  }

  Future<bool> changePassword(
    String oldPassword,
    String newPassword,
    BuildContext context,
  ) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("userToken");
    const url = '${UrlHolderLoan.baseUrl}${UrlHolderLoan.changepassword}';

    var headers = {'Authorization': 'Bearer $token'};

    var request = Request('POST', Uri.parse(url));
    request.body = json.encode({
      "oldPassword": oldPassword.trimRight(),
      "newPassword": newPassword.trimRight(),
    });
    request.headers.addAll(headers);

    StreamedResponse response = await request.send().timeout(
      Duration(seconds: 60),
    );

    print("${response.statusCode} statuscode");

    if (response.statusCode == 200) {
      bool? checkVibrate = await Vibration.hasVibrator();

      if (checkVibrate!) Vibration.vibrate();
      AudioPlayer().play(AssetSource('audio/sound.wav'));
      notifyListeners();
      return true;
    } else {
      bool? checkVibrate = await Vibration.hasVibrator();
      final xyz = await response.stream.bytesToString();
      if (checkVibrate!) Vibration.vibrate();
      player.play(AssetSource('audio/sirenerror.wav'));
      player.setReleaseMode(ReleaseMode.loop);

      final responseData = json.decode(xyz)["message"];
      showDialogForall(context, responseData.toString());

      return false;
    }
  }

  Future showDialogForall(BuildContext context, String text) async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return Container(
          margin: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
          child: Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 20.0.w, vertical: 20.h),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'ERROR',
                        style: TextStyle(
                          fontSize: 38.sp,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Icon(Icons.error, color: Colors.red, size: 38.r),
                    ],
                  ),
                  SizedBox(height: 10.0),
                  Text(
                    text,
                    style: TextStyle(
                      fontSize: 30.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 10.0),
                  SizedBox(
                    width: 120.w,
                    height: 70.h,
                    child: Align(
                      alignment: Alignment.center,
                      child: ElevatedButton(
                        onPressed: () {
                          player.stop();
                          Navigator.of(context).pop();
                        },
                        child: Text(
                          'OK',
                          style: TextStyle(
                            fontSize: 28.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class AuthClass {
  String? token;
  String? usrid;
  String? baseLoc;
  AuthClass({this.token, this.usrid, this.baseLoc});
}

class LocationClass {
  String locationCode;
  String locationDesc;

  LocationClass({this.locationCode = "", this.locationDesc = ""});
}
