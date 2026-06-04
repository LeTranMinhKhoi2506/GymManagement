import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../controllers/feedback_controller.dart';
import '../../../data/models/feedback_model.dart';
import '../../../common/widgets/admin_dashboard_widgets/sidebar_widget.dart';
import '../../../common/widgets/admin_dashboard_widgets/header_widget.dart';

class FeedbackManagementScreen extends StatefulWidget {
  const FeedbackManagementScreen({super.key});

  @override
  State<FeedbackManagementScreen> createState() => _FeedbackManagementScreenState();
}

class _FeedbackManagementScreenState extends State<FeedbackManagementScreen> {
  final _replyController = TextEditingController();

  @override
  void dispose() {
    _replyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final feedbackController = Provider.of<FeedbackController>(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: Row(
        children: [
          const SidebarWidget(),
          Expanded(
            child: Column(
              children: [
                const HeaderWidget(),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(32.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildHeader(),
                        const SizedBox(height: 32),
                        _buildFeedbackList(feedbackController),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Quản lý phản hồi & Khiếu nại",
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF0A192F)),
        ),
        Text("Lắng nghe và giải quyết các vấn đề của hội viên",
            style: TextStyle(color: Colors.grey)),
      ],
    );
  }

  Widget _buildFeedbackList(FeedbackController controller) {
    if (controller.feedbacks.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(100.0),
          child: Text("Hiện chưa có phản hồi nào từ hội viên."),
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: controller.feedbacks.length,
      separatorBuilder: (context, index) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        final fb = controller.feedbacks[index];
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: _getStatusColor(fb.status).withValues(alpha: 0.2)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      CircleAvatar(child: Text(fb.userName[0])),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(fb.userName, style: const TextStyle(fontWeight: FontWeight.bold)),
                          Text(DateFormat('dd/MM/yyyy HH:mm').format(fb.createdAt), style: TextStyle(fontSize: 12, color: Colors.grey[500])),
                        ],
                      ),
                    ],
                  ),
                  _buildStatusBadge(fb.status),
                ],
              ),
              const SizedBox(height: 16),
              Text(fb.subject, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text(fb.message, style: const TextStyle(color: Color(0xFF4A5568))),
              if (fb.adminReply != null) ...[
                const SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: Colors.blueGrey[50], borderRadius: BorderRadius.circular(12)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Phản hồi từ Admin:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.blueGrey)),
                      const SizedBox(height: 4),
                      Text(fb.adminReply!),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (fb.status == 'pending')
                    TextButton.icon(
                      onPressed: () => _showReplyDialog(fb, controller),
                      icon: const Icon(Icons.reply),
                      label: const Text("Trả lời"),
                    ),
                  if (fb.status != 'resolved')
                    TextButton.icon(
                      onPressed: () => controller.resolveFeedback(fb.id),
                      icon: const Icon(Icons.check_circle_outline),
                      label: const Text("Đánh dấu hoàn thành"),
                      style: TextButton.styleFrom(foregroundColor: Colors.green),
                    ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                    onPressed: () => controller.deleteFeedback(fb.id),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  void _showReplyDialog(FeedbackModel fb, FeedbackController controller) {
    _replyController.clear();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Trả lời phản hồi: ${fb.userName}"),
        content: TextField(
          controller: _replyController,
          maxLines: 4,
          decoration: const InputDecoration(hintText: "Nhập nội dung trả lời...", border: OutlineInputBorder()),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Hủy")),
          ElevatedButton(
            onPressed: () async {
              if (_replyController.text.isNotEmpty) {
                await controller.replyFeedback(fb.id, _replyController.text);
                if (mounted) Navigator.pop(context);
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFF6B35), foregroundColor: Colors.white),
            child: const Text("Gửi phản hồi"),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color = _getStatusColor(status);
    String text = status == 'pending' ? 'ĐANG CHỜ' : (status == 'replied' ? 'ĐÃ TRẢ LỜI' : 'ĐÃ GIẢI QUYẾT');
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(20)),
      child: Text(text, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold)),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'replied': return Colors.blue;
      case 'resolved': return Colors.green;
      default: return Colors.orange;
    }
  }
}
