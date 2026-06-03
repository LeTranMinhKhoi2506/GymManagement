import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../controllers/admin_controller.dart';

class SummaryCards extends StatelessWidget {
  final AdminController controller;

  const SummaryCards({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(locale: 'vi_VN', symbol: '₫', decimalDigits: 0);
    final numberFormat = NumberFormat('#,###');

    return Row(
      children: [
        // Card 1: TOTAL MEMBERS
        Expanded(
          child: StreamBuilder<int>(
            stream: controller.totalMembersStream,
            builder: (context, snapshot) {
              final count = snapshot.data ?? 0;
              return StreamBuilder<Map<String, dynamic>>(
                stream: controller.membersGrowthStream,
                builder: (context, growthSnapshot) {
                  final growthData = growthSnapshot.data;
                  final status = growthData?['status'] ?? "STABLE";
                  final growthValue = growthData?['value'] ?? "0%";

                  // Xác định màu badge theo trạng thái
                  Color badgeColor = const Color(0xFFF1F5F9);
                  Color badgeTextColor = const Color(0xFF475569);

                  if (status == "PEAK") {
                    badgeColor = const Color(0xFFE8F5E9);
                    badgeTextColor = const Color(0xFF2E7D32);
                  } else if (status == "DROPPING") {
                    badgeColor = Colors.red.withValues(alpha: 0.1);
                    badgeTextColor = Colors.red;
                  }

                  String displayStatus = "ỔN ĐỊNH";
                  if (status == "PEAK") {
                    displayStatus = "TĂNG TRƯỞNG";
                  } else if (status == "DROPPING") {
                    displayStatus = "GIẢM SÚT";
                  } else if (status == "STABLE") {
                    displayStatus = growthValue;
                  }

                  return _statCard(
                    title: "TỔNG HỘI VIÊN",
                    value: numberFormat.format(count),
                    icon: Icons.people_alt_outlined,
                    iconColor: const Color(0xFF1A237E),
                    iconBgColor: const Color(0xFFF0F2FA),
                    badgeText: displayStatus,
                    badgeColor: badgeColor,
                    badgeTextColor: badgeTextColor,
                    progress: (count / 5000).clamp(0.0, 1.0),
                    isDark: false,
                  );
                },
              );
            },
          ),
        ),
        const SizedBox(width: 24),

        // Card 2: ACTIVE STAFF
        Expanded(
          child: StreamBuilder<int>(
            stream: controller.activeStaffCountStream,
            builder: (context, activeSnapshot) {
              final activeCount = activeSnapshot.data ?? 0;
              return StreamBuilder<int>(
                stream: controller.totalStaffStream,
                builder: (context, totalSnapshot) {
                  final totalStaff = totalSnapshot.data ?? 0;

                  return _statCard(
                    title: "NHÂN VIÊN HOẠT ĐỘNG",
                    value: "$activeCount/$totalStaff",
                    icon: Icons.badge_outlined,
                    iconColor: const Color(0xFFE65100),
                    iconBgColor: const Color(0xFFFFF3E0),
                    badgeText: "ỔN ĐỊNH",
                    badgeColor: const Color(0xFFF1F5F9),
                    badgeTextColor: const Color(0xFF475569),
                    isStaffCard: true,
                    count: activeCount,
                    total: totalStaff > 0 ? totalStaff : 1,
                    isDark: false,
                  );
                },
              );
            },
          ),
        ),
        const SizedBox(width: 24),

        // Card 3: TODAY'S REVENUE
        Expanded(
          child: StreamBuilder<double>(
            stream: controller.todayRevenueStream,
            builder: (context, snapshot) {
              final revenue = snapshot.data ?? 0.0;
              return StreamBuilder<Map<String, dynamic>>(
                stream: controller.revenueStatusStream,
                builder: (context, statusSnapshot) {
                  final statusData = statusSnapshot.data;
                  final status = statusData?['status'] ?? "STABLE";
                  final subtitle = statusData?['message'] ?? "Đang cập nhật...";

                  // Dịch subtitle tài chính sang tiếng việt
                  String displaySubtitle = subtitle;
                  if (subtitle == "No change") {
                    displaySubtitle = "Không thay đổi";
                  } else if (subtitle == "New sales today") {
                    displaySubtitle = "Có giao dịch mới hôm nay";
                  } else if (subtitle == "Stable since yesterday") {
                    displaySubtitle = "Ổn định từ hôm qua";
                  } else if (subtitle == "Updating...") {
                    displaySubtitle = "Đang cập nhật...";
                  } else if (subtitle.contains("higher than yesterday")) {
                    final percent = subtitle.split("%")[0];
                    displaySubtitle = "$percent% cao hơn hôm qua";
                  } else if (subtitle.contains("lower than yesterday")) {
                    final percent = subtitle.split("%")[0];
                    displaySubtitle = "$percent% thấp hơn hôm qua";
                  }

                  // Màu sắc cho Card tối (Dark Mode)
                  Color badgeColor = const Color(0xFFF1F5F9).withValues(alpha: 0.1);
                  Color badgeTextColor = Colors.white70;

                  if (status == "PEAK") {
                    badgeColor = const Color(0xFFFF6B35);
                    badgeTextColor = Colors.white;
                  } else if (status == "DROPPING") {
                    badgeColor = Colors.red;
                    badgeTextColor = Colors.white;
                  }

                  String displayRevenueStatus = "ỔN ĐỊNH";
                  if (status == "PEAK") {
                    displayRevenueStatus = "TĂNG TRƯỞNG";
                  } else if (status == "DROPPING") {
                    displayRevenueStatus = "GIẢM SÚT";
                  }

                  return _statCard(
                    title: "DOANH THU HÔM NAY",
                    value: currencyFormat.format(revenue),
                    icon: Icons.payments_outlined,
                    iconColor: Colors.white,
                    iconBgColor: Colors.white.withValues(alpha: 0.1),
                    badgeText: displayRevenueStatus,
                    badgeColor: badgeColor,
                    badgeTextColor: badgeTextColor,
                    subtitle: displaySubtitle,
                    isDark: true,
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _statCard({
    required String title,
    required String value,
    required IconData icon,
    required Color iconColor,
    required Color iconBgColor,
    required String badgeText,
    required Color badgeColor,
    required Color badgeTextColor,
    double? progress,
    String? subtitle,
    bool isDark = false,
    bool isStaffCard = false,
    int? count,
    int? total,
  }) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0A192F) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 24,
            offset: const Offset(0, 8),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: iconBgColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: iconColor, size: 22),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: badgeColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  badgeText,
                  style: TextStyle(
                    color: badgeTextColor,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            title,
            style: TextStyle(
              color: isDark ? Colors.grey[400] : Colors.grey[500],
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              color: isDark ? Colors.white : const Color(0xFF0A192F),
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          if (isStaffCard && count != null && total != null)
            Row(
              children: List.generate(4, (index) {
                final threshold = (index + 1) * (total / 4);
                final isActive = count >= threshold || (index == 0 && count > 0);
                return Expanded(
                  child: Container(
                    height: 4,
                    margin: EdgeInsets.only(right: index == 3 ? 0 : 6),
                    decoration: BoxDecoration(
                      color: isActive ? const Color(0xFFFF6B35) : Colors.grey[100],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                );
              }),
            )
          else if (progress != null)
            Stack(
              children: [
                Container(
                  height: 4,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                LayoutBuilder(
                  builder: (context, constraints) => Container(
                    height: 4,
                    width: constraints.maxWidth * progress,
                    decoration: BoxDecoration(
                      color: const Color(0xFF0A192F),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
              ],
            )
          else if (subtitle != null)
            Text(
              subtitle,
              style: const TextStyle(
                color: Color(0xFFFF6B35),
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
        ],
      ),
    );
  }
}
