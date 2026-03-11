import 'dart:convert';
import 'dart:developer';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:http/http.dart';
import 'package:pdc/Modules/bin_model.dart';
import 'package:pdc/Modules/category_model.dart';
import 'package:pdc/Modules/competitors_model.dart';
import 'package:pdc/Modules/department_model.dart';
import 'package:pdc/Modules/document_detail_model.dart';
import 'package:pdc/Modules/document_modal.dart';
import 'package:pdc/Modules/homepage_model.dart';
import 'package:pdc/Modules/location_model.dart';
import 'package:pdc/Modules/material.dart';
import 'package:pdc/Modules/material_model.dart';
import 'package:pdc/Modules/material_plant_model.dart';
import 'package:pdc/Modules/plant.dart';
import 'package:pdc/Modules/purpose_modal.dart';
import 'package:pdc/Modules/rack_model.dart';
import 'package:pdc/Modules/reasons_model.dart';
import 'package:pdc/Modules/scan_module.dart';
import 'package:pdc/Urls/url_holder_loan.dart'; 
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vibration/vibration.dart';

class ReceivingProvider with ChangeNotifier {
  final AudioPlayer _player = AudioPlayer();

  List<DocumentData> documents = [];
  List<DocumentDetailData> documentDetail = [];
  TextEditingController stencilIdController = TextEditingController();
  String errorMessage = "";
  List<Department> departments = [];
  List<Competitor> competitors = [];
  List<Reason> reasons = [];
  List<PlantModal> plantList = [];

  List<String> locationList = [];
  String barcodeShow = "";
  TextEditingController manuDateController = TextEditingController();
  String prodDate = "";
  String matnr = "";
  String stencilNo = "";
  String material = "";
  List<MaterialModal> materialList = [];
  List<Purpose> purposes = [];
  String selectedPrefix = "";
  String selectedMaterialss = "";
  List<Bin> binList = [];
  String cage = "";
  String fromLocation = "";
  String toLocation = "";
  String pickListNo = "";
  String shift = "";
  final player = AudioPlayer();
  List<Rack> rackList = [];
  List<Module> modules = [];
  TextEditingController barcodeManualController = TextEditingController();
  bool showBin = false;
  String selectedMaterial = "";
  bool showRack = false;

  TextEditingController? _selectedCategory,
      _selectedLocation,
      _selectedMaterialPlant;

  TextEditingController? get selectedLocation => _selectedLocation;
  TextEditingController? get selectedCategory => _selectedCategory;

  TextEditingController? get selectedMaterialPlant => _selectedMaterialPlant;

  late BarcodeDetails _barcodeDetails = BarcodeDetails(
    locationDetails: LocationModel(locations: []),
    categoryDetails: CategoryModel(categories: []),
    materialDetails: MaterialModel(materials: []),
    materialPlantDetails: MaterialPlantModel(plants: []),
  );
  String materialCode = "";

  BarcodeDetails get barcodeDetails => _barcodeDetails;

  /// Last scan response data, populated on successful [scanDocument].
  ScanModuleData? lastScanData;

  // late BarcodeDetails _barcodeDetails = BarcodeDetails(
  //   locationDetails: LocationModel(locations: []),
  //   categoryDetails: CategoryModel(categories: []),
  //   materialDetails: MaterialModel(materials: []),
  //   materialPlantDetails: MaterialPlantModel(plants: []),
  // );
  // String materialCode = "";
  // BarcodeDetails get barcodeDetails => _barcodeDetails;

  String selectedType = "JK Tyre";
  String? selectedCompany;
  String? selectedPurpose;
  String? selectedReason;
  String? selectedDepartment;
  String? selectedBin;
  String? selectedRack;
  String? selectedLocationss;

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
      selectedCompany =
          uniqueCompetitorNames.isNotEmpty ? uniqueCompetitorNames.first : null;
    }
    notifyListeners();
  }

  Future<BarcodeDetails> fetchMappingData(
      BuildContext context, String location) async {
    selectedMaterial = "";
    selectedPrefix = "";

    await fetchLocations(location);

    _barcodeDetails.materialDetails.materials = [];

    await fetchMaterialPlants(context);
    notifyListeners();
    return _barcodeDetails;
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
    selectedLocationss = v;
    notifyListeners();
  }

  void onMaterialItemChanged(String newValue) {
    selectedMaterial = newValue;
    notifyListeners();
  }

  void onMaterialPlantChangedformanul(String idetifier) {
    selectedPrefix = idetifier;
    notifyListeners();
  }

  Future stencilVerficationForAddBarcode(
      String stencilNo,
      String material,
      String selectMaterial,
      String txlocation,
      String ordType,
      String picklistNos) async {
    final prefs = await SharedPreferences.getInstance();
    var _accessToken = await prefs.getString("userToken");

    var _materialPlatDetail = _barcodeDetails.materialPlantDetails.plants
        .firstWhere((plant) => plant.description == selectMaterial);

    var headers = {'Authorization': 'Bearer $_accessToken'};

    log("check date $stencilNo checking");
    log("check date $material checking");
    log("check date ${_materialPlatDetail.code} checking");

    var request = Request(
        'GET',
        Uri.parse(
            '${UrlHolderLoan.baseUrl}${UrlHolderLoan.stencilVerification}?stencilNo=$stencilNo&material=$material&manPlant=${_materialPlatDetail.code.trimRight()}&location=$txlocation&ordType=$ordType&picklistNo=$picklistNos'));

    request.headers.addAll(headers);

    StreamedResponse response =
        await request.send().timeout(Duration(seconds: 60));

    if (response.statusCode == 200) {
      bool? checkVibrate = await Vibration.hasVibrator();
      final xyz = await response.stream.bytesToString();
      if (checkVibrate) Vibration.vibrate();
      AudioPlayer().play(AssetSource('audio/sound.wav'));

      final responseData = json.decode(xyz)["message"];
      final responseDataForDate = json.decode(xyz)["ProdDt"];
      print(responseDataForDate);

      manuDateController =
          TextEditingController(text: responseDataForDate.toString());

      log("check date ${manuDateController.value.text}");

      await EasyLoading.showToast(responseData.toString(),
          maskType: EasyLoadingMaskType.black,
          duration: Duration(milliseconds: 200),
          dismissOnTap: true);

      notifyListeners();
    } else {
      bool? checkVibrate = await Vibration.hasVibrator();
      final xyz = await response.stream.bytesToString();
      if (checkVibrate) Vibration.vibrate();
      AudioPlayer().play(AssetSource('audio/error.wav'));

      final responseData = json.decode(xyz)["message"];

      EasyLoading.showToast(responseData.toString(),
          maskType: EasyLoadingMaskType.black);

      notifyListeners();
    }
  }

  Future<bool> markAsCompleted(String picklistNo, String location,
      String orderType, BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    final txtoken = prefs.getString("userToken");
    var headers = {'Authorization': 'Bearer $txtoken'};
    var request = Request('POST',
        Uri.parse('${UrlHolderLoan.baseUrl}${UrlHolderLoan.markAsCompleted}'));
    request.body = json.encode({
      "pickListNo": picklistNo.trimRight(),
      "location": location.trimRight(),
      "orderType": orderType.trimRight(),
    });
    request.headers.addAll(headers);

    StreamedResponse response =
        await request.send().timeout(Duration(seconds: 60));

    if (response.statusCode == 200) {
      bool? checkVibrate = await Vibration.hasVibrator();
      final xyz = await response.stream.bytesToString();
      if (checkVibrate!) Vibration.vibrate();
      AudioPlayer().play(AssetSource('audio/sound.wav'));

      final responseData = json.decode(xyz)["message"];

      await EasyLoading.showToast(responseData.toString(),
          maskType: EasyLoadingMaskType.black,
          duration: Duration(milliseconds: 600),
          dismissOnTap: true);

      notifyListeners();

      return true;
    } else {
      bool? checkVibrate = await Vibration.hasVibrator();
      final xyz = await response.stream.bytesToString();
      if (checkVibrate!) Vibration.vibrate();
      AudioPlayer().play(AssetSource('audio/error.wav'));

      final responseData = json.decode(xyz)["message"];

      showDialogForallDialog(context, responseData.toString());

      notifyListeners();

      return false;
    }
  }

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
    final storageLocation = selectedLocationss ?? '';
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
      departmentCode: 'MG',
      location: location,
      remark: remark.isEmpty ? null : remark,
    );

    if (result != null) {
      await fetchDocuments(context, docType, 'MG', location);
      if (context.mounted) Navigator.of(context).pop();
      return true;
    }
    return false;
  }

  void dateEmpty() {
    manuDateController = TextEditingController();
    notifyListeners();
  }

  Future getPlants(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("userToken");
    var headers = {'Authorization': 'Bearer $token'};
    var request = Request(
        'GET', Uri.parse('${UrlHolderLoan.baseUrl}${UrlHolderLoan.plants}'));

    request.headers.addAll(headers);

    List<PlantModal> demoPlantList = [];

    StreamedResponse response =
        await request.send().timeout(Duration(seconds: 60));

    if (response.statusCode == 200) {
      final xyz = await response.stream.bytesToString();
      final List responseData = json.decode(xyz)["plants"];

      responseData.forEach((element) {
        return demoPlantList.add(PlantModal(
            id: element["_id"],
            code: element["code"],
            identifiers: element["identifier"],
            description: element["description"]));
      });
      plantList = demoPlantList;
      log('plantList: ${plantList.length} lenth');
      notifyListeners();
    } else {
      bool? checkVibrate = await Vibration.hasVibrator();
      final xyz = await response.stream.bytesToString();
      if (checkVibrate) Vibration.vibrate();
      AudioPlayer().play(AssetSource('audio/error.wav'));
      final responseData = json.decode(xyz)["message"];
      EasyLoading.showToast(responseData.toString(),
          maskType: EasyLoadingMaskType.black);
    }
  }

  /// Fetch documents from API and populate [documents] list.
  ///
  /// Returns `true` on success, `false` on failure.
  Future<bool> fetchDocuments(
    BuildContext context,
    String documentType,
    String departmentCode,
    String location,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("userToken");

    if (token == null || token.isEmpty) {
      return false;
    }

    log('token: $location');

    final headers = {'Authorization': 'Bearer $token'};

    final request = Request(
      'GET',
      Uri.parse(
        '${UrlHolderLoan.baseUrl}${UrlHolderLoan.getDocuments}?documentType=$documentType&departmentCode=MG&location=$location',
      ),
    );

    request.headers.addAll(headers);

    final response = await request.send();

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
  }

  /// Fetch single document detail by [documentNumber] and store in [documentDetail].
  ///
  /// Returns `true` on success, `false` on failure.
  Future<bool> fetchDocumentDetail(
    BuildContext context,
    String documentNumber,
    String location,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("userToken");

    if (token == null || token.isEmpty) {
      return false;
    }

    final headers = {'Authorization': 'Bearer $token'};

    final request = Request(
      'GET',
      Uri.parse(
        '${UrlHolderLoan.baseUrl}${UrlHolderLoan.getDocuments}/$documentNumber?location=$location',
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
  }

  /// Fetch list of departments from API and populate [departments] list.
  ///
  /// Returns `true` on success, `false` on failure.
  Future<bool> fetchDepartments(BuildContext context, String location) async {
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
          '${UrlHolderLoan.baseUrl}${UrlHolderLoan.getDepartments}?location=$location',
        ),
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
                !departments.any(
                  (d) => d.departmentCode == selectedDepartment,
                ))) {
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
  Future<bool> fetchCompetitors(BuildContext context, String location) async {
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
          '${UrlHolderLoan.baseUrl}${UrlHolderLoan.getCompetitors}?location=$location',
        ),
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
  Future<bool> fetchReasons(BuildContext context, String location) async {
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
          '${UrlHolderLoan.baseUrl}${UrlHolderLoan.getReasons}?location=$location',
        ),
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

  Future getPurposes(BuildContext context, String location) async {
    List<Purpose> txpurposes = [];
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("userToken");

      var headers = {'Authorization': 'Bearer $token'};

      var request = Request(
        'GET',
        Uri.parse(
          '${UrlHolderLoan.baseUrl}${UrlHolderLoan.purpose}?location=$location',
        ),
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
          (selectedLocationss == null ||
              !locationList.contains(selectedLocationss))) {
        selectedLocationss = locationList.first;
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

  Future showDialogForallDialog(BuildContext context, String text) async {
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
      final validRacks =
          rackList.where((r) => r.code != null && r.code!.isNotEmpty).toList();
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
          (selectedBin == null || !binList.any((b) => b.code == selectedBin))) {
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
        "createDocument inputs: docType=$docType, competitorCode=$competitorCode, purposeCode=$purposeCode, reasonCode=$reasonCode, storageLocation=$storageLocation, binCode=$binCode, rackCode=$rackCode, departmentCode=MG, location=$location, remark=$remark",
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
        "documentType": docType,
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
        if (data != null &&
            data["message"] == "Document created successfully") {
          EasyLoading.showToast(
            data["message"],
            maskType: EasyLoadingMaskType.black,
          );
        }
        return data;
      } else {
        final responseBody = await response.stream.bytesToString();
        bool? checkVibrate = await Vibration.hasVibrator();
        if (checkVibrate == true) {
          Vibration.vibrate();
        }

        final message = _extractErrorMessage(responseBody);
        EasyLoading.showToast(message, maskType: EasyLoadingMaskType.black);
        lastScanData = null;
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

  /// Scans a barcode for a PDC document line item via POST.
  ///
  /// [documentNumber] e.g. "JK-1770884172670"
  /// [barcode] scanned barcode
  /// [lineItemNo] line item number
  /// [docType] e.g. "RE"
  /// [location] e.g. "1100"
  /// [storageLocation] e.g. "FG10"
  /// [binCode] optional
  /// [rackCode] optional
  ///
  /// Returns `true` on success, `false` on failure. Stores [ScanModuleData] in [lastScanData] on success.
  Future<bool> scanDocument(
    BuildContext context, {
    required String documentNumber,
    required String barcode,
    required String lineItemNo,
    required String docType,
    required String location,
    required String storageLocation,
    String binCode = "",
    String rackCode = "",
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("userToken");

      final headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      };

      final body = {
        "barcode": barcode,
        "lineItemNo": lineItemNo,
        "docType": docType,
        "location": location,
        "storageLocation": storageLocation,
        "binCode": binCode,
        "rackCode": rackCode,
      };

      final request = Request(
        'POST',
        Uri.parse(
          '${UrlHolderLoan.baseUrl}${UrlHolderLoan.getDocuments}/$documentNumber/scan',
        ),
      );
      request.body = json.encode(body);
      request.headers.addAll(headers);

      final response = await request.send().timeout(
            const Duration(seconds: 60),
          );

      if (response.statusCode == 200) {
        final responseBody = await response.stream.bytesToString();
        final decoded = json.decode(responseBody) as Map<String, dynamic>;
        lastScanData = ScanModuleResponse.fromJson(decoded).data;
        notifyListeners();
        return true;
      } else {
        final responseBody = await response.stream.bytesToString();
        bool? checkVibrate = await Vibration.hasVibrator();
        if (checkVibrate == true) {
          Vibration.vibrate();
        }
        _player.play(AssetSource('audio/error.wav'));
        final message = _extractErrorMessage(responseBody);
        EasyLoading.showToast(message, maskType: EasyLoadingMaskType.black);
        lastScanData = null;
        return false;
      }
    } catch (e) {
      EasyLoading.showToast(
        "Connectivity issue, Please try again",
        maskType: EasyLoadingMaskType.black,
      );
      lastScanData = null;
      return false;
    }
  }

  void getManualBarcode(String resultData) {
    barcodeManualController = TextEditingController();
    barcodeManualController = TextEditingController(text: resultData);
    notifyListeners();
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

  Future<List<Category>?> fetchCategories(
      String location, String manPlant) async {
    final prefs = await SharedPreferences.getInstance();
    var _accessToken = await prefs.getString(
      "userToken",
    );
    final url =
        '${UrlHolderLoan.baseUrl}${UrlHolderLoan.getMappingCategories}?location=$location&manfplant=$manPlant';
    var headers = {
      'Content-Type': 'application/json',
      "authorization": 'Bearer $_accessToken'
    };
    var request = Request('GET', Uri.parse(url));
    request.headers.addAll(headers);

    StreamedResponse response =
        await request.send().timeout(Duration(seconds: 60));

    if (response.statusCode == 200) {
      final resp = await response.stream.bytesToString();
      CategoryModel categoryDetail = categoryModelFromJson(resp);
      // _categoryDetails.categories = categoryDetail.categories;
      _barcodeDetails.categoryDetails = categoryDetail;
      _selectedCategory = TextEditingController(
          text: _barcodeDetails.categoryDetails.categories[0].description);
      notifyListeners();
    } else {
      bool? checkVibrate = await Vibration.hasVibrator();
      final resp = await response.stream.bytesToString();
      if (checkVibrate!) Vibration.vibrate();
      AudioPlayer().play(AssetSource('audio/error.wav'));

      final responseData = json.decode(resp)["message"];
      EasyLoading.showToast(responseData.toString(),
          maskType: EasyLoadingMaskType.black);
      return null;
    }
    return null;
  }

  Future<void> fetchMaterials(
      String categoryId, String manPlant, String location) async {
    final prefs = await SharedPreferences.getInstance();
    var _accessToken = await prefs.getString(
      "userToken",
    );
    final url =
        '${UrlHolderLoan.baseUrl}${UrlHolderLoan.getMappingMaterials}?category=${categoryId.trimRight()}&manfplant=$manPlant&location=$location';
    var headers = {
      'Content-Type': 'application/json',
      "authorization": 'Bearer $_accessToken'
    };
    var request = Request('GET', Uri.parse(url));
    request.headers.addAll(headers);

    StreamedResponse response =
        await request.send().timeout(Duration(seconds: 60));

    if (response.statusCode == 200) {
      final resp = await response.stream.bytesToString();
      MaterialModel materialsDetail = materialModelFromJson(resp);
      _barcodeDetails.materialDetails = materialsDetail;

      notifyListeners();
    } else {
      bool? checkVibrate = await Vibration.hasVibrator();
      final resp = await response.stream.bytesToString();
      if (checkVibrate) Vibration.vibrate();
      AudioPlayer().play(AssetSource('audio/error.wav'));

      final responseData = json.decode(resp)["message"];
      EasyLoading.showToast(responseData.toString(),
          maskType: EasyLoadingMaskType.black);
      return null;
    }
  }

  Future<void> fetchMaterialPlants(BuildContext context) async {
    print("objectkjasdknskjd");
    final prefs = await SharedPreferences.getInstance();
    var _accessToken = await prefs.getString(
      "userToken",
    );
    final url = '${UrlHolderLoan.baseUrl}${UrlHolderLoan.getMappingPlants}';
    var headers = {
      'Content-Type': 'application/json',
      "authorization": 'Bearer $_accessToken'
    };
    var request = Request('GET', Uri.parse(url));
    request.headers.addAll(headers);

    StreamedResponse response =
        await request.send().timeout(Duration(seconds: 60));

    if (response.statusCode == 200) {
      final resp = await response.stream.bytesToString();
      MaterialPlantModel materialPlantsDetail =
          materialPlantModelFromJson(resp);
      _barcodeDetails.materialPlantDetails = materialPlantsDetail;
      log("${_barcodeDetails.materialPlantDetails.plants.length} lengthhhh");
      // _selectedPrefix =
      //     _barcodeDetails.materialPlantDetails.plants[0].identifiers;
      notifyListeners();
    } else {
      bool? checkVibrate = await Vibration.hasVibrator();
      final resp = await response.stream.bytesToString();
      if (checkVibrate) Vibration.vibrate();
      AudioPlayer().play(AssetSource('audio/error.wav'));

      final responseData = json.decode(resp)["message"];
      EasyLoading.showToast(responseData.toString(),
          maskType: EasyLoadingMaskType.black);
      return null;
    }
  }

  Future onCategoryChanged(
      String? newValue, String location, String manPlant) async {
    // _isCategoryLoading = true;
    selectedMaterial = "";
    log("${newValue} newvalll");
    notifyListeners();
    _selectedCategory = TextEditingController(text: newValue);

    var _newSelectedCategory = _barcodeDetails.categoryDetails.categories
        .firstWhere((category) =>
            category.description == _selectedCategory!.value.text);
    _barcodeDetails.materialDetails.materials.clear();
    log(_newSelectedCategory.code);
    await fetchMaterials(_newSelectedCategory.code, manPlant, location);

    notifyListeners();
  }

  Future<Map<String, dynamic>?> unscanDocument({
    required String documentNumber,
    required String barcode,
    required String lineItemNo,
    required String docType,
    required String location,
    required String storageLocation,
    String binCode = "",
    String rackCode = "",
  }) async {
    try {
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

      final url = Uri.parse(
        '${UrlHolderLoan.baseUrl}${UrlHolderLoan.getDocuments}/$documentNumber/unscan',
      );

      final requestBody = {
        "barcode": barcode,
        "lineItemNo": lineItemNo,
        "docType": docType,
        "location": location,
        "storageLocation": storageLocation,
        "binCode": binCode,
        "rackCode": rackCode,
      };

      final request = Request('POST', url);
      request.body = json.encode(requestBody);
      request.headers.addAll(headers);

      final response = await request.send();

      if (response.statusCode == 200) {
        final body = await response.stream.bytesToString();
        return json.decode(body) as Map<String, dynamic>;
      } else {
        final body = await response.stream.bytesToString();
        EasyLoading.showToast(
          _extractErrorMessage(body),
          maskType: EasyLoadingMaskType.black,
        );
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

  Future<bool> scanBarcode(
      String barcode,
      String pickListNos,
      String docType,
      String location,
      String storageLocation,
      String txxdeviceId,
      BuildContext context,
      {bool removeBarcode = false}) async {
    final prefs = await SharedPreferences.getInstance();
    final txtoken = prefs.getString("userToken");
    var headers = {'Authorization': 'Bearer $txtoken'};
    log('${UrlHolderLoan.baseUrl}${UrlHolderLoan.scanBarcode}?barcode=${barcode.trimRight()}&pickListNo=${pickListNos.trimRight()}&docType=${docType.trimRight()}&ordType=TT&location=$location&fromstrg=&deviceId=');
    var request = Request(
        removeBarcode ? 'DELETE' : 'GET',
        Uri.parse(
            '${UrlHolderLoan.baseUrl}${UrlHolderLoan.scanBarcode}?barcode=${barcode.trimRight()}&pickListNo=${pickListNos.trimRight()}&docType=${docType.trimRight()}&ordType=TT&location=$location&fromstrg=&deviceId=&binCd=&rackCd='));

    request.headers.addAll(headers);

    StreamedResponse response =
        await request.send().timeout(Duration(seconds: 60));

    if (response.statusCode == 200) {
      bool? checkVibrate = await Vibration.hasVibrator();
      final xyz = await response.stream.bytesToString();
      if (checkVibrate!) Vibration.vibrate();
      AudioPlayer().play(AssetSource('audio/sound.wav'));
      final responseDataToShow = json.decode(xyz);

      log("$responseDataToShow testing");

      barcodeShow = responseDataToShow["data"]["Barcode"] ?? "";
      pickListNo = responseDataToShow["data"]["PickListNo"] ?? "";
      prodDate = responseDataToShow["data"]["ProdDate"] ?? "";
      stencilNo = responseDataToShow["data"]["StencilBarcode"] ?? "";
      material = responseDataToShow["data"]["Maktx"] ?? "";
      matnr = responseDataToShow["data"]["Matnr"] ?? "";

      final responseData = json.decode(xyz)["message"] ?? "";

      errorMessage = responseData.toString();

      // EasyLoading.showToast(responseData.toString(),
      //     maskType: EasyLoadingMaskType.black);

      notifyListeners();
      return true;
    } else {
      bool? checkVibrate = await Vibration.hasVibrator();
      final xyz = await response.stream.bytesToString();
      final responseDataToShow = json.decode(xyz);

      log("$responseDataToShow testing fail");

      if (checkVibrate) Vibration.vibrate();
      player.play(AssetSource('audio/sirenerror.wav'));
      player.setReleaseMode(ReleaseMode.loop);

      showDialogForall(context, json.decode(xyz)["message"].toString());

      final responseData = json.decode(xyz)["message"];
      errorMessage = responseData.toString();

      // final responseDataForStatus =
      //     json.decode(xyz)["data"]["UID_Status"]["Status"] ?? "";
      // print("$responseDataForStatus checkingtesting");

      barcodeShow = responseDataToShow["data"]?["Barcode"] ?? "";
      prodDate = responseDataToShow["data"]?["ProdDate"] ?? "";
      stencilNo = responseDataToShow["data"]?["StencilBarcode"] ?? "";
      material = responseDataToShow["data"]?["Maktx"] ?? "";
      matnr = responseDataToShow["data"]?["Matnr"] ?? "";

      // EasyLoading.showToast(responseData.toString(),
      //     maskType: EasyLoadingMaskType.black);

      notifyListeners();

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
                            fontSize: 38.sp, fontWeight: FontWeight.w700),
                      ),
                      SizedBox(width: 8.w),
                      Icon(Icons.error, color: Colors.red, size: 38.r)
                    ],
                  ),
                  SizedBox(height: 10.0),
                  Text(
                    text,
                    style:
                        TextStyle(fontSize: 30.sp, fontWeight: FontWeight.w600),
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
                              fontSize: 28.sp, fontWeight: FontWeight.w600),
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

class BarcodeDetails {
  late LocationModel locationDetails;
  late CategoryModel categoryDetails;
  late MaterialModel materialDetails;
  late MaterialPlantModel materialPlantDetails;

  BarcodeDetails(
      {required this.locationDetails,
      required this.categoryDetails,
      required this.materialDetails,
      required this.materialPlantDetails});
}
