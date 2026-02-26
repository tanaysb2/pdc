import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_datawedge/flutter_datawedge.dart';
import 'package:flutter_datawedge/models/scan_result.dart';
import 'package:flutter_datawedge/models/scanner_status.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:pdc_test/Modules/category_model.dart';
import 'package:pdc_test/Modules/document_detail_model.dart';
import 'package:pdc_test/Modules/document_modal.dart';
import 'package:pdc_test/Modules/plant.dart';
import 'package:pdc_test/Providers/auth_provider.dart';
import 'package:pdc_test/Providers/receiving_provider.dart';
import 'package:pdc_test/Resuable%20components/app_bar.dart';
import 'package:pdc_test/Resuable%20components/barcode_info.dart';
import 'package:pdc_test/Resuable%20components/custom_lablel_dropdown.dart';
import 'package:pdc_test/Resuable%20components/custom_searchable_dropdown.dart';
import 'package:pdc_test/Resuable%20components/custom_searchbox.dart';
import 'package:pdc_test/Resuable%20components/loading.dart';
import 'package:pdc_test/Resuable%20components/text_field.dart';
import 'package:pdc_test/Screens/Receiving_screen.dart/receiving_screen.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:provider/provider.dart';
import 'package:vibration/vibration.dart';

// ignore: must_be_immutable
class ReceivingScanScreen extends StatefulWidget {
  DocumentData document;
  String location;
  String erName;
  String pickListnos;
  String docType;
  String ordType;
  String type;
  String invoiceNo;
  bool bbdn;
  bool nonBbdn;
  String shipmentId;
  String title;
  String userId;
  ReceivingScanScreen({
    super.key,
    required this.document,
    required this.location,
    required this.pickListnos,
    required this.invoiceNo,
    this.shipmentId = "",
    this.title = "",
    this.erName = "",
    required this.type,
    this.bbdn = false,
    this.nonBbdn = false,
    required this.docType,
    required this.ordType,
    this.userId = "",
  });

  @override
  State<ReceivingScanScreen> createState() => _PendingTabScreenState();
}

class _PendingTabScreenState extends State<ReceivingScanScreen> {
  bool _isLoading = false;
  bool _isLoadingInside = false;
  ScanResult? scanResults;
  String lastStatus = '';
  bool removeCheck = false;
  String materialCode = "";
  String manPlantCode = "";
  int checkSuccess = 0;
  String material = "";
  late StreamSubscription<ScanResult> onScanResultListener;
  late StreamSubscription<ScannerStatus> onScannerStatusListener;
  // late StreamSubscription<ActionResult> onScannerEventListener;
  late FlutterDataWedge fdw;
  Future<void>? initScannerResult;
  bool isTrue = false;
  String barcodeFromScanning = "";
  FocusNode stencilFocusNode = FocusNode();

  bool reload = false;

  // bool scanningCompleted = false;
  final player = AudioPlayer();

  ///// Controller fields

  TextEditingController barcodeController = TextEditingController();
  TextEditingController materialController = TextEditingController();
  TextEditingController stencilNoController = TextEditingController();
  TextEditingController dateController = TextEditingController();
  TextEditingController barcodeManualController = TextEditingController();
  TextEditingController manufactoringPlantController = TextEditingController();

  ///// MANUAL

  TextEditingController materialManualController = TextEditingController();
  TextEditingController stencilManualController = TextEditingController();
  TextEditingController prodDateManualController = TextEditingController();
  TextEditingController plantController = TextEditingController();

  TextEditingController manufacturingDateManualController =
      TextEditingController();

  ///// End fields
  ///

  // @override
  // void initState() {
  //   super.initState();
  //   // reload = true;
  //   setState(() {
  //     _isLoading = true;
  //   });

  //   log("${widget.document.documentNumber}");
  //   log("${widget.type}");
  //   log("${widget.location}");

  //   checkSuccess = 0;

  //   // _barcodeDetailProvider =
  //   //     Provider.of<BarcodeDetailProvider>(context, listen: false);
  //   // barcodeDetails = _barcodeDetailProvider.barcodeDetails;

  //   Provider.of<ReceivingProvider>(context, listen: false).getPlants(context);

  //   stencilFocusNode.addListener(() {
  //     log("$materialCode tanaysingh");
  //     log("${stencilManualController.value.text} tanaysingh222");
  //     log("${plantController.value.text} tanaysingh333");
  //     if (stencilManualController.value.text.isNotEmpty) {
  //       if (!stencilFocusNode.hasFocus) {
  //         setState(() {
  //           _isLoading = true;
  //         });
  //         Provider.of<ReceivingProvider>(context, listen: false)
  //             .stencilVerficationForAddBarcode(
  //           stencilManualController.value.text,
  //           materialCode,
  //           plantController.value.text,
  //           widget.location,
  //           "CG",
  //           widget.pickListnos,
  //         );
  //         setState(() {
  //           _isLoading = false;
  //         });
  //       }
  //     }
  //   });

  //   Provider.of<ReceivingProvider>(context, listen: false)
  //       .fetchDocumentDetail(
  //           context, widget.document.documentNumber, widget.location)
  //       .then((value) {
  //     initScannerResult = initScanner();
  //     setState(() {
  //       _isLoading = false;
  //     });
  //   });
  // }

  @override
  void initState() {
    super.initState();
    setState(() {
      _isLoading = true;
    });

    log("${widget.document.documentNumber}");
    log("${widget.type}");
    log("${widget.location}");

    checkSuccess = 0;

    // _barcodeDetailProvider =
    //     Provider.of<BarcodeDetailProvider>(context, listen: false);
    // barcodeDetails = _barcodeDetailProvider.barcodeDetails;

    stencilFocusNode.addListener(() {
      log("stencil 1");
      if (Provider.of<ReceivingProvider>(context, listen: false)
          .stencilIdController
          .value
          .text
          .isNotEmpty) {
        if (!stencilFocusNode.hasFocus) {
          log("stencil 2");
          setState(() {
            _isLoading = true;
          });
          log("stencil 3");
          Provider.of<ReceivingProvider>(context, listen: false)
              .stencilVerficationForAddBarcode(
                  "${Provider.of<ReceivingProvider>(context, listen: false).stencilIdController.value.text}",
                  materialCode,
                  plantController.value.text,
                  widget.location,
                  "TT",
                  widget.document.documentNumber);
          setState(() {
            _isLoading = false;
          });
        }
      }
    });

    Provider.of<ReceivingProvider>(context, listen: false)
        .fetchDocumentDetail(
            context, widget.document.documentNumber, widget.location)
        .then((value) {
      Provider.of<ReceivingProvider>(context, listen: false)
          .getPlants(context)
          .then((value) {
        Provider.of<ReceivingProvider>(context, listen: false)
            .fetchMappingData(context, widget.location)
            .then((value) {
          setState(() {
            _isLoading = false;
          });
        });
      });
    }).then((value) {
      initScannerResult = initScanner();
      setState(() {
        _isLoading = false;
      });
    });
  }

  Future showPlantBox(BuildContext context) async {
    final itemSelect = Provider.of<ReceivingProvider>(context, listen: false);

    itemSelect.selectedMaterial = "";
    itemSelect.stencilIdController = TextEditingController();
    itemSelect.manuDateController = TextEditingController();
    isTrue = true;

    setState(() {});

    await showModalBottomSheet<void>(
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.0),
      ),
      backgroundColor: Colors.white,
      context: context,
      builder: (BuildContext context) {
        final item = Provider.of<ReceivingProvider>(context, listen: true);
        // final itemForPlant = Provider.of<AuthProvider>(context, listen: true);
        final itemSelect =
            Provider.of<ReceivingProvider>(context, listen: true);
        return StatefulBuilder(
            builder: (BuildContext context, StateSetter setState11) {
          return Stack(
            children: [
              Padding(
                padding: EdgeInsets.only(
                    bottom: MediaQuery.of(context).viewInsets.bottom),
                child: Container(
                  height: 1050.h,
                  padding: EdgeInsets.symmetric(horizontal: 30.w),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        SizedBox(height: 40.h),
                        Text("Add Barcode",
                            style: textFieldStyle(
                                color: Color.fromARGB(255, 1, 77, 138),
                                weight: FontWeight.w700,
                                fontSize: 43.sp)),
                        SizedBox(height: 40.h),
                        Container(
                          margin: EdgeInsets.only(left: 8.w),
                          child: CustomTextField(
                            controller: item.barcodeManualController,
                            isEnabled: false,
                            labelText: "Enter Barcode",
                            margin: false,
                            checking: true,
                          ),
                        ),
                        SizedBox(height: 30.h),
                        Container(
                          margin: EdgeInsets.only(left: 10.w, bottom: 20.h),
                          child: DropdownInput(
                            isMargin: false,
                            controller: plantController,
                            labelText: "Select Manufacturing Plant",
                            // value: consajda.value.text,

                            isEnabled: true,
                            inputFieldWidth: double.infinity,
                            items: item.plantList.map((PlantModal value) {
                              return DropdownMenuItem<String>(
                                value: value.description,
                                child: Text(value.description),
                              );
                            }).toList(),
                            onChanged: (value) async {
                              print(value);
                              // print("$value vauejnka");

                              PlantModal cyz = item.plantList.firstWhere(
                                  (element) => element.description == value);
                              print("${cyz.code} indeftid");

                              manPlantCode = cyz.code;

                              setState(() {
                                _isLoading = true;
                              });

                              await itemSelect.fetchCategories(
                                  widget.location, cyz.code);

                              setState(() {
                                _isLoading = false;
                              });

                              itemSelect
                                  .onMaterialPlantChangedformanul(cyz.code);
                              plantController =
                                  TextEditingController(text: cyz.description);
                              setState(() {});
                            },
                          ),
                        ),
                        Container(
                          alignment: Alignment.centerLeft,
                          margin: EdgeInsets.only(left: 14.w, bottom: 10.h),
                          child: DropdownInput(
                            isMargin: false,
                            controller: item.selectedCategory,
                            labelText: "Select Category",
                            isEnabled: true,
                            inputFieldWidth: double.infinity,
                            items: item
                                .barcodeDetails.categoryDetails.categories
                                .map((Category value) {
                              return DropdownMenuItem<String>(
                                value: value.description,
                                child: Text(value.description),
                              );
                            }).toList(),
                            onChanged: (value) async {
                              setState(() {
                                _isLoading = true;
                              });

                              log("$value checking value");
                              log("${widget.location} checking value");
                              log("${manPlantCode} checking value");

                              await itemSelect.onCategoryChanged(
                                value,
                                widget.location,
                                manPlantCode,
                              );
                              setState(() {
                                _isLoading = false;
                              });
                            },
                          ),
                        ),
                        SizedBox(height: 15.h),
                        Container(
                          alignment: Alignment.centerLeft,
                          margin: EdgeInsets.only(left: 14.w, bottom: 10.h),
                          child: SearchableDropDown(
                            labelName: "Select Item",
                            dropDownItems: item
                                .barcodeDetails.materialDetails.materials
                                .map((material) => material.description)
                                .toList(),
                            selectedItem: item.selectedMaterial,
                            onDropDownItemSelected: (p0) {
                              print(p0);

                              itemSelect.onMaterialItemChanged(p0.toString());
                              var _materialDetail = item
                                  .barcodeDetails.materialDetails.materials
                                  .firstWhere(
                                      (material) => material.description == p0);
                              materialCode = _materialDetail.code;
                              setState(() {});
                            },
                          ),
                        ),
                        SizedBox(height: 40.h),
                        Container(
                          margin: EdgeInsets.symmetric(horizontal: 10.w),
                          child: Row(
                            children: [
                              Expanded(
                                child: CustomTextField(
                                  margin: false,
                                  isEnabled: item.selectedMaterial.isEmpty &&
                                          plantController.value.text.isEmpty
                                      ? false
                                      : true,
                                  focusNode: stencilFocusNode,
                                  maxlength: true,
                                  onChanged: (p0) {
                                    itemSelect.dateEmpty();
                                  },
                                  labelText: "Enter Stencil ID",
                                  controller: itemSelect.stencilIdController,
                                  validator: (value) {
                                    // String finalStringsss = value!.substring(
                                    //     (value.length - 4).clamp(0, value.length));
                                    // print("$finalStringsss finalString");
                                    if (value!.isEmpty) {
                                      return "Stencil ID can't be empty";
                                    } else {
                                      return null;
                                    }
                                  },
                                ),
                              ),
                              SizedBox(width: 5.w),
                              if (itemSelect
                                  .manuDateController.value.text.isNotEmpty)
                                Container(
                                    margin: EdgeInsets.only(bottom: 35.h),
                                    child: Icon(Icons.check_circle,
                                        color: Colors.blue))
                            ],
                          ),
                        ),
                        SizedBox(height: 15.h),
                        CustomTextField(
                          controller: itemSelect.manuDateController,
                          labelText: "Select Mfg Date",
                          isReadOnly: true,
                        ),
                        SizedBox(height: 10.h),
                        Container(
                          height: 90.h,
                          margin: EdgeInsets.symmetric(horizontal: 10.w),
                          width: double.infinity,
                          child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    Color.fromARGB(255, 1, 77, 138),
                                shape: RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.circular(12), // <-- Radius
                                ),
                              ),
                              onPressed: () async {
                                setState11(() {
                                  _isLoadingInside = true;
                                });
                                // log(item.selectedMaterial);

                                // bool check = await item.submitBarcode(
                                //     item.barcodeManualController!.value.text,
                                //     materialCode,
                                //     itemSelect.stencilIdController.value.text,
                                //     itemSelect.manuDateController.value.text,
                                //     manPlantCode,
                                //     widget.location,
                                //     "IN${widget.location}${locationController.value.text}${binController.value.text}${rackController.value.text}${DateFormat('ddMMyy').format(DateTime.now()).toString()}");

                                // if (check) {
                                //   reload = true;
                                //   setState(() {});
                                //   setState11(() {
                                //     _isLoadingInside = false;
                                //   });
                                //   Navigator.of(context).pop();
                                // } else {
                                //   setState(() {
                                //     reload = false;
                                //   });
                                //   setState11(() {
                                //     _isLoadingInside = false;
                                //   });
                                // }
                              },
                              child: Text("Submit",
                                  style: textFieldStyle(
                                      color: Colors.white,
                                      weight: FontWeight.w700,
                                      fontSize: 34.sp))),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              if (_isLoadingInside)
                Center(
                  child: LoaderTransparent(color: Colors.white),
                ),
            ],
          );
        });
      },
    ).whenComplete(() {
      // final itemSelect =
      //     Provider.of<BarcodeDetailProvider>(context, listen: true);
      // itemSelect.selectedMaterial = "";
      // itemSelect.stencilIdController = TextEditingController();

      // prodDateManualController = TextEditingController();
      // manufacturingDateManualController = TextEditingController();
      // Provider.of<BarcodeDetailProvider>(context, listen: false)
      //     .manuDateController = TextEditingController();

      // Provider.of<AdHocProvider>(context, listen: false)
      //     .barcodeManualController = TextEditingController();

      // isTrue = false;

      setState(() {});
    });
  }

  Future<void> initScanner() async {
    if (Platform.isAndroid) {
      // final item = Provider.of<ReceivingProvider>(context, listen: false);
      fdw = FlutterDataWedge(profileName: 'flutter wedge');
      onScanResultListener =
          fdw.onScanResult.listen((result) => setState(() async {
                scanResults = result;

                if (isTrue) {
                  Provider.of<ReceivingProvider>(context, listen: false)
                      .getManualBarcode(result.data);
                }

                if (isTrue == false)
                  await Provider.of<ReceivingProvider>(context, listen: false)
                      .scanBarcode(result.data, widget.document.documentNumber,
                          widget.type, widget.location, "", '', context,
                          removeBarcode: removeCheck)
                      .then((value) {
                    if (value) {
                      if (isTrue == false)
                        Provider.of<ReceivingProvider>(context, listen: false)
                            .fetchDocumentDetail(
                                context,
                                widget.document.documentNumber,
                                widget.location);
                      //// response 200x
                      checkSuccess = 1;
                      setState(() {});
                      //// response 200
                    } else {
                      checkSuccess = 2;
                      setState(() {});
                      //// response 400
                    }
                  });
              }));

      onScannerStatusListener = fdw.onScannerStatus.listen(
          (status) => setState(() => lastStatus = status.status.toString()));
      await fdw.initialize();
    }
  }

  @override
  void dispose() {
    onScanResultListener.cancel();
    onScannerStatusListener.cancel();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final item = Provider.of<ReceivingProvider>(context, listen: true);

    return Stack(
      children: [
        SafeArea(
          child: Scaffold(
            backgroundColor: Colors.white,
            body: Column(
              children: [
                Container(
                  height: 1115.h,
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        CustomAppBar(text: 'Gate In'),
                        SizedBox(height: 15.h),
                        customTile(widget.document, widget.location, context,
                            () {}, "COMPLETED QA CAGE LIST"),

                        // Container(
                        //   width: double.infinity,
                        //   padding: EdgeInsets.only(top: 20.h),
                        //   margin: EdgeInsets.symmetric(
                        //     horizontal: 30.w,
                        //     vertical: 4.h,
                        //   ),
                        //   decoration: BoxDecoration(
                        //     // border: Border.all(color: Colors.white),
                        //     color: Colors.white,
                        //     boxShadow: [
                        //       BoxShadow(
                        //         color: Colors.black,
                        //         offset: Offset(0.0, 0.4), //(x,y)
                        //         blurRadius: 0.6,
                        //       ),
                        //     ],
                        //     borderRadius: BorderRadius.circular(8),
                        //   ),
                        //   child: Column(
                        //     children: [
                        //       Container(
                        //         padding: EdgeInsets.only(
                        //           right: 16.w,
                        //           left: 16.w,
                        //           top: 20.h,
                        //         ),
                        //         child: Row(
                        //           children: [
                        //             Column(
                        //               crossAxisAlignment:
                        //                   CrossAxisAlignment.start,
                        //               children: [
                        //                 InkWell(
                        //                   onTap: () {
                        //                     // tempScan();
                        //                   },
                        //                   child: Text(
                        //                     "Order#",
                        //                     style: textFieldStyle(
                        //                       color: Colors.grey.shade800,
                        //                       fontSize: 26.sp,
                        //                       weight: FontWeight.w500,
                        //                     ),
                        //                   ),
                        //                 ),
                        //                 SizedBox(height: 3.h),
                        //                 Container(
                        //                   width: 210.w,
                        //                   child: Text(
                        //                     widget.pickListnos,
                        //                     maxLines: 2,
                        //                     style: textFieldStyle(
                        //                       color: Color.fromARGB(
                        //                         255,
                        //                         1,
                        //                         77,
                        //                         138,
                        //                       ),
                        //                       fontSize: 34.sp,
                        //                       weight: FontWeight.w700,
                        //                     ),
                        //                   ),
                        //                 ),
                        //                 SizedBox(height: 10.h),
                        //               ],
                        //             ),
                        //             Spacer(),
                        //             Column(
                        //               crossAxisAlignment:
                        //                   CrossAxisAlignment.start,
                        //               children: [
                        //                 Text(
                        //                   "Total Items",
                        //                   style: textFieldStyle(
                        //                     color: Colors.grey.shade800,
                        //                     fontSize: 26.sp,
                        //                     weight: FontWeight.w500,
                        //                   ),
                        //                 ),
                        //                 SizedBox(height: 3.h),
                        //                 Text(
                        //                   _isLoading
                        //                       ? ""
                        //                       : item.singleOrderList.length
                        //                             .toString(),
                        //                   style: textFieldStyle(
                        //                     color: Color.fromARGB(
                        //                       255,
                        //                       1,
                        //                       77,
                        //                       138,
                        //                     ),
                        //                     fontSize: 34.sp,
                        //                     weight: FontWeight.w700,
                        //                   ),
                        //                 ),
                        //                 SizedBox(height: 10.h),
                        //               ],
                        //             ),
                        //             Spacer(),
                        //             if (item.singleOrderList.isNotEmpty)
                        //               Text(
                        //                 _isLoading
                        //                     ? ""
                        //                     : "${item.singleOrderList[0].scanned}/${item.singleOrderList[0].total}",
                        //                 style: textFieldStyle(
                        //                   color: Color.fromARGB(
                        //                     255,
                        //                     1,
                        //                     77,
                        //                     138,
                        //                   ),
                        //                   fontSize: 52.sp,
                        //                   weight: FontWeight.w700,
                        //                 ),
                        //               ),
                        //             Icon(Icons.person_2_outlined, size: 55.sp),
                        //             Spacer(),
                        //           ],
                        //         ),
                        //       ),
                        //       SizedBox(height: 25.h),
                        //       if (widget.bbdn)
                        //         Container(
                        //           margin: EdgeInsets.only(left: 20.w),
                        //           child: Row(
                        //             children: [
                        //               Text(
                        //                 "Invoice no:",
                        //                 style: textFieldStyle(
                        //                   color: Colors.grey.shade800,
                        //                   fontSize: 26.sp,
                        //                   weight: FontWeight.w500,
                        //                 ),
                        //               ),
                        //               SizedBox(width: 17.h),
                        //               Container(
                        //                 width: 400.w,
                        //                 child: Text(
                        //                   widget.invoiceNo,
                        //                   style: textFieldStyle(
                        //                     color: Color.fromARGB(
                        //                       255,
                        //                       1,
                        //                       77,
                        //                       138,
                        //                     ),
                        //                     fontSize: 28.sp,
                        //                     weight: FontWeight.w700,
                        //                   ),
                        //                 ),
                        //               ),
                        //             ],
                        //           ),
                        //         ),
                        //       SizedBox(height: 16.h),
                        //       if (widget.bbdn)
                        //         Container(
                        //           margin: EdgeInsets.only(left: 20.w),
                        //           child: Row(
                        //             children: [
                        //               Text(
                        //                 "Shipment Id:",
                        //                 style: textFieldStyle(
                        //                   color: Colors.grey.shade800,
                        //                   fontSize: 26.sp,
                        //                   weight: FontWeight.w500,
                        //                 ),
                        //               ),
                        //               SizedBox(width: 17.h),
                        //               Container(
                        //                 width: 400.w,
                        //                 child: Text(
                        //                   widget.shipmentId,
                        //                   style: textFieldStyle(
                        //                     color: Color.fromARGB(
                        //                       255,
                        //                       1,
                        //                       77,
                        //                       138,
                        //                     ),
                        //                     fontSize: 28.sp,
                        //                     weight: FontWeight.w700,
                        //                   ),
                        //                 ),
                        //               ),
                        //             ],
                        //           ),
                        //         ),
                        //       if (widget.bbdn) SizedBox(height: 15.h),
                        //       if (item
                        //           .singleOrderList[0]
                        //           .customerName
                        //           .isNotEmpty)
                        //         Container(
                        //           margin: EdgeInsets.only(
                        //             left: 20.w,
                        //             bottom: 20.h,
                        //           ),
                        //           child: Row(
                        //             children: [
                        //               Text(
                        //                 "Customer:",
                        //                 style: textFieldStyle(
                        //                   color: Colors.grey.shade800,
                        //                   fontSize: 26.sp,
                        //                   weight: FontWeight.w500,
                        //                 ),
                        //               ),
                        //               SizedBox(width: 17.h),
                        //               Container(
                        //                 width: 400.w,
                        //                 child: Text(
                        //                   item.singleOrderList[0].customerName,
                        //                   style: textFieldStyle(
                        //                     color: Color.fromARGB(
                        //                       255,
                        //                       1,
                        //                       77,
                        //                       138,
                        //                     ),
                        //                     fontSize: 28.sp,
                        //                     weight: FontWeight.w700,
                        //                   ),
                        //                 ),
                        //               ),
                        //               SizedBox(width: 17.h),
                        //             ],
                        //           ),
                        //         ),
                        //       if (widget.docType.isNotEmpty)
                        //         Container(
                        //           margin: EdgeInsets.only(
                        //             left: 20.w,
                        //             bottom: 20.h,
                        //           ),
                        //           child: Row(
                        //             children: [
                        //               Text(
                        //                 "Document:",
                        //                 style: textFieldStyle(
                        //                   color: Colors.grey.shade800,
                        //                   fontSize: 26.sp,
                        //                   weight: FontWeight.w500,
                        //                 ),
                        //               ),
                        //               SizedBox(width: 17.h),
                        //               Container(
                        //                 child: Text(
                        //                   widget.docType,
                        //                   style: textFieldStyle(
                        //                     color: Color.fromARGB(
                        //                       255,
                        //                       1,
                        //                       77,
                        //                       138,
                        //                     ),
                        //                     fontSize: 28.sp,
                        //                     weight: FontWeight.w700,
                        //                   ),
                        //                 ),
                        //               ),
                        //               SizedBox(width: 80.h),
                        //               if (item
                        //                   .singleOrderList[0]
                        //                   .info
                        //                   .isNotEmpty)
                        //                 Row(
                        //                   children: [
                        //                     Text(
                        //                       "Info:",
                        //                       style: textFieldStyle(
                        //                         color: Colors.grey.shade800,
                        //                         fontSize: 26.sp,
                        //                         weight: FontWeight.w500,
                        //                       ),
                        //                     ),
                        //                     SizedBox(width: 17.h),
                        //                     ElTooltip(
                        //                       content: Text(
                        //                         item.singleOrderList[0].info,
                        //                         style: textFieldStyle(
                        //                           color: Color.fromARGB(
                        //                             255,
                        //                             1,
                        //                             77,
                        //                             138,
                        //                           ),
                        //                           fontSize: 30.sp,
                        //                           weight: FontWeight.w800,
                        //                         ),
                        //                       ),
                        //                       color: Colors.white,
                        //                       child: Icon(
                        //                         Icons.info_rounded,
                        //                         size: 40.r,
                        //                       ),
                        //                     ),
                        //                   ],
                        //                 ),
                        //             ],
                        //           ),
                        //         ),
                        //       SizedBox(height: 20.h),
                        //       if (item.singleOrderList.isNotEmpty)
                        //         ClipRRect(
                        //           borderRadius: BorderRadius.only(
                        //             bottomLeft: Radius.circular(8),
                        //             bottomRight: Radius.circular(8),
                        //           ),
                        //           child: LinearPercentIndicator(
                        //             lineHeight: 28.0.h,
                        //             padding: EdgeInsets.zero,
                        //             percent: _isLoading
                        //                 ? 0
                        //                 : double.parse(
                        //                     item
                        //                         .singleOrderList[0]
                        //                         .totalPercentage,
                        //                   ),
                        //             animation: true,
                        //             backgroundColor: Colors.white,
                        //             progressColor: _isLoading
                        //                 ? Colors.white
                        //                 : item
                        //                           .singleOrderList[0]
                        //                           .totalPercentage ==
                        //                       1
                        //                 ? Color.fromARGB(255, 15, 122, 19)
                        //                 : const Color.fromARGB(
                        //                     255,
                        //                     241,
                        //                     222,
                        //                     51,
                        //                   ),
                        //             // Color.fromARGB(255, 117, 221, 120),
                        //           ),
                        //         ),
                        //     ],
                        //   ),
                        // ),
                        SizedBox(height: 10.h),

                        //////
                        ///      container for barcode result
                        //////
                        if (widget.type != "COMPLETE DISPATCH LIST")
                          Container(
                            height: 360.h,
                            width: double.infinity,
                            padding: EdgeInsets.symmetric(
                              horizontal: 20.w,
                              vertical: 10.h,
                            ),
                            margin: EdgeInsets.symmetric(
                              horizontal: 30.w,
                              vertical: 14.h,
                            ),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: checkSuccess == 0
                                    ? Colors.grey
                                    : checkSuccess == 1
                                        ? Color.fromARGB(255, 15, 122, 19)
                                        : Color.fromARGB(255, 239, 36, 22),
                                width: checkSuccess == 0 ? 1 : 6,
                              ),
                            ),
                            child: Column(
                              children: [
                                // if (checkSuccess == 1)
                                //   Row(
                                //     crossAxisAlignment: CrossAxisAlignment.end,
                                //     mainAxisAlignment: MainAxisAlignment.end,
                                //     children: [
                                //       CircleAvatar(
                                //         backgroundColor:
                                //             item.showCircleLight == "R"
                                //             ? Colors.red
                                //             : Colors.green,
                                //         radius: 28.r,
                                //       ),
                                //     ],
                                //   ),
                                // if (item.skuNo == "0" || item.skuNo.isEmpty)
                                //   SizedBox(height: 15.h),
                                // if (checkSuccess == 1)
                                //   Row(
                                //     children: [
                                //       Expanded(
                                //         child: BarcodeInfo(
                                //           header: "Barcode",
                                //           info: item.barcodeShow,
                                //         ),
                                //       ),
                                //       if (item.skuNo != "0" &&
                                //           item.skuNo.isNotEmpty)
                                //         ElevatedButton(
                                //           onPressed: () {
                                //             Navigator.of(context).push(
                                //               MaterialPageRoute(
                                //                 builder: (context) {
                                //                   return OldStkScreen(
                                //                     location: widget.location,
                                //                     materialCode: item.matnr,
                                //                     materialDesc: item.material,
                                //                     date: item.prodDate,
                                //                   );
                                //                 },
                                //               ),
                                //             );
                                //           },
                                //           style: ElevatedButton.styleFrom(
                                //             backgroundColor: Color.fromARGB(
                                //               255,
                                //               84,
                                //               157,
                                //               217,
                                //             ),
                                //             foregroundColor: Colors.grey,
                                //             padding: EdgeInsets.symmetric(
                                //               horizontal: 20.w,
                                //               vertical: 10.h,
                                //             ),
                                //           ),
                                //           child: Text(
                                //             "Old Stk : ${item.skuNo}",
                                //             style: TextStyle(
                                //               fontSize: 28.sp,
                                //               fontWeight: FontWeight.bold,
                                //               color: Colors.white,
                                //             ),
                                //           ),
                                //         ),
                                //       // BarcodeInfoOldSKu(
                                //       //     header: "Old Sku", info: "5")
                                //     ],
                                //   ),
                                // if (item.skuNo == "0" || item.skuNo.isEmpty)
                                //   SizedBox(height: 15.h),

                                if (checkSuccess == 1)
                                  BarcodeInfo(
                                    header: "Mfg Date",
                                    info: item.prodDate,
                                  ),

                                SizedBox(height: 15.h),
                                if (checkSuccess == 1)
                                  BarcodeInfo(
                                    header: "Stencil No",
                                    bold: true,
                                    info: item.stencilNo,
                                  ),
                                SizedBox(height: 15.h),
                                if (checkSuccess == 1)
                                  BarcodeInfo(
                                    header: "Material",
                                    info: item.material,
                                  ),
                                SizedBox(height: 30.h),
                                Spacer(),
                                Container(
                                  width: double.infinity,
                                  alignment: Alignment.centerRight,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Text(
                                        "Remove Barcode",
                                        style: textFieldStyle(
                                          color: Color.fromARGB(
                                            255,
                                            1,
                                            77,
                                            138,
                                          ),
                                          fontSize: 30.sp,
                                          weight: FontWeight.w800,
                                        ),
                                      ),
                                      Container(
                                        alignment: Alignment.centerRight,
                                        constraints: const BoxConstraints(
                                          maxHeight: 13.0,
                                        ),
                                        child: Switch(
                                          value: removeCheck,
                                          activeColor: Colors.red,
                                          onChanged: (p0) {
                                            if (p0 == true) {
                                              removeCheck = true;
                                            } else {
                                              removeCheck = false;
                                            }
                                            setState(() {});
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(height: 8.h),
                              ],
                            ),
                          ),

                        //////
                        ///
                        //////
                        SizedBox(height: 5.h),
                        if (checkSuccess != 0)
                          if (widget.type != "COMPLETE DISPATCH LIST")
                            Text(
                              checkSuccess == 1
                                  ? item.errorMessage
                                  : item.errorMessage,
                              style: textFieldStyle(
                                color: checkSuccess == 1
                                    ? Color.fromARGB(255, 15, 122, 19)
                                    : Color.fromARGB(255, 239, 36, 22),
                                weight: FontWeight.w700,
                                fontSize: 29.sp,
                              ),
                            ),
                        SizedBox(height: 20.h),

                        Container(
                          margin: EdgeInsets.symmetric(horizontal: 28.w),
                          width: double.infinity,
                          child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    Color.fromARGB(255, 1, 77, 138),
                                shape: RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.circular(12), // <-- Radius
                                ),
                              ),
                              onPressed: () async {
                                showPlantBox(context).then((value) async {
                                  if (reload == true) {
                                    _isLoading = true;
                                    setState(() {});
                                    // await Provider.of<QacageProvider>(context,
                                    //         listen: false)
                                    //     .getSingleQaCageList(
                                    //         widget.location,
                                    //         widget.pickListnos,
                                    //         widget.type !=
                                    //                 "COMPLETED QA CAGE LIST"
                                    //             ? ""
                                    //             : "C");
                                    _isLoading = false;

                                    setState(() {});
                                  } else {}
                                });
                              },
                              child: Text("+ Add Barcode",
                                  style: textFieldStyle(
                                      color: Colors.white,
                                      weight: FontWeight.w700,
                                      fontSize: 30.sp))),
                        ),

                        SizedBox(height: 20.h),
                        ...(item.documentDetail)
                            .map(
                              (e) => customTileDown(
                                e,
                                widget.type,
                                context,
                                widget.location,
                                widget.docType,
                                widget.pickListnos,
                              ),
                            )
                            .toList(),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    width: double.infinity,
                    padding:
                        EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
                    decoration: BoxDecoration(
                        border: Border.all(color: Colors.white),
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black,
                            offset: Offset(0.0, 0.4), //(x,y)
                            blurRadius: 0.6,
                          ),
                        ],
                        borderRadius: BorderRadius.circular(8)),
                    child: InkWell(
                      onTap: () async {
                        await showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              content: Text(
                                  'Are you sure you want to Mark As Complete?'),
                              actions: <Widget>[
                                TextButton(
                                  onPressed: () async {
                                    setState(() {
                                      _isLoading = true;
                                    });

                                    bool check = await item.markAsCompleted(
                                        widget.document.documentNumber,
                                        widget.location,
                                        'TT',
                                        context);
                                    if (check) {
                                      Navigator.of(context).pop("yesload");
                                    }
                                    setState(() {
                                      _isLoading = false;
                                    });
                                  },

                                  //kjndkjasnd
                                  child: Text('Yes'),
                                ),
                                TextButton(
                                  onPressed: () {
                                    // Handle "No" button tap
                                    Navigator.of(context).pop(
                                        false); // Return false to the caller
                                  },
                                  child: Text('No'),
                                ),
                              ],
                            );
                          },
                        );
                      },
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text("Mark as Completed",
                              style: textFieldStyle(
                                  color: Color.fromARGB(255, 1, 77, 138),
                                  fontSize: 28.sp,
                                  weight: FontWeight.w700)),
                          SizedBox(width: 10.w),
                          Icon(Icons.arrow_forward_ios,
                              size: 30.sp,
                              color: Color.fromARGB(255, 1, 77, 138))
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        if (_isLoading) Center(child: LoaderTransparent(color: Colors.white)),
      ],
    );
  }
}

Widget customTileDown(
  DocumentDetailData data,
  String type,
  BuildContext context,
  String location,
  String docType,
  String order, {
  Function(bool?)? onChangedtx,
}) {
  return Container(
    width: double.infinity,
    margin: EdgeInsets.symmetric(horizontal: 30.w, vertical: 14.h),
    decoration: BoxDecoration(
      // border: Border.all(color: Colors.white),
      color: Colors.white,
      boxShadow: [
        BoxShadow(
          color: Colors.black,
          offset: Offset(0.0, 0.4), //(x,y)
          blurRadius: 0.6,
        ),
      ],
      borderRadius: BorderRadius.circular(8),
    ),
    child: Column(
      children: [
        SizedBox(height: 10.h),
        Padding(
          padding: EdgeInsets.only(left: 20.w, right: 15.w, top: 20.h),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 150.w,
                child: Text(
                  "Item Desc",
                  style: textFieldStyle(
                    color: Colors.grey.shade800,
                    fontSize: 26.sp,
                    weight: FontWeight.w500,
                  ),
                ),
              ),
              SizedBox(width: 20.w),
              Expanded(
                child: Text(
                  data.maktx,
                  style: textFieldStyle(
                    color: Color.fromARGB(255, 1, 77, 138),
                    fontSize: 28.sp,
                    weight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 10.h),
        Padding(
          padding: EdgeInsets.only(left: 20.w, right: 15.w, top: 30.h),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 150.w,
                child: Text(
                  "Item Code",
                  style: textFieldStyle(
                    color: Colors.grey.shade800,
                    fontSize: 26.sp,
                    weight: FontWeight.w500,
                  ),
                ),
              ),
              SizedBox(width: 20.w),
              Text(
                data.matnr,
                style: textFieldStyle(
                  color: Color.fromARGB(255, 1, 77, 138),
                  fontSize: 28.sp,
                  weight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 10.h),
        Padding(
          padding: EdgeInsets.only(left: 20.w, right: 15.w, top: 30.h),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 150.w,
                child: Text(
                  "Scan Qty.",
                  style: textFieldStyle(
                    color: Colors.grey.shade800,
                    fontSize: 26.sp,
                    weight: FontWeight.w500,
                  ),
                ),
              ),
              SizedBox(width: 20.w),
              Text(
                data.skuCnt,
                style: textFieldStyle(
                  color: Color.fromARGB(255, 1, 77, 138),
                  fontSize: 28.sp,
                  weight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 10.h),
      ],
    ),
  );
}
