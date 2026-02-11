import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pdc/Modules/competitors_model.dart';
import 'package:pdc/Modules/department_model.dart';
import 'package:pdc/Modules/purpose_modal.dart';
import 'package:pdc/Modules/bin_model.dart';
import 'package:pdc/Modules/rack_model.dart';
import 'package:pdc/Modules/reasons_model.dart';
import 'package:pdc/Providers/receiving_provider.dart';
import 'package:pdc/Resuable components/text_field.dart';
import 'package:pdc/Resuable%20components/app_bar.dart';
import 'package:pdc/Resuable%20components/loading.dart';
import 'package:provider/provider.dart';

class AddReceivingScreen extends StatefulWidget {
  final String location;
  final String type;
  AddReceivingScreen({super.key, required this.location, required this.type});
  @override
  _AddReceivingScreenState createState() => _AddReceivingScreenState();
}

class _AddReceivingScreenState extends State<AddReceivingScreen> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController remarkController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final provider = Provider.of<ReceivingProvider>(context, listen: false);
    provider.fetchLocations(widget.location).then((_) {
      if (!mounted) return;
      final p = Provider.of<ReceivingProvider>(context, listen: false);
      if (p.locationList.isNotEmpty && p.selectedLocation != null) {
        p.getBin(widget.location, p.selectedLocation!);
      }
    });
  }

  @override
  void dispose() {
    remarkController.dispose();
    super.dispose();
  }

  /// Deduplicate competitor names so DropdownButton has exactly one item per value.
  List<String> _uniqueCompetitorNames(List<Competitor> competitors) {
    final seen = <String>{};
    final list = <String>[];
    for (final c in competitors) {
      if (seen.add(c.competitorName)) list.add(c.competitorName);
    }
    return list;
  }

  /// Build Company dropdown with unique values and valid selected value.
  Widget _buildCompanyDropdown(
    List<Competitor> competitors,
    String? selectedCompany,
    ValueChanged<String?> onChanged,
  ) {
    final names = _uniqueCompetitorNames(competitors);
    final validValue =
        selectedCompany != null && names.contains(selectedCompany)
        ? selectedCompany
        : (names.isNotEmpty ? names.first : null);
    return DropdownButton<String>(
      iconEnabledColor: Colors.black,
      value: validValue,
      style: textFieldStyle(color: Colors.black, fontSize: 24.sp),
      isExpanded: true,
      hint: names.isEmpty
          ? Text(
              'No companies',
              style: textFieldStyle(color: Colors.grey, fontSize: 24.sp),
            )
          : null,
      items: names
          .map(
            (name) => DropdownMenuItem<String>(value: name, child: Text(name)),
          )
          .toList(),
      onChanged: names.isEmpty ? null : onChanged,
    );
  }

  /// Build Purpose dropdown from provider purposes; value is purposeCode.
  Widget _buildPurposeDropdown(
    List<Purpose> purposes,
    String? selectedPurpose,
    ValueChanged<String?> onChanged,
  ) {
    final codes = purposes.map((p) => p.purposeCode).toList();
    final validValue =
        selectedPurpose != null && codes.contains(selectedPurpose)
        ? selectedPurpose
        : (codes.isNotEmpty ? codes.first : null);
    return DropdownButton<String>(
      iconEnabledColor: Colors.black,
      value: validValue,
      style: textFieldStyle(color: Colors.black, fontSize: 24.sp),
      isExpanded: true,
      hint: purposes.isEmpty
          ? Text(
              'Select Purpose',
              style: textFieldStyle(color: Colors.grey, fontSize: 24.sp),
            )
          : null,
      items: purposes
          .map(
            (p) => DropdownMenuItem<String>(
              value: p.purposeCode,
              child: Text(p.purposeName),
            ),
          )
          .toList(),
      onChanged: purposes.isEmpty ? null : onChanged,
    );
  }

  /// Build Reason dropdown from provider reasons (fetchReasons); value is reasonCode.
  Widget _buildReasonDropdown(
    List<Reason> reasons,
    String? selectedReason,
    ValueChanged<String?> onChanged,
  ) {
    final codes = reasons.map((r) => r.reasonCode).toList();
    final validValue = selectedReason != null && codes.contains(selectedReason)
        ? selectedReason
        : (codes.isNotEmpty ? codes.first : null);
    return DropdownButton<String>(
      iconEnabledColor: Colors.black,
      value: validValue,
      style: textFieldStyle(color: Colors.black, fontSize: 24.sp),
      isExpanded: true,
      hint: reasons.isEmpty
          ? Text(
              'Select Reason',
              style: textFieldStyle(color: Colors.grey, fontSize: 24.sp),
            )
          : null,
      items: reasons
          .map(
            (r) => DropdownMenuItem<String>(
              value: r.reasonCode,
              child: Text(r.reasonName),
            ),
          )
          .toList(),
      onChanged: reasons.isEmpty ? null : onChanged,
    );
  }

  /// Build Department dropdown from provider departments (fetchDepartments); value is departmentCode.
  Widget _buildDepartmentDropdown(
    List<Department> departments,
    String? selectedDepartment,
    ValueChanged<String?> onChanged,
  ) {
    final codes = departments.map((d) => d.departmentCode).toList();
    final validValue =
        selectedDepartment != null && codes.contains(selectedDepartment)
        ? selectedDepartment
        : (codes.isNotEmpty ? codes.first : null);
    return DropdownButton<String>(
      iconEnabledColor: Colors.black,
      value: validValue,
      style: textFieldStyle(color: Colors.black, fontSize: 24.sp),
      isExpanded: true,
      hint: departments.isEmpty
          ? Text(
              'Select Department',
              style: textFieldStyle(color: Colors.grey, fontSize: 24.sp),
            )
          : null,
      items: departments
          .map(
            (d) => DropdownMenuItem<String>(
              value: d.departmentCode,
              child: Text(d.departmentName),
            ),
          )
          .toList(),
      onChanged: departments.isEmpty ? null : onChanged,
    );
  }

  Widget _buildLocationDropdown(
    List<String> locationList,
    String? selectedLocation,
    ValueChanged<String?> onChanged,
  ) {
    final validValue =
        selectedLocation != null && locationList.contains(selectedLocation)
        ? selectedLocation
        : (locationList.isNotEmpty ? locationList.first : null);
    return DropdownButton<String>(
      iconEnabledColor: Colors.black,
      value: validValue,
      style: textFieldStyle(color: Colors.black, fontSize: 24.sp),
      isExpanded: true,
      hint: locationList.isEmpty
          ? Text(
              'No locations',
              style: textFieldStyle(color: Colors.grey, fontSize: 24.sp),
            )
          : null,
      items: locationList
          .map(
            (String value) =>
                DropdownMenuItem<String>(value: value, child: Text(value)),
          )
          .toList(),
      onChanged: locationList.isEmpty ? null : onChanged,
    );
  }

  Widget _buildRackDropdown(
    List<Rack> rackList,
    String? selectedRack,
    ValueChanged<String?> onChanged,
  ) {
    final validRacks = rackList
        .where((r) => r.code != null && r.code!.isNotEmpty)
        .toList();
    final codes = validRacks.map((r) => r.code!).toList();
    final validValue = selectedRack != null && codes.contains(selectedRack)
        ? selectedRack
        : (codes.isNotEmpty ? codes.first : null);
    return DropdownButton<String>(
      iconEnabledColor: Colors.black,
      value: validValue,
      style: textFieldStyle(color: Colors.black, fontSize: 24.sp),
      isExpanded: true,
      hint: validRacks.isEmpty
          ? Text(
              'Select Rack',
              style: textFieldStyle(color: Colors.grey, fontSize: 24.sp),
            )
          : null,
      items: validRacks
          .map(
            (Rack value) => DropdownMenuItem<String>(
              value: value.code!,
              child: Text(value.description ?? ''),
            ),
          )
          .toList(),
      onChanged: validRacks.isEmpty ? null : onChanged,
    );
  }

  Widget _buildBinDropdown(
    List<Bin> binList,
    String? selectedBin,
    ValueChanged<String?> onChanged,
  ) {
    final codes = binList.map((b) => b.code).toList();
    final validValue = selectedBin != null && codes.contains(selectedBin)
        ? selectedBin
        : (codes.isNotEmpty ? codes.first : null);
    return DropdownButton<String>(
      iconEnabledColor: Colors.black,
      value: validValue,
      style: textFieldStyle(color: Colors.black, fontSize: 24.sp),
      isExpanded: true,
      hint: binList.isEmpty
          ? Text(
              'Select Rack',
              style: textFieldStyle(color: Colors.grey, fontSize: 24.sp),
            )
          : null,
      items: binList
          .map(
            (Bin value) => DropdownMenuItem<String>(
              value: value.code,
              child: Text(value.description ?? ''),
            ),
          )
          .toList(),
      onChanged: binList.isEmpty ? null : onChanged,
    );
  }

  @override
  Widget build(BuildContext context) {
    final item = Provider.of<ReceivingProvider>(context, listen: true);
    return Scaffold(
      backgroundColor: Colors.white,

      body: Stack(
        children: [
          SafeArea(
            child: Scaffold(
              backgroundColor: Colors.white,
              body: SingleChildScrollView(
                child: Column(
                  children: [
                    CustomAppBar(
                      text: "ADD RECEIVING",
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
                    SizedBox(height: 10.h),

                    SingleChildScrollView(
                      child: Form(
                        key: _formKey,
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            // vertical: 30.h,
                            horizontal: 30.w,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Text(
                              //   'Add Receiving',
                              //   style: textFieldStyle(
                              //     color: Color.fromARGB(255, 14, 73, 161),
                              //     fontSize: 38.sp,
                              //     weight: FontWeight.w700,
                              //   ),
                              // ),
                              // SizedBox(height: 30.h),

                              // Type dropdown (jk/others)
                              Text(
                                'Type',
                                style: textFieldStyle(
                                  color: Colors.black,
                                  fontSize: 26.sp,
                                  weight: FontWeight.w600,
                                ),
                              ),
                              SizedBox(height: 10.h),
                              Container(
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: Colors.grey,
                                    width: 2,
                                  ),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                padding: EdgeInsets.symmetric(horizontal: 15.w),
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton<String>(
                                    iconEnabledColor: Colors.black,
                                    value: item.selectedType,
                                    style: textFieldStyle(
                                      color: Colors.black,
                                      fontSize: 24.sp,
                                    ),
                                    isExpanded: true,
                                    items: ["JK Tyre", "Others"].map((
                                      String value,
                                    ) {
                                      return DropdownMenuItem<String>(
                                        value: value,
                                        child: Text(value),
                                      );
                                    }).toList(),
                                    onChanged: (String? newValue) {
                                      if (newValue != null) {
                                        item.setSelectedType(newValue);
                                      }
                                    },
                                  ),
                                ),
                              ),
                              SizedBox(height: 20.h),

                              // Company dropdown (only if "others" is selected)
                              if (item.selectedType == "Others") ...[
                                Text(
                                  'Company',
                                  style: textFieldStyle(
                                    color: Colors.black,
                                    fontSize: 26.sp,
                                    weight: FontWeight.w600,
                                  ),
                                ),
                                SizedBox(height: 10.h),

                                Container(
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: Colors.grey,
                                      width: 2,
                                    ),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 15.w,
                                  ),
                                  child: DropdownButtonHideUnderline(
                                    child: _buildCompanyDropdown(
                                      item.competitors,
                                      item.selectedCompany,
                                      item.setSelectedCompany,
                                    ),
                                  ),
                                ),

                                SizedBox(height: 20.h),
                              ],

                              // Purpose dropdown
                              Text(
                                'Purpose',
                                style: textFieldStyle(
                                  color: Colors.black,
                                  fontSize: 26.sp,
                                  weight: FontWeight.w600,
                                ),
                              ),
                              SizedBox(height: 10.h),

                              Container(
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: Colors.grey,
                                    width: 2,
                                  ),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                padding: EdgeInsets.symmetric(horizontal: 15.w),
                                child: DropdownButtonHideUnderline(
                                  child: _buildPurposeDropdown(
                                    item.purposes,
                                    item.selectedPurpose,
                                    item.setSelectedPurpose,
                                  ),
                                ),
                              ),

                              SizedBox(height: 20.h),

                              // Reason dropdown
                              Text(
                                'Reason',
                                style: textFieldStyle(
                                  color: Colors.black,
                                  fontSize: 26.sp,
                                  weight: FontWeight.w600,
                                ),
                              ),
                              SizedBox(height: 10.h),
                              Container(
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: Colors.grey,
                                    width: 2,
                                  ),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                padding: EdgeInsets.symmetric(horizontal: 15.w),
                                child: DropdownButtonHideUnderline(
                                  child: _buildReasonDropdown(
                                    item.reasons,
                                    item.selectedReason,
                                    item.setSelectedReason,
                                  ),
                                ),
                              ),
                              SizedBox(height: 20.h),

                              // Department dropdown
                              Text(
                                'Department',
                                style: textFieldStyle(
                                  color: Colors.black,
                                  fontSize: 26.sp,
                                  weight: FontWeight.w600,
                                ),
                              ),

                              SizedBox(height: 10.h),
                              Container(
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: Colors.grey,
                                    width: 2,
                                  ),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                padding: EdgeInsets.symmetric(horizontal: 15.w),
                                child: DropdownButtonHideUnderline(
                                  child: _buildDepartmentDropdown(
                                    item.departments,
                                    item.selectedDepartment,
                                    item.setSelectedDepartment,
                                  ),
                                ),
                              ),

                              SizedBox(height: 20.h),

                              // Location dropdown
                              Text(
                                'Select Location',
                                style: textFieldStyle(
                                  color: Colors.black,
                                  fontSize: 26.sp,
                                  weight: FontWeight.w600,
                                ),
                              ),
                              SizedBox(height: 10.h),

                              Container(
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: Colors.grey,
                                    width: 2,
                                  ),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                padding: EdgeInsets.symmetric(horizontal: 15.w),
                                child: DropdownButtonHideUnderline(
                                  child: _buildLocationDropdown(
                                    item.locationList,
                                    item.selectedLocation,
                                    (String? value) async {
                                      if (value == null) return;
                                      item.setSelectedLocation(value);
                                      await item.getBin(widget.location, value);
                                    },
                                  ),
                                ),
                              ),

                              if (item.binList.isNotEmpty) ...[
                                SizedBox(height: 20.h),
                                Text(
                                  'Select Rack',
                                  style: textFieldStyle(
                                    color: Colors.black,
                                    fontSize: 26.sp,
                                    weight: FontWeight.w600,
                                  ),
                                ),
                                SizedBox(height: 10.h),
                                Container(
                                  margin: EdgeInsets.only(
                                    right: 20.w,
                                    left: 20.w,
                                    bottom: 20.h,
                                  ),
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: Colors.grey,
                                      width: 2,
                                    ),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 15.w,
                                  ),
                                  child: DropdownButtonHideUnderline(
                                    child: _buildBinDropdown(
                                      item.binList,
                                      item.selectedBin,
                                      item.setSelectedBin,
                                    ),
                                  ),
                                ),
                              ],

                              if (item.rackList.isNotEmpty) ...[
                                SizedBox(height: 20.h),
                                Text(
                                  'Select Bin',
                                  style: textFieldStyle(
                                    color: Colors.black,
                                    fontSize: 26.sp,
                                    weight: FontWeight.w600,
                                  ),
                                ),
                                SizedBox(height: 10.h),
                                Container(
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: Colors.grey,
                                      width: 2,
                                    ),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 15.w,
                                  ),
                                  child: DropdownButtonHideUnderline(
                                    child: _buildRackDropdown(
                                      item.rackList,
                                      item.selectedRack,
                                      item.setSelectedRack,
                                    ),
                                  ),
                                ),
                              ],
                              SizedBox(height: 14.h),

                              // Remark text field
                              Text(
                                'Remark',
                                style: textFieldStyle(
                                  color: Colors.black,
                                  fontSize: 26.sp,
                                  weight: FontWeight.w600,
                                ),
                              ),
                              SizedBox(height: 10.h),
                              Container(
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: Colors.grey,
                                    width: 2,
                                  ),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: TextFormField(
                                  controller: remarkController,
                                  style: textFieldStyle(color: Colors.black),
                                  maxLines: 2,
                                  decoration: InputDecoration(
                                    filled: true,
                                    fillColor: Colors.white,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10.0),
                                      borderSide: BorderSide.none,
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10.0),
                                      borderSide: BorderSide.none,
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10.0),
                                      borderSide: BorderSide.none,
                                    ),
                                    contentPadding: EdgeInsets.all(15.w),
                                  ),
                                ),
                              ),
                              SizedBox(height: 30.h),

                              // Submit button
                              Container(
                                height: 60.h,
                                width: double.infinity,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Color.fromARGB(
                                      255,
                                      14,
                                      73,
                                      161,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  onPressed: () async {
                                    if (_formKey.currentState!.validate()) {
                                      setState(() => _isLoading = true);
                                      final ok = await item.submitAddReceiving(
                                        context,
                                        widget.type,
                                        widget.location,
                                        remarkController.text,
                                      );
                                      if (mounted)
                                        setState(() => _isLoading = false);
                                      if (ok && mounted) {
                                        remarkController.clear();
                                      }
                                    }
                                  },
                                  child: Text(
                                    "Submit",
                                    style: textFieldStyle(
                                      color: Colors.white,
                                      weight: FontWeight.w700,
                                      fontSize: 24.sp,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (_isLoading) Center(child: LoaderTransparent(color: Colors.white)),
        ],
      ),
    );
  }
}
