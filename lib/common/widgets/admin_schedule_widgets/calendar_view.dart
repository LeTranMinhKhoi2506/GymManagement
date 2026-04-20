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
          _buildCalendarHeader(),
          const Divider(height: 1),
          Container(
            height: 600,
            padding: const EdgeInsets.all(24),
            child: StreamBuilder<List<ScheduleModel>>(
              stream: scheduleController.todaySchedulesStream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Lỗi: ${snapshot.error}'));
                }
                
                final schedules = snapshot.data ?? [];
                
                if (schedules.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.event_busy, size: 48, color: Colors.grey),
                        SizedBox(height: 16),
                        Text("Chưa có lịch làm việc hôm nay", style: TextStyle(color: Colors.grey)),
                      ],
                    ),
                  );
                }

                Map<String, List<ScheduleModel>> groupedSchedules = {};
                for (var schedule in schedules) {
                  String hourKey = DateFormat('hh:00 a').format(schedule.startTime);
                  if (!groupedSchedules.containsKey(hourKey)) {
                    groupedSchedules[hourKey] = [];
                  }
                  groupedSchedules[hourKey]!.add(schedule);
                }

                var sortedHours = groupedSchedules.keys.toList()..sort();

                return SingleChildScrollView(
                  child: Column(
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
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarHeader() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Text(
                "Hôm nay, ${DateFormat('dd').format(DateTime.now())} thg ${DateFormat('MM').format(DateTime.now())}",
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Color(0xFF0A192F)),
              ),
              const SizedBox(width: 20),
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(color: const Color(0xFFEDEEEF), borderRadius: BorderRadius.circular(8)),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(6), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 4)]),
                      child: const Text("Ngày", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF0A192F))),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Text("Tuần", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Row(
            children: [
              IconButton(onPressed: () {}, icon: const Icon(Icons.chevron_left)),
              IconButton(onPressed: () {}, icon: const Icon(Icons.chevron_right)),
            ],
          ),
        ],
      ),
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
