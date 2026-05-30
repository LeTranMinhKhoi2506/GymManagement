import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../controllers/customer_controller.dart';
import '../../data/models/member_model.dart';
import '../../common/widgets/admin_dashboard_widgets/sidebar_widget.dart';
import '../../common/widgets/admin_dashboard_widgets/header_widget.dart';

class CustomerManagementScreen extends StatelessWidget {
  const CustomerManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<CustomerController>(context);

    if (controller.errorMessage != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.error_outline, color: Colors.white),
                  const SizedBox(width: 12),
                  Expanded(child: Text("Lỗi thành viên: ${controller.errorMessage!}")),
                ],
              ),
              backgroundColor: Colors.redAccent,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              margin: const EdgeInsets.all(16),
            ),
          );
          controller.clearError();
        }
      });
    }

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
                        _buildPageHeader(context),
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
        onPressed: () {
          // TODO: Open Add Member Dialog
        },
        backgroundColor: const Color(0xFFFF6B35),
        child: const Icon(Icons.person_add, color: Colors.white),
      ),
    );
  }

  Widget _buildPageHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'QUẢN LÝ DANH SÁCH',
              style: TextStyle(
                color: Color(0xFFFF6B35),
                fontSize: 10,
                fontWeight: FontWeight.w900,
                letterSpacing: 2,
              ),
            ),
            Text(
              'Thành viên Gym',
              style: TextStyle(
                color: Color(0xFF0A192F),
                fontSize: 36,
                fontWeight: FontWeight.w900,
                letterSpacing: -1,
              ),
            ),
          ],
        ),
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Consumer<CustomerController>(
            builder: (context, controller, _) {
              return Row(
                children: ['All', 'Active', 'Expired', 'New'].map((status) {
                  final isSelected = controller.filterStatus == status;
                  return GestureDetector(
                    onTap: () => controller.setFilter(status),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.white : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.05),
                                    blurRadius: 4)
                              ]
                            : null,
                      ),
                      child: Text(
                        status == 'All' ? 'Tất cả' : status,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: isSelected ? const Color(0xFF0A192F) : Colors.grey,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _CustomerContentLayout extends StatelessWidget {
  const _CustomerContentLayout();

  @override
  Widget build(BuildContext context) {
    return const Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(flex: 8, child: _MembersGrid()),
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
      return const Center(child: Text('Không tìm thấy thành viên nào'));
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 24,
        mainAxisSpacing: 24,
        mainAxisExtent: 180,
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
    return GestureDetector(
      onTap: () => context.read<CustomerController>().selectMember(member),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF0A192F) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)
          ],
          border: isSelected
              ? const Border(
                  left: BorderSide(color: Color(0xFFFF6B35), width: 4))
              : null,
        ),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    member.profileImageUrl ?? 'https://via.placeholder.com/80',
                    width: 64,
                    height: 64,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                        color: Colors.grey[200],
                        width: 64,
                        height: 64,
                        child: const Icon(Icons.person, color: Colors.grey)),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              member.fullName,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: isSelected
                                    ? Colors.white
                                    : const Color(0xFF0A192F),
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? const Color(0xFFFF6B35)
                                  : const Color(0xFFD2E0FE),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              member.membershipType.toUpperCase(),
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                                color: isSelected
                                    ? Colors.white
                                    : const Color(0xFF515F78),
                              ),
                            ),
                          ),
                        ],
                      ),
                      Text(
                        'Tham gia từ ${member.memberSince != null ? DateFormat('MM/yyyy').format(member.memberSince!) : '---'}',
                        style: TextStyle(
                            color: isSelected ? Colors.white54 : Colors.grey,
                            fontSize: 12),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: member.isCurrentlyTraining
                                  ? const Color(0xFF10B981)
                                  : Colors.grey.shade300,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            member.isCurrentlyTraining
                                ? 'ĐANG TẬP LUYỆN'
                                : 'NGOẠI TUYẾN',
                            style: TextStyle(
                              color: member.isCurrentlyTraining
                                  ? const Color(0xFF10B981)
                                  : Colors.grey,
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Spacer(),
            const Divider(color: Colors.black12, height: 1),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'GIA HẠN KẾ TIẾP: ${member.nextRenewal != null ? DateFormat('dd/MM').format(member.nextRenewal!) : 'N/A'}',
                  style: TextStyle(
                      color: isSelected ? Colors.white54 : Colors.grey,
                      fontSize: 10,
                      fontWeight: FontWeight.bold),
                ),
                if (isSelected)
                  const Text('ĐANG CHỌN',
                      style: TextStyle(
                          color: Color(0xFFFF6B35),
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.5))
                else
                  const Icon(Icons.more_horiz, color: Color(0xFFFF6B35)),
              ],
            ),
          ],
        ),
      ),
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
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: const Color(0xFFE7E8E9),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'NHẬT KÝ HOẠT ĐỘNG',
                style: TextStyle(
                    color: Color(0xFF0A192F),
                    fontSize: 18,
                    fontWeight: FontWeight.w900),
              ),
              Text(
                'LỊCH SỬ: ${selectedMember?.fullName ?? ''}',
                style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 10,
                    fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 32),
          Row(
            children: [
              Expanded(
                child: _statCard('Check-ins', '18', '+2', const Color(0xFF10B981)),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _statCard('LTV',
                    '\$${selectedMember?.ltv.toStringAsFixed(0) ?? '0'}', '', Colors.transparent),
              ),
            ],
          ),
          const SizedBox(height: 32),
          if (controller.isLoadingLogs)
            const Center(child: CircularProgressIndicator())
          else if (controller.selectedMemberLogs.isEmpty)
            const Center(child: Text('Không có nhật ký hoạt động'))
          else
            ...controller.selectedMemberLogs.map((log) => _ActivityItem(log: log)),
          const SizedBox(height: 32),
          OutlinedButton(
            onPressed: () {},
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(double.infinity, 56),
              side: const BorderSide(color: Colors.grey),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('XEM TẤT CẢ GIAO DỊCH',
                style: TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                    fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _statCard(
      String label, String value, String change, Color changeColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label.toUpperCase(),
              style: const TextStyle(
                  color: Colors.grey, fontSize: 10, fontWeight: FontWeight.w900)),
          const SizedBox(height: 4),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(value,
                  style: const TextStyle(
                      color: Color(0xFF0A192F),
                      fontSize: 24,
                      fontWeight: FontWeight.w900)),
              if (change.isNotEmpty) ...[
                const SizedBox(width: 4),
                Text(change,
                    style: TextStyle(
                        color: changeColor,
                        fontSize: 10,
                        fontWeight: FontWeight.bold)),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _ActivityItem extends StatelessWidget {
  final ActivityLog log;
  const _ActivityItem({required this.log});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
        border: const Border(
            left: BorderSide(color: Color(0xFFFF6B35), width: 2)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
                color: const Color(0xFFFF6B35).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8)),
            child:
                const Icon(Icons.receipt_long, color: Color(0xFFFF6B35), size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(log.title,
                    style: const TextStyle(
                        color: Color(0xFF0A192F),
                        fontSize: 13,
                        fontWeight: FontWeight.bold)),
                Text(
                  DateFormat('dd/MM/yyyy • HH:mm').format(log.timestamp),
                  style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 9,
                      fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('-\$${log.amount.toStringAsFixed(2)}',
                  style: const TextStyle(
                      color: Color(0xFF0A192F),
                      fontSize: 13,
                      fontWeight: FontWeight.w900)),
              Text(log.status == 'Paid' ? 'ĐÃ THANH TOÁN' : log.status.toUpperCase(),
                  style: const TextStyle(
                      color: Color(0xFF10B981),
                      fontSize: 9,
                      fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }
}
