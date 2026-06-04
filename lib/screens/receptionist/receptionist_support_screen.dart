import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../controllers/feedback_controller.dart';
import '../../controllers/customer_controller.dart';
import '../../data/models/member_model.dart';
import '../../data/models/feedback_model.dart';
import 'package:go_router/go_router.dart';
import '../../app/route/routes.dart';

class ReceptionistSupportScreen extends StatefulWidget {
  const ReceptionistSupportScreen({super.key});

  @override
  State<ReceptionistSupportScreen> createState() => _ReceptionistSupportScreenState();
}

class _ReceptionistSupportScreenState extends State<ReceptionistSupportScreen> {
  final _formKey = GlobalKey<FormState>();
  String _subject = '';
  String _message = '';
  String _priority = 'Normal'; // 'Normal', 'High', 'Urgent'
  MemberModel? _selectedMember;
  String _searchQuery = '';

  void _submitIncident(BuildContext context) async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      final feedbackController = Provider.of<FeedbackController>(context, listen: false);

      String userId = _selectedMember?.id ?? 'GUEST';
      String userName = _selectedMember?.fullName ?? 'Khách vãng lai';

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator(color: Color(0xFFFF6B35))),
      );

      try {
        await feedbackController.createFeedback(
          userId: userId,
          userName: "$userName [Độ ưu tiên: $_priority]",
          subject: _subject,
          message: _message,
        );

        if (!mounted) return;
        Navigator.pop(context); // Close loading indicator

        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: const Color(0xFF1C1C1E),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: const BorderSide(color: Colors.white10)),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.verified_outlined, color: Colors.greenAccent, size: 60),
                const SizedBox(height: 16),
                const Text(
                  "ĐÃ GỬI BÁO CÁO",
                  style: TextStyle(color: Colors.greenAccent, fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                const Text(
                  "Sự cố đã được ghi nhận thành công và gửi lên cấp quản lý xử lý.",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white, fontSize: 13),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      setState(() {
                        _selectedMember = null;
                        _subject = '';
                        _message = '';
                        _priority = 'Normal';
                        _searchQuery = '';
                      });
                      _formKey.currentState!.reset();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF6B35),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text("XÁC NHẬN", style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                )
              ],
            ),
          ),
        );
      } catch (e) {
        if (!mounted) return;
        Navigator.pop(context); // Close loading
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Lỗi gửi phản hồi: $e"), backgroundColor: Colors.redAccent),
        );
      }
    }
  }

  void _openIncidentLog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return const _IncidentLogSheet();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final feedbackController = Provider.of<FeedbackController>(context);
    final customerController = Provider.of<CustomerController>(context);
    final pendingCount = feedbackController.feedbacks.where((fb) => fb.status == 'pending').length;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        leadingWidth: 100,
        leading: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => context.go(Routes.receptionistDashboard),
            ),
            IconButton(
              tooltip: "Nhật ký sự cố",
              onPressed: () => _openIncidentLog(context),
              icon: Badge(
                isLabelVisible: pendingCount > 0,
                label: Text(
                  pendingCount.toString(),
                  style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                ),
                backgroundColor: const Color(0xFFFF6B35),
                child: const Icon(Icons.assignment, color: Colors.white, size: 24),
              ),
            ),
          ],
        ),
        title: const Text(
          "HỖ TRỢ KHÁCH HÀNG",
          style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1),
        ),
        backgroundColor: const Color(0xFF1C1C1E),
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Center(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 600),
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFF1C1C1E),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white10),
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "GHI NHẬN SỰ CỐ / Ý KIẾN MỚI",
                      style: TextStyle(color: Color(0xFFFF6B35), fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 20),

                    // Customer autocomplete search
                    const Text("Thành viên gặp sự cố (Tùy chọn)", style: TextStyle(color: Colors.grey, fontSize: 11)),
                    const SizedBox(height: 8),
                    _selectedMember == null
                        ? TextField(
                            style: const TextStyle(color: Colors.white, fontSize: 13),
                            onChanged: (val) {
                              setState(() {
                                _searchQuery = val.toLowerCase();
                              });
                            },
                            decoration: InputDecoration(
                              hintText: "Nhập tên hoặc số điện thoại...",
                              hintStyle: const TextStyle(color: Colors.grey),
                              prefixIcon: const Icon(Icons.person_search, color: Colors.grey, size: 20),
                              filled: true,
                              fillColor: Colors.black,
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                              contentPadding: const EdgeInsets.symmetric(vertical: 8),
                            ),
                          )
                        : Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.black,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: const Color(0xFFFF6B35)),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.person, color: Color(0xFFFF6B35), size: 20),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    _selectedMember!.fullName,
                                    style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.cancel, color: Colors.grey, size: 18),
                                  onPressed: () => setState(() => _selectedMember = null),
                                ),
                              ],
                            ),
                          ),

                    // Suggestion lookup dropdown
                    if (_selectedMember == null && _searchQuery.isNotEmpty)
                      Container(
                        constraints: const BoxConstraints(maxHeight: 150),
                        margin: const EdgeInsets.only(top: 8),
                        decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.white10),
                        ),
                        child: ListView(
                          shrinkWrap: true,
                          children: customerController.allMembers.where((m) {
                            return m.fullName.toLowerCase().contains(_searchQuery) ||
                                (m.phoneNumber ?? '').contains(_searchQuery);
                          }).map((m) {
                            return ListTile(
                              dense: true,
                              title: Text(m.fullName, style: const TextStyle(color: Colors.white)),
                              onTap: () {
                                setState(() {
                                  _selectedMember = m;
                                  _searchQuery = '';
                                });
                              },
                            );
                          }).toList(),
                        ),
                      ),
                    const SizedBox(height: 16),

                    // Subject field
                    const Text("Tiêu đề báo cáo", style: TextStyle(color: Colors.grey, fontSize: 11)),
                    const SizedBox(height: 8),
                    TextFormField(
                      style: const TextStyle(color: Colors.white, fontSize: 13),
                      decoration: InputDecoration(
                        hintText: "Ví dụ: Máy chạy bộ hỏng điện, Mất nước...",
                        hintStyle: const TextStyle(color: Colors.grey),
                        filled: true,
                        fillColor: Colors.black,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                      validator: (val) => (val == null || val.isEmpty) ? "Vui lòng nhập tiêu đề sự cố" : null,
                      onSaved: (val) => _subject = val ?? '',
                    ),
                    const SizedBox(height: 16),

                    // Priority dropdown
                    const Text("Mức độ ưu tiên", style: TextStyle(color: Colors.grey, fontSize: 11)),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      dropdownColor: const Color(0xFF1C1C1E),
                      value: _priority,
                      style: const TextStyle(color: Colors.white, fontSize: 13),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.black,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                      ),
                      items: const [
                        DropdownMenuItem(value: 'Normal', child: Text("Bình thường")),
                        DropdownMenuItem(value: 'High', child: Text("Ưu tiên cao")),
                        DropdownMenuItem(value: 'Urgent', child: Text("Khẩn cấp")),
                      ],
                      onChanged: (val) {
                        setState(() {
                          _priority = val ?? 'Normal';
                        });
                      },
                    ),
                    const SizedBox(height: 16),

                    // Message details
                    const Text("Nội dung chi tiết sự cố", style: TextStyle(color: Colors.grey, fontSize: 11)),
                    const SizedBox(height: 8),
                    TextFormField(
                      style: const TextStyle(color: Colors.white, fontSize: 13),
                      maxLines: 4,
                      decoration: InputDecoration(
                        hintText: "Mô tả cụ thể sự cố vật lý hoặc ý kiến phản ánh từ khách hàng...",
                        hintStyle: const TextStyle(color: Colors.grey),
                        filled: true,
                        fillColor: Colors.black,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                        contentPadding: const EdgeInsets.all(16),
                      ),
                      validator: (val) => (val == null || val.isEmpty) ? "Vui lòng nhập nội dung chi tiết" : null,
                      onSaved: (val) => _message = val ?? '',
                    ),
                    const SizedBox(height: 24),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => _submitIncident(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFF6B35),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: const Text("GỬI BÁO CÁO LÊN BAN QUẢN LÝ", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, letterSpacing: 0.5)),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Incident Log Bottom Sheet (stateful for its own filter) ────────────────
class _IncidentLogSheet extends StatefulWidget {
  const _IncidentLogSheet();

  @override
  State<_IncidentLogSheet> createState() => _IncidentLogSheetState();
}

class _IncidentLogSheetState extends State<_IncidentLogSheet> {
  String _filterStatus = 'all';

  @override
  Widget build(BuildContext context) {
    final feedbackController = Provider.of<FeedbackController>(context);
    final allFeedbacks = feedbackController.feedbacks;

    final filteredFeedbacks = _filterStatus == 'all'
        ? allFeedbacks
        : allFeedbacks.where((fb) => fb.status == 'pending').toList();

    final pendingCount = allFeedbacks.where((fb) => fb.status == 'pending').length;

    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.4,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Color(0xFF1C1C1E),
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              // Drag handle
              Padding(
                padding: const EdgeInsets.only(top: 12, bottom: 8),
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              // Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Row(
                  children: [
                    const Icon(Icons.assignment, color: Color(0xFFFF6B35), size: 22),
                    const SizedBox(width: 10),
                    const Text(
                      "NHẬT KÝ SỰ CỐ ĐÃ GỬI",
                      style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                    ),
                    const Spacer(),
                    if (pendingCount > 0)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFF6B35).withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          "$pendingCount chờ xử lý",
                          style: const TextStyle(color: Color(0xFFFF6B35), fontSize: 11, fontWeight: FontWeight.bold),
                        ),
                      ),
                  ],
                ),
              ),

              // Filter chips
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Row(
                  children: [
                    _buildFilterChip("Tất cả", "all"),
                    const SizedBox(width: 8),
                    _buildFilterChip("Chưa xử lý", "pending"),
                  ],
                ),
              ),

              const Divider(color: Colors.white10, height: 1),

              // Feedback list
              Expanded(
                child: filteredFeedbacks.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.inbox_outlined, color: Colors.white24, size: 48),
                            const SizedBox(height: 12),
                            Text(
                              _filterStatus == 'pending' ? "Không có sự cố nào đang chờ xử lý" : "Chưa có nhật ký sự cố nào",
                              style: const TextStyle(color: Colors.grey, fontSize: 13),
                            ),
                          ],
                        ),
                      )
                    : ListView.separated(
                        controller: scrollController,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        itemCount: filteredFeedbacks.length,
                        separatorBuilder: (context, index) => const Divider(color: Colors.white10, height: 24),
                        itemBuilder: (context, index) {
                          final fb = filteredFeedbacks[index];
                          final dateStr = DateFormat('HH:mm - dd/MM/yyyy').format(fb.createdAt);
                          final isPending = fb.status == 'pending';

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      fb.userName,
                                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(dateStr, style: const TextStyle(color: Colors.grey, fontSize: 10)),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Text(
                                "Tiêu đề: ${fb.subject}",
                                style: const TextStyle(color: Color(0xFFFF6B35), fontSize: 12, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                fb.message,
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(color: Colors.grey, fontSize: 12),
                              ),
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: isPending ? Colors.orange.withValues(alpha: 0.1) : Colors.green.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  isPending ? "Đang chờ xử lý" : "Đã giải quyết",
                                  style: TextStyle(
                                    color: isPending ? Colors.orangeAccent : Colors.greenAccent,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFilterChip(String label, String value) {
    bool isSelected = _filterStatus == value;
    return GestureDetector(
      onTap: () {
        setState(() {
          _filterStatus = value;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFFF6B35) : Colors.black,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: isSelected ? Colors.transparent : Colors.white10),
        ),
        child: Text(
          label,
          style: TextStyle(color: isSelected ? Colors.white : Colors.grey, fontSize: 11, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
