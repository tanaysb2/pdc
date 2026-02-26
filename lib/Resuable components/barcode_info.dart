import 'package:flutter/material.dart'; 
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pdc_test/Resuable%20components/text_field.dart';

// ignore: must_be_immutable
class BarcodeInfo extends StatelessWidget {
  String header;
  String info;
  bool bold;

  BarcodeInfo({super.key, this.header = "", this.info = "", this.bold = false});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 170.w,
          child: Text("$header :",
              style: textFieldStyle(
                  color: Colors.grey.shade800,
                  fontSize: 28.sp,
                  weight: FontWeight.w800)),
        ),
        SizedBox(height: 8.h),
        Expanded(
          child: Text(info,
              style: textFieldStyle(
                  color: bold
                      ? Color.fromARGB(255, 0, 171, 88)
                      : Color.fromARGB(255, 1, 77, 138),
                  fontSize: bold ? 38.sp : 28.sp,
                  weight: bold ? FontWeight.w900 : FontWeight.w700)),
        ),
      ],
    );
  }
}

class BarcodeInfoOldSKu extends StatelessWidget {
  String header;
  String info;
  bool bold;

  BarcodeInfoOldSKu(
      {super.key, this.header = "", this.info = "", this.bold = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.only(left: 5),
            height: 45.h,
            alignment: Alignment.centerLeft,
            width: 170.w,
            child: Text("$header :",
                style: textFieldStyle(
                    color: Colors.red,
                    fontSize: 28.sp,
                    weight: FontWeight.w800)),
          ),
          SizedBox(height: 8.h),
          Container(
            height: 45.h,
            padding: EdgeInsets.only(right: 5),
            alignment: Alignment.centerLeft,
            child: Text(info,
                style: textFieldStyle(
                    color: Colors.red,
                    fontSize: 38.sp,
                    weight: bold ? FontWeight.w900 : FontWeight.w700)),
          ),
        ],
      ),
    );
  }
}
