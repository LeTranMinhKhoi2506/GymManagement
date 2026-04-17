import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../data/models/schedule_model.dart';

class ActiveShiftsWidget extends StatefulWidget {
  final List<ScheduleModel> schedules;

  const ActiveShiftsWidget({
    super.key,
    required this.schedules,
  });

  @override
  State<ActiveShiftsWidget> createState() => _ActiveShiftsWidgetState();
}

class _ActiveShiftsWidgetState extends State<ActiveShiftsWidget> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    // Determine how many items to show
    final displayList = _isExpanded 
        ? widget.schedules 
        : widget.schedules.take(3).toList();

    return Container(
      width: 350,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF0D1B2A),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Ca đang chạy",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Text(
                "HÔM NAY",
                style: TextStyle(
                  color: Colors.orange,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          if (widget.schedules.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Text("Không có ca làm việc nào", style: TextStyle(color: Colors.grey)),
            )
          else ...[
            AnimatedSize(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              child: ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: displayList.length,
                itemBuilder: (context, index) {
                  final schedule = displayList[index];
                  return _buildShiftItem(schedule, index == displayList.length - 1);
                },
              ),
            ),
            if (widget.schedules.length > 3)
              const SizedBox(height: 16),
            if (widget.schedules.length > 3)
              SizedBox(
                width: double.infinity,
                child: TextButton.icon(
                  onPressed: () {
                    setState(() {
                      _isExpanded = !_isExpanded;
                    });
                  },
                  icon: Icon(
                    _isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                    color: Colors.white70,
                  ),
                  label: Text(
                    _isExpanded ? "Thu gọn" : "Xem thêm lịch",
                    style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
          ],
        ],
      ),
    );
  }

  Widget _buildShiftItem(ScheduleModel schedule, bool isLast) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: schedule.status == 'ongoing' ? Colors.orange : Colors.blueGrey.withValues(alpha: 0.5),
                  shape: BoxShape.circle,
                  boxShadow: schedule.status == 'ongoing' 
                    ? [BoxShadow(color: Colors.orange.withValues(alpha: 0.5), blurRadius: 8)] 
                    : [],
                ),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    color: Colors.white.withValues(alpha: 0.1),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        schedule.task,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      "${DateFormat('HH:mm').format(schedule.startTime)} - ${DateFormat('HH:mm').format(schedule.endTime)}",
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.6),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    CircleAvatar(
                      radius: 14,
                      backgroundColor: Colors.blue.withValues(alpha: 0.2),
                      child: Text(
                        schedule.staffName.isNotEmpty ? schedule.staffName[0] : "?",
                        style: const TextStyle(fontSize: 10, color: Colors.blue),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      schedule.staffName,
                      style: TextStyle(color: Colors.white.withValues(alpha: 0.4), fontSize: 13),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
