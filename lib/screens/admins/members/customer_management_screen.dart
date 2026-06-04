import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../controllers/customer_controller.dart';
import '../../../data/models/member_model.dart';
import '../../../common/widgets/admin_dashboard_widgets/sidebar_widget.dart';
import '../../../common/widgets/admin_dashboard_widgets/header_widget.dart';

class CustomerManagementScreen extends StatefulWidget {
  const CustomerManagementScreen({super.key});

  @override
  State<CustomerManagementScreen> createState() => _CustomerManagementScreenState();
}

class _CustomerManagementScreenState extends State<CustomerManagementScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<CustomerController>(context);

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
                        _buildPageHeader(context, controller),
                        const SizedBox(height: 32),
                        const _CustomerContentLayout(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddMemberDialog(context),
        backgroundColor: const Color(0xFFFF6B35),
        child: const Icon(Icons.person_add, color: Colors.white),
      ),
    );
  }

  Widget _buildPageHeader(BuildContext context, CustomerController controller) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('QUẢN LÝ THÀNH VIÊN', style: TextStyle(color: Color(0xFFFF6B35), fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 2)),
            Text('Danh sách Hội viên', style: TextStyle(color: Color(0xFF0A192F), fontSize: 32, fontWeight: FontWeight.w900)),
          ],
        ),
        Row(
          children: [
            SizedBox(
              width: 300,
              child: TextField(
                controller: _searchController,
                onChanged: (val) => controller.setSearchQuery(val),
                decoration: InputDecoration(
                  hintText: 'Tìm theo tên, email...',
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                ),
              ),
            ),
            const SizedBox(width: 16),
            _buildFilterTabs(controller),
          ],
        ),
      ],
    );
  }

  Widget _buildFilterTabs(CustomerController controller) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: ['All', 'Active', 'Banned'].map((status) {
          final isSelected = controller.filterStatus == status;
          return GestureDetector(
            onTap: () => controller.setFilter(status),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? Colors.white : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                status == 'All' ? 'Tất cả' : (status == 'Banned' ? 'Bị khóa' : 'Hoạt động'),
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: isSelected ? const Color(0xFF0A192F) : Colors.grey),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  void _showAddMemberDialog(BuildContext context) {
    // Implement Add Member Dialog logic
  }
}

class _CustomerContentLayout extends StatelessWidget {
  const _CustomerContentLayout();

  @override
  Widget build(BuildContext context) {
    return const Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(flex: 7, child: _MembersGrid()),
        SizedBox(width: 24),
        Expanded(flex: 4, child: _ActivityLogsPanel()),
      ],
    );
  }
}

class _MembersGrid extends StatelessWidget {
  const _MembersGrid();

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<CustomerController>();
    final members = controller.members;

    if (members.isEmpty) {
      return const Center(child: Padding(padding: EdgeInsets.all(50.0), child: Text('Không tìm thấy hội viên nào.')));
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 20,
        mainAxisSpacing: 20,
        mainAxisExtent: 200,
      ),
      itemCount: members.length,
      itemBuilder: (context, index) {
        final member = members[index];
        final isSelected = controller.selectedMember?.id == member.id;
        return _MemberCard(member: member, isSelected: isSelected);
      },
    );
  }
}

class _MemberCard extends StatelessWidget {
  final MemberModel member;
  final bool isSelected;

  const _MemberCard({required this.member, required this.isSelected});

  @override
  Widget build(BuildContext context) {
    final controller = context.read<CustomerController>();
    final isBanned = member.status == 'Banned';

    return GestureDetector(
      onTap: () => controller.selectMember(member),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF0A192F) : (isBanned ? Colors.red.withValues(alpha: 0.05) : Colors.white),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)],
          border: Border.all(color: isSelected ? const Color(0xFFFF6B35) : (isBanned ? Colors.red.withValues(alpha: 0.3) : Colors.transparent), width: 2),
        ),
        child: Column(
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundImage: member.profileImageUrl != null ? NetworkImage(member.profileImageUrl!) : null,
                  child: member.profileImageUrl == null ? const Icon(Icons.person) : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(member.fullName, style: TextStyle(color: isSelected ? Colors.white : const Color(0xFF0A192F), fontWeight: FontWeight.bold, fontSize: 16), maxLines: 1, overflow: TextOverflow.ellipsis),
                      Text(member.email, style: TextStyle(color: isSelected ? Colors.white70 : Colors.grey, fontSize: 12), maxLines: 1),
                    ],
                  ),
                ),
                PopupMenuButton(
                  icon: Icon(Icons.more_vert, color: isSelected ? Colors.white : Colors.grey),
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      child: Text(isBanned ? 'Mở khóa tài khoản' : 'Khóa tài khoản'),
                      onTap: () => controller.toggleUserStatus(member.id, member.status),
                    ),
                    PopupMenuItem(
                      child: const Text('Xóa hội viên', style: TextStyle(color: Colors.red)),
                      onTap: () => controller.deleteMember(member.id),
                    ),
                  ],
                ),
              ],
            ),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildInfoTag(member.membershipType, isSelected ? Colors.orange : Colors.blueGrey),
                _buildInfoTag(member.status, isBanned ? Colors.red : Colors.green),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoTag(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(6)),
      child: Text(text.toUpperCase(), style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold)),
    );
  }
}

class _ActivityLogsPanel extends StatelessWidget {
  const _ActivityLogsPanel();

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<CustomerController>();
    final selectedMember = controller.selectedMember;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('CHI TIẾT HOẠT ĐỘNG', style: TextStyle(color: Colors.grey[600], fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1)),
          const SizedBox(height: 8),
          Text(selectedMember?.fullName ?? 'Chọn một hội viên', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),
          if (controller.isLoadingLogs)
            const Center(child: CircularProgressIndicator())
          else if (controller.selectedMemberLogs.isEmpty)
            const Center(child: Text('Không có nhật ký hoạt động.'))
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: controller.selectedMemberLogs.length,
              itemBuilder: (context, index) {
                final log = controller.selectedMemberLogs[index];
                return ListTile(
                  dense: true,
                  leading: const Icon(Icons.history, size: 18),
                  title: Text(log.title),
                  subtitle: Text(DateFormat('dd/MM/yyyy HH:mm').format(log.timestamp)),
                  trailing: Text(NumberFormat.currency(locale: 'vi_VN', symbol: '₫').format(log.amount), style: const TextStyle(fontWeight: FontWeight.bold)),
                );
              },
            ),
        ],
      ),
    );
  }
}
