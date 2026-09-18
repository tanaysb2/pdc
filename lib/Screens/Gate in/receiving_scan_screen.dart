import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_datawedge/flutter_datawedge.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:pdc/Modules/category_model.dart';
import 'package:pdc/Modules/document_detail_model.dart';
import 'package:pdc/Modules/document_modal.dart';
import 'package:pdc/Modules/plant.dart';
import 'package:pdc/Providers/receiving_provider.dart';
import 'package:pdc/Resuable%20components/app_bar.dart';
import 'package:pdc/Resuable%20components/barcode_info.dart';
import 'package:pdc/Resuable%20components/cart_page_screen.dart';
import 'package:pdc/Resuable%20components/custom_lablel_dropdown.dart';
import 'package:pdc/Resuable%20components/custom_searchable_dropdown.dart';
import 'package:pdc/Resuable%20components/loading.dart';
import 'package:pdc/Resuable%20components/text_field.dart';
import 'package:pdc/Screens/Gate%20in/receiving_screen.dart';
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
  String name;
  bool bbdn;
  bool nonBbdn;
  String shipmentId;
  String title;
  String userId;
  bool isCompletedTab;
  VoidCallback? onMarkedComplete;
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
    required this.name,
    this.nonBbdn = false,
    required this.docType,
    required this.ordType,
    this.userId = "",
    this.isCompletedTab = false,
    this.onMarkedComplete,
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
      if (Provider.of<ReceivingProvider>(
        context,
        listen: false,
      ).stencilIdController.value.text.isNotEmpty) {
        if (!stencilFocusNode.hasFocus) {
          log("stencil 2");
          setState(() {
            _isLoading = true;
          });
          log("stencil 3");
          Provider.of<ReceivingProvider>(
            context,
            listen: false,
          ).stencilVerficationForAddBarcode(
            Provider.of<ReceivingProvider>(
              context,
              listen: false,
            ).stencilIdController.value.text,
            materialCode,
            plantController.value.text,
            widget.location,
            widget.ordType,
            widget.document.documentNumber,
          );
          setState(() {
            _isLoading = false;
          });
        }
      }
    });

    Provider.of<ReceivingProvider>(context, listen: false)
        .fetchDocumentDetail(
          context,
          widget.document.documentNumber,
          widget.location,
        )
        .then((value) {
          Provider.of<ReceivingProvider>(
            context,
            listen: false,
          ).getPlants(context).then((value) {
            Provider.of<ReceivingProvider>(
              context,
              listen: false,
            ).fetchMappingData(context, widget.location).then((value) {
              setState(() {
                _isLoading = false;
              });
            });
          });
        })
        .then((value) {
          if (!widget.isCompletedTab) {
            initScannerResult = initScanner();
          }
          setState(() {
            _isLoading = false;
          });
        });
  }

  // Future showPlantBox(BuildContext context) async {
  //   final itemSelect = Provider.of<ReceivingProvider>(context, listen: false);

  //   itemSelect.selectedMaterial = "";
  //   itemSelect.stencilIdController = TextEditingController();
  //   itemSelect.manuDateController = TextEditingController();
  //   isTrue = true;

  //   setState(() {});

  //   await showModalBottomSheet<void>(
  //     isScrollControlled: true,
  //     shape: RoundedRectangleBorder(
  //       borderRadius: BorderRadius.circular(20.0),
  //     ),
  //     backgroundColor: Colors.white,
  //     context: context,
  //     builder: (BuildContext context) {
  //       final item = Provider.of<ReceivingProvider>(context, listen: true);
  //       // final itemForPlant = Provider.of<AuthProvider>(context, listen: true);
  //       final itemSelect =
  //           Provider.of<ReceivingProvider>(context, listen: true);
  //       return StatefulBuilder(
  //           builder: (BuildContext context, StateSetter setState11) {
  //         return Stack(
  //           children: [
  //             Padding(
  //               padding: EdgeInsets.only(
  //                   bottom: MediaQuery.of(context).viewInsets.bottom),
  //               child: Container(
  //                 height: 1050.h,
  //                 padding: EdgeInsets.symmetric(horizontal: 30.w),
  //                 child: SingleChildScrollView(
  //                   child: Column(
  //                     mainAxisAlignment: MainAxisAlignment.start,
  //                     children: <Widget>[
  //                       SizedBox(height: 40.h),
  //                       Text("Add Barcode",
  //                           style: textFieldStyle(
  //                               color: Color.fromARGB(255, 1, 77, 138),
  //                               weight: FontWeight.w700,
  //                               fontSize: 43.sp)),
  //                       SizedBox(height: 40.h),
  //                       Container(
  //                         margin: EdgeInsets.only(left: 8.w),
  //                         child: CustomTextField(
  //                           controller: item.barcodeManualController,
  //                           isEnabled: false,
  //                           labelText: "Enter Barcode",
  //                           margin: false,
  //                           checking: true,
  //                         ),
  //                       ),
  //                       SizedBox(height: 30.h),
  //                       Container(
  //                         margin: EdgeInsets.only(left: 10.w, bottom: 20.h),
  //                         child: DropdownInput(
  //                           isMargin: false,
  //                           controller: plantController,
  //                           labelText: "Select Manufacturing Plant",
  //                           // value: consajda.value.text,

  //                           isEnabled: true,
  //                           inputFieldWidth: double.infinity,
  //                           items: item.plantList.map((PlantModal value) {
  //                             return DropdownMenuItem<String>(
  //                               value: value.description,
  //                               child: Text(value.description),
  //                             );
  //                           }).toList(),
  //                           onChanged: (value) async {
  //                             print(value);
  //                             // print("$value vauejnka");

  //                             PlantModal cyz = item.plantList.firstWhere(
  //                                 (element) => element.description == value);
  //                             print("${cyz.code} indeftid");

  //                             manPlantCode = cyz.code;

  //                             setState(() {
  //                               _isLoading = true;
  //                             });

  //                             await itemSelect.fetchCategories(
  //                                 widget.location, cyz.code);

  //                             setState(() {
  //                               _isLoading = false;
  //                             });

  //                             itemSelect
  //                                 .onMaterialPlantChangedformanul(cyz.code);
  //                             plantController =
  //                                 TextEditingController(text: cyz.description);
  //                             setState(() {});
  //                           },
  //                         ),
  //                       ),
  //                       Container(
  //                         alignment: Alignment.centerLeft,
  //                         margin: EdgeInsets.only(left: 14.w, bottom: 10.h),
  //                         child: DropdownInput(
  //                           isMargin: false,
  //                           controller: item.selectedCategory,
  //                           labelText: "Select Category",
  //                           isEnabled: true,
  //                           inputFieldWidth: double.infinity,
  //                           items: item
  //                               .barcodeDetails.categoryDetails.categories
  //                               .map((Category value) {
  //                             return DropdownMenuItem<String>(
  //                               value: value.description,
  //                               child: Text(value.description),
  //                             );
  //                           }).toList(),
  //                           onChanged: (value) async {
  //                             setState(() {
  //                               _isLoading = true;
  //                             });

  //                             log("$value checking value");
  //                             log("${widget.location} checking value");
  //                             log("${manPlantCode} checking value");

  //                             await itemSelect.onCategoryChanged(
  //                               value,
  //                               widget.location,
  //                               manPlantCode,
  //                             );
  //                             setState(() {
  //                               _isLoading = false;
  //                             });
  //                           },
  //                         ),
  //                       ),
  //                       SizedBox(height: 15.h),
  //                       Container(
  //                         alignment: Alignment.centerLeft,
  //                         margin: EdgeInsets.only(left: 14.w, bottom: 10.h),
  //                         child: SearchableDropDown(
  //                           labelName: "Select Item",
  //                           dropDownItems: item
  //                               .barcodeDetails.materialDetails.materials
  //                               .map((material) => material.description)
  //                               .toList(),
  //                           selectedItem: item.selectedMaterial,
  //                           onDropDownItemSelected: (p0) {
  //                             print(p0);

  //                             itemSelect.onMaterialItemChanged(p0.toString());
  //                             var _materialDetail = item
  //                                 .barcodeDetails.materialDetails.materials
  //                                 .firstWhere(
  //                                     (material) => material.description == p0);
  //                             materialCode = _materialDetail.code;
  //                             setState(() {});
  //                           },
  //                         ),
  //                       ),
  //                       SizedBox(height: 40.h),
  //                       Container(
  //                         margin: EdgeInsets.symmetric(horizontal: 10.w),
  //                         child: Row(
  //                           children: [
  //                             Expanded(
  //                               child: CustomTextField(
  //                                 margin: false,
  //                                 isEnabled: item.selectedMaterial.isEmpty &&
  //                                         plantController.value.text.isEmpty
  //                                     ? false
  //                                     : true,
  //                                 focusNode: stencilFocusNode,
  //                                 maxlength: true,
  //                                 onChanged: (p0) {
  //                                   itemSelect.dateEmpty();
  //                                 },
  //                                 labelText: "Enter Stencil ID",
  //                                 controller: itemSelect.stencilIdController,
  //                                 validator: (value) {
  //                                   // String finalStringsss = value!.substring(
  //                                   //     (value.length - 4).clamp(0, value.length));
  //                                   // print("$finalStringsss finalString");
  //                                   if (value!.isEmpty) {
  //                                     return "Stencil ID can't be empty";
  //                                   } else {
  //                                     return null;
  //                                   }
  //                                 },
  //                               ),
  //                             ),
  //                             SizedBox(width: 5.w),
  //                             if (itemSelect
  //                                 .manuDateController.value.text.isNotEmpty)
  //                               Container(
  //                                   margin: EdgeInsets.only(bottom: 35.h),
  //                                   child: Icon(Icons.check_circle,
  //                                       color: Colors.blue))
  //                           ],
  //                         ),
  //                       ),
  //                       SizedBox(height: 15.h),
  //                       CustomTextField(
  //                         controller: itemSelect.manuDateController,
  //                         labelText: "Select Mfg Date",
  //                         isReadOnly: true,
  //                       ),
  //                       SizedBox(height: 10.h),
  //                       Container(
  //                         height: 90.h,
  //                         margin: EdgeInsets.symmetric(horizontal: 10.w),
  //                         width: double.infinity,
  //                         child: ElevatedButton(
  //                             style: ElevatedButton.styleFrom(
  //                               backgroundColor:
  //                                   Color.fromARGB(255, 1, 77, 138),
  //                               shape: RoundedRectangleBorder(
  //                                 borderRadius:
  //                                     BorderRadius.circular(12), // <-- Radius
  //                               ),
  //                             ),
  //                             onPressed: () async {
  //                               setState11(() {
  //                                 _isLoadingInside = true;
  //                               });
  //                               // log(item.selectedMaterial);

  //                               // bool check = await item.submitBarcode(
  //                               //     item.barcodeManualController!.value.text,
  //                               //     materialCode,
  //                               //     itemSelect.stencilIdController.value.text,
  //                               //     itemSelect.manuDateController.value.text,
  //                               //     manPlantCode,
  //                               //     widget.location,
  //                               //     "IN${widget.location}${locationController.value.text}${binController.value.text}${rackController.value.text}${DateFormat('ddMMyy').format(DateTime.now()).toString()}");

  //                               // if (check) {
  //                               //   reload = true;
  //                               //   setState(() {});
  //                               //   setState11(() {
  //                               //     _isLoadingInside = false;
  //                               //   });
  //                               //   Navigator.of(context).pop();
  //                               // } else {
  //                               //   setState(() {
  //                               //     reload = false;
  //                               //   });
  //                               //   setState11(() {
  //                               //     _isLoadingInside = false;
  //                               //   });
  //                               // }
  //                             },
  //                             child: Text("Submit",
  //                                 style: textFieldStyle(
  //                                     color: Colors.white,
  //                                     weight: FontWeight.w700,
  //                                     fontSize: 34.sp))),
  //                       ),
  //                     ],
  //                   ),
  //                 ),
  //               ),
  //             ),
  //             if (_isLoadingInside)
  //               Center(
  //                 child: LoaderTransparent(color: Colors.white),
  //               ),
  //           ],
  //         );
  //       });
  //     },
  //   ).whenComplete(() {
  //     // final itemSelect =
  //     //     Provider.of<BarcodeDetailProvider>(context, listen: true);
  //     // itemSelect.selectedMaterial = "";
  //     // itemSelect.stencilIdController = TextEditingController();

  //     // prodDateManualController = TextEditingController();
  //     // manufacturingDateManualController = TextEditingController();
  //     // Provider.of<BarcodeDetailProvider>(context, listen: false)
  //     //     .manuDateController = TextEditingController();

  //     // Provider.of<AdHocProvider>(context, listen: false)
  //     //     .barcodeManualController = TextEditingController();

  //     // isTrue = false;

  //     setState(() {});
  //   });
  // }

  Future<void> initScanner() async {
    if (Platform.isAndroid) {
      // final item = Provider.of<ReceivingProvider>(context, listen: false);
      fdw = FlutterDataWedge();
      onScanResultListener = fdw.onScanResult.listen((result) async {
        scanResults = result;
        if (isTrue) {
          Provider.of<ReceivingProvider>(
            context,
            listen: false,
          ).barcodeManualController.text = result.data;
          return;
        }
        await _processBarcode(result.data);
      });

      onScannerStatusListener = fdw.onScannerStatus.listen(
        (status) => setState(() => lastStatus = status.status.toString()),
      );
      await fdw.initialize();
    }
  }

  @override
  void dispose() {
    onScanResultListener.cancel();
    onScannerStatusListener.cancel();

    super.dispose();
  }

  Future<void> _handleMarkAsComplete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          content: const Text('Are you sure you want to Mark As Complete?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Yes'),
            ),
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('No'),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !mounted) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final provider = Provider.of<ReceivingProvider>(context, listen: false);
      final check = await provider.markAsCompleted(
        widget.document.documentNumber,
        widget.location,
        widget.pickListnos.isNotEmpty
            ? widget.pickListnos
            : widget.document.documentNumber,
        widget.docType.isNotEmpty
            ? widget.docType
            : (widget.type.isNotEmpty ? widget.type : "TT"),
        context,
      );

      if (!mounted) return;

      if (check) {
        await provider.fetchDocuments(
          context,
          widget.type,
          "MG",
          widget.location,
        );
        if (!mounted) return;
        Navigator.of(context).pop(true);
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _processBarcode(String barcode) async {
    final trimmed = barcode.trim();
    if (trimmed.isEmpty || !mounted) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final provider = Provider.of<ReceivingProvider>(context, listen: false);
      final success = await provider.scanBarcode(
        trimmed,
        widget.document.documentNumber,
        widget.type,
        widget.location,
        "",
        '',
        context,
        removeBarcode: removeCheck,
      );

      if (!mounted) return;

      if (success) {
        await provider.fetchDocumentDetail(
          context,
          widget.document.documentNumber,
          widget.location,
        );
        checkSuccess = 1;
      } else {
        checkSuccess = 2;
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _showEnterBarcodeSheet() async {
    isTrue = true;
    final provider = Provider.of<ReceivingProvider>(context, listen: false);
    provider.barcodeManualController = TextEditingController();

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        bool sheetRemove = removeCheck;
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 40.w, vertical: 24.h),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(height: 10.h),
                    Text(
                      "Enter Barcode",
                      style: textFieldStyle(
                        color: const Color.fromARGB(255, 1, 77, 138),
                        weight: FontWeight.w700,
                        fontSize: 40.sp,
                      ),
                    ),
                    SizedBox(height: 36.h),
                    CustomTextField(
                      controller: provider.barcodeManualController,
                      labelText: "Barcode",
                      margin: false,
                      isFocused: true,
                    ),
                    SizedBox(height: 16.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          "Remove Barcode",
                          style: textFieldStyle(
                            color: const Color.fromARGB(255, 1, 77, 138),
                            fontSize: 28.sp,
                            weight: FontWeight.w800,
                          ),
                        ),
                        Switch(
                          value: sheetRemove,
                          activeThumbColor: Colors.red,
                          onChanged: (value) {
                            setSheetState(() {
                              sheetRemove = value;
                            });
                            setState(() {
                              removeCheck = value;
                            });
                          },
                        ),
                      ],
                    ),
                    SizedBox(height: 24.h),
                    SizedBox(
                      width: double.infinity,
                      height: 88.h,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color.fromARGB(255, 1, 77, 138),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onPressed: () async {
                          final code =
                              provider.barcodeManualController.text.trim();
                          if (code.isEmpty) {
                            EasyLoading.showToast(
                              "Please enter barcode",
                              maskType: EasyLoadingMaskType.black,
                            );
                            return;
                          }
                          Navigator.of(sheetContext).pop();
                          await _processBarcode(code);
                        },
                        child: Text(
                          "Scan",
                          style: textFieldStyle(
                            color: Colors.white,
                            weight: FontWeight.w700,
                            fontSize: 32.sp,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 16.h),
                  ],
                ),
              ),
            );
          },
        );
      },
    ).whenComplete(() {
      isTrue = false;
      if (mounted) setState(() {});
    });
  }

  Future<void> _processCompetitor({
    required String category,
    required String size,
    required String make,
    required String brand,
    required String pattern,
    required String serialNo,
    required String remarks,
  }) async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final provider = Provider.of<ReceivingProvider>(context, listen: false);
      final success = await provider.scanCompetitor(
        context,
        documentNumber: widget.document.documentNumber,
        category: category,
        size: size,
        make: make,
        brand: brand,
        pattern: pattern,
        serialNo: serialNo,
        remarks: remarks,
        docType: widget.docType.isNotEmpty
            ? widget.docType
            : (widget.type.isNotEmpty ? widget.type : "TT"),
        location: widget.location,
      );

      if (!mounted) return;

      if (success) {
        await provider.fetchDocumentDetail(
          context,
          widget.document.documentNumber,
          widget.location,
        );
        checkSuccess = 1;
      } else {
        checkSuccess = 2;
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _showCompetitorSheet() async {
    setState(() {
      _isLoading = true;
    });
    await Provider.of<ReceivingProvider>(
      context,
      listen: false,
    ).fetchTyreCategories();
    if (!mounted) return;
    setState(() {
      _isLoading = false;
    });

    final formKey = GlobalKey<FormState>();
    final sizeController = TextEditingController();
    final makeController = TextEditingController();
    final brandController = TextEditingController();
    final patternController = TextEditingController();
    final serialNoController = TextEditingController();
    final remarksController = TextEditingController();
    String? selectedCategoryCode;
    final tyreCategories = Provider.of<ReceivingProvider>(
      context,
      listen: false,
    ).tyreCategories;

    final upperNoSpace = [
      FilteringTextInputFormatter.deny(RegExp(r'\s')),
      _UpperCaseTextFormatter(),
    ];

    Widget requiredField({
      required TextEditingController controller,
      required String label,
    }) {
      return Padding(
        padding: EdgeInsets.only(bottom: 20.h),
        child: CustomTextField(
          controller: controller,
          labelText: "$label *",
          margin: false,
          inputFormatters: upperNoSpace,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return "$label is required";
            }
            return null;
          },
        ),
      );
    }

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(sheetContext).viewInsets.bottom,
          ),
          child: Form(
            key: formKey,
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 40.w, vertical: 24.h),
              child: StatefulBuilder(
                builder: (context, setSheetState) {
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(height: 10.h),
                      Text(
                        "Competitor",
                        style: textFieldStyle(
                          color: const Color.fromARGB(255, 1, 77, 138),
                          weight: FontWeight.w700,
                          fontSize: 40.sp,
                        ),
                      ),
                      SizedBox(height: 36.h),
                      Padding(
                        padding: EdgeInsets.only(bottom: 20.h),
                        child: DropdownButtonFormField<String>(
                          isExpanded: true,
                          initialValue: selectedCategoryCode,
                          hint: Text(
                            tyreCategories.isEmpty
                                ? "No categories"
                                : "Select Category",
                            style: TextStyle(
                              color: Colors.black,
                              fontFamily: "NotoSans",
                              fontSize: 32.sp,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          items: tyreCategories
                              .map(
                                (c) => DropdownMenuItem<String>(
                                  value: c.code,
                                  child: Text(
                                    "${c.code} - ${c.description}",
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              )
                              .toList(),
                          onChanged: (value) {
                            setSheetState(() {
                              selectedCategoryCode = value;
                            });
                          },
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Category is required";
                            }
                            return null;
                          },
                          style: TextStyle(
                            color: Colors.black,
                            fontFamily: "NotoSans",
                            fontSize: 32.sp,
                            fontWeight: FontWeight.w600,
                          ),
                          decoration: InputDecoration(
                            labelText: "Category *",
                            labelStyle: TextStyle(
                              fontSize: 32.sp,
                              color: Colors.black,
                            ),
                            contentPadding: EdgeInsets.symmetric(
                              vertical: 5.h,
                              horizontal: 14.w,
                            ),
                            border: defaultBorderTextField(),
                            errorBorder: defaultBorderTextField(),
                            disabledBorder: defaultBorderTextField(),
                            focusedBorder: defaultBorderTextField(),
                            enabledBorder: defaultBorderTextField(),
                          ),
                        ),
                      ),
                      requiredField(
                        controller: sizeController,
                        label: "Size",
                      ),
                      requiredField(controller: makeController, label: "Make"),
                      requiredField(
                        controller: brandController,
                        label: "Brand",
                      ),
                      requiredField(
                        controller: patternController,
                        label: "Pattern",
                      ),
                      requiredField(
                        controller: serialNoController,
                        label: "Serial No",
                      ),
                      CustomTextField(
                        controller: remarksController,
                        labelText: "Remarks",
                        margin: false,
                        maxCheck: 3,
                      ),
                      SizedBox(height: 28.h),
                      SizedBox(
                        width: double.infinity,
                        height: 88.h,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color.fromARGB(
                              255,
                              1,
                              77,
                              138,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          onPressed: () async {
                            if (!(formKey.currentState?.validate() ?? false)) {
                              EasyLoading.showToast(
                                "Please fill all required fields",
                                maskType: EasyLoadingMaskType.black,
                              );
                              return;
                            }
                            final category = selectedCategoryCode ?? "";
                            final size = sizeController.text.trim();
                            final make = makeController.text.trim();
                            final brand = brandController.text.trim();
                            final pattern = patternController.text.trim();
                            final serialNo = serialNoController.text.trim();
                            final remarks = remarksController.text.trim();
                            Navigator.of(sheetContext).pop();
                            await _processCompetitor(
                              category: category,
                              size: size,
                              make: make,
                              brand: brand,
                              pattern: pattern,
                              serialNo: serialNo,
                              remarks: remarks,
                            );
                          },
                          child: Text(
                            "Submit",
                            style: textFieldStyle(
                              color: Colors.white,
                              weight: FontWeight.w700,
                              fontSize: 32.sp,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 16.h),
                    ],
                  );
                },
              ),
            ),
          ),
        );
      },
    ).whenComplete(() {
      sizeController.dispose();
      makeController.dispose();
      brandController.dispose();
      patternController.dispose();
      serialNoController.dispose();
      remarksController.dispose();
    });
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
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        CustomAppBar(text: widget.name),
                        SizedBox(height: 15.h),
                        customTile(
                          widget.document,
                          widget.location,
                          context,
                          () {},
                          widget.type,
                          widget.name,
                          isCompletedTab: widget.isCompletedTab,
                          enableNavigation: false,
                        ),

                        SizedBox(height: 10.h),

                        //////
                        ///      container for barcode result
                        //////
                        if (!widget.isCompletedTab &&
                            widget.type != "COMPLETE DISPATCH LIST")
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
                                          activeThumbColor: Colors.red,
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
                          if (!widget.isCompletedTab &&
                              widget.type != "COMPLETE DISPATCH LIST")
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
                        if (!widget.isCompletedTab)
                          Container(
                            margin: EdgeInsets.symmetric(horizontal: 30.w),
                            width: double.infinity,
                            height: 88.h,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color.fromARGB(
                                  255,
                                  1,
                                  77,
                                  138,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              onPressed: _showEnterBarcodeSheet,
                              child: Text(
                                "Enter barcode",
                                style: textFieldStyle(
                                  color: Colors.white,
                                  weight: FontWeight.w700,
                                  fontSize: 30.sp,
                                ),
                              ),
                            ),
                          ),
                        SizedBox(height: 20.h),
                        if (!widget.isCompletedTab)
                          Container(
                            margin: EdgeInsets.symmetric(horizontal: 30.w),
                            width: double.infinity,
                            height: 88.h,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color.fromARGB(
                                  255,
                                  1,
                                  77,
                                  138,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              onPressed: _showCompetitorSheet,
                              child: Text(
                                "Competitor",
                                style: textFieldStyle(
                                  color: Colors.white,
                                  weight: FontWeight.w700,
                                  fontSize: 30.sp,
                                ),
                              ),
                            ),
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
                                widget.document.documentNumber,
                                widget.name,
                                // showSkuArrow: widget.name != "Gate In" ||
                                //     widget.isCompletedTab,
                              ),
                            )
                            .toList(),
                      ],
                    ),
                  ),
                ),
                if (!widget.isCompletedTab)
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(
                      horizontal: 20.w,
                      vertical: 20.h,
                    ),
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
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: InkWell(
                      onTap: _handleMarkAsComplete,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            "Mark as Completed",
                            style: textFieldStyle(
                              color: Color.fromARGB(255, 1, 77, 138),
                              fontSize: 28.sp,
                              weight: FontWeight.w700,
                            ),
                          ),
                          SizedBox(width: 10.w),
                          Icon(
                            Icons.arrow_forward_ios,
                            size: 30.sp,
                            color: Color.fromARGB(255, 1, 77, 138),
                          ),
                        ],
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
  String order,
  String documentNumber,
  String title,
  // bool showSkuArrow = true,
) {
  void openSkuScreen() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => CartPageScreen(
          location: location,
          materialCode: data.matnr,
          materialDesc: data.maktx,
          documentNumber:
              documentNumber.isNotEmpty ? documentNumber : data.docNo,
          docType: docType,
          title: title,
        ),
      ),
    );
  }

  return InkWell(
    onTap:  
    // showSkuArrow ?
     openSkuScreen ,
    // : null,
    child: Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(horizontal: 30.w, vertical: 14.h),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black,
            offset: Offset(0.0, 0.4),
            blurRadius: 0.6,
          ),
        ],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          SizedBox(height: 10.h),
          Padding(
            padding: EdgeInsets.only(left: 20.w, right: 8.w, top: 20.h),
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
                // if (showSkuArrow)
                  SizedBox(
                    width: 56.w,
                    height: 48.h,
                    child: Center(
                      child: Icon(
                        Icons.arrow_forward_ios,
                        size: 28.sp,
                        color: Color.fromARGB(255, 1, 77, 138),
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
    ),
  );
}

class _UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    return TextEditingValue(
      text: newValue.text.toUpperCase(),
      selection: newValue.selection,
    );
  }
}
