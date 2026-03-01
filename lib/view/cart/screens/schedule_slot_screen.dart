import 'package:eatezy/style/app_color.dart';
import 'package:eatezy/utils/app_spacing.dart';
import 'package:eatezy/view/cart/screens/payment_method_screen.dart';
import 'package:eatezy/view/cart/services/cart_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

const double _cardRadius = 16;
const Color _surface = Color(0xFFF8F9FA);
const int _slotMinutes = 30;

/// Screen to select a delivery time slot based on vendor opening/closing hours.
class ScheduleSlotScreen extends StatefulWidget {
  const ScheduleSlotScreen({super.key});

  @override
  State<ScheduleSlotScreen> createState() => _ScheduleSlotScreenState();
}

class _ScheduleSlotScreenState extends State<ScheduleSlotScreen> {
  String? _selectedSlot;
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selectedDate = DateTime(now.year, now.month, now.day);
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<CartService>(context);
    final vendorId = provider.cartVendorId;
    final vendor = vendorId != null ? provider.findVendorById(vendorId) : null;

    if (vendor == null) {
      return Scaffold(
        backgroundColor: _surface,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: _surface,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios_new_rounded,
                color: Colors.grey.shade800),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            'Schedule Order',
            style: TextStyle(
              color: Colors.grey.shade900,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          centerTitle: true,
        ),
        body: Center(
          child: Text(
            'Unable to load vendor timing',
            style: TextStyle(color: Colors.grey.shade600),
          ),
        ),
      );
    }

    final opening = _parseTime(vendor.effectiveOpeningTime);
    final closing = _parseTime(vendor.effectiveClosingTime);
    final dateOptions = _buildDateOptions();
    final slots = _generateSlots(opening, closing, _selectedDate);

    return Scaffold(
      backgroundColor: _surface,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: _surface,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded,
              color: Colors.grey.shade800),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Schedule Order',
          style: TextStyle(
            color: Colors.grey.shade900,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(_cardRadius),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColor.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.calendar_today_rounded,
                            color: AppColor.primary,
                            size: 28,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Select delivery time',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey.shade800,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                DateFormat('EEEE, d MMMM yyyy')
                                    .format(_selectedDate),
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.grey.shade900,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${vendor.shopName} • ${vendor.openingHoursDisplay}',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  AppSpacing.h20,
                  Text(
                    'Select date',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: Colors.grey.shade900,
                    ),
                  ),
                  AppSpacing.h10,
                  SizedBox(
                    height: 70,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: dateOptions.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 10),
                      itemBuilder: (context, index) {
                        final date = dateOptions[index];
                        final isSelected = _isSameDate(_selectedDate, date);
                        return _DateChip(
                          label: _dateLabel(date),
                          subLabel: DateFormat('d MMM').format(date),
                          isSelected: isSelected,
                          onTap: () => setState(() {
                            _selectedDate = date;
                            _selectedSlot = null;
                          }),
                        );
                      },
                    ),
                  ),
                  AppSpacing.h20,
                  Text(
                    'Available slots',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: Colors.grey.shade900,
                    ),
                  ),
                  AppSpacing.h10,
                  if (slots.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(_cardRadius),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 10,
                          ),
                        ],
                      ),
                      child: Center(
                        child: Column(
                          children: [
                            Icon(Icons.schedule_rounded,
                                size: 48, color: Colors.grey.shade400),
                            AppSpacing.h15,
                            Text(
                              'No slots available for selected date',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey.shade700,
                              ),
                            ),
                            AppSpacing.h5,
                            Text(
                              'The restaurant may be closed or all slots have passed.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 3,
                      mainAxisSpacing: 10,
                      crossAxisSpacing: 10,
                      childAspectRatio: 2.2,
                      children: slots
                          .map((slot) => _SlotChip(
                                label: slot,
                                isSelected: _selectedSlot == slot,
                                onTap: () =>
                                    setState(() => _selectedSlot = slot),
                              ))
                          .toList(),
                    ),
                ],
              ),
            ),
          ),
          if (slots.isNotEmpty)
            Container(
              padding: EdgeInsets.fromLTRB(
                  20, 16, 20, 16 + MediaQuery.of(context).padding.bottom),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 12,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: SafeArea(
                child: SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      backgroundColor: _selectedSlot != null
                          ? AppColor.primary
                          : Colors.grey.shade300,
                    ),
                    onPressed:
                        _selectedSlot != null && slots.contains(_selectedSlot)
                            ? () => _onContinue(context)
                            : null,
                    child: const Text(
                      'Continue',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _onContinue(BuildContext context) {
    if (_selectedSlot == null) return;
    final slotLabel = _selectedSlot!;
    final parts = slotLabel.split(':');
    if (parts.length != 2) return;

    final hour = int.tryParse(parts[0]) ?? 0;
    final minute = int.tryParse(parts[1]) ?? 0;

    final scheduled = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      hour,
      minute,
    );
    final scheduledFor = scheduled.toIso8601String();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PaymentMethodScreen(scheduledFor: scheduledFor),
      ),
    );
  }

  List<DateTime> _buildDateOptions() {
    final now = DateTime.now();
    final base = DateTime(now.year, now.month, now.day);
    return List.generate(7, (index) => base.add(Duration(days: index)));
  }

  String _dateLabel(DateTime date) {
    final today = DateTime.now();
    final todayOnly = DateTime(today.year, today.month, today.day);
    final tomorrow = todayOnly.add(const Duration(days: 1));

    if (_isSameDate(date, todayOnly)) return 'Today';
    if (_isSameDate(date, tomorrow)) return 'Tomorrow';
    return DateFormat('EEE').format(date);
  }

  bool _isSameDate(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}

class _SlotChip extends StatelessWidget {
  const _SlotChip({
    required this.label,
    required this.onTap,
    this.isSelected = false,
  });

  final String label;
  final VoidCallback onTap;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      elevation: 1,
      shadowColor: Colors.black.withOpacity(0.04),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? AppColor.primary : Colors.grey.shade200,
              width: isSelected ? 2 : 1,
            ),
            color: isSelected ? AppColor.primary.withOpacity(0.08) : null,
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: isSelected ? AppColor.primary : Colors.grey.shade800,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DateChip extends StatelessWidget {
  const _DateChip({
    required this.label,
    required this.subLabel,
    required this.onTap,
    this.isSelected = false,
  });

  final String label;
  final String subLabel;
  final VoidCallback onTap;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      elevation: 1,
      shadowColor: Colors.black.withOpacity(0.04),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: 88,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? AppColor.primary : Colors.grey.shade200,
              width: isSelected ? 2 : 1,
            ),
            color: isSelected ? AppColor.primary.withOpacity(0.08) : null,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: isSelected ? AppColor.primary : Colors.grey.shade800,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subLabel,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: isSelected ? AppColor.primary : Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Parses time string. Supports:
/// - "1pm", "11pm", "9am", "1 pm", "11 pm"
/// - "09:00", "22:00", "9:00"
/// - "0900", "2200" (4 digits)
(int, int) _parseTime(String timeStr) {
  final s = timeStr.trim().toLowerCase().replaceAll(' ', '');
  if (s.isEmpty) return (9, 0);

  // Handle "1pm", "11pm", "9am", "1:30pm" format (strip space first)
  final isPm = s.endsWith('pm');
  final isAm = s.endsWith('am');
  if (isPm || isAm) {
    final withoutSuffix = s.substring(0, s.length - 2);
    final parts = withoutSuffix.split(':');
    var hour = int.tryParse(parts[0]) ?? 9;
    final minute = parts.length > 1 ? (int.tryParse(parts[1]) ?? 0) : 0;

    if (isPm && hour != 12) hour += 12;
    if (isAm && hour == 12) hour = 0;

    return (hour.clamp(0, 23), minute.clamp(0, 59));
  }

  // Handle "09:00", "22:00", "9:00" (has colon)
  if (s.contains(':')) {
    final parts = s.split(':');
    final hour = (int.tryParse(parts[0]) ?? 9).clamp(0, 23);
    final minute =
        parts.length > 1 ? (int.tryParse(parts[1]) ?? 0).clamp(0, 59) : 0;
    return (hour, minute);
  }

  // Handle "0900", "2200" (4 digits, no colon)
  if (s.length >= 3 && int.tryParse(s) != null) {
    final num = int.parse(s);
    final hour = (num ~/ 100).clamp(0, 23);
    final minute = (num % 100).clamp(0, 59);
    return (hour, minute);
  }

  return (9, 0);
}

/// Generates time slots from opening to closing, excluding past slots for today.
/// Handles overnight hours (e.g. 11pm-2am) by treating closing as next day.
List<String> _generateSlots(
    (int, int) opening, (int, int) closing, DateTime selectedDate) {
  final now = DateTime.now();
  var startHour = opening.$1;
  var startMinute = opening.$2;
  var endHour = closing.$1;
  var endMinute = closing.$2;

  // If closing is before opening (overnight), treat closing as next day
  final isOvernight =
      endHour < startHour || (endHour == startHour && endMinute <= startMinute);
  if (isOvernight) {
    endHour += 24;
  }

  final filteredSlots = <String>[];
  final allSlots = <String>[];
  var currentHour = startHour;
  var currentMinute = startMinute;

  while (currentHour < endHour ||
      (currentHour == endHour && currentMinute < endMinute)) {
    final displayHour = currentHour >= 24 ? currentHour - 24 : currentHour;
    final slotStart =
        '$displayHour:${currentMinute.toString().padLeft(2, '0')}';
    var endH = currentHour;
    var endM = currentMinute + _slotMinutes;
    if (endM >= 60) {
      endM -= 60;
      endH++;
    }
    allSlots.add(slotStart);

    // Skip if slot extends past closing (for same-day)
    if (!isOvernight &&
        (endH > endHour || (endH == endHour && endM > endMinute))) {
      break;
    }

    final slotStartTime = DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
      displayHour,
      currentMinute,
    );
    final today = DateTime(now.year, now.month, now.day);
    final selectedDay =
        DateTime(selectedDate.year, selectedDate.month, selectedDate.day);
    final isToday = selectedDay == today;

    // For today, hide already-passed slots. For future dates, keep all slots.
    final minAcceptable =
        DateTime(now.year, now.month, now.day, now.hour, now.minute)
            .subtract(const Duration(minutes: 30));
    if (!isToday || !slotStartTime.isBefore(minAcceptable)) {
      filteredSlots.add(slotStart);
    }

    currentMinute += _slotMinutes;
    if (currentMinute >= 60) {
      currentMinute -= 60;
      currentHour++;
    }
  }

  // Fallback: if no future slots (e.g. late night or timezone issue), show all
  return filteredSlots.isNotEmpty ? filteredSlots : allSlots;
}
