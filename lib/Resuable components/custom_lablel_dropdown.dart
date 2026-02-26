import 'package:flutter/material.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';

class DropdownInput extends StatelessWidget {
  final String? inputName;
  final TextEditingController? controller;
  final dynamic value;
  final String labelText;
  final String hintText;
  final double? inputLabelWidth;
  final double? inputFieldWidth;
  final bool? isEnabled;
  final bool hintStyleChange;
  final bool? isMargin;
  final bool paddingChange;
  final List<DropdownMenuItem<dynamic>>? items;
  final void Function(dynamic)? onChanged;

  const DropdownInput({
    Key? key,
    this.inputName,
    this.labelText = "",
    this.hintText = "",
    this.controller,
    this.value,
    this.inputLabelWidth,
    this.inputFieldWidth,
    this.isEnabled = true,
    this.items,
    this.onChanged,
    this.isMargin = true,
    this.hintStyleChange = false,
    this.paddingChange = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: isEnabled == true ? Colors.white : Colors.black,
      margin: isMargin!
          ? EdgeInsets.only(left: 10.w, right: 10.w, bottom: 42.h)
          : EdgeInsets.zero,
      child: DropdownButtonFormField(
        isExpanded: true,
        focusNode: FocusNode(canRequestFocus: false),
        value: value ?? null,
        items: items,
        onChanged: isEnabled == true ? onChanged : null,
        style: hintStyleChange == false
            ? TextStyle(
                color: Colors.black,
                fontFamily: "NotoSans",
                fontSize: 37.sp,
                fontWeight: FontWeight.w600,
              )
            : TextStyle(
                color: Colors.black,
                fontFamily: "NotoSans",
                fontSize: 32.sp,
                fontWeight: FontWeight.w800,
              ),
        hint: Text(
          hintText,
          style: hintStyleChange == false
              ? TextStyle(
                  color: Colors.black,
                  fontFamily: "NotoSans",
                  fontSize: 37.sp,
                  fontWeight: FontWeight.w500,
                )
              : TextStyle(
                  color: Colors.black,
                  fontFamily: "NotoSans",
                  fontSize: 30.sp,
                  fontWeight: FontWeight.w800,
                ),
        ),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(
            color: Color.fromARGB(255, 1, 77, 138),
            fontFamily: "NotoSans",
            fontSize: 30.sp,
            fontWeight: FontWeight.w600,
          ),
          labelText: labelText,
          labelStyle: TextStyle(
            fontSize: 32.sp,
            color: Colors.black,
          ),
          border: defaultBorderTextFieldsss(),
          errorBorder: defaultBorderTextFieldsss(),
          disabledBorder: defaultBorderTextFieldsss(),
          focusedBorder: defaultBorderTextFieldsss(),
          enabledBorder: defaultBorderTextFieldsss(),
          contentPadding: paddingChange
              ? EdgeInsets.only(
                  left: 14.h, right: 14.h, top: 10.w, bottom: 13.h)
              : EdgeInsets.symmetric(vertical: 25.h, horizontal: 14.w),
          isCollapsed: true,
        ),
      ),
    );
  }
}

defaultBorderTextFieldsss({bool fill = false}) => OutlineInputBorder(
    borderSide: BorderSide(color: Color.fromARGB(255, 1, 77, 138), width: 2),
    borderRadius: BorderRadius.circular(8));
