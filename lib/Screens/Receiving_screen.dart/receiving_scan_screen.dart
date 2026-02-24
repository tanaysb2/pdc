import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'package:audioplayers/audioplayers.dart';
import 'package:el_tooltip/el_tooltip.dart';
import 'package:flutter/material.dart';
import 'package:flutter_datawedge/flutter_datawedge.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:pdc/Modules/plant.dart';
import 'package:pdc/Providers/receiving_provider.dart';
import 'package:pdc/Resuable%20components/app_bar.dart';
import 'package:pdc/Resuable%20components/custom_lablel_dropdown.dart';
import 'package:pdc/Resuable%20components/custom_searchbox.dart';
import 'package:pdc/Resuable%20components/loading.dart';
import 'package:pdc/Resuable%20components/text_field.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:provider/provider.dart';
import 'package:vibration/vibration.dart';

// ignore: must_be_immutable
class ReceivingScanScreen extends StatefulWidget {
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



  // Future showPlantBox(BuildContext context) async {
  //   isTrue = true; 
  //   setState(() {}); 
  //   await showModalBottomSheet<void>(
  //     isScrollControlled: true,
  //     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
  //     backgroundColor: Colors.white,
  //     context: context,
  //     builder: (BuildContext context) {
  //       final item = Provider.of<DispatchProvider>(context, listen: true);
  //       final itemForPlant = Provider.of<AuthProvider>(context, listen: true);
  //       final itemSelect = Provider.of<BarcodeDetailProvider>(
  //         context,
  //         listen: true,
  //       );
  //       return StatefulBuilder(
  //         builder: (BuildContext context, StateSetter setState11) {
  //           return Stack(
  //             children: [
  //               Padding(
  //                 padding: EdgeInsets.only(
  //                   bottom: MediaQuery.of(context).viewInsets.bottom,
  //                 ),
  //                 child: Container(
  //                   height: 1050.h,
  //                   padding: EdgeInsets.symmetric(horizontal: 30.w),
  //                   child: SingleChildScrollView(
  //                     child: Column(
  //                       mainAxisAlignment: MainAxisAlignment.start,
  //                       children: <Widget>[
  //                         SizedBox(height: 40.h),
  //                         InkWell(
  //                           onTap: () {
  //                             // tempScan();
  //                           },
  //                           child: Text(
  //                             "Add Barcode",
  //                             style: textFieldStyle(
  //                               color: Color.fromARGB(255, 1, 77, 138),
  //                               weight: FontWeight.w700,
  //                               fontSize: 43.sp,
  //                             ),
  //                           ),
  //                         ),
  //                         SizedBox(height: 40.h),
  //                         Container(
  //                           margin: EdgeInsets.only(left: 8.w),
  //                           child: CustomTextField(
  //                             controller: item.barcodeManualController,
  //                             isEnabled: false,
  //                             labelText: "Enter Barcode",
  //                             margin: false,
  //                             checking: true,
  //                           ),
  //                         ),
  //                         SizedBox(height: 30.h),
  //                         Container(
  //                           margin: EdgeInsets.only(left: 10.w, bottom: 20.h),
  //                           child: DropdownInput(
  //                             isMargin: false,
  //                             controller: plantController,
  //                             labelText: "Select Manufacturing Plant",
 //                             // value: consajda.value.text,
  //                             isEnabled: true,
  //                             inputFieldWidth: double.infinity,
  //                             items: itemForPlant.plantList.map((
  //                               PlantModal value,
  //                             ) {
  //                               return DropdownMenuItem<String>(
  //                                 value: value.description,
  //                                 child: Text(value.description),
  //                               );
  //                             }).toList(),
  //                             onChanged: (value) {
  //                               print(value);
  //                               // print("$value vauejnka");
 //                               PlantModal cyz = itemForPlant.plantList
  //                                   .firstWhere(
  //                                     (element) => element.description == value,
  //                                   );
  //                               print("${cyz.code} indeftid");
 //                               manPlantCode = cyz.code;
 //                               itemSelect.onMaterialPlantChangedformanul(
  //                                 cyz.code,
  //                               );
  //                               plantController = TextEditingController(
  //                                 text: cyz.description,
  //                               );
  //                               setState(() {});
  //                             },
  //                           ),
  //                         ),
  //                         Container(
  //                           alignment: Alignment.centerLeft,
  //                           margin: EdgeInsets.only(left: 14.w, bottom: 10.h),
  //                           child: Text(
  //                             "Select Material",
  //                             style: TextStyle(
  //                               color: Colors.black,
  //                               fontFamily: "NotoSans",
  //                               fontSize: 30.sp,
  //                               fontWeight: FontWeight.w600,
  //                             ),
  //                           ),
  //                         ),
  //                         Container(
  //                           margin: EdgeInsets.symmetric(horizontal: 8.w),
  //                           child: SearchableDropDownOnlyDropdown(
  //                             labelName: "Select Item",
  //                             dropDownItems: item.materialList
  //                                 .map((material) => material.description)
  //                                 .toList(),
  //                             selectedItem: materialManualController.value.text,
  //                             onDropDownItemSelected: (p0) {
  //                               print(p0);
  //                               materialManualController =
  //                                   TextEditingController(text: p0.toString());
  //                               setState(() {});
 //                               var _materialDetail = item.materialList
  //                                   .firstWhere(
  //                                     (material) => material.description == p0,
  //                                   );
  //                               materialCode = _materialDetail.code;
  //                               setState(() {});
  //                             },
  //                           ),
  //                         ),
  //                         SizedBox(height: 40.h),
  //                         Container(
  //                           margin: EdgeInsets.symmetric(horizontal: 10.w),
  //                           child: Row(
  //                             children: [
  //                               Expanded(
  //                                 child: CustomTextField(
  //                                   margin: false,
  //                                   isEnabled:
  //                                       materialManualController
  //                                               .value
  //                                               .text
  //                                               .isEmpty &&
  //                                           plantController.value.text.isEmpty
  //                                       ? false
  //                                       : true,
  //                                   focusNode: stencilFocusNode,
  //                                   maxlength: true,
  //                                   onChanged: (p0) {
  //                                     itemSelect.dateEmpty();
  //                                   },
  //                                   // onFieldSubmitted: (p0) async {
  //                                   //   if (stencilManualController
  //                                   //       .value.text.isNotEmpty) {
  //                                   //     setState(() {
  //                                   //       _isLoading = true;
  //                                   //     });
  //                                   //     await itemSelect
  //                                   //         .stencilVerficationForAddBarcode(
  //                                   //             p0,
  //                                   //             materialCode,
  //                                   //             plantController.value.text);
  //                                   //     setState(() {
  //                                   //       _isLoading = false;
  //                                   //     });
  //                                   //   }
  //                                   // },
  //                                   // prefix: itemSelect.selectedPrefix!,
  //                                   labelText: "Enter Stencil ID",
  //                                   controller: stencilManualController,
  //                                   validator: (value) {
  //                                     // String finalStringsss = value!.substring(
  //                                     //     (value.length - 4).clamp(0, value.length));
  //                                     // print("$finalStringsss finalString");
  //                                     if (value!.isEmpty) {
  //                                       return "Stencil ID can't be empty";
  //                                     } else {
  //                                       return null;
  //                                     }
  //                                   },
  //                                 ),
  //                               ),
  //                               SizedBox(width: 5.w),
  //                               if (itemSelect
  //                                   .manuDateController
  //                                   .value
  //                                   .text
  //                                   .isNotEmpty)
  //                                 Container(
  //                                   margin: EdgeInsets.only(bottom: 35.h),
  //                                   child: Icon(
  //                                     Icons.check_circle,
  //                                     color: Colors.blue,
  //                                   ),
  //                                 ),
  //                             ],
  //                           ),
  //                         ),
  //                         SizedBox(height: 15.h),
  //                         CustomTextField(
  //                           controller: itemSelect.manuDateController,
  //                           labelText: "Select Mfg Date",
  //                           isReadOnly: true,
  //                         ),
  //                         SizedBox(height: 10.h),
  //                         Container(
  //                           height: 90.h,
  //                           margin: EdgeInsets.symmetric(horizontal: 10.w),
  //                           width: double.infinity,
  //                           child: ElevatedButton(
  //                             style: ElevatedButton.styleFrom(
  //                               backgroundColor: Color.fromARGB(
  //                                 255,
  //                                 1,
  //                                 77,
  //                                 138,
  //                               ),
  //                               shape: RoundedRectangleBorder(
  //                                 borderRadius: BorderRadius.circular(
  //                                   12,
  //                                 ), // <-- Radius
  //                               ),
  //                             ),
  //                             onPressed: () async {
  //                               setState11(() {
  //                                 _isLoadingInside = true;
  //                               });
  //                               print(itemSelect.manuDateController.value.text);
 //                               bool check = await item.submitBarcode(
  //                                 item.barcodeManualController.value.text,
  //                                 materialManualController.value.text,
  //                                 stencilManualController.value.text,
  //                                 itemSelect.manuDateController.value.text,
  //                                 manPlantCode,
  //                                 widget.location,
  //                                 widget.pickListnos,
  //                               );
 //                               if (check) {
  //                                 reload = true;
  //                                 setState(() {});
  //                                 setState11(() {
  //                                   _isLoadingInside = false;
  //                                 });
  //                                 Navigator.of(context).pop();
  //                               } else {
  //                                 setState(() {
  //                                   reload = false;
  //                                 });
  //                                 setState11(() {
  //                                   _isLoadingInside = false;
  //                                 });
  //                               }
  //                             },
  //                             child: Text(
  //                               "Submit",
  //                               style: textFieldStyle(
  //                                 color: Colors.white,
  //                                 weight: FontWeight.w700,
  //                                 fontSize: 34.sp,
  //                               ),
  //                             ),
  //                           ),
  //                         ),
  //                       ],
  //                     ),
  //                   ),
  //                 ),
  //               ),
  //               if (_isLoadingInside)
  //                 Center(child: LoaderTransparent(color: Colors.white)),
  //             ],
  //           );
  //         },
  //       );
  //     },
  //   ).whenComplete(() {
  //     materialManualController = TextEditingController();
  //     stencilManualController = TextEditingController();
  //     prodDateManualController = TextEditingController();
  //     manufacturingDateManualController = TextEditingController();
  //     Provider.of<BarcodeDetailProvider>(
  //       context,
  //       listen: false,
  //     ).manuDateController = TextEditingController();
 //     Provider.of<DispatchProvider>(
  //       context,
  //       listen: false,
  //     ).barcodeManualController = TextEditingController();
 //     isTrue = false;
 //     setState(() {});
  //   });
  // }



  // Future changeInfo(BuildContext context) async {
  //   isTrue = true;
  //   int tab = 1;
  //   setState(() {});
  //   await showModalBottomSheet<void>(
  //     isScrollControlled: true,
  //     shape: RoundedRectangleBorder(
  //       borderRadius: BorderRadius.circular(20.0),
  //     ),
  //     backgroundColor: Colors.white,
  //     context: context,
  //     builder: (BuildContext context) {
  //       final item = Provider.of<DispatchProvider>(context, listen: true);
  //       final itemForPlant = Provider.of<AuthProvider>(context, listen: true);
  //       final itemForQaCage =
  //           Provider.of<QacageProvider>(context, listen: true);
  //       final itemSelect =
  //           Provider.of<BarcodeDetailProvider>(context, listen: true);
  //       return StatefulBuilder(
  //           builder: (BuildContext context, StateSetter setState11) {
  //         return Stack(
  //           children: [
  //             Padding(
  //               padding: EdgeInsets.only(
  //                   bottom: MediaQuery.of(context).viewInsets.bottom),
  //               child: Container(
  //                 height: 1020.h,
  //                 padding: EdgeInsets.symmetric(horizontal: 30.w),
  //                 child: SingleChildScrollView(
  //                   child: Column(
  //                     mainAxisAlignment: MainAxisAlignment.start,
  //                     children: <Widget>[
  //                       SizedBox(height: 40.h),
  //                       Text("Change Info",
  //                           style: textFieldStyle(
  //                               color: Color.fromARGB(255, 1, 77, 138),
  //                               weight: FontWeight.w700,
  //                               fontSize: 38.sp)),
  //                       SizedBox(height: 30.h),
  //                       Container(
  //                           margin: EdgeInsets.only(left: 10.w, bottom: 20.h),
  //                           child: BarcodeInfo(
  //                               header: "Barcode", info: item.barcodeShow)),
  //                       Container(
  //                           margin: EdgeInsets.only(left: 10.w, bottom: 20.h),
  //                           child: BarcodeInfo(
  //                               header: "Mfg Date", info: item.prodDate)),
  //                       Container(
  //                           margin: EdgeInsets.only(left: 10.w, bottom: 20.h),
  //                           child: BarcodeInfo(
  //                               header: "Stencil No", info: item.stencilNo)),
  //                       Container(
  //                           margin: EdgeInsets.only(left: 10.w, bottom: 20.h),
  //                           child: BarcodeInfo(
  //                               header: "Material", info: item.material)),
  //                       Row(
  //                         crossAxisAlignment: CrossAxisAlignment.center,
  //                         mainAxisAlignment: MainAxisAlignment.center,
  //                         children: [
  //                           Container(
  //                             child: Transform.scale(
  //                               scale: 24.0 /
  //                                   24.0, // Adjust the scale factor to change the radio button's size
  //                               child: Radio(
  //                                 value: 1,
  //                                 groupValue: tab,
  //                                 onChanged: (value) {
  //                                   tab = value!;
  //                                   setState11(() {});
  //                                 },
  //                               ),
  //                             ),
  //                           ),
  //                           // Radio(
  //                           //   value: 1,
  //                           //   groupValue: tab,
  //                           //   onChanged: (value) {
  //                           //     tab = value!;
  //                           //     setState(() {});
  //                           //   },
  //                           // ),
  //                           Text("Item Change",
  //                               style: textFieldStyle(
  //                                   color: Color.fromARGB(255, 1, 77, 138),
  //                                   fontSize: 28.sp,
  //                                   weight: FontWeight.w700)),
  //                           SizedBox(width: 20.w),
  //                           Container(
  //                             child: Radio(
  //                               value: 0,
  //                               groupValue: tab,
  //                               onChanged: (value) {
  //                                 tab = value!;
  //                                 setState11(() {});
  //                               },
  //                             ),
  //                           ),
  //                           Text("Stencil Change",
  //                               style: textFieldStyle(
  //                                   color: Color.fromARGB(255, 1, 77, 138),
  //                                   fontSize: 28.sp,
  //                                   weight: FontWeight.w700)),
  //                         ],
  //                       ),
  //                       //// Item change
  //                       if (tab == 1)
  //                         Container(
  //                           margin: EdgeInsets.only(top: 40.h),
  //                           child: Column(
  //                             children: [
  //                               Container(
  //                                 alignment: Alignment.centerLeft,
  //                                 margin:
  //                                     EdgeInsets.only(left: 14.w, bottom: 10.h),
  //                                 child: Text(
  //                                   "Select Material",
  //                                   style: TextStyle(
  //                                     color: Colors.black,
  //                                     fontFamily: "NotoSans",
  //                                     fontSize: 30.sp,
  //                                     fontWeight: FontWeight.w600,
  //                                   ),
  //                                 ),
  //                               ),
  //                               Container(
  //                                 margin: EdgeInsets.symmetric(horizontal: 8.w),
  //                                 child: SearchableDropDownOnlyDropdown(
  //                                   labelName: "Select Item",
  //                                   dropDownItems: item.materialList
  //                                       .map((material) => material.description)
  //                                       .toList(),
  //                                   selectedItem:
  //                                       materialManualController.value.text,
  //                                   onDropDownItemSelected: (p0) {
  //                                     print(p0);
  //                                     materialManualController =
  //                                         TextEditingController(
  //                                             text: p0.toString());
  //                                     setState(() {});
  //                                     var _materialDetail = item.materialList
  //                                         .firstWhere((material) =>
  //                                             material.description == p0);
  //                                     materialDetail = _materialDetail;
  //                                     setState(() {});
  //                                   },
  //                                 ),
  //                               ),
  //                             ],
  //                           ),
  //                         ),
  //                       if (tab == 0)
  //                         //// Stencil change
  //                         Container(
  //                           margin: EdgeInsets.only(top: 40.h),
  //                           child: SingleChildScrollView(
  //                             child: Column(
  //                               children: [
  //                                 Container(
  //                                   margin: EdgeInsets.only(
  //                                       left: 10.w, bottom: 20.h),
  //                                   child: DropdownInput(
  //                                     isMargin: false,
  //                                     controller: plantController,
  //                                     labelText: "Select Manufacturing Plant",
  //                                     // value: consajda.value.text,
  //                                     isEnabled: true,
  //                                     inputFieldWidth: double.infinity,
  //                                     items: itemForPlant.plantList
  //                                         .map((PlantModal value) {
  //                                       return DropdownMenuItem<String>(
  //                                         value: value.description,
  //                                         child: Text(value.description),
  //                                       );
  //                                     }).toList(),
  //                                     onChanged: (value) {
  //                                       print(value);
  //                                       // print("$value vauejnka");
  //                                       PlantModal cyz = itemForPlant.plantList
  //                                           .firstWhere((element) =>
  //                                               element.description == value);
  //                                       print("${cyz.code} indeftid");
  //                                       manPlantCode = cyz.code;
  //                                       itemSelect
  //                                           .onMaterialPlantChangedformanul(
  //                                               cyz.code);
  //                                       plantController = TextEditingController(
  //                                           text: cyz.description);
  //                                       setState(() {});
  //                                     },
  //                                   ),
  //                                 ),
  //                                 Container(
  //                                   margin: EdgeInsets.only(
  //                                       left: 10.w, bottom: 20.h),
  //                                   child: Row(
  //                                     children: [
  //                                       Expanded(
  //                                         child: CustomTextField(
  //                                           margin: false,
  //                                           isEnabled: plantController
  //                                                   .value.text.isEmpty
  //                                               ? false
  //                                               : true,
  //                                           focusNode: stencilFocusNode,
  //                                           maxlength: true,
  //                                           onChanged: (p0) {
  //                                             itemSelect.dateEmpty();
  //                                             materialCode = item.matnr;
  //                                             print("$materialCode dholna");
  //                                             setState(() {});
  //                                           },
  //                                           labelText: "Enter Stencil ID",
  //                                           controller: stencilManualController,
  //                                           validator: (value) {
  //                                             // String finalStringsss = value!.substring(
  //                                             //     (value.length - 4).clamp(0, value.length));
  //                                             // print("$finalStringsss finalString");
  //                                             if (value!.isEmpty) {
  //                                               return "Stencil ID can't be empty";
  //                                             } else {
  //                                               return null;
  //                                             }
  //                                           },
  //                                         ),
  //                                       ),
  //                                       SizedBox(width: 5.w),
  //                                       if (itemSelect.manuDateController.value
  //                                           .text.isNotEmpty)
  //                                         Container(
  //                                             margin:
  //                                                 EdgeInsets.only(bottom: 35.h),
  //                                             child: Icon(Icons.check_circle,
  //                                                 color: Colors.blue))
  //                                     ],
  //                                   ),
  //                                 ),
  //                                 SizedBox(height: 15.h),
  //                               ],
  //                             ),
  //                           ),
  //                         ),
  //                       SizedBox(height: 10.h),
  //                       Container(
  //                         height: 90.h,
  //                         margin: EdgeInsets.symmetric(
  //                             horizontal: 10.w, vertical: 20.h),
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
  //                               if (tab == 1) {
  //                                 _isLoading = true;
  //                                 _isLoadingInside = true;
  //                                 setState11(() {});
  //                                 bool check =
  //                                     await itemForQaCage.changeInfoSubmit(
  //                                   item.barcodeShow,
  //                                   widget.pickListnos,
  //                                   materialDetail!.lineItemNo,
  //                                   materialDetail!.code,
  //                                   materialDetail!.description,
  //                                   "",
  //                                   "",
  //                                   widget.location,
  //                                   widget.ordType,
  //                                   '',
  //                                   "M",
  //                                 );
  //                                 if (check) {
  //                                   _isLoading = false;
  //                                   _isLoadingInside = false;
  //                                   setState11(() {});
  //                                   materialManualController =
  //                                       TextEditingController();
  //                                   stencilManualController =
  //                                       TextEditingController();
  //                                   prodDateManualController =
  //                                       TextEditingController();
  //                                   materialCode = "";
  //                                   manufacturingDateManualController =
  //                                       TextEditingController();
  //                                   Provider.of<BarcodeDetailProvider>(context,
  //                                               listen: false)
  //                                           .manuDateController =
  //                                       TextEditingController();
  //                                   Provider.of<DispatchProvider>(context,
  //                                               listen: false)
  //                                           .barcodeManualController =
  //                                       TextEditingController();
  //                                   setState11(() {});
  //                                   Navigator.pop(context);
  //                                 } else {
  //                                   _isLoading = false;
  //                                   _isLoadingInside = false;
  //                                   setState11(() {});
  //                                 }
  //                               } else {
  //                                 _isLoading = true;
  //                                 _isLoadingInside = true;
  //                                 setState11(() {});
  //                                 bool check =
  //                                     await itemForQaCage.changeInfoSubmit(
  //                                   item.barcodeShow,
  //                                   widget.pickListnos,
  //                                   "",
  //                                   "",
  //                                   "",
  //                                   itemSelect.manuDateController.value.text,
  //                                   stencilManualController.value.text,
  //                                   widget.location,
  //                                   widget.ordType,
  //                                   '',
  //                                   "S",
  //                                 );
  //                                 if (check) {
  //                                   _isLoading = false;
  //                                   _isLoadingInside = false;
  //                                   setState11(() {});
  //                                   materialManualController =
  //                                       TextEditingController();
  //                                   stencilManualController =
  //                                       TextEditingController();
  //                                   prodDateManualController =
  //                                       TextEditingController();
  //                                   materialCode = "";
  //                                   manufacturingDateManualController =
  //                                       TextEditingController();
  //                                   Provider.of<BarcodeDetailProvider>(context,
  //                                               listen: false)
  //                                           .manuDateController =
  //                                       TextEditingController();
  //                                   Provider.of<DispatchProvider>(context,
  //                                               listen: false)
  //                                           .barcodeManualController =
  //                                       TextEditingController();
  //                                   ;
  //                                   setState(() {});
  //                                   Navigator.pop(context);
  //                                 } else {
  //                                   _isLoading = false;
  //                                   _isLoadingInside = false;
  //                                   setState11(() {});
  //                                 }
  //                               }
  //                               await item.getSingleDispatch(
  //                                   widget.location,
  //                                   widget.pickListnos,
  //                                   widget.type != "COMPLETE DISPATCH LIST"
  //                                       ? ""
  //                                       : "C");
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
  //     materialManualController = TextEditingController();
  //     stencilManualController = TextEditingController();
  //     prodDateManualController = TextEditingController();
  //     manufacturingDateManualController = TextEditingController();
  //     Provider.of<BarcodeDetailProvider>(context, listen: false)
  //         .manuDateController = TextEditingController();
  //     Provider.of<DispatchProvider>(context, listen: false)
  //         .barcodeManualController = TextEditingController();
  //     ;
  //     isTrue = false;
  //     setState(() {});
  //   });
  // }



  @override
  void initState() {
    super.initState();
    // reload = true;
    // setState(() {
    //   _isLoading = true;
    // });
    // final item = Provider.of<DispatchProvider>(context, listen: false);

    // Provider.of<DispatchProvider>(context, listen: false).showChangeInfo =
    //     false;

    // log("${widget.erName} dsadas 11");

    // // if (widget.erName == "U") {
    // // } else if (widget.erName == "E") {}
    // // setState(() {});

    // Provider.of<DispatchProvider>(context, listen: false).barcodeShow = "";
    // Provider.of<DispatchProvider>(context, listen: false).prodDate = "";
    // Provider.of<DispatchProvider>(context, listen: false).stencilNo = "";
    // Provider.of<DispatchProvider>(context, listen: false).material = "";

    // item.barcodeManualController = TextEditingController();
    // Provider.of<BarcodeDetailProvider>(
    //   context,
    //   listen: false,
    // ).manuDateController = TextEditingController();

    // stencilFocusNode.addListener(() {
    //   if (stencilManualController.value.text.isNotEmpty) {
    //     if (!stencilFocusNode.hasFocus) {
    //       setState(() {
    //         _isLoading = true;
    //       });
    //       Provider.of<BarcodeDetailProvider>(
    //         context,
    //         listen: false,
    //       ).stencilVerficationForAddBarcode(
    //         stencilManualController.value.text,
    //         materialCode.isEmpty
    //             ? Provider.of<DispatchProvider>(context, listen: false).matnr
    //             : materialCode,
    //         plantController.value.text,
    //         widget.location,
    //         widget.ordType,
    //         widget.pickListnos,
    //       );
    //       setState(() {
    //         _isLoading = false;
    //       });
    //     }
    //   }
    // });

    // log("${isTrue} dsadas 12");
    // checkSuccess = 0;

    // Provider.of<DispatchProvider>(context, listen: false)
    //     .getSingleDispatch(
    //       widget.location,
    //       widget.pickListnos,
    //       widget.type != "COMPLETE DISPATCH LIST" ? "" : "C",
    //     )
    //     .then((value) {
    //       Provider.of<BarcodeDetailProvider>(
    //         context,
    //         listen: false,
    //       ).fetchMappingData(context, widget.location);
    //     })
    //     .then((value) {
    //       initScannerResult = initScanner();

    //       setState(() {
    //         _isLoading = false;
    //       });
    //     });
    // tempScan();
  }

  Future<void> initScanner() async {
    print("fall here true");
    final item = Provider.of<ReceivingProvider>(context, listen: false);
    if (Platform.isAndroid) {
      print("fall here true 2");
      fdw = FlutterDataWedge();
      onScanResultListener = fdw.onScanResult.listen(
        (result) => setState(() async {
          scanResults = result;
          if (isTrue) {
            return item.getManualBarcode(result.data);
          }                

          await Provider.of<ReceivingProvider>(context, listen: false)
              .scanDocument(
                context,
                barcode: result.data,
                lineItemNo: "",
                docType: "",
                location: "",
                storageLocation: "",
                binCode: "",
                rackCode: "",
                documentNumber: widget.pickListnos,
              )
              .then((value) {
                if (value) {
                  // if (isTrue == false)
                  //   Provider.of<ReceivingProvider>(
                  //     context,
                  //     listen: false,
                  //   ).getSingleDispatch(
                  //     widget.location,
                  //     widget.pickListnos,
                  //     widget.type != "COMPLETE DISPATCH LIST" ? "" : "C",
                  //   );
                  // //// response 200x
                  checkSuccess = 1;
                  setState(() {});
                  //// response 200
                } else {
                  checkSuccess = 2;
                  setState(() {});
                  //// response 400
                }
              });
        }),
      );

      onScannerStatusListener = fdw.onScannerStatus.listen(
        (status) => setState(() => lastStatus = status.status.toString()),
      );
      await fdw.initialize();
    }
  }
  

  // Future tempScan() async {
  //   log('$isTrue checktrue');

  //   // if (widget.type != "COMPLETE DISPATCH LIST") {
  //   //   if (Platform.isAndroid) {
  //   //     log("here");
  //   //     final item = Provider.of<DispatchProvider>(context, listen: false);
  //   //     // fdw = FlutterDataWedge(profileName: 'flutter wedge');
  //   //     int scanned = int.tryParse(item.singleOrderList[0].scanned) ?? 0;
  //   //     int total = int.tryParse(item.singleOrderList[0].total) ?? 0;

  //   //     log("here 1");
  //   //     setState(() {
  //   //       _isLoading = true;
  //   //     });

  //   //     if (isTrue) {
  //   //       item.getManualBarcode("Y401280010");
  //   //     }

  //   //     log("${widget.erName} dsadas 11");

  //   //     if (widget.erName != "O" &&
  //   //         item.singleOrderList[0].scanned == item.singleOrderList[0].total &&
  //   //         removeCheck == false) {
  //   //       bool? checkVibrate = await Vibration.hasVibrator();

  //   //       if (checkVibrate!) Vibration.vibrate();
  //   //       AudioPlayer().play(AssetSource('audio/error.wav'));
  //   //       item
  //   //           .showDialogForallDialog(context, "Scanning Already Completed")
  //   //           .then((value) {
  //   //         player.stop();
  //   //       });
  //   //     } else {
  //   //       if (isTrue == false)
  //   //         await Provider.of<DispatchProvider>(context, listen: false)
  //   //             .scanBarcode(
  //   //           "Y401280010",
  //   //           widget.pickListnos,
  //   //           widget.docType,
  //   //           widget.ordType,
  //   //           widget.location,
  //   //           "",
  //   //           context,
  //   //           removeBarcode: removeCheck,
  //   //         )
  //   //             .then((value) {
  //   //           if (value) {
  //   //             if (isTrue == false)
  //   //               Provider.of<DispatchProvider>(context, listen: false)
  //   //                   .getSingleDispatch(
  //   //                 widget.location,
  //   //                 widget.pickListnos,
  //   //                 widget.type != "COMPLETE DISPATCH LIST" ? "" : "C",
  //   //               );
  //   //             //// response 200x
  //   //             checkSuccess = 1;
  //   //             setState(() {});
  //   //             //// response 200
  //   //           } else {
  //   //             checkSuccess = 2;
  //   //             setState(() {});
  //   //             //// response 400
  //   //           }
  //   //         });
  //   //     }

  //   //     setState(() {
  //   //       _isLoading = false;
  //   //     });
  //   //   }
  //   // }
  // }

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
                        CustomAppBar(text: 'RECEIVING'),
                        SizedBox(height: 15.h),

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

                                // if (checkSuccess == 1)
                                //   BarcodeInfo(
                                //     header: "Mfg Date",
                                //     info: item.prodDate,
                                //   ),

                                // SizedBox(height: 15.h),
                                // if (checkSuccess == 1)
                                //   BarcodeInfo(
                                //     header: "Stencil No",
                                //     bold: true,
                                //     info: item.stencilNo,
                                //   ),
                                // SizedBox(height: 15.h),
                                // if (checkSuccess == 1)
                                //   BarcodeInfo(
                                //     header: "Material",
                                //     info: item.material,
                                //   ),
                                // SizedBox(height: 30.h),
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
                        SizedBox(height: 10.h),

                        // if (widget.type != "COMPLETE DISPATCH LIST")
                        //   if (widget.userId != "N")
                        //     Container(
                        //       margin: EdgeInsets.symmetric(horizontal: 28.w),
                        //       width: double.infinity,
                        //       child: ElevatedButton(
                        //         style: ElevatedButton.styleFrom(
                        //           backgroundColor: Color.fromARGB(
                        //             255,
                        //             1,
                        //             77,
                        //             138,
                        //           ),
                        //           shape: RoundedRectangleBorder(
                        //             borderRadius: BorderRadius.circular(
                        //               12,
                        //             ), // <-- Radius
                        //           ),
                        //         ),
                        //         onPressed: () async {
                        //           showPlantBox(context).then((value) async {
                        //             if (reload == true) {
                        //               _isLoading = true;
                        //               setState(() {});
                        //               await Provider.of<ReceivingProvider>(
                        //                 context,
                        //                 listen: false,
                        //               ).getSingleDispatch(
                        //                 widget.location,
                        //                 widget.pickListnos,
                        //                 widget.type != "COMPLETE DISPATCH LIST"
                        //                     ? ""
                        //                     : "C",
                        //               );
                        //               _isLoading = false;

                        //               setState(() {});
                        //             } else {}
                        //           });
                        //         },
                        //         child: Text(
                        //           "+ Add Barcode",
                        //           style: textFieldStyle(
                        //             color: Colors.white,
                        //             weight: FontWeight.w700,
                        //             fontSize: 30.sp,
                        //           ),
                        //         ),
                        //       ),
                        //     ),
                        SizedBox(height: 20.h),
                        // ...(item.singleOrderList)
                        //     .map(
                        //       (e) => customTile(
                        //         e,
                        //         widget.type,
                        //         context,
                        //         widget.location,
                        //         widget.docType,
                        //         widget.pickListnos,
                        //       ),
                        //     )
                        //     .toList(),
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

// Widget customTile(
//   SingleDispatch data,
//   String type,
//   BuildContext context,
//   String location,
//   String docType,
//   String order, {
//   Function(bool?)? onChangedtx,
// }) {
//   print("${data.linePercentage} dasa");
//   return InkWell(
//     onTap: () {
//       Navigator.of(context).push(
//         MaterialPageRoute(
//           builder: (context) {
//             return BarcodesScreen(
//               location: location,
//               ordType: data.ordType,
//               itemCode: data.matnr,
//               lineItemNo: data.lineItemNo,
//               customer: data.customerName,
//               document: docType,
//               order: order,
//             );
//           },
//         ),
//       );
//     },
//     child: Container(
//       width: double.infinity,
//       margin: EdgeInsets.symmetric(horizontal: 30.w, vertical: 14.h),
//       decoration: BoxDecoration(
//         // border: Border.all(color: Colors.white),
//         color: Colors.white,
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black,
//             offset: Offset(0.0, 0.4), //(x,y)
//             blurRadius: 0.6,
//           ),
//         ],
//         borderRadius: BorderRadius.circular(8),
//       ),
//       child: Column(
//         children: [
//           SizedBox(height: 10.h),
//           Padding(
//             padding: EdgeInsets.only(left: 20.w, right: 15.w, top: 20.h),
//             child: Row(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 SizedBox(
//                   width: 130.w,
//                   child: Text(
//                     "Item Desc",
//                     style: textFieldStyle(
//                       color: Colors.grey.shade800,
//                       fontSize: 26.sp,
//                       weight: FontWeight.w500,
//                     ),
//                   ),
//                 ),
//                 SizedBox(width: 20.w),
//                 Expanded(
//                   child: Text(
//                     data.maktx,
//                     style: textFieldStyle(
//                       color: Color.fromARGB(255, 1, 77, 138),
//                       fontSize: 28.sp,
//                       weight: FontWeight.w700,
//                     ),
//                   ),
//                 ),
//                 SizedBox(width: 3.w),
//                 Container(
//                   decoration: BoxDecoration(
//                     border: Border.all(color: Colors.grey),
//                     borderRadius: BorderRadius.circular(40),
//                   ),
//                   child: CircleAvatar(
//                     radius: 16,
//                     backgroundColor: Colors.white,
//                     child: Icon(
//                       Icons.arrow_forward_ios_outlined,
//                       color: Colors.grey,
//                       size: 35.sp,
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           SizedBox(height: 10.h),
//           Padding(
//             padding: EdgeInsets.only(left: 20.w, right: 15.w, top: 30.h),
//             child: Row(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 SizedBox(
//                   width: 130.w,
//                   child: Text(
//                     "Item Code",
//                     style: textFieldStyle(
//                       color: Colors.grey.shade800,
//                       fontSize: 26.sp,
//                       weight: FontWeight.w500,
//                     ),
//                   ),
//                 ),
//                 SizedBox(width: 20.w),
//                 Text(
//                   data.matnr,
//                   style: textFieldStyle(
//                     color: Color.fromARGB(255, 1, 77, 138),
//                     fontSize: 28.sp,
//                     weight: FontWeight.w700,
//                   ),
//                 ),
//                 Spacer(),
//                 InkWell(
//                   onTap: () {
//                     print("object");
//                     Navigator.of(context).push(
//                       MaterialPageRoute(
//                         builder: (context) {
//                           return CartPageScreen(
//                             location: location,
//                             materialCode: data.matnr,
//                             materialDesc: data.maktx,
//                           );
//                         },
//                       ),
//                     );
//                   },
//                   child: Container(
//                     alignment: Alignment.center,
//                     decoration: BoxDecoration(
//                       border: Border.all(color: Colors.grey),
//                       borderRadius: BorderRadius.circular(40),
//                     ),
//                     child: CircleAvatar(
//                       radius: 16,
//                       backgroundColor: Color.fromARGB(255, 1, 77, 138),
//                       child: Icon(
//                         Icons.shopping_cart,
//                         color: Colors.white,
//                         size: 35.sp,
//                       ),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           SizedBox(height: 10.h),
//           Padding(
//             padding: EdgeInsets.only(
//               left: 20.w,
//               right: 15.w,
//               top: 20.h,
//               bottom: 30.h,
//             ),
//             child: Row(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 SizedBox(
//                   width: 130.w,
//                   child: Text(
//                     "Quantity",
//                     style: textFieldStyle(
//                       color: Colors.grey.shade800,
//                       fontSize: 26.sp,
//                       weight: FontWeight.w500,
//                     ),
//                   ),
//                 ),
//                 SizedBox(width: 20.w),
//                 Text(
//                   "${data.readCnt}/${data.ordQty}",
//                   style: textFieldStyle(
//                     color: Color.fromARGB(255, 1, 77, 138),
//                     fontSize: 28.sp,
//                     weight: FontWeight.w700,
//                   ),
//                 ),
//                 SizedBox(width: 40.w),
//                 SizedBox(
//                   width: 200.w,
//                   child: Text(
//                     "Stock Quantity :",
//                     style: textFieldStyle(
//                       color: Colors.grey.shade800,
//                       fontSize: 26.sp,
//                       weight: FontWeight.w500,
//                     ),
//                   ),
//                 ),
//                 SizedBox(width: 20.w),
//                 Text(
//                   "${data.stkQty}",
//                   style: textFieldStyle(
//                     color: Color.fromARGB(255, 1, 77, 138),
//                     fontSize: 28.sp,
//                     weight: FontWeight.w700,
//                   ),
//                 ),
//                 Spacer(),
//                 InkWell(
//                   onTap: () {
//                     print("object");
//                     Navigator.of(context).push(
//                       MaterialPageRoute(
//                         builder: (context) {
//                           return BinSummaryScreen(
//                             location: location,
//                             materialCode: data.matnr,
//                             materialDesc: data.maktx,
//                             user: data.ordQty,
//                           );
//                         },
//                       ),
//                     );
//                   },
//                   child: Container(
//                     alignment: Alignment.center,
//                     decoration: BoxDecoration(
//                       border: Border.all(color: Colors.grey),
//                       borderRadius: BorderRadius.circular(40),
//                     ),
//                     child: CircleAvatar(
//                       radius: 16,
//                       backgroundColor: Color.fromARGB(255, 1, 77, 138),
//                       child: Padding(
//                         padding: EdgeInsets.only(left: 2.w),
//                         child: SvgPicture.asset(
//                           "assets/newfinal.svg",
//                           fit: BoxFit.cover,
//                           height: 28.h,
//                           width: 35.w,
//                           // ignore: deprecated_member_use
//                           color: Colors.white,
//                         ),
//                       ),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           ClipRRect(
//             borderRadius: BorderRadius.only(
//               bottomLeft: Radius.circular(8),
//               bottomRight: Radius.circular(8),
//             ),
//             child: LinearPercentIndicator(
//               lineHeight: 28.0.h,
//               padding: EdgeInsets.zero,
//               percent: double.parse(data.linePercentage),
//               animation: true,
//               backgroundColor: Colors.white,
//               progressColor: data.linePercentage == "1"
//                   ? Color.fromARGB(255, 15, 122, 19)
//                   : const Color.fromARGB(255, 241, 222, 51),
//               // Color.fromARGB(255, 117, 221, 120),
//             ),
//           ),
//         ],
//       ),
//     ),
//   );
// }
