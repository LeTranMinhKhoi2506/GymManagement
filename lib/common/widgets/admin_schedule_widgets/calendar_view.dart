import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../controllers/schedule_controller.dart';
import '../../../data/models/schedule_model.dart';

class CalendarView extends StatelessWidget {
  const CalendarView({super.key});

  @override
  Widget build(BuildContext context) {
    final scheduleController = Provider.of<ScheduleController>(context);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildCalendarHeader(context, scheduleController),
          const Divider(height: 1),
          Container(
            height: 680,
            padding: const EdgeInsets.all(24),
            child: StreamBuilder<List<ScheduleModel>>(
              stream: scheduleController.schedulesStream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Lỗi: ${snapshot.error}'));
                }
                
                final schedules = snapshot.data ?? [];
                
                Widget viewWidget;
                if (scheduleController.viewMode == 'day') {
                  viewWidget = _buildDayView(context, schedules, scheduleController.selectedDate);
                } else if (scheduleController.viewMode == 'week') {
                  viewWidget = _buildWeekView(context, schedules, scheduleController.selectedDate);
                } else {
                  viewWidget = _buildMonthView(context, schedules, scheduleController.selectedDate, scheduleController);
                }

                if (scheduleController.viewMode == 'month') {
                  return viewWidget;
                } else {
                  return SingleChildScrollView(
                    child: viewWidget,
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildViewModeTab(String label, String mode, ScheduleController controller) {
    final isSelected = controller.viewMode == mode;
    return InkWell(
      onTap: () => controller.setViewMode(mode),
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
          boxShadow: isSelected
              ? [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 4, offset: const Offset(0, 2))]
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: isSelected ? const Color(0xFF0A192F) : Colors.grey[600],
          ),
        ),
      ),
    );
  }

  Widget _buildCalendarHeader(BuildContext context, ScheduleController controller) {
    String titleText = "";
    if (controller.viewMode == 'day') {
      final isToday = DateUtils.isSameDay(controller.selectedDate, DateTime.now());
      titleText = isToday
          ? "Hôm nay, ${DateFormat('dd').format(controller.selectedDate)} thg ${DateFormat('MM').format(controller.selectedDate)}"
          : DateFormat('EEEE, dd/MM', 'vi_VN').format(controller.selectedDate);
    } else if (controller.viewMode == 'week') {
      final startOfWeek = controller.selectedDate.subtract(Duration(days: controller.selectedDate.weekday - 1));
      final endOfWeek = startOfWeek.add(const Duration(days: 6));
      if (startOfWeek.month == endOfWeek.month) {
        titleText = "${DateFormat('dd').format(startOfWeek)} - ${DateFormat('dd/MM/yyyy').format(endOfWeek)}";
      } else {
        titleText = "${DateFormat('dd/MM').format(startOfWeek)} - ${DateFormat('dd/MM/yyyy').format(endOfWeek)}";
      }
    } else { // month
      titleText = "Tháng ${DateFormat('MM/yyyy').format(controller.selectedDate)}";
    }

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Text(
                titleText,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Color(0xFF0A192F)),
              ),
              const SizedBox(width: 20),
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(color: const Color(0xFFEDEEEF), borderRadius: BorderRadius.circular(8)),
                child: Row(
                  children: [
                    _buildViewModeTab("Ngày", "day", controller),
                    _buildViewModeTab("Tuần", "week", controller),
                    _buildViewModeTab("Tháng", "month", controller),
                  ],
                ),
              ),
            ],
          ),
          Row(
            children: [
              TextButton.icon(
                onPressed: () => controller.jumpToToday(),
                icon: const Icon(Icons.today, size: 16, color: Color(0xFFFF6B35)),
                label: const Text("Hôm nay", style: TextStyle(color: Color(0xFF0A192F), fontWeight: FontWeight.bold, fontSize: 13)),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                    side: const BorderSide(color: Color(0xFFEDEEEF)),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Container(
                decoration: BoxDecoration(color: const Color(0xFFEDEEEF), borderRadius: BorderRadius.circular(8)),
                child: IconButton(
                  onPressed: () => controller.previous(),
                  icon: const Icon(Icons.chevron_left, size: 20),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                decoration: BoxDecoration(color: const Color(0xFFEDEEEF), borderRadius: BorderRadius.circular(8)),
                child: IconButton(
                  onPressed: () => controller.next(),
                  icon: const Icon(Icons.chevron_right, size: 20),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDayView(BuildContext context, List<ScheduleModel> schedules, DateTime selectedDate) {
    if (schedules.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.event_busy, size: 48, color: Colors.grey),
            SizedBox(height: 16),
            Text("Chưa có lịch làm việc trong ngày này", style: TextStyle(color: Colors.grey)),
          ],
        ),
      );
    }

    Map<String, List<ScheduleModel>> groupedSchedules = {};
    for (var schedule in schedules) {
      String hourKey = DateFormat('HH:00').format(schedule.startTime);
      if (!groupedSchedules.containsKey(hourKey)) {
        groupedSchedules[hourKey] = [];
      }
      groupedSchedules[hourKey]!.add(schedule);
    }

    var sortedHours = groupedSchedules.keys.toList()..sort();

    return Column(
      children: sortedHours.map((hour) {
        return _buildTimeSlot(hour, groupedSchedules[hour]!.map((s) {
          Gradient? gradient;
          Color? color;
          Color textColor = const Color(0xFF0A192F);
          
          if (s.task.toLowerCase().contains("hiit") || s.task.toLowerCase().contains("power")) {
            gradient = const LinearGradient(colors: [Color(0xFFFF6B35), Color(0xFFF59E0B)]);
            textColor = Colors.white;
          } else if (s.status == 'ongoing') {
            color = const Color(0xFF0A192F);
            textColor = Colors.white;
          }

          return _buildScheduleCard(
            context,
            s,
            gradient: gradient,
            color: color,
            textColor: textColor,
          );
        }).toList());
      }).toList(),
    );
  }

  Widget _buildWeekView(BuildContext context, List<ScheduleModel> schedules, DateTime selectedDate) {
    final startOfWeek = DateTime(selectedDate.year, selectedDate.month, selectedDate.day).subtract(Duration(days: selectedDate.weekday - 1));
    
    Map<int, List<ScheduleModel>> weekdaySchedules = {1: [], 2: [], 3: [], 4: [], 5: [], 6: [], 7: []};
    for (var s in schedules) {
      weekdaySchedules[s.startTime.weekday]?.add(s);
    }

    final List<String> weekdayLabels = ["Thứ Hai", "Thứ Ba", "Thứ Tư", "Thứ Năm", "Thứ Sáu", "Thứ Bảy", "Chủ Nhật"];

    return Column(
      children: List.generate(7, (index) {
        final dayIndex = index + 1;
        final currentDay = startOfWeek.add(Duration(days: index));
        final daySchedules = weekdaySchedules[dayIndex] ?? [];
        final isToday = DateUtils.isSameDay(currentDay, DateTime.now());

        return Container(
          margin: const EdgeInsets.only(bottom: 24),
          decoration: BoxDecoration(
            color: isToday ? const Color(0xFFFF6B35).withValues(alpha: 0.02) : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: isToday ? Border.all(color: const Color(0xFFFF6B35).withValues(alpha: 0.2), width: 1) : null,
          ),
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: isToday ? const Color(0xFFFF6B35) : const Color(0xFF0A192F),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          weekdayLabels[index],
                          style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        DateFormat('dd/MM/yyyy').format(currentDay),
                        style: TextStyle(
                          color: isToday ? const Color(0xFFFF6B35) : const Color(0xFF0A192F),
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    "${daySchedules.length} ca làm việc",
                    style: TextStyle(
                      color: daySchedules.isEmpty ? Colors.grey : const Color(0xFFFF6B35),
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (daySchedules.isEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8F9FA),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFEDEEEF)),
                  ),
                  child: const Center(
                    child: Text(
                      "Nghỉ - Không có lịch làm việc",
                      style: TextStyle(color: Colors.grey, fontSize: 12, fontStyle: FontStyle.italic),
                    ),
                  ),
                )
              else
                Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  children: daySchedules.map((s) {
                    Gradient? gradient;
                    Color? color;
                    Color textColor = const Color(0xFF0A192F);
                    
                    if (s.task.toLowerCase().contains("hiit") || s.task.toLowerCase().contains("power")) {
                      gradient = const LinearGradient(colors: [Color(0xFFFF6B35), Color(0xFFF59E0B)]);
                      textColor = Colors.white;
                    } else if (s.status == 'ongoing') {
                      color = const Color(0xFF0A192F);
                      textColor = Colors.white;
                    }

                    return SizedBox(
                      width: 280,
                      child: _buildScheduleCard(
                        context,
                        s,
                        gradient: gradient,
                        color: color,
                        textColor: textColor,
                      ),
                    );
                  }).toList(),
                ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildMonthView(BuildContext context, List<ScheduleModel> schedules, DateTime selectedDate, ScheduleController controller) {
    final firstDay = DateTime(selectedDate.year, selectedDate.month, 1);
    final weekdayOfFirst = firstDay.weekday; // Monday = 1, Sunday = 7
    final prevMonthPadding = weekdayOfFirst - 1;
    final gridStartDate = firstDay.subtract(Duration(days: prevMonthPadding));

    final lastDay = DateTime(selectedDate.year, selectedDate.month + 1, 0);
    final totalDaysNeeded = lastDay.day + prevMonthPadding;
    final rowsNeeded = (totalDaysNeeded / 7).ceil();
    final totalGridCells = rowsNeeded * 7;
    
    List<DateTime> days = [];
    DateTime curr = gridStartDate;
    for (int i = 0; i < totalGridCells; i++) {
      days.add(curr);
      curr = curr.add(const Duration(days: 1));
    }

    final weekdays = ["T2", "T3", "T4", "T5", "T6", "T7", "CN"];

    return Column(
      children: [
        Row(
          children: weekdays.map((day) => Expanded(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Text(
                  day,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    color: Color(0xFF0A192F),
                  ),
                ),
              ),
            ),
          )).toList(),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: GridView.builder(
            physics: const AlwaysScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              childAspectRatio: 0.85,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: days.length,
            itemBuilder: (context, index) {
              final day = days[index];
              final isCurrentMonth = day.month == selectedDate.month;
              final isToday = DateUtils.isSameDay(day, DateTime.now());
              final isSelected = DateUtils.isSameDay(day, selectedDate);
              
              final daySchedules = schedules.where((s) => DateUtils.isSameDay(s.startTime, day)).toList();

              return InkWell(
                onTap: () {
                  controller.setSelectedDate(day);
                  controller.setViewMode('day');
                },
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  decoration: BoxDecoration(
                    color: isCurrentMonth
                        ? (isToday ? const Color(0xFFFF6B35).withValues(alpha: 0.05) : Colors.white)
                        : const Color(0xFFF8F9FA),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected
                          ? const Color(0xFFFF6B35)
                          : (isToday ? const Color(0xFFFF6B35).withValues(alpha: 0.3) : const Color(0xFFEDEEEF)),
                      width: isSelected ? 2 : 1,
                    ),
                    boxShadow: isSelected
                        ? [BoxShadow(color: const Color(0xFFFF6B35).withValues(alpha: 0.2), blurRadius: 6)]
                        : null,
                  ),
                  padding: const EdgeInsets.all(6),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            width: 22,
                            height: 22,
                            decoration: BoxDecoration(
                              color: isToday ? const Color(0xFFFF6B35) : Colors.transparent,
                              shape: BoxShape.circle,
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              day.day.toString(),
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: isToday
                                    ? Colors.white
                                    : (isCurrentMonth ? const Color(0xFF0A192F) : Colors.grey),
                              ),
                            ),
                          ),
                          if (daySchedules.isNotEmpty)
                            Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: Color(0xFFFF6B35),
                                shape: BoxShape.circle,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Expanded(
                        child: ListView(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          children: [
                            ...daySchedules.take(2).map((s) {
                              final isOngoing = s.status == 'ongoing';
                              return Container(
                                margin: const EdgeInsets.only(bottom: 2),
                                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                                decoration: BoxDecoration(
                                  color: isOngoing
                                      ? const Color(0xFF0A192F)
                                      : const Color(0xFFFF6B35).withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  "${DateFormat('HH:mm').format(s.startTime)} ${s.task}",
                                  style: TextStyle(
                                    fontSize: 8,
                                    fontWeight: FontWeight.bold,
                                    color: isOngoing ? Colors.white : const Color(0xFF0A192F),
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              );
                            }),
                            if (daySchedules.length > 2)
                              Padding(
                                padding: const EdgeInsets.only(left: 2.0),
                                child: Text(
                                  "+${daySchedules.length - 2} ca nữa",
                                  style: const TextStyle(
                                    fontSize: 8,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildTimeSlot(String time, List<Widget> cards) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              time,
              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Colors.grey, letterSpacing: -0.5),
              textAlign: TextAlign.right,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Positioned(
                  top: 6,
                  left: 0,
                  right: 0,
                  child: Container(height: 1, color: const Color(0xFFE1E3E4)),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 0),
                  child: Wrap(
                    spacing: 16,
                    runSpacing: 16,
                    children: cards.map((c) => SizedBox(width: 300, child: c)).toList(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScheduleCard(BuildContext context, ScheduleModel s, {Color? color, Gradient? gradient, Color textColor = const Color(0xFF0A192F)}) {
    bool isDark = color != null || gradient != null;
    Color mainTextColor = isDark ? Colors.white : textColor;
    final scheduleController = Provider.of<ScheduleController>(context, listen: false);

    return InkWell(
      onTap: () => _showScheduleActions(context, s, scheduleController),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color ?? (gradient == null ? Colors.white : null),
          gradient: gradient,
          borderRadius: BorderRadius.circular(12),
          border: gradient == null && color == null ? Border.all(color: const Color(0xFFEDEEEF)) : null,
          boxShadow: isDark ? [BoxShadow(color: (color ?? const Color(0xFFFF6B35)).withValues(alpha: 0.3), blurRadius: 12, offset: const Offset(0, 4))] : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Phiên tập • ${s.status.toUpperCase()}", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: isDark ? Colors.white.withValues(alpha: 0.8) : const Color(0xFFFF6B35), letterSpacing: 1)),
                if (isDark) const Icon(Icons.bolt, size: 14, color: Colors.white) else const Icon(Icons.fitness_center, size: 14, color: Color(0xFF0A192F)),
              ],
            ),
            const SizedBox(height: 8),
            Text(s.task, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: mainTextColor, letterSpacing: -0.5)),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.person, size: 14, color: isDark ? Colors.white : Colors.grey),
                const SizedBox(width: 4),
                Expanded(child: Text("HLV: ${s.staffName}", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: mainTextColor), overflow: TextOverflow.ellipsis)),
                const SizedBox(width: 12),
                Icon(Icons.schedule, size: 14, color: isDark ? Colors.white : Colors.grey),
                const SizedBox(width: 4),
                Text("${DateFormat('HH:mm').format(s.startTime)} - ${DateFormat('HH:mm').format(s.endTime)}", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: mainTextColor)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showScheduleActions(BuildContext context, ScheduleModel s, ScheduleController controller) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.play_arrow, color: Colors.green),
            title: const Text("Bắt đầu ngay"),
            onTap: () {
              controller.updateStatus(s.id, 'ongoing');
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.check_circle, color: Colors.blue),
            title: const Text("Hoàn thành"),
            onTap: () {
              controller.updateStatus(s.id, 'completed');
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.delete, color: Colors.red),
            title: const Text("Xóa lịch trình"),
            onTap: () {
              controller.deleteSchedule(s.id);
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}
