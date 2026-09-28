import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pdc/Modules/document_detail_model.dart';
import 'package:pdc/Providers/receiving_provider.dart';
import 'package:pdc/Resuable%20components/app_bar.dart';
import 'package:pdc/Resuable%20components/loading.dart';
import 'package:pdc/Resuable%20components/text_field.dart';
import 'package:provider/provider.dart';

// ignore: must_be_immutable
class CartPageScreen extends StatefulWidget {
  String location;
  String materialCode;
  String materialDesc;
  String documentNumber;
  String docType;
  String title;

  CartPageScreen({
    super.key,
    required this.location,
    required this.materialCode,
    required this.materialDesc,
    required this.documentNumber,
    required this.docType,
    this.title = "Gate In",
  });

  @override
  State<CartPageScreen> createState() => _CartPageScreenState();
}

class _CartPageScreenState extends State<CartPageScreen> {
  static const _primaryBlue = Color.fromARGB(255, 1, 77, 138);

  bool isLoading = false;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    setState(() {
      isLoading = true;
    });
    Provider.of<ReceivingProvider>(context, listen: false)
        .fetchSkuDetails(
          documentNumber: widget.documentNumber,
          materialCode: widget.materialCode,
          location: widget.location,
          docType: widget.docType,
          materialDescription: widget.materialDesc,
        )
        .then((_) {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<DocumentDetailData> _filteredItems(List<DocumentDetailData> items) {
    final query = _searchController.text.trim().toLowerCase();
    if (query.isEmpty) return items;
    return items.where((item) {
      return item.barcode.toLowerCase().contains(query) ||
          item.manfPlant.toLowerCase().contains(query) ||
          item.prodDt.toLowerCase().contains(query) ||
          item.stencilno.toLowerCase().contains(query) ||
          item.matnr.toLowerCase().contains(query) ||
          item.docNo.toLowerCase().contains(query) ||
          item.catg.toLowerCase().contains(query) ||
          item.ysize.toLowerCase().contains(query) ||
          item.maktx.toLowerCase().contains(query) ||
          item.make.toLowerCase().contains(query) ||
          item.brand.toLowerCase().contains(query) ||
          item.pattern.toLowerCase().contains(query) ||
          item.serialNo.toLowerCase().contains(query) ||
          item.remark.toLowerCase().contains(query);
    }).toList();
  }

  bool get _isCompetitorSku =>
      widget.materialCode.toUpperCase().contains('COMPPDCMATNR');

  String _displayValue(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty || trimmed == "0000-00-00") return "-";
    return trimmed;
  }

  Widget _competitorCard(DocumentDetailData item) {
    Widget pair(String leftLabel, String leftValue, String rightLabel, String rightValue) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: _StackedField(
              label: leftLabel,
              value: _displayValue(leftValue),
            ),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: _StackedField(
              label: rightLabel,
              value: _displayValue(rightValue),
            ),
          ),
        ],
      );
    }

    return _InfoCard(
      children: [
        _StackedField(label: "Barcode", value: _displayValue(item.barcode)),
        SizedBox(height: 24.h),
        pair("Size", item.maktx, "Make", item.make),
        SizedBox(height: 24.h),
        pair("Brand", item.brand, "Pattern", item.pattern),
        SizedBox(height: 24.h),
        pair("Serial No", item.serialNo, "Production Date", item.prodDt),
      ],
    );
  }

  Widget _regularCard(DocumentDetailData item) {
    return _InfoCard(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _StackedField(
                label: "Barcode",
                value: item.barcode,
              ),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: _StackedField(
                label: "Manf Plant",
                value: item.manfPlant,
              ),
            ),
          ],
        ),
        SizedBox(height: 24.h),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _StackedField(
                label: "Prod. Date",
                value: item.prodDt,
              ),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: _StackedField(
                label: "Stencil No",
                value: item.stencilno,
              ),
            ),
          ],
        ),
      ],
    );
  }

  String _headerValue(String fromApi, String fallback) {
    return fromApi.trim().isNotEmpty ? fromApi.trim() : fallback;
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ReceivingProvider>(context, listen: true);
    final skuItems = provider.skuDetails;
    final headerItem = skuItems.isNotEmpty ? skuItems.first : null;
    final filteredItems = _filteredItems(skuItems);

    final documentNo = _headerValue(
      headerItem?.docNo ?? "",
      widget.documentNumber,
    );
    final itemCode = _headerValue(
      headerItem?.matnr ?? "",
      widget.materialCode,
    );
    final itemDesc = _headerValue(
      headerItem?.maktx ?? "",
      widget.materialDesc,
    );

    return Stack(
      children: [
        SafeArea(
          child: Scaffold(
            backgroundColor: const Color(0xFFF6F6F6),
            body: Column(
              children: [
                CustomAppBar(
                  text: widget.title,
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
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: EdgeInsets.only(bottom: 40.h),
                      child: Column(
                        children: [
                          _InfoCard(
                            children: [
                              _LabelValueRow(
                                label: "Document",
                                value: documentNo,
                              ),
                              SizedBox(height: 18.h),
                              _LabelValueRow(
                                label: "Item Code",
                                value: itemCode,
                              ),
                              SizedBox(height: 18.h),
                              _LabelValueRow(
                                label: "Item Desc",
                                value: itemDesc,
                              ),
                            ],
                          ),
                          SizedBox(height: 20.h),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 30.w),
                            child: TextField(
                              controller: _searchController,
                              onChanged: (_) => setState(() {}),
                              style: textFieldStyle(
                                color: _primaryBlue,
                                fontSize: 26.sp,
                                weight: FontWeight.w500,
                              ),
                              decoration: InputDecoration(
                                hintText: "Search...",
                                hintStyle: textFieldStyle(
                                  color: Colors.grey.shade800,
                                  fontSize: 26.sp,
                                  weight: FontWeight.w400,
                                ),
                                filled: true,
                                fillColor: Colors.white,
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 28.w,
                                  vertical: 16.h,
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(28.r),
                                  borderSide: const BorderSide(
                                    color: _primaryBlue,
                                    width: 2.5,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(28.r),
                                  borderSide: const BorderSide(
                                    color: _primaryBlue,
                                    width: 2.5,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 20.h),
                          if (!isLoading && filteredItems.isEmpty)
                            Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: 30.w,
                                vertical: 40.h,
                              ),
                              child: Text(
                                skuItems.isEmpty
                                    ? "No SKU details found"
                                    : "No matching results",
                                style: textFieldStyle(
                                  color: Colors.grey.shade600,
                                  fontSize: 26.sp,
                                  weight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ...filteredItems.map(
                            (item) => Padding(
                              padding: EdgeInsets.only(bottom: 16.h),
                              child: _isCompetitorSku
                                  ? _competitorCard(item)
                                  : _regularCard(item),
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
        if (isLoading)
          Center(child: LoaderTransparent(color: Colors.white)),
      ],
    );
  }
}

class _InfoCard extends StatelessWidget {
  final List<Widget> children;

  const _InfoCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(horizontal: 30.w),
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 22.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: const Color(0xFFE3E3E3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            offset: const Offset(0, 1),
            blurRadius: 4,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }
}

class _LabelValueRow extends StatelessWidget {
  final String label;
  final String value;

  const _LabelValueRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 180.w,
          child: Text(
            label,
            style: textFieldStyle(
              color: Colors.grey.shade800,
              fontSize: 26.sp,
              weight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: textFieldStyle(
              color: const Color.fromARGB(255, 1, 77, 138),
              fontSize: 28.sp,
              weight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}

class _StackedField extends StatelessWidget {
  final String label;
  final String value;

  const _StackedField({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: textFieldStyle(
            color: Colors.grey.shade800,
            fontSize: 24.sp,
            weight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 6.h),
        Text(
          value,
          style: textFieldStyle(
            color: const Color.fromARGB(255, 1, 77, 138),
            fontSize: 28.sp,
            weight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}
