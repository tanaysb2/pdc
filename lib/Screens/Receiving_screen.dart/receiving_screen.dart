import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pdc/Modules/document_detail_model.dart';
import 'package:pdc/Modules/document_modal.dart';
import 'package:pdc/Providers/receiving_provider.dart';
import 'package:pdc/Resuable%20components/app_bar.dart';
import 'package:pdc/Resuable%20components/loading.dart';
import 'package:pdc/Resuable%20components/text_field.dart';
import 'package:pdc/Screens/Receiving_screen.dart/add_receiving_screen.dart';
import 'package:provider/provider.dart';

// ignore: must_be_immutable
class ReceivingScreen extends StatefulWidget {
  String location;
  String type;
  ReceivingScreen({super.key, required this.location, required this.type});

  @override
  State<ReceivingScreen> createState() => _OrderDispatchScreenState();
}

class _OrderDispatchScreenState extends State<ReceivingScreen>
    with SingleTickerProviderStateMixin {
  TabController? _tabController;
  late ScrollController _controller;

  int indexx = 0;
  int tab = 1;
  bool _isLoading = false;
  bool errorShow = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _controller = ScrollController();
    setState(() {
      _isLoading = true;
    });

    Provider.of<ReceivingProvider>(context, listen: false)
        .fetchDocuments(context)
        .then((value) {
          Provider.of<ReceivingProvider>(
            // ignore: use_build_context_synchronously
            context,
            listen: false,
            // ignore: use_build_context_synchronously
          ).fetchDepartments(context).then((value) {
            Provider.of<ReceivingProvider>(
              // ignore: use_build_context_synchronously
              context,
              listen: false,
              // ignore: use_build_context_synchronously
            ).fetchCompetitors(context).then((value) {
              Provider.of<ReceivingProvider>(
                // ignore: use_build_context_synchronously
                context,
                listen: false,
                // ignore: use_build_context_synchronously
              ).fetchReasons(context);
            });
          });
        })
        .then((value) {
          setState(() {
            _isLoading = false;
          });
        })
        .onError((error, stackTrace) {
          setState(() {
            _isLoading = false;
            errorShow = true;
          });
        });
  }

  @override
  void dispose() {
    _tabController!.dispose();
    _controller.dispose();
    super.dispose();
  }

  void refresh() {
    // print("object");
    // setState(() {
    //   _isLoading = true;
    // });

    // Provider.of<QacageProvider>(
    //   context,
    //   listen: false,
    // ).getQaList(widget.location).then((value) {
    //   setState(() {
    //     _isLoading = false;
    //   });
    // });
  }

  @override
  Widget build(BuildContext context) {
    final item = Provider.of<ReceivingProvider>(context, listen: true);

    log(widget.location);

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
                        onPressed: () {},
                        child: Text(
                          "Retry",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 32.sp,
                          ),
                        ),
                      ),
                      Spacer(),
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
              SafeArea(
                child: Scaffold(
                  backgroundColor: Colors.white,
                  body: Column(
                    children: [
                      CustomAppBar(
                        text: "RECEIVING",
                        trailingIcon: ClipRRect(
                          borderRadius: BorderRadius.circular(16.w),
                          child: Image.asset(
                            "assets/jklogo.png",
                            height: 60.h,
                            width: 60.w,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),

                      Expanded(
                        child: ListView.builder(
                          itemCount: item.documents.length,
                          itemBuilder: (context, index) {
                            return customTile(
                              item.documents[index],
                              context,
                              refresh,
                              "COMPLETED QA CAGE LIST",
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                  floatingActionButton: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color.fromARGB(255, 1, 77, 138),
                      alignment: Alignment.center,
                      padding: EdgeInsets.symmetric(
                        vertical: 17.h,
                        horizontal: 40.w,
                      ),
                    ),
                    onPressed: () async {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) {
                            return AddReceivingScreen(
                              location: widget.location,
                              type: widget.type,
                            );
                          },
                        ),
                      );
                    },
                    child: Text(
                      "Add Document",
                      style: TextStyle(
                        fontSize: 28.sp,
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
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

Widget customTile(
  DocumentData document,
  BuildContext context,
  final Function callback,
  String type,
) {
  return InkWell(
    onTap: () {
      // Navigator.of(context)
      //     .push(
      //       MaterialPageRoute(
      //         builder: (context) {
      //           return QaCageDetailScreen(
      //             location: location,
      //             type: type,
      //             pickListnos: dispatch.pickListNo,
      //             docType: dispatch.docType,
      //             ordType: dispatch.ordType,
      //           );
      //         },
      //       ),
      //     )
      //     .then((value) {
      //       callback();
      //     });
    },
    child: Container(
      width: double.infinity,

      // padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(left: 20.w, right: 15.w, top: 20.h),
            child: Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Order #",
                              style: textFieldStyle(
                                color: Colors.grey.shade800,
                                fontSize: 26.sp,
                                weight: FontWeight.w500,
                              ),
                            ),
                            SizedBox(height: 3.h),
                            SizedBox(
                              width: 320.w,
                              child: Text(
                                document.documentNumber,
                                maxLines: 2,
                                style: textFieldStyle(
                                  color: Color.fromARGB(255, 1, 77, 138),
                                  fontSize: 28.sp,
                                  weight: FontWeight.w700,
                                ),
                              ),
                            ),
                            SizedBox(height: 10.h),
                          ],
                        ),
                        SizedBox(width: 40.w),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Ord. Date",
                              style: textFieldStyle(
                                color: Colors.grey.shade800,
                                fontSize: 26.sp,
                                weight: FontWeight.w500,
                              ),
                            ),
                            SizedBox(height: 3.h),
                            Text(
                              document.documentDate.split(',')[0],
                              style: textFieldStyle(
                                color: Color.fromARGB(255, 1, 77, 138),
                                fontSize: 28.sp,
                                weight: FontWeight.w700,
                              ),
                            ),
                            SizedBox(height: 10.h),
                          ],
                        ),
                      ],
                    ),

                    SizedBox(height: 3.h),

                    Row(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Tyre Type",
                              style: textFieldStyle(
                                color: Colors.grey.shade800,
                                fontSize: 26.sp,
                                weight: FontWeight.w500,
                              ),
                            ),
                            SizedBox(height: 3.h),
                            SizedBox(
                              width: 320.w,
                              child: Text(
                                document.competitorCode ?? "",
                                maxLines: 2,
                                style: textFieldStyle(
                                  color: Color.fromARGB(255, 1, 77, 138),
                                  fontSize: 28.sp,
                                  weight: FontWeight.w700,
                                ),
                              ),
                            ),
                            SizedBox(height: 10.h),
                          ],
                        ),
                        SizedBox(width: 40.w),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Purpose",
                              style: textFieldStyle(
                                color: Colors.grey.shade800,
                                fontSize: 26.sp,
                                weight: FontWeight.w500,
                              ),
                            ),
                            SizedBox(height: 3.h),
                            Text(
                              document.purposeCode ?? "",
                              style: textFieldStyle(
                                color: Color.fromARGB(255, 1, 77, 138),
                                fontSize: 28.sp,
                                weight: FontWeight.w700,
                              ),
                            ),
                            SizedBox(height: 10.h),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),

          // SizedBox(height: 20.h),
          Padding(
            padding: EdgeInsets.only(left: 20.w, right: 15.w, top: 10.h),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Remarks",
                        style: textFieldStyle(
                          color: Colors.grey.shade800,
                          fontSize: 26.sp,
                          weight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: 3.h),
                      Text(
                        document.remark ?? "",
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: textFieldStyle(
                          color: Color.fromARGB(255, 1, 77, 138),
                          fontSize: 28.sp,
                          weight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(height: 10.h),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}
