import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

// ignore: must_be_immutable
class CustomAppBar extends StatelessWidget {
  String text;
  final Widget? trailingIcon;

  CustomAppBar({super.key, this.text = "", this.trailingIcon});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 30.w, vertical: 20.h),
      child: Row(
        children: [
          InkWell(
            onTap: () {
              Navigator.pop(context);
            },
            child: Icon(
              Icons.arrow_back_ios,
              size: 34.sp,
              color: Color.fromARGB(255, 1, 77, 138),
            ),
          ),
          SizedBox(width: 20.w),
          Container(
            width: 500.w,
            // decoration: BoxDecoration(border: Border.all()),
            child: Text(
              text,
              style: TextStyle(
                color: Color.fromARGB(255, 1, 77, 138),
                fontFamily: "NotoSans",
                fontSize: 32.sp,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          if (trailingIcon != null) ...[
            Spacer(),
            trailingIcon!,
          ]
        ],
      ),
    );
  }
}
