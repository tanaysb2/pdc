import 'dart:convert';
import 'dart:developer';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:http/http.dart';
import 'package:pdc/Modules/bin_model.dart';
import 'package:pdc/Modules/document_detail_model.dart';
import 'package:pdc/Modules/document_modal.dart';
import 'package:pdc/Modules/department_model.dart';
import 'package:pdc/Modules/competitors_model.dart';
import 'package:pdc/Modules/purpose_modal.dart';
import 'package:pdc/Modules/rack_model.dart';
import 'package:pdc/Modules/reasons_model.dart';
import 'package:pdc/Modules/homepage_model.dart';
import 'package:pdc/Urls/url_holder_loan.dart';
import 'package:pdc/main.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vibration/vibration.dart';

class ReceivingProvider with ChangeNotifier {
  final AudioPlayer _player = AudioPlayer();

  List<DocumentData> documents = [];
  DocumentDetailData? documentDetail;
  List<Department> departments = [];
  List<Competitor> competitors = [];
  List<Reason> reasons = [];
  List<String> locationList = [];
  List<Purpose> purposes = [];
  List<Bin> binList = [];
  List<Rack> rackList = [];
  List<Module> modules = [];
  bool showBin = false;
  bool showRack = false;

  // Add Receiving form state (dropdowns)
  String selectedType = "JK Tyre";
  String? selectedCompany;
  String? selectedPurpose;
  String? selectedReason;
  String? selectedDepartment;
  String? selectedBin;
  String? selectedRack;
  String? selectedLocation;

  List<String> get uniqueCompetitorNames {
    final seen = <String>{};
    return competitors
        .where((c) => seen.add(c.competitorName))
        .map((c) => c.competitorName)
        .toList();
  }

  void setSelectedType(String v) {
    selectedType = v;
    if (v == "JK Tyre") {
      selectedCompany = null;
    } else {
      selectedCompany = uniqueCompetitorNames.isNotEmpty
          ? uniqueCompetitorNames.first
          : null;
    }
    notifyListeners();
  }

  void setSelectedCompany(String? v) {
    selectedCompany = v;
    notifyListeners();
  }

  void setSelectedPurpose(String? v) {
    selectedPurpose = v;
    notifyListeners();
  }

  void setSelectedReason(String? v) {
    selectedReason = v;
    notifyListeners();
  }

  void setSelectedDepartment(String? v) {
    selectedDepartment = v;
    notifyListeners();
  }

  void setSelectedBin(String? v) {
    selectedBin = v;
    notifyListeners();
  }

  void setSelectedRack(String? v) {
    selectedRack = v;
    notifyListeners();
  }

  void setSelectedLocation(String? v) {
    selectedLocation = v;
    notifyListeners();
  }

  // void resetAddReceivingForm() {
  //   selectedType = "JK Tyre";
  //   selectedCompany = null;
  //   selectedPurpose = null;
  //   selectedReason = null;
  //   selectedDepartment = null;
  //   selectedBin = null;
  //   selectedRack = null;
  //   selectedLocation = null;
  //   notifyListeners();
  // }

  /// Submits the Add Receiving form: calls [createDocument] with current dropdown values and [remark], then resets form on success.
  Future<bool> submitAddReceiving(
    BuildContext context,
    String docType,
    String location,
    String remark,
  ) async {
    final purposeCode = selectedPurpose ?? '';
    final reasonCode = selectedReason ?? '';
    final departmentCode = selectedDepartment ?? '';
    final storageLocation = selectedLocation ?? '';
    final binCode = selectedBin ?? '';
    final rackCode = selectedRack ?? '';

    if (purposeCode.isEmpty ||
        reasonCode.isEmpty ||
        departmentCode.isEmpty ||
        storageLocation.isEmpty) {
      EasyLoading.showToast(
        "Please fill all required fields",
        maskType: EasyLoadingMaskType.black,
      );
      return false;
    }

    String competitorCode = '';
    if (selectedType == "Others" && selectedCompany != null) {
      final list = competitors
          .where((c) => c.competitorName == selectedCompany)
          .toList();
      competitorCode = list.isNotEmpty ? list.first.competitorCode : '';
    }

     
    final result = await createDocument(
      context,
      docType: docType,
      competitorCode: competitorCode,
      purposeCode: purposeCode,
      reasonCode: reasonCode,
      storageLocation: storageLocation,
      binCode: binCode,
      rackCode: rackCode,
      departmentCode: departmentCode,
      location: location,
      remark: remark.isEmpty ? null : remark,
    );

    if (result != null) {
      await fetchDocuments(context);
      if (context.mounted) Navigator.of(context).pop();
      return true;
    }
    return false;
  }

  /// Fetch documents from API and populate [documents] list.
  ///
  /// Returns `true` on success, `false` on failure.
  Future<bool> fetchDocuments(BuildContext context) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("userToken");

      if (token == null || token.isEmpty) {
        return false;
      }

      log('token: ${token}');

      final headers = {'Authorization': 'Bearer $token'};

      final request = Request(
        'GET',
        Uri.parse('${UrlHolderLoan.baseUrl}${UrlHolderLoan.getDocuments}'),
      );

      request.headers.addAll(headers);

      final response = await request.send().timeout(
        const Duration(seconds: 60),
      );

      if (response.statusCode == 200) {
        final body = await response.stream.bytesToString();
        final Map<String, dynamic> jsonData = json.decode(body);

        final documentResponse = DocumentResponse.fromJson(jsonData);
        documents = documentResponse.data;
        notifyListeners();
        return true;
      } else {
        final body = await response.stream.bytesToString();

        bool? checkVibrate = await Vibration.hasVibrator();
        if (checkVibrate == true) {
          Vibration.vibrate();
        }

        _player.play(AssetSource('audio/error.wav'));

        final message = _extractErrorMessage(body);
        EasyLoading.showToast(message, maskType: EasyLoadingMaskType.black);
        return false;
      }
    } catch (e) {
      EasyLoading.showToast(
        "Connectivity issue, Please try again",
        maskType: EasyLoadingMaskType.black,
      );
      return false;
    }
  }

  /// Fetch single document detail by [documentNumber] and store in [documentDetail].
  ///
  /// Returns `true` on success, `false` on failure.
  Future<bool> fetchDocumentDetail(
    BuildContext context,
    String documentNumber,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("userToken");

      if (token == null || token.isEmpty) {
        return false;
      }

      final headers = {'Authorization': 'Bearer $token'};

      final request = Request(
        'GET',
        Uri.parse(
          '${UrlHolderLoan.baseUrl}${UrlHolderLoan.getDocuments}/$documentNumber',
        ),
      );

      request.headers.addAll(headers);

      final response = await request.send().timeout(
        const Duration(seconds: 60),
      );

      if (response.statusCode == 200) {
        final body = await response.stream.bytesToString();
        final Map<String, dynamic> jsonData = json.decode(body);

        final detailResponse = DocumentDetailResponse.fromJson(jsonData);
        documentDetail = detailResponse.data;
        notifyListeners();
        return true;
      } else {
        final body = await response.stream.bytesToString();

        bool? checkVibrate = await Vibration.hasVibrator();
        if (checkVibrate == true) {
          Vibration.vibrate();
        }

        _player.play(AssetSource('audio/error.wav'));

        final message = _extractErrorMessage(body);
        EasyLoading.showToast(message, maskType: EasyLoadingMaskType.black);
        return false;
      }
    } catch (e) {
      EasyLoading.showToast(
        "Connectivity issue, Please try again",
        maskType: EasyLoadingMaskType.black,
      );
      return false;
    }
  }

  /// Fetch list of departments from API and populate [departments] list.
  ///
  /// Returns `true` on success, `false` on failure.
  Future<bool> fetchDepartments(BuildContext context) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("userToken");

      if (token == null || token.isEmpty) {
        return false;
      }

      final headers = {'Authorization': 'Bearer $token'};

      final request = Request(
        'GET',
        Uri.parse('${UrlHolderLoan.baseUrl}${UrlHolderLoan.getDepartments}'),
      );

      request.headers.addAll(headers);

      final response = await request.send().timeout(
        const Duration(seconds: 60),
      );

      if (response.statusCode == 200) {
        final body = await response.stream.bytesToString();
        final Map<String, dynamic> jsonData = json.decode(body);

        final departmentResponse = DepartmentResponse.fromJson(jsonData);
        departments = departmentResponse.data;
        if (departments.isNotEmpty &&
            (selectedDepartment == null ||
                !departments.any((d) => d.departmentCode == selectedDepartment))) {
          selectedDepartment = departments.first.departmentCode;
        }
        notifyListeners();
        return true;
      } else {
        final body = await response.stream.bytesToString();

        bool? checkVibrate = await Vibration.hasVibrator();
        if (checkVibrate == true) {
          Vibration.vibrate();
        }

        _player.play(AssetSource('audio/error.wav'));

        final message = _extractErrorMessage(body);
        EasyLoading.showToast(message, maskType: EasyLoadingMaskType.black);
        return false;
      }
    } catch (e) {
      EasyLoading.showToast(
        "Connectivity issue, Please try again",
        maskType: EasyLoadingMaskType.black,
      );
      return false;
    }
  }

  /// Fetch list of competitors from API and populate [competitors] list.
  ///
  /// Returns `true` on success, `false` on failure.
  Future<bool> fetchCompetitors(BuildContext context) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("userToken");

      if (token == null || token.isEmpty) {
        return false;
      }

      final headers = {'Authorization': 'Bearer $token'};

      final request = Request(
        'GET',
        Uri.parse('${UrlHolderLoan.baseUrl}${UrlHolderLoan.getCompetitors}'),
      );

      request.headers.addAll(headers);

      final response = await request.send().timeout(
        const Duration(seconds: 60),
      );

      if (response.statusCode == 200) {
        final body = await response.stream.bytesToString();
        final Map<String, dynamic> jsonData = json.decode(body);

        final competitorResponse = CompetitorResponse.fromJson(jsonData);
        competitors = competitorResponse.data;
        if (selectedType == 'Others' && uniqueCompetitorNames.isNotEmpty) {
          selectedCompany = uniqueCompetitorNames.first;
        }
        notifyListeners();
        return true;
      } else {
        final body = await response.stream.bytesToString();

        bool? checkVibrate = await Vibration.hasVibrator();
        if (checkVibrate == true) {
          Vibration.vibrate();
        }

        _player.play(AssetSource('audio/error.wav'));

        final message = _extractErrorMessage(body);
        EasyLoading.showToast(message, maskType: EasyLoadingMaskType.black);
        return false;
      }
    } catch (e) {
      EasyLoading.showToast(
        "Connectivity issue, Please try again",
        maskType: EasyLoadingMaskType.black,
      );
      return false;
    }
  }

  /// Fetch list of reasons from API and populate [reasons] list.
  ///
  /// Returns `true` on success, `false` on failure.
  Future<bool> fetchReasons(BuildContext context) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("userToken");

      if (token == null || token.isEmpty) {
        return false;
      }

      final headers = {'Authorization': 'Bearer $token'};

      final request = Request(
        'GET',
        Uri.parse('${UrlHolderLoan.baseUrl}${UrlHolderLoan.getReasons}'),
      );

      request.headers.addAll(headers);

      final response = await request.send().timeout(
        const Duration(seconds: 60),
      );

      if (response.statusCode == 200) {
        final body = await response.stream.bytesToString();
        final Map<String, dynamic> jsonData = json.decode(body);

        final reasonResponse = ReasonResponse.fromJson(jsonData);
        reasons = reasonResponse.data;
        if (reasons.isNotEmpty &&
            (selectedReason == null ||
                !reasons.any((r) => r.reasonCode == selectedReason))) {
          selectedReason = reasons.first.reasonCode;
        }
        notifyListeners();
        return true;
      } else {
        final body = await response.stream.bytesToString();

        bool? checkVibrate = await Vibration.hasVibrator();
        if (checkVibrate == true) {
          Vibration.vibrate();
        }

        _player.play(AssetSource('audio/error.wav'));

        final message = _extractErrorMessage(body);
        EasyLoading.showToast(message, maskType: EasyLoadingMaskType.black);
        return false;
      }
    } catch (e) {
      EasyLoading.showToast(
        "Connectivity issue, Please try again",
        maskType: EasyLoadingMaskType.black,
      );
      return false;
    }
  }

  Future getPurposes(BuildContext context) async {
    List<Purpose> txpurposes = [];
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("userToken");

      var headers = {'Authorization': 'Bearer $token'};

      var request = Request(
        'GET',
        Uri.parse('${UrlHolderLoan.baseUrl}${UrlHolderLoan.purpose}'),
      );
      request.headers.addAll(headers);

      StreamedResponse response = await request.send().timeout(
        Duration(seconds: 60),
      );

      if (response.statusCode == 200) {
        final responseBody = await response.stream.bytesToString();
        final Map<String, dynamic> jsonData = json.decode(responseBody);
        txpurposes = parsePurposesFromJson(jsonData);
        purposes = txpurposes;
        if (purposes.isNotEmpty &&
            (selectedPurpose == null ||
                !purposes.any((p) => p.purposeCode == selectedPurpose))) {
          selectedPurpose = purposes.first.purposeCode;
        }
        notifyListeners();
      } else {
        bool? checkVibrate = await Vibration.hasVibrator();
        final responseBody = await response.stream.bytesToString();
        if (checkVibrate) Vibration.vibrate();
        AudioPlayer().play(AssetSource('audio/error.wav'));
        final responseData = json.decode(responseBody)["message"];
        EasyLoading.showToast(
          responseData.toString(),
          maskType: EasyLoadingMaskType.black,
        );
      }
    } catch (e) {
      print("Error fetching purposes: $e");
    }
  }

  Future<void> fetchLocations(String location, {String changeUrl = ""}) async {
    final prefs = await SharedPreferences.getInstance();
    var _accessToken = await prefs.getString("userToken");
    final url =
        '${UrlHolderLoan.baseUrl}${UrlHolderLoan.getMappingLocations}?location=$location';
    var headers = {
      'Content-Type': 'application/json',
      "authorization": 'Bearer $_accessToken',
    };
    var request = Request('GET', Uri.parse(url));
    // request.body = json.encode({"userName": email, "password": password});
    request.headers.addAll(headers);

    StreamedResponse response = await request.send().timeout(
      Duration(seconds: 60),
    );
    List<String> demoLocationList = [];

    if (response.statusCode == 200) {
      final xyz = await response.stream.bytesToString();

      final List responseData = json.decode(xyz)["locations"];

      responseData.forEach((element) {
        return demoLocationList.add(element.toString());
      });

      locationList = demoLocationList;
      if (locationList.isNotEmpty &&
          (selectedLocation == null ||
              !locationList.contains(selectedLocation))) {
        selectedLocation = locationList.first;
      }

      print("${locationList.length} lllist");

      notifyListeners();
      //"Success";
      // return true;
    } else {
      final resp = await response.stream.bytesToString();

      final responseData = json.decode(resp)["message"];
      EasyLoading.showToast(
        responseData.toString(),
        maskType: EasyLoadingMaskType.black,
      );
      return null;
    }
  }

  Future getRack(String location, String storageLocation, String bin) async {
    final prefs = await SharedPreferences.getInstance();
    final txtoken = prefs.getString("userToken");
    var headers = {'Authorization': 'Bearer $txtoken'};
    var request = Request(
      'GET',
      Uri.parse(
        '${UrlHolderLoan.baseUrl}${UrlHolderLoan.getRack}?location=$location&storageLocation=$storageLocation&bin=$bin',
      ),
    );

    request.headers.addAll(headers);
    List<Rack> demoRackList = [];

    StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      final xyz = await response.stream.bytesToString();

      final List responseData = json.decode(xyz)["data"];
      responseData.forEach((element) {
        return demoRackList.add(
          Rack(
            code: element["code"].toString(),
            description: element["description"].toString(),
          ),
        );
      });
      rackList = demoRackList;
      final validRacks = rackList
          .where((r) => r.code != null && r.code!.isNotEmpty)
          .toList();
      if (validRacks.isNotEmpty &&
          (selectedRack == null ||
              !validRacks.any((r) => r.code == selectedRack))) {
        selectedRack = validRacks.first.code;
      }
      if (rackList.isEmpty) {
        showRack = true;
      }
      notifyListeners();
    } else {}
  }

  Future getBin(String location, String storageLocation) async {
    final prefs = await SharedPreferences.getInstance();
    final txtoken = prefs.getString("userToken");
    var headers = {'Authorization': 'Bearer $txtoken'};
    var request = Request(
      'GET',
      Uri.parse(
        '${UrlHolderLoan.baseUrl}${UrlHolderLoan.getBin}?location=$location&storageLocation=$storageLocation',
      ),
    );

    request.headers.addAll(headers);
    List<Bin> demoBinList = [];

    StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      final xyz = await response.stream.bytesToString();

      final List responseData = json.decode(xyz)["data"];
      responseData.forEach((element) {
        return demoBinList.add(
          Bin(
            code: element["code"].toString(),
            description: element["description"].toString(),
          ),
        );
      });
      binList = demoBinList;
      if (binList.isNotEmpty &&
          (selectedBin == null ||
              !binList.any((b) => b.code == selectedBin))) {
        selectedBin = binList.first.code;
      }
      log("${binList.length} binList");
      if (binList.isEmpty) {
        showBin = true;
      }
      notifyListeners();
    } else {}
  }

  /// Creates a new PDC document via POST.
  ///
  /// Returns the response body as [Map<String, dynamic>] on success, or `null` on failure.
  Future<Map<String, dynamic>?> createDocument(
    BuildContext context, {
    required String docType,
    required String competitorCode,
    required String purposeCode,
    required String reasonCode,
    required String storageLocation,
    required String binCode,
    required String rackCode,
    required String departmentCode,
    required String location,
    String? remark,
  }) async {
    try {
      log(
        "createDocument inputs: docType=$docType, competitorCode=$competitorCode, purposeCode=$purposeCode, reasonCode=$reasonCode, storageLocation=$storageLocation, binCode=$binCode, rackCode=$rackCode, departmentCode=$departmentCode, location=$location, remark=$remark",
      );
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("userToken");

      if (token == null || token.isEmpty) {
        EasyLoading.showToast(
          "Please login again",
          maskType: EasyLoadingMaskType.black,
        );
        return null;
      }

      final headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      };

      final body = {
        "docType": docType,
        "competitorCode": competitorCode,
        "purposeCode": purposeCode,
        "reasonCode": reasonCode,
        "storageLocation": storageLocation,
        "binCode": binCode,
        "rackCode": rackCode,
        "departmentCode": departmentCode,
        "location": location,
        if (remark != null && remark.isNotEmpty) "remark": remark,
      };

      final request = Request(
        'POST',
        Uri.parse('${UrlHolderLoan.baseUrl}${UrlHolderLoan.getDocuments}'),
      );
      request.body = json.encode(body);
      request.headers.addAll(headers);

      final response = await request.send().timeout(
        const Duration(seconds: 60),
      );

      log("${response.statusCode} response.statusCode");

      if (response.statusCode == 200) {
        final responseBody = await response.stream.bytesToString();
        final data = json.decode(responseBody) as Map<String, dynamic>?;
        return data;
      } else {
        final responseBody = await response.stream.bytesToString();
        bool? checkVibrate = await Vibration.hasVibrator();
        if (checkVibrate == true) {
          Vibration.vibrate();
        }

        final message = _extractErrorMessage(responseBody);
        EasyLoading.showToast(message, maskType: EasyLoadingMaskType.black);
        return null;
      }
    } catch (e) {
      EasyLoading.showToast(
        "Connectivity issue, Please try again",
        maskType: EasyLoadingMaskType.black,
      );
      return null;
    }
  }

  /// Fetch list of modules from API by [location] and populate [modules] list.
  ///
  /// Returns `true` on success, `false` on failure.
  Future<bool> fetchModules(BuildContext context, String location) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("userToken");

      if (token == null || token.isEmpty) {
        return false;
      }

      final headers = {'Authorization': 'Bearer $token'};

      final request = Request(
        'GET',
        Uri.parse(
          '${UrlHolderLoan.baseUrl}${UrlHolderLoan.getModules}?location=$location',
        ),
      );

      request.headers.addAll(headers);

      final response = await request.send().timeout(
        const Duration(seconds: 60),
      );

      if (response.statusCode == 200) {
        final body = await response.stream.bytesToString();
        final Map<String, dynamic> jsonData = json.decode(body);

        final moduleResponse = ModuleResponse.fromJson(jsonData);
        modules = moduleResponse.data;
        notifyListeners();
        return true;
      } else {
        final body = await response.stream.bytesToString();

        bool? checkVibrate = await Vibration.hasVibrator();
        if (checkVibrate == true) {
          Vibration.vibrate();
        }

        _player.play(AssetSource('audio/error.wav'));

        final message = _extractErrorMessage(body);
        EasyLoading.showToast(message, maskType: EasyLoadingMaskType.black);
        return false;
      }
    } catch (e) {
      EasyLoading.showToast(
        "Connectivity issue, Please try again",
        maskType: EasyLoadingMaskType.black,
      );
      return false;
    }
  }

  String _extractErrorMessage(String body) {
    try {
      final data = json.decode(body);
      if (data is Map<String, dynamic> && data["message"] != null) {
        return data["message"].toString();
      }
    } catch (_) {
      // ignore and fall back to default message
    }
    return "Something went wrong. Please try again.";
  }
}
