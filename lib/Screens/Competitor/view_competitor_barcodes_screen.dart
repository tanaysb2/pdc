import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:pdc/Modules/competitor_barcode_model.dart';
import 'package:pdc/Providers/receiving_provider.dart';
import 'package:pdc/Resuable%20components/app_bar.dart';
import 'package:pdc/Resuable%20components/date_range_picker.dart';
import 'package:pdc/Resuable%20components/loading.dart';
import 'package:pdc/Resuable%20components/text_field.dart';
import 'package:pdc/Screens/Competitor/add_competitor_barcode_screen.dart';
import 'package:provider/provider.dart';

class ViewCompetitorBarcodesScreen extends StatefulWidget {
  final String location;

  const ViewCompetitorBarcodesScreen({super.key, required this.location});

  @override
  State<ViewCompetitorBarcodesScreen> createState() =>
      _ViewCompetitorBarcodesScreenState();
}

class _ViewCompetitorBarcodesScreenState
    extends State<ViewCompetitorBarcodesScreen> {
  static const _primaryBlue = Color.fromARGB(255, 1, 77, 138);

  late DateTime fromDate;
  late DateTime toDate;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    toDate = DateTime(now.year, now.month, now.day);
    fromDate = toDate.subtract(const Duration(days: 2));
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchBarcodes();
    });
  }

  String _formatDate(DateTime date) => DateFormat('yyyy-MM-dd').format(date);

  String _displayValue(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty || trimmed == "0000-00-00") return "-";
    return trimmed;
  }

  Future<void> _pickDateRange() async {
    final picked = await AppDateRangePicker.pickDateRange(
      context,
      initialDateRange: DateTimeRange(start: fromDate, end: toDate),
      minDate: DateTime(2000),
      maxDate: DateTime.now(),
    );
    if (picked == null) return;

    setState(() {
      fromDate = DateTime(
        picked.start.year,
        picked.start.month,
        picked.start.day,
      );
      toDate = DateTime(picked.end.year, picked.end.month, picked.end.day);
    });
    await _fetchBarcodes();
  }

  Future<void> _openEdit(CompetitorBarcode item) async {
    final updated = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (context) => AddCompetitorBarcodeScreen(
          location: widget.location,
          item: item,
        ),
      ),
    );
    if (updated == true && mounted) {
      await _fetchBarcodes();
    }
  }

  Future<void> _fetchBarcodes() async {
    setState(() {
      _isLoading = true;
    });
    await Provider.of<ReceivingProvider>(
      context,
      listen: false,
    ).fetchCompetitorBarcodes(
      context,
      fromDate: _formatDate(fromDate),
      toDate: _formatDate(toDate),
    );
    if (!mounted) return;
    setState(() {
      _isLoading = false;
    });
  }

  String _rangeLabel() {
    if (_formatDate(fromDate) == _formatDate(toDate)) {
      return _formatDate(fromDate);
    }
    return "${_formatDate(fromDate)}  -  ${_formatDate(toDate)}";
  }

  Widget _dateRangeField() {
    return InkWell(
      onTap: _pickDateRange,
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: "Date Range",
          labelStyle: TextStyle(fontSize: 26.sp, color: Colors.black),
          contentPadding: EdgeInsets.symmetric(
            vertical: 12.h,
            horizontal: 14.w,
          ),
          border: defaultBorderTextField(),
          enabledBorder: defaultBorderTextField(),
          focusedBorder: defaultBorderTextField(),
          suffixIcon: const Icon(Icons.calendar_today, size: 18),
        ),
        child: Text(
          _rangeLabel(),
          style: textFieldStyle(
            color: _primaryBlue,
            fontSize: 26.sp,
            weight: FontWeight.w700,
          ),
        ),
      ),
    );
  }

  Widget _fieldRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 220.w,
            child: Text(
              label,
              style: textFieldStyle(
                color: Colors.grey.shade800,
                fontSize: 24.sp,
                weight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              _displayValue(value),
              style: textFieldStyle(
                color: _primaryBlue,
                fontSize: 26.sp,
                weight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _barcodeCard(CompetitorBarcode item) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(bottom: 16.h),
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 22.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            offset: const Offset(0, 1),
            blurRadius: 4,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (item.barcode.trim().isNotEmpty) ...[
            _fieldRow("Barcode", item.barcode),
          ],
          _fieldRow("Category", item.category),
          _fieldRow("Size", item.size),
          _fieldRow("Make", item.make),
          _fieldRow("Brand", item.brand),
          _fieldRow("Pattern", item.pattern),
          _fieldRow("Serial No", item.serialNo),
          _fieldRow("Production Date", item.productionDate),
          _fieldRow("Remarks", item.remark),
          SizedBox(height: 8.h),
          Align(
            alignment: Alignment.centerRight,
            child: SizedBox(
              height: 52.h,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: _primaryBlue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: () => _openEdit(item),
                child: Text(
                  "Edit",
                  style: textFieldStyle(
                    color: Colors.white,
                    fontSize: 24.sp,
                    weight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final items = Provider.of<ReceivingProvider>(context).competitorBarcodes;

    return Stack(
      children: [
        SafeArea(
          child: Scaffold(
            backgroundColor: const Color(0xFFF6F6F6),
            body: Column(
              children: [
                CustomAppBar(
                  text: "View Barcodes",
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
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 30.w),
                  child: _dateRangeField(),
                ),
                SizedBox(height: 16.h),
                // Padding(
                //   padding: EdgeInsets.symmetric(horizontal: 30.w),
                //   child: SizedBox(
                //     width: double.infinity,
                //     height: 72.h,
                //     child: ElevatedButton(
                //       style: ElevatedButton.styleFrom(
                //         backgroundColor: _primaryBlue,
                //         shape: RoundedRectangleBorder(
                //           borderRadius: BorderRadius.circular(10),
                //         ),
                //       ),
                //       onPressed: _fetchBarcodes,
                //       child: Text(
                //         "Search",
                //         style: textFieldStyle(
                //           color: Colors.white,
                //           fontSize: 28.sp,
                //           weight: FontWeight.w700,
                //         ),
                //       ),
                //     ),
                //   ),
                // ),
                SizedBox(height: 16.h),
                Expanded(
                  child: items.isEmpty && !_isLoading
                      ? Center(
                          child: Text(
                            "No barcodes found",
                            style: textFieldStyle(
                              color: Colors.grey.shade600,
                              fontSize: 26.sp,
                              weight: FontWeight.w500,
                            ),
                          ),
                        )
                      : ListView.builder(
                          padding: EdgeInsets.fromLTRB(30.w, 0, 30.w, 30.h),
                          itemCount: items.length,
                          itemBuilder: (context, index) {
                            return _barcodeCard(items[index]);
                          },
                        ),
                ),
              ],
            ),
          ),
        ),
        if (_isLoading)
          Center(child: LoaderTransparent(color: Colors.white)),
      ],
    );
  }
}
