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
  String _filterStatus = 'all'; // 'all', 'pending', 'replied', 'resolved'
  final _replyController = TextEditingController();

  @override
  void dispose() {
    _replyController.dispose();
    super.dispose();
  }

  void _submitIncident(BuildContext context) async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      final feedbackController = Provider.of<FeedbackController>(context, listen: false);
      final navigator = Navigator.of(context);

      String userId = _selectedMember?.id ?? 'GUEST';
      String userName = _selectedMember?.fullName ?? 'Khách vãng lai';

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (dialogCtx) => const Center(child: CircularProgressIndicator(color: Color(0xFFFF6B35))),
      );

      try {
        await feedbackController.createFeedback(
          userId: userId,
          userName: "$userName [Độ ưu tiên: $_priority]",
          subject: _subject,
          message: _message,
        );

        if (!context.mounted) return;
        navigator.pop(); // Close loading indicator

        showDialog(
          context: context,
          builder: (dialogCtx) => AlertDialog(
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
                  "Sự cố đã được ghi nhận thành công và gửi lên hệ thống.",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white, fontSize: 13),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(dialogCtx).pop();
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
                    child: const Text("XÁC NHẬN", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                  ),
                )
              ],
            ),
          ),
        );
      } catch (e) {
        if (!context.mounted) return;
        navigator.pop(); // Close loading
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Lỗi gửi phản hồi: $e"), backgroundColor: Colors.redAccent),
        );
      }
    }
  }

  void _showReplyDialog(FeedbackModel fb, FeedbackController controller) {
    _replyController.clear();
    if (fb.adminReply != null) {
      _replyController.text = fb.adminReply!;
    }
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        backgroundColor: const Color(0xFF1C1C1E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: const BorderSide(color: Colors.white10)),
        title: Text(
          "Trả lời phản hồi: ${fb.userName.split(' [').first}",
          style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Nội dung: ${fb.message}",
              style: const TextStyle(color: Colors.white70, fontSize: 13),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _replyController,
              maxLines: 4,
              style: const TextStyle(color: Colors.white, fontSize: 13),
              decoration: InputDecoration(
                hintText: "Nhập nội dung phản hồi từ lễ tân...",
                hintStyle: const TextStyle(color: Colors.grey),
                filled: true,
                fillColor: Colors.black,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                contentPadding: const EdgeInsets.all(12),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: const Text("Hủy", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () async {
              if (_replyController.text.isNotEmpty) {
                await controller.replyFeedback(fb.id, _replyController.text);
                if (context.mounted) {
                  Navigator.pop(dialogCtx);
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF6B35),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text("Gửi phản hồi", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final feedbackController = Provider.of<FeedbackController>(context);
    final customerController = Provider.of<CustomerController>(context);
    final pendingCount = feedbackController.feedbacks.where((fb) => fb.status == 'pending').length;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => context.go(Routes.receptionistDashboard),
          ),
          title: const Text(
            "HỖ TRỢ KHÁCH HÀNG",
            style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1),
          ),
          backgroundColor: const Color(0xFF1C1C1E),
          elevation: 0,
          bottom: TabBar(
            indicatorColor: const Color(0xFFFF6B35),
            labelColor: const Color(0xFFFF6B35),
            unselectedLabelColor: Colors.white60,
            indicatorSize: TabBarIndicatorSize.tab,
            tabs: [
              const Tab(
                icon: Icon(Icons.edit_note),
                text: "Ghi nhận sự cố",
              ),
              Tab(
                icon: Badge(
                  isLabelVisible: pendingCount > 0,
                  label: Text(
                    pendingCount.toString(),
                    style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                  backgroundColor: const Color(0xFFFF6B35),
                  child: const Icon(Icons.mail_outline),
                ),
                text: "Ý kiến & Phản hồi",
              ),
            ],
          ),
        ),
        body: SafeArea(
          child: TabBarView(
            children: [
              // TAB 1: GHI NHẬN SỰ CỐ
              SingleChildScrollView(
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
                            initialValue: _priority,
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
                              child: const Text("GỬI BÁO CÁO LÊN BAN QUẢN LÝ", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, letterSpacing: 0.5, color: Colors.white)),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // TAB 2: DANH SÁCH Ý KIẾN & PHẢN HỒI
              Column(
                children: [
                  // Filter Chips
                  Padding(
                    padding: const EdgeInsets.only(top: 16, bottom: 8, left: 16, right: 16),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _buildFilterChip("Tất cả", "all"),
                          const SizedBox(width: 8),
                          _buildFilterChip("Chưa xử lý", "pending"),
                          const SizedBox(width: 8),
                          _buildFilterChip("Đã trả lời", "replied"),
                          const SizedBox(width: 8),
                          _buildFilterChip("Đã giải quyết", "resolved"),
                        ],
                      ),
                    ),
                  ),
                  const Divider(color: Colors.white10),
                  
                  // Feedbacks List
                  Expanded(
                    child: _buildFeedbackList(context, feedbackController),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
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
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFFF6B35) : const Color(0xFF1C1C1E),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isSelected ? Colors.transparent : Colors.white10),
        ),
        child: Text(
          label,
          style: TextStyle(color: isSelected ? Colors.white : Colors.grey, fontSize: 11, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildFeedbackList(BuildContext context, FeedbackController controller) {
    final allFeedbacks = controller.feedbacks;
    final filteredFeedbacks = _filterStatus == 'all'
        ? allFeedbacks
        : allFeedbacks.where((fb) => fb.status == _filterStatus).toList();

    if (filteredFeedbacks.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.inbox_outlined, color: Colors.white24, size: 48),
            const SizedBox(height: 12),
            Text(
              _filterStatus == 'all' ? "Chưa có phản hồi nào" : "Không có phản hồi nào ở trạng thái này",
              style: const TextStyle(color: Colors.grey, fontSize: 13),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      itemCount: filteredFeedbacks.length,
      separatorBuilder: (context, index) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        final fb = filteredFeedbacks[index];
        final dateStr = DateFormat('HH:mm - dd/MM/yyyy').format(fb.createdAt);
        final isPending = fb.status == 'pending';
        final isReplied = fb.status == 'replied';

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF1C1C1E),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white10),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 14,
                          backgroundColor: Colors.white12,
                          child: Text(
                            fb.userName.isNotEmpty ? fb.userName[0].toUpperCase() : '?',
                            style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            fb.userName,
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(dateStr, style: const TextStyle(color: Colors.grey, fontSize: 10)),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                "Tiêu đề: ${fb.subject}",
                style: const TextStyle(color: Color(0xFFFF6B35), fontSize: 14, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              Text(
                fb.message,
                style: const TextStyle(color: Colors.white70, fontSize: 13, height: 1.4),
              ),
              
              // Show Admin/Receptionist Reply if it exists
              if (fb.adminReply != null) ...[
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.white10),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Đã phản hồi:",
                        style: TextStyle(color: Color(0xFFFF6B35), fontSize: 11, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        fb.adminReply!,
                        style: const TextStyle(color: Colors.white, fontSize: 12, fontStyle: FontStyle.italic),
                      ),
                    ],
                  ),
                ),
              ],
              
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Status badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: isPending
                          ? Colors.orange.withValues(alpha: 0.1)
                          : isReplied
                              ? Colors.blue.withValues(alpha: 0.1)
                              : Colors.green.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      isPending
                          ? "Chờ xử lý"
                          : isReplied
                              ? "Đã trả lời"
                              : "Đã giải quyết",
                      style: TextStyle(
                        color: isPending
                            ? Colors.orangeAccent
                            : isReplied
                                ? Colors.blueAccent
                                : Colors.greenAccent,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  
                  // Actions row
                  Row(
                    children: [
                      if (fb.status != 'resolved') ...[
                        TextButton.icon(
                          onPressed: () => _showReplyDialog(fb, controller),
                          icon: const Icon(Icons.reply, size: 16, color: Color(0xFFFF6B35)),
                          label: const Text(
                            "Trả lời",
                            style: TextStyle(color: Color(0xFFFF6B35), fontSize: 12, fontWeight: FontWeight.bold),
                          ),
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                        ),
                        const SizedBox(width: 12),
                        TextButton.icon(
                          onPressed: () => controller.resolveFeedback(fb.id),
                          icon: const Icon(Icons.check_circle_outline, size: 16, color: Colors.greenAccent),
                          label: const Text(
                            "Giải quyết",
                            style: TextStyle(color: Colors.greenAccent, fontSize: 12, fontWeight: FontWeight.bold),
                          ),
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                        ),
                        const SizedBox(width: 8),
                      ],
                      IconButton(
                        icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 18),
                        onPressed: () => controller.deleteFeedback(fb.id),
                        constraints: const BoxConstraints(),
                        padding: const EdgeInsets.all(4),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
