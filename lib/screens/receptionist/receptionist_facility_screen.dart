import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:uuid/uuid.dart';
import '../../controllers/equipment_controller.dart';
import '../../controllers/report_controller.dart';
import '../../data/models/equipment_model.dart';
import '../../data/models/report_model.dart';


class ReceptionistFacilityScreen extends StatefulWidget {
  const ReceptionistFacilityScreen({super.key});

  @override
  State<ReceptionistFacilityScreen> createState() => _ReceptionistFacilityScreenState();
}

class _ReceptionistFacilityScreenState extends State<ReceptionistFacilityScreen> {
  String _selectedCategory = 'Tất cả';

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (mounted) {
        Provider.of<EquipmentController>(context, listen: false).fetchAllEquipment();
      }
    });
  }

  void _updateStatus(BuildContext context, EquipmentModel eq, String newStatus) async {
    final controller = Provider.of<EquipmentController>(context, listen: false);
    final updated = eq.copyWith(status: newStatus);

    try {
      await controller.updateEquipment(updated);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Đã cập nhật trạng thái ${eq.name} thành: $newStatus"),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Lỗi cập nhật: $e"), backgroundColor: Colors.redAccent),
      );
    }
  }

  void _saveNotes(BuildContext context, EquipmentModel eq, String notes) async {
    final controller = Provider.of<EquipmentController>(context, listen: false);
    final updated = eq.copyWith(notes: notes);

    try {
      await controller.updateEquipment(updated);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Lỗi lưu ghi chú: $e"), backgroundColor: Colors.redAccent),
      );
    }
  }

  void _showReportDialog(BuildContext context) {
    final eqController = Provider.of<EquipmentController>(context, listen: false);
    final reportController = Provider.of<ReportController>(context, listen: false);
    final user = FirebaseAuth.instance.currentUser;

    final total = eqController.equipment.length;
    final operational = eqController.equipment.where((e) => e.status == 'Operational').length;
    final maintenance = eqController.equipment.where((e) => e.status == 'Needs Maintenance' || e.status == 'Maintenance').length;
    final broken = eqController.equipment.where((e) => e.status == 'Broken').length;

    // Build lists of devices needing maintenance or broken
    final issueList = eqController.equipment.where((e) => e.status != 'Operational').toList();
    
    final StringBuffer issueBuffer = StringBuffer();
    if (issueList.isEmpty) {
      issueBuffer.write("Tất cả thiết bị hoạt động bình thường.");
    } else {
      for (var eq in issueList) {
        final statusVn = (eq.status == 'Broken') ? 'Hỏng hóc' : 'Cần bảo trì';
        issueBuffer.writeln("- ${eq.name} (${eq.location ?? 'Chung'}): $statusVn${eq.notes != null && eq.notes!.isNotEmpty ? ' (Ghi chú: ${eq.notes})' : ''}");
      }
    }

    final dateStr = DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now());
    final defaultReason = """Báo cáo tình trạng thiết bị ngày $dateStr:
- Tổng số thiết bị: $total
- Bình thường: $operational
- Cần bảo trì: $maintenance
- Hỏng hóc: $broken

Chi tiết thiết bị cần chú ý:
${issueBuffer.toString()}""";

    final reasonController = TextEditingController(text: defaultReason);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1C1C1E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          "Báo cáo cơ sở vật chất hôm nay",
          style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
        ),
        content: SizedBox(
          width: 500,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Nội dung báo cáo gửi lên quản trị viên:",
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: reasonController,
                maxLines: 10,
                style: const TextStyle(color: Colors.white, fontSize: 12),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.black,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Colors.white10),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Color(0xFFFF6B35)),
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Hủy", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () async {
              final report = ReportModel(
                id: const Uuid().v4(),
                reporterId: user?.uid ?? 'receptionist',
                reporterName: user?.displayName ?? 'Lễ Tân',
                reportedItemId: 'gym_equipment_daily_check',
                type: 'facility',
                reason: reasonController.text.trim(),
                status: 'pending',
                createdAt: DateTime.now(),
              );

              final messenger = ScaffoldMessenger.of(context);
              final navigator = Navigator.of(ctx);

              try {
                await reportController.createReport(report);
                navigator.pop();
                messenger.showSnackBar(
                  const SnackBar(
                    content: Text("Đã gửi báo cáo cơ sở vật chất thành công!"),
                    backgroundColor: Colors.green,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              } catch (e) {
                messenger.showSnackBar(
                  SnackBar(
                    content: Text("Lỗi gửi báo cáo: $e"),
                    backgroundColor: Colors.redAccent,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF6B35),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text("Gửi báo cáo"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<EquipmentController>(context);

    // Get unique categories for filtering
    final categories = ['Tất cả', ...controller.equipment.map((e) => e.category).toSet().toList()];

    final filteredEquipment = controller.equipment.where((e) {
      return _selectedCategory == 'Tất cả' || e.category == _selectedCategory;
    }).toList();

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text(
          "KIỂM TRA CƠ SỞ VẬT CHẤT",
          style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1),
        ),
        backgroundColor: const Color(0xFF1C1C1E),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showReportDialog(context),
        label: const Text('Báo cáo hôm nay', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        icon: const Icon(Icons.assignment_turned_in, color: Colors.white),
        backgroundColor: const Color(0xFFFF6B35),
      ),
      body: SafeArea(
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 800),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Category Filter Row
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.all(15.0),
                  child: Row(
                    children: categories.map((cat) {
                      bool isSelected = _selectedCategory == cat;
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedCategory = cat;
                          });
                        },
                        child: Container(
                          margin: const EdgeInsets.only(right: 10),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: isSelected ? const Color(0xFFFF6B35) : const Color(0xFF1C1C1E),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: isSelected ? Colors.transparent : Colors.white10),
                          ),
                          child: Text(
                            cat,
                            style: TextStyle(
                              color: isSelected ? Colors.white : Colors.grey,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),

                // Equipment List
                Expanded(
                  child: controller.isLoading
                      ? const Center(child: CircularProgressIndicator(color: Color(0xFFFF6B35)))
                      : filteredEquipment.isEmpty
                          ? const Center(
                              child: Text(
                                "Không tìm thấy thiết bị nào.",
                                style: TextStyle(color: Colors.grey, fontSize: 13),
                              ),
                            )
                          : ListView.separated(
                              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                              itemCount: filteredEquipment.length,
                              separatorBuilder: (context, index) => const SizedBox(height: 15),
                              itemBuilder: (context, index) {
                                final eq = filteredEquipment[index];
                                return _buildEquipmentCheckCard(context, eq);
                              },
                            ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEquipmentCheckCard(BuildContext context, EquipmentModel eq) {
    Color statusColor = Colors.greenAccent;
    String statusText = "Hoạt động tốt";

    if (eq.status == 'Needs Maintenance' || eq.status == 'Maintenance') {
      statusColor = Colors.orangeAccent;
      statusText = "Cần bảo trì";
    } else if (eq.status == 'Broken') {
      statusColor = Colors.redAccent;
      statusText = "Đang hỏng";
    }

    final TextEditingController noteController = TextEditingController(text: eq.notes ?? '');

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1C1C1E),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      eq.name,
                      style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Khu vực: ${eq.location ?? 'Chung'} • Thể loại: ${eq.category}",
                      style: const TextStyle(color: Colors.grey, fontSize: 11),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  statusText,
                  style: TextStyle(color: statusColor, fontSize: 10, fontWeight: FontWeight.bold),
                ),
              )
            ],
          ),
          const SizedBox(height: 16),
          const Divider(color: Colors.white10, height: 1),
          const SizedBox(height: 16),

          // Status toggle buttons
          const Text("CẬP NHẬT TRẠNG THÁI", style: TextStyle(color: Colors.grey, fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
          const SizedBox(height: 8),
          Row(
            children: [
              _buildStatusButton(context, eq, 'Operational', 'Bình thường', Colors.green, eq.status == 'Operational'),
              const SizedBox(width: 8),
              _buildStatusButton(context, eq, 'Needs Maintenance', 'Bảo trì', Colors.orange, eq.status == 'Needs Maintenance' || eq.status == 'Maintenance'),
              const SizedBox(width: 8),
              _buildStatusButton(context, eq, 'Broken', 'Hỏng hóc', Colors.red, eq.status == 'Broken'),
            ],
          ),
          const SizedBox(height: 16),

          // Instant Note Field
          const Text("GHI CHÚ SỰ CỐ / THÔNG TIN", style: TextStyle(color: Colors.grey, fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
          const SizedBox(height: 8),
          TextField(
            controller: noteController,
            style: const TextStyle(color: Colors.white, fontSize: 12),
            onSubmitted: (val) => _saveNotes(context, eq, val.trim()),
            decoration: InputDecoration(
              hintText: "Nhập ghi chú nhanh (ví dụ: bị lỏng cáp)...",
              hintStyle: const TextStyle(color: Colors.grey),
              filled: true,
              fillColor: Colors.black,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              suffixIcon: IconButton(
                icon: const Icon(Icons.check, color: Color(0xFFFF6B35), size: 18),
                onPressed: () => _saveNotes(context, eq, noteController.text.trim()),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildStatusButton(
    BuildContext context,
    EquipmentModel eq,
    String status,
    String label,
    Color activeColor,
    bool isActive,
  ) {
    return Expanded(
      child: GestureDetector(
        onTap: () => _updateStatus(context, eq, status),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isActive ? activeColor.withValues(alpha: 0.2) : Colors.black,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: isActive ? activeColor : Colors.white10),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: isActive ? activeColor : Colors.grey,
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
