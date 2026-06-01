import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../controllers/feedback_controller.dart';
import '../../controllers/customer_controller.dart';
import '../../data/models/member_model.dart';
import '../../data/models/feedback_model.dart';

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
  String _filterStatus = 'all'; // 'all', 'pending', 'resolved'

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

  @override
  Widget build(BuildContext context) {
    final feedbackController = Provider.of<FeedbackController>(context);
    final customerController = Provider.of<CustomerController>(context);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text(
          "HỖ TRỢ KHÁCH HÀNG",
          style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1),
        ),
        backgroundColor: const Color(0xFF1C1C1E),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: SafeArea(
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 900),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Ticket Submission Form
                Expanded(
                  flex: 3,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Container(
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

                            // Priority dropdown and message
                            Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
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
                                    ],
                                  ),
                                ),
                              ],
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

                // Active Tickets Feed
                Expanded(
                  flex: 2,
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Color(0xFF1C1C1E),
                      border: Border(left: BorderSide(color: Colors.white10)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Padding(
                          padding: EdgeInsets.all(20),
                          child: Text(
                            "NHẬT KÝ SỰ CỐ ĐÃ GỬI",
                            style: TextStyle(color: Colors.grey, fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 1),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Row(
                            children: [
                              _buildStatusFilterChip("Tất cả", "all"),
                              const SizedBox(width: 8),
                              _buildStatusFilterChip("Chưa xử lý", "pending"),
                            ],
                          ),
                        ),
                        const SizedBox(height: 15),
                        Expanded(
                          child: ListView.separated(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            itemCount: feedbackController.feedbacks.length,
                            separatorBuilder: (context, index) => const Divider(color: Colors.white10, height: 1),
                            itemBuilder: (context, index) {
                              final fb = feedbackController.feedbacks[index];
                              
                              if (_filterStatus == 'pending' && fb.status != 'pending') {
                                return const SizedBox.shrink();
                              }

                              final dateStr = DateFormat('HH:mm - dd/MM').format(fb.createdAt);
                              final isPending = fb.status == 'pending';

                              return Padding(
                                padding: const EdgeInsets.symmetric(vertical: 8.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          fb.userName,
                                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                                        ),
                                        Text(dateStr, style: const TextStyle(color: Colors.grey, fontSize: 10)),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      "Tiêu đề: ${fb.subject}",
                                      style: const TextStyle(color: Color(0xFFFF6B35), fontSize: 11, fontWeight: FontWeight.bold),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      fb.message,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(color: Colors.grey, fontSize: 11),
                                    ),
                                    const SizedBox(height: 6),
                                    Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: isPending ? Colors.orange.withValues(alpha: 0.1) : Colors.green.withValues(alpha: 0.1),
                                            borderRadius: BorderRadius.circular(4),
                                          ),
                                          child: Text(
                                            isPending ? "Đang chờ xử lý" : "Đã giải quyết",
                                            style: TextStyle(color: isPending ? Colors.orangeAccent : Colors.greenAccent, fontSize: 9, fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                      ],
                                    )
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusFilterChip(String label, String value) {
    bool isSelected = _filterStatus == value;
    return GestureDetector(
      onTap: () {
        setState(() {
          _filterStatus = value;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFFF6B35) : Colors.black,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: isSelected ? Colors.transparent : Colors.white10),
        ),
        child: Text(
          label,
          style: TextStyle(color: isSelected ? Colors.white : Colors.grey, fontSize: 10, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
