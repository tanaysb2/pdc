import 'package:flutter/material.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SearchableDropDown extends StatelessWidget {
  final String labelName;
  final String? selectedItem;
  final List<String> dropDownItems;
  final void Function(String?) onDropDownItemSelected;

  const SearchableDropDown(
      {super.key,
      required this.dropDownItems,
      this.selectedItem,
      required this.onDropDownItemSelected,
      required this.labelName});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          labelName,
          style: TextStyle(
            color: Color.fromARGB(255, 1, 77, 138),
            fontFamily: "NotoSans",
            fontSize: 20.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(
          height: 12.h,
        ),
        DropdownSearch<String>(
          popupProps: PopupProps.menu(
              showSelectedItems: false,
              showSearchBox: true,
              searchFieldProps: TextFieldProps(
                decoration: InputDecoration(
                  isDense: true,
                  hintText: "Search Material Item",
                  hintStyle: TextStyle(color: Colors.grey),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                        color: Color.fromARGB(255, 1, 77, 138), width: 1.5),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                        color: Color.fromARGB(255, 1, 77, 138), width: 1.5),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  suffixIcon: Icon(Icons.search),
                ),
              )),
          items: dropDownItems,
          //const ['India','Brazil','Canada','Australia'],
          onChanged: onDropDownItemSelected,
          //print,
          selectedItem: selectedItem,

          //'India',
          dropdownDecoratorProps: DropDownDecoratorProps(
            baseStyle: TextStyle(
              color: Colors.black,
              fontFamily: "NotoSans",
              fontSize: 32.sp,
              fontWeight: FontWeight.w600,
            ),
            dropdownSearchDecoration: InputDecoration(
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(
                    color: Color.fromARGB(255, 1, 77, 138), width: 1.5),
                borderRadius: BorderRadius.circular(10),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(
                    color: Color.fromARGB(255, 1, 77, 138), width: 1.5),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
