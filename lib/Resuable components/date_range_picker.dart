import 'package:flutter/material.dart';
import 'package:flutter_date_range_picker/flutter_date_range_picker.dart';
import 'package:pdc/Resuable%20components/text_field.dart';

class AppDateRangePicker {
  static const _primaryBlue = Color.fromARGB(255, 1, 77, 138);

  static Future<DateTimeRange?> pickDateRange(
    BuildContext context, {
    DateTimeRange? initialDateRange,
    DateTime? minDate,
    DateTime? maxDate,
    String cancelText = 'Cancel',
    String confirmText = 'Apply',
  }) async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final DateTime effectiveMinDate =
        minDate ?? DateTime(today.year - 1, today.month, today.day);
    final DateTime effectiveMaxDate =
        maxDate ??
        DateTime(today.year, today.month, today.day, 23, 59, 59, 999);

    DateRange? initialRange;
    if (initialDateRange != null) {
      initialRange = DateRange(initialDateRange.start, initialDateRange.end);
    }

    final selectedRange = await showDateRangePickerModalDialog(
      context: context,
      builder: (dialogContext, onDateRangeChanged) {
        return DateRangePickerWidget(
          doubleMonth: false,
          initialDateRange: initialRange,
          initialDisplayedDate:
              initialDateRange?.start ??
              today.subtract(const Duration(days: 10)),
          minDate: effectiveMinDate,
          maxDate: effectiveMaxDate,
          allowSingleTapDaySelection: true,
          firstDayOfWeek: 1,
          lengthOfDateName: 1,
          height: 360,
          onDateRangeChanged: onDateRangeChanged,
          theme: CalendarTheme(
            selectedColor: _primaryBlue,
            dayNameTextStyle: textFieldStyle(
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.45),
              fontSize: 12,
            ),
            inRangeColor: _primaryBlue.withValues(alpha: 0.1),
            inRangeTextStyle: textFieldStyle(
              color: _primaryBlue,
              weight: FontWeight.w500,
              fontSize: 14,
            ),
            selectedTextStyle: textFieldStyle(
              color: Theme.of(context).colorScheme.surface,
              weight: FontWeight.w500,
              fontSize: 14,
            ),
            todayTextStyle: textFieldStyle(
              weight: FontWeight.bold,
              color: _primaryBlue,
              fontSize: 14,
            ),
            defaultTextStyle: textFieldStyle(
              color: Theme.of(context).colorScheme.onSurface,
              fontSize: 14,
            ),
            radius: 8,
            tileSize: 40,
            disabledTextStyle: textFieldStyle(
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.38),
              fontSize: 14,
            ),
          ),
        );
      },
      footerBuilder: ({selectedDateRange}) {
        return DateRangePickerDialogFooter(
          selectedDateRange: selectedDateRange,
          cancelText: cancelText,
          confirmText: confirmText,
        );
      },
    );

    if (selectedRange == null) {
      return null;
    }
    return DateTimeRange(start: selectedRange.start, end: selectedRange.end);
  }
}
