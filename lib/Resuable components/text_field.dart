import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

// ignore: must_be_immutable
class CustomTextField extends StatelessWidget {
  String hintText;
  TextEditingController? controller;
  double? inputLabelWidth;
  double? inputFieldWidth;
  String? Function(String?)? validator;
  List<TextInputFormatter>? inputFormatters;
  bool isRequired;
  TextInputType? txKeyboardType;

  bool isEnabled;
  bool isReadOnly;
  FocusNode? focusNode;
  bool isFocused;
  bool? obscureText;
  bool check;
  bool margin;
  bool checking;
  bool maxlength;
  String prefix;
  bool changeColor;
  bool isDense;
  String labelText;
  void Function(String)? onChanged;
  Function(String?)? onSaved;
  int maxCheck;

  final void Function(String)? onFieldSubmitted;
  Function()? onEditingComplete;
  Function()? onTap;

  CustomTextField({
    super.key,
    this.hintText = "",
    this.maxCheck = 1,
    this.controller,
    this.labelText = "",
    this.inputFormatters,
    this.onTap,
    this.isRequired = false,
    this.isDense = false,
    this.maxlength = false,
    this.prefix = "",
    this.onChanged,
    this.checking = false,
    this.inputLabelWidth,
    this.inputFieldWidth,
    this.isEnabled = true,
    this.isReadOnly = false,
    this.txKeyboardType,
    this.obscureText,
    this.validator,
    this.focusNode,
    this.check = false,
    this.margin = true,
    this.isFocused = false,
    this.onSaved,
    this.changeColor = false,
    this.onFieldSubmitted,
    this.onEditingComplete,
  });

  defaultBorderTextField({bool fill = false}) => OutlineInputBorder(
      borderSide: BorderSide(color: Color.fromARGB(255, 1, 77, 138), width: 2),
      borderRadius: BorderRadius.circular(8));

  @override
  Widget build(BuildContext context) {
    print('$changeColor changeColorchangeColor');
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: inputFieldWidth,
          margin: margin == true
              ? EdgeInsets.only(left: 10.w, right: 10.w, bottom: 42.h)
              : EdgeInsets.zero,
          decoration: const BoxDecoration(color: Colors.transparent),
          child: TextFormField(
            controller: controller,
            focusNode: focusNode,
            autofocus: isFocused,
            onFieldSubmitted: onFieldSubmitted,
            onEditingComplete: onEditingComplete,
            onChanged: onChanged,
            onSaved: onSaved,
            keyboardType: txKeyboardType ?? TextInputType.name,
            obscureText: obscureText ?? false,
            enabled: isEnabled == false ? false : true,
            readOnly: isReadOnly == false ? false : true,
            maxLines: maxCheck,
            onTap: onTap,
            maxLength: maxlength ? 11 : null,
            style: TextStyle(
              color: Colors.black,
              fontFamily: "NotoSans",
              fontSize: 37.sp,
              fontWeight: FontWeight.w600,
            ),
            decoration: InputDecoration(
              // filled: true,
              prefixText: prefix,

              isDense: isDense ? true : false,
              labelText: labelText,
              labelStyle: TextStyle(
                fontSize: 32.sp,
                color: Colors.black,
              ),
              contentPadding:
                  EdgeInsets.symmetric(vertical: 5.h, horizontal: 14.w),
              border: defaultBorderTextField(),
              errorBorder: defaultBorderTextField(),
              disabledBorder: defaultBorderTextField(),
              focusedBorder: defaultBorderTextField(),
              enabledBorder: defaultBorderTextField(),
              hintText: hintText,

              hintStyle: textFieldStyle(isHint: true),
            ),
            validator: validator,
            inputFormatters: inputFormatters,
          ),
        ),
      ],
    );
  }
}

TextStyle textFieldStyle(
        {double? fontSize,
        FontWeight weight = FontWeight.w400,
        FontStyle style = FontStyle.normal,
        bool underlineCheck = false,
        bool isHint = false,
        Color color = Colors.black}) =>
            TextStyle(
      color: color,
      fontFamily: "NotoSans",

      fontSize: fontSize,
      fontWeight: weight,
          decoration: underlineCheck? TextDecoration.underline:null, 
    );



defaultBorderTextField({bool fill = false}) => OutlineInputBorder(
    borderSide: BorderSide(
      color: Colors.blue.shade900,
    ),
    borderRadius: BorderRadius.circular(8));
TextStyle customStyle = TextStyle(
  color: Colors.black,
  fontFamily: "NotoSans",
  fontSize: 16.sp,
  fontWeight: FontWeight.w700,
);

class DateInput extends StatelessWidget {
  final String? inputName;
  final TextEditingController? controller;
  final double? inputLabelWidth;
  final double? inputFieldWidth;
  final bool? isEnabled;

  const DateInput({
    Key? key,
    this.inputName,
    this.controller,
    this.inputLabelWidth,
    this.inputFieldWidth,
    this.isEnabled,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width: inputLabelWidth ?? 100,
          child: Text(
            inputName ?? '',
            style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
                fontFamily: "NotoSans"),
            textAlign: TextAlign.end,
          ),
        ),
        const SizedBox(
          width: 5.0,
        ),
        Container(
          width: inputFieldWidth ?? 100,
          color: Colors.white,
          child: TextFormField(
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontFamily: "NotoSans",
              fontSize: 15,
            ),
            enabled: isEnabled == true,
            keyboardType: TextInputType.datetime,
            controller: controller,
            onTap: () async {
              if (isEnabled == true) {
                final DateTime? picked = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2101),
                );
                if (picked != null) {
                  // controller?.value = TextEditingValue(text: DateFormat('dd-MM-yyyy').format(picked).toString());
                }
              }
            },
            decoration: const InputDecoration(
              border: OutlineInputBorder(
                borderSide: BorderSide(),
                borderRadius: BorderRadius.all(Radius.circular(0)),
              ),
              contentPadding:
                  EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
              isCollapsed: true,
            ),
          ),
        ),
      ],
    );
  }
}
