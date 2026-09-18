import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_datawedge/flutter_datawedge.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:pdc/Providers/receiving_provider.dart';
import 'package:pdc/Resuable%20components/app_bar.dart';
import 'package:pdc/Resuable%20components/loading.dart';
import 'package:pdc/Resuable%20components/text_field.dart';
import 'package:provider/provider.dart';

class AddCompetitorBarcodeScreen extends StatefulWidget {
  final String location;

  const AddCompetitorBarcodeScreen({super.key, required this.location});

  @override
  State<AddCompetitorBarcodeScreen> createState() =>
      _AddCompetitorBarcodeScreenState();
}

class _AddCompetitorBarcodeScreenState
    extends State<AddCompetitorBarcodeScreen> {
  final _formKey = GlobalKey<FormState>();
  final barcodeController = TextEditingController();
  final sizeController = TextEditingController();
  final makeController = TextEditingController();
  final brandController = TextEditingController();
  final patternController = TextEditingController();
  final serialNoController = TextEditingController();
  final remarksController = TextEditingController();
  final productionDateController = TextEditingController();

  String? selectedCategoryCode;
  bool _isLoading = false;

  StreamSubscription<ScanResult>? onScanResultListener;
  StreamSubscription<ScannerStatus>? onScannerStatusListener;
  FlutterDataWedge? fdw;

  final upperNoSpace = [
    FilteringTextInputFormatter.deny(RegExp(r'\s')),
    _UpperCaseTextFormatter(),
  ];

  @override
  void initState() {
    super.initState();
    _loadCategories();
    initScanner();
  }

  Future<void> initScanner() async {
    if (!Platform.isAndroid) return;
    fdw = FlutterDataWedge();
    onScanResultListener = fdw!.onScanResult.listen((result) {
      if (!mounted) return;
      setState(() {
        barcodeController.text = result.data.trim();
      });
    });
    onScannerStatusListener = fdw!.onScannerStatus.listen((_) {});
    await fdw!.initialize();
  }

  Future<void> _loadCategories() async {
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
  }

  @override
  void dispose() {
    onScanResultListener?.cancel();
    onScannerStatusListener?.cancel();
    barcodeController.dispose();
    sizeController.dispose();
    makeController.dispose();
    brandController.dispose();
    patternController.dispose();
    serialNoController.dispose();
    remarksController.dispose();
    productionDateController.dispose();
    super.dispose();
  }

  Future<void> _pickProductionDate() async {
    DateTime initial = DateTime.now();
    if (productionDateController.text.isNotEmpty) {
      initial =
          DateTime.tryParse(productionDateController.text) ?? DateTime.now();
    }
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked == null) return;
    setState(() {
      productionDateController.text = DateFormat('yyyy-MM-dd').format(picked);
    });
  }

  Future<void> _submit() async {
    if (barcodeController.text.trim().isEmpty) {
      EasyLoading.showToast(
        "Please scan barcode",
        maskType: EasyLoadingMaskType.black,
      );
      return;
    }

    if (!(_formKey.currentState?.validate() ?? false)) {
      EasyLoading.showToast(
        "Please fill all required fields",
        maskType: EasyLoadingMaskType.black,
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final success = await Provider.of<ReceivingProvider>(
      context,
      listen: false,
    ).addCompetitorBarcode(
      context,
      barcode: barcodeController.text.trim(),
      category: selectedCategoryCode ?? "",
      size: sizeController.text.trim(),
      make: makeController.text.trim(),
      brand: brandController.text.trim(),
      pattern: patternController.text.trim(),
      serialNo: serialNoController.text.trim(),
      productionDate: productionDateController.text.trim(),
      remarks: remarksController.text.trim(),
      location: widget.location,
    );

    if (!mounted) return;
    setState(() {
      _isLoading = false;
    });

    if (success) {
      barcodeController.clear();
      setState(() {});
    }
  }

  void _clearAll() {
    barcodeController.clear();
    sizeController.clear();
    makeController.clear();
    brandController.clear();
    patternController.clear();
    serialNoController.clear();
    remarksController.clear();
    productionDateController.clear();
    setState(() {
      selectedCategoryCode = null;
    });
  }

  static const int _maxRemarkCharacters = 300;

  Widget _fieldLabel(String label) {
    return Text(
      label,
      style: textFieldStyle(
        color: Colors.black,
        fontSize: 26.sp,
        weight: FontWeight.w600,
      ),
    );
  }

  Widget _inputBox({required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey, width: 2),
        borderRadius: BorderRadius.circular(10),
      ),
      padding: EdgeInsets.symmetric(horizontal: 15.w),
      child: child,
    );
  }

  InputDecoration get _innerDecoration => InputDecoration(
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
    disabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10.0),
      borderSide: BorderSide.none,
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10.0),
      borderSide: BorderSide.none,
    ),
    contentPadding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 0),
  );

  Widget requiredField({
    required TextEditingController controller,
    required String label,
    bool enabled = true,
    bool readOnly = false,
    VoidCallback? onTap,
    int maxLines = 1,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: 20.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _fieldLabel(label),
          SizedBox(height: 10.h),
          _inputBox(
            child: TextFormField(
              controller: controller,
              enabled: enabled,
              readOnly: readOnly,
              onTap: onTap,
              maxLines: maxLines,
              inputFormatters: maxLines == 1 ? upperNoSpace : null,
              style: textFieldStyle(color: Colors.black, fontSize: 24.sp),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return "$label is required";
                }
                return null;
              },
              decoration: _innerDecoration,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final item = Provider.of<ReceivingProvider>(context, listen: true);
    final tyreCategories = item.tyreCategories;

    return Stack(
      children: [
        SafeArea(
          child: Scaffold(
            backgroundColor: Colors.white,
            body: Column(
              children: [
                CustomAppBar(
                  text: "Add Barcode",
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
                  child: Form(
                    key: _formKey,
                    child: SingleChildScrollView(
                      padding: EdgeInsets.symmetric(
                        horizontal: 30.w,
                        vertical: 10.h,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          requiredField(
                            controller: barcodeController,
                            label: "Add Barcode",
                            enabled: false,
                          ),
                          Padding(
                            padding: EdgeInsets.only(bottom: 20.h),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _fieldLabel("Category"),
                                SizedBox(height: 10.h),
                                _inputBox(
                                  child: DropdownButtonHideUnderline(
                                    child: DropdownButtonFormField<String>(
                                      key: ValueKey(selectedCategoryCode),
                                      isExpanded: true,
                                      initialValue: selectedCategoryCode,
                                      iconEnabledColor: Colors.black,
                                      hint: Text(
                                        tyreCategories.isEmpty
                                            ? "No categories"
                                            : "Select Category",
                                        style: textFieldStyle(
                                          color: Colors.grey,
                                          fontSize: 24.sp,
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
                                        setState(() {
                                          selectedCategoryCode = value;
                                        });
                                      },
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return "Category is required";
                                        }
                                        return null;
                                      },
                                      style: textFieldStyle(
                                        color: Colors.black,
                                        fontSize: 24.sp,
                                      ),
                                      decoration: _innerDecoration,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          requiredField(
                            controller: sizeController,
                            label: "Size",
                          ),
                          requiredField(
                            controller: makeController,
                            label: "Make",
                          ),
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
                          requiredField(
                            controller: productionDateController,
                            label: "Production Date",
                            readOnly: true,
                            onTap: _pickProductionDate,
                          ),
                          _fieldLabel("Remarks"),
                          SizedBox(height: 10.h),
                          Container(
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey, width: 2),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: TextFormField(
                              controller: remarksController,
                              style: textFieldStyle(
                                color: Colors.black,
                                fontSize: 24.sp,
                              ),
                              maxLines: 5,
                              inputFormatters: [
                                LengthLimitingTextInputFormatter(
                                  _maxRemarkCharacters,
                                ),
                              ],
                              onChanged: (_) => setState(() {}),
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
                                counterText:
                                    '${remarksController.text.length} / $_maxRemarkCharacters characters',
                              ),
                            ),
                          ),
                          SizedBox(height: 30.h),
                          SizedBox(
                            width: double.infinity,
                            height: 60.h,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color.fromARGB(
                                  255,
                                  14,
                                  73,
                                  161,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              onPressed: _submit,
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
                          SizedBox(height: 16.h),
                          SizedBox(
                            width: double.infinity,
                            height: 60.h,
                            child: OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(
                                  color: Color.fromARGB(255, 14, 73, 161),
                                  width: 2,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              onPressed: _clearAll,
                              child: Text(
                                "Clear",
                                style: textFieldStyle(
                                  color: const Color.fromARGB(255, 14, 73, 161),
                                  weight: FontWeight.w700,
                                  fontSize: 24.sp,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 24.h),
                        ],
                      ),
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

                          