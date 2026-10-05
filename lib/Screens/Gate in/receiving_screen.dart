import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pdc/Modules/document_modal.dart';
import 'package:pdc/Providers/receiving_provider.dart';
import 'package:pdc/Resuable%20components/app_bar.dart';
import 'package:pdc/Resuable%20components/loading.dart';
import 'package:pdc/Resuable%20components/text_field.dart';
import 'package:pdc/Screens/Gate%20in/add_receiving_screen.dart';
import 'package:pdc/Screens/Gate%20in/receiving_scan_screen.dart';
import 'package:provider/provider.dart';

// ignore: must_be_immutable
class ReceivingScreen extends StatefulWidget {
  String location;
  String type;
  String name;
  ReceivingScreen({
    super.key,
    required this.location,
    required this.type,
    required this.name,
  });

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

    log("documentType: ${widget.type}");
    log("departmentCode: MG");
    log("location: ${widget.location}");

    Provider.of<ReceivingProvider>(context, listen: false)
        .fetchDocuments(context, widget.type, "MG", widget.location)
        .then((value) {
          Provider.of<ReceivingProvider>(
            // ignore: use_build_context_synchronously
            context,
            listen: false,
            // ignore: use_build_context_synchronously
          ).fetchDepartments(context, widget.location).then((value) {
            Provider.of<ReceivingProvider>(
              // ignore: use_build_context_synchronously
              context,
              listen: false,
              // ignore: use_build_context_synchronously
            ).fetchReasons(context, widget.location);
          });
        })
        .then((value) {
          setState(() {
            _isLoading = false;
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
    setState(() {
      _isLoading = true;
    });

    Provider.of<ReceivingProvider>(
      context,
      listen: false,
    ).fetchDocuments(context, widget.type, "MG", widget.location).then((_) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    });
  }

  Widget _buildDocumentList(
    List<DocumentData> documents,
    ReceivingProvider item, {
    bool isCompletedTab = false,
  }) {
    if (documents.isEmpty) {
      return Center(
        child: Text(
          "No documents found",
          style: textFieldStyle(
            color: Colors.grey.shade600,
            fontSize: 28.sp,
            weight: FontWeight.w500,
          ),
        ),
      );
    }

    return ListView.builder(
      itemCount: documents.length,
      itemBuilder: (context, index) {
        return customTile(
          documents[index],
          widget.location,
          context,
          refresh,
          widget.type,
          widget.name,
          isCompletedTab: isCompletedTab,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final item = Provider.of<ReceivingProvider>(context, listen: true);

    log("location: ${widget.location}");
    log("type: ${widget.type}");

    return errorShow
        ? Stack(
            children: [
              Scaffold(
                backgroundColor: Colors.grey.shade400,
                body: SizedBox(
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
                        text: widget.name,
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
                      TabBar(
                        controller: _tabController,
                        labelColor: const Color.fromARGB(255, 1, 77, 138),
                        unselectedLabelColor: Colors.grey.shade600,
                        indicatorColor: const Color.fromARGB(255, 1, 77, 138),
                        labelStyle: textFieldStyle(
                          fontSize: 26.sp,
                          weight: FontWeight.w700,
                        ),
                        unselectedLabelStyle: textFieldStyle(
                          fontSize: 26.sp,
                          weight: FontWeight.w500,
                        ),
                        tabs: const [
                          Tab(text: "Pending"),
                          Tab(text: "Completed"),
                        ],
                      ),
                      Expanded(
                        child: TabBarView(
                          controller: _tabController,
                          children: [
                            _buildDocumentList(item.pendingDocuments, item),
                            _buildDocumentList(item.completedDocuments, item,
                                isCompletedTab: true),
                          ],
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
                      await Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) {
                            return AddReceivingScreen(
                              location: widget.location,
                              type: widget.type,
                              name: widget.name,
                            );
                          },
                        ),
                      );
                      refresh();
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
  String location,
  BuildContext context,
  Function callback,
  String type,
  String name, {
  bool isCompletedTab = false,
  bool enableNavigation = true,
}) {
  final item = Provider.of<ReceivingProvider>(context, listen: true);
  log("document: ${document.toJson()}");
  return InkWell(
    onTap: enableNavigation
        ? () {
      Navigator.of(context)
          .push(
            MaterialPageRoute(
              builder: (context) {
                return ReceivingScanScreen(
                  document: document,
                  location: location,
                  type: type,
                  pickListnos: document.documentNumber,
                  invoiceNo: '',
                  name: name,
                  docType: document.documentType ?? '',
                  ordType: document.documentType ?? '',
                  isCompletedTab: isCompletedTab,
                  onMarkedComplete: () => callback(),
                );
              },
            ),
          )
          .then((_) => callback());
    }
        : null,
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
                              "Document #",
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
                              "Doc. Date",
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

                    if (type == "GI") ...[
                      Row(
                        children: [
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
                                document.oth1?.isNotEmpty ?? false
                                    ? item.purposes
                                          .firstWhere(
                                            (element) =>
                                                element.purposeCode ==
                                                document.oth1,
                                          )
                                          .purposeName
                                    : "",
                                // document.oth1 ?? "",
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

                    if (type == "TR") ...[
                      Row(
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "To Location",
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
                                  document.toDept?.isNotEmpty ?? false
                                      ? item.departments
                                            .firstWhere(
                                              (element) =>
                                                  element.departmentCode ==
                                                  document.toDept,
                                            )
                                            .departmentName
                                      : "",
                                  // document.toDept ?? "",
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
                        ],
                      ),
                    ],

                    if (type == "GO") ...[
                      Row(
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Reason",
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
                                  document.reasonCode?.isNotEmpty ?? false
                                      ? item.reasons
                                            .firstWhere(
                                              (element) =>
                                                  element.reasonCode ==
                                                  document.reasonCode,
                                            )
                                            .reasonName
                                      : "",
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
                        ],
                      ),
                    ],
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
                        maxLines: 1,
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
