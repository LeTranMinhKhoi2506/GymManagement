import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../controllers/payment_controller.dart';
import '../../data/models/payment_model.dart';
import '../../common/widgets/admin_dashboard_widgets/sidebar_widget.dart';
import '../../common/widgets/admin_dashboard_widgets/header_widget.dart';

class PaymentManagementScreen extends StatefulWidget {
  const PaymentManagementScreen({super.key});

  @override
  State<PaymentManagementScreen> createState() =>
      _PaymentManagementScreenState();
}

class _PaymentManagementScreenState extends State<PaymentManagementScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() {});
      }
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<PaymentController>(context, listen: false).fetchAllPayments();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                        _buildBreadcrumbs(),
                        const SizedBox(height: 12),
                        _buildHeaderSection(),
                        const SizedBox(height: 24),
                        _buildTabs(),
                        const SizedBox(height: 24),
                        _buildTabContent(),
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

  Widget _buildBreadcrumbs() {
    return Row(
      children: [
        Text("Admin", style: TextStyle(color: Colors.grey[600], fontSize: 14)),
        const Icon(Icons.chevron_right, size: 16, color: Colors.grey),
        const Text(" Quản lý tài chính",
            style: TextStyle(color: Colors.grey, fontSize: 14)),
        const Icon(Icons.chevron_right, size: 16, color: Colors.grey),
        const Text(" Thanh toán",
            style: TextStyle(
                color: Color(0xFFFF6B35),
                fontWeight: FontWeight.bold,
                fontSize: 14)),
      ],
    );
  }

  Widget _buildHeaderSection() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 4),
            Text("Thanh toán hội viên",
                style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0A192F))),
          ],
        ),
        ElevatedButton.icon(
          onPressed: _showAddPaymentDialog,
          icon: const Icon(Icons.add_circle_outline, size: 20),
          label: const Text("Thêm thanh toán",
              style: TextStyle(fontWeight: FontWeight.bold)),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFFF6B35),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ],
    );
  }

  Widget _buildTabs() {
    return TabBar(
      controller: _tabController,
      isScrollable: true,
      indicatorColor: const Color(0xFFFF6B35),
      labelColor: const Color(0xFF0A192F),
      unselectedLabelColor: Colors.grey,
      labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
      indicatorSize: TabBarIndicatorSize.label,
      tabs: const [
        Tab(text: "TẤT CẢ"),
        Tab(text: "CHƯA THANH TOÁN"),
        Tab(text: "QUÁ HẠN"),
      ],
    );
  }

  Widget _buildTabContent() {
    switch (_tabController.index) {
      case 1:
        return _buildPaymentsList('Pending');
      case 2:
        return _buildPaymentsList('Overdue');
      case 0:
      default:
        return _buildPaymentsList(null);
    }
  }

  Widget _buildPaymentsList(String? filter) {
    return Consumer<PaymentController>(
      builder: (context, controller, _) {
        if (controller.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        List<PaymentModel> payments;
        if (filter == null) {
          payments = controller.payments;
        } else if (filter == 'Pending') {
          payments = controller.pendingPayments;
        } else {
          payments = controller.overduePayments;
        }

        return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Danh sách thanh toán",
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0A192F)),
              ),
              const SizedBox(height: 16),
              if (payments.isEmpty)
                const Text('Không có thanh toán nào')
              else
                ListView.builder(
                  itemCount: payments.length,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemBuilder: (context, index) {
                    final payment = payments[index];
                    return _buildPaymentCard(context, payment);
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPaymentCard(BuildContext context, PaymentModel payment) {
    final currencyFormat = NumberFormat.currency(
      symbol: '₫',
      locale: 'vi_VN',
      decimalDigits: 0,
    );

    final statusColor = payment.status == 'Paid'
        ? Colors.green
        : payment.isOverdue
            ? Colors.red
            : Colors.orange;

    return InkWell(
      onTap: () => _showPaymentDetailsDialog(context, payment),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFF8F9FA),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(Icons.person, color: statusColor, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(payment.memberName,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0A192F))),
                  const SizedBox(height: 2),
                  Text(
                    '${payment.membershipType} • Hạn: ${DateFormat('dd/MM/yyyy').format(payment.dueDate)}',
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  currencyFormat.format(payment.amount),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Color(0xFF0A192F),
                  ),
                ),
                Text(
                  payment.status,
                  style: TextStyle(
                    fontSize: 12,
                    color: statusColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showPaymentDetailsDialog(BuildContext context, PaymentModel payment) {
    showDialog(
      context: context,
      builder: (context) => _PaymentDetailsDialog(payment: payment),
    );
  }

  void _showAddPaymentDialog() {
    showDialog(
      context: context,
      builder: (context) => const _AddPaymentDialog(),
    );
  }
}

class _PaymentDetailsDialog extends StatelessWidget {
  final PaymentModel payment;

  const _PaymentDetailsDialog({required this.payment});

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(
      symbol: '₫',
      locale: 'vi_VN',
      decimalDigits: 0,
    );

    return AlertDialog(
      title: const Text('Chi Tiết Thanh Toán'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDetailRow('Hội Viên', payment.memberName),
          _buildDetailRow('Loại Thành Viên', payment.membershipType),
          _buildDetailRow('Số Tiền', currencyFormat.format(payment.amount)),
          _buildDetailRow('Loại Thanh Toán', payment.paymentType),
          _buildDetailRow('Hạn Thanh Toán',
              DateFormat('dd/MM/yyyy').format(payment.dueDate)),
          _buildDetailRow('Trạng Thái', payment.status),
          if (payment.paymentDate != null)
            _buildDetailRow('Ngày Thanh Toán',
                DateFormat('dd/MM/yyyy').format(payment.paymentDate!)),
        ],
      ),
      actions: [
        if (payment.status == 'Pending')
          ElevatedButton(
            onPressed: () {
              Provider.of<PaymentController>(context, listen: false)
                  .markPaymentAsPaid(payment.id, 'Cash');
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: const Text('Đánh Dấu Là Đã Thanh Toán'),
          ),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Đóng'),
        ),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}

class _AddPaymentDialog extends StatefulWidget {
  const _AddPaymentDialog();

  @override
  State<_AddPaymentDialog> createState() => _AddPaymentDialogState();
}

class _AddPaymentDialogState extends State<_AddPaymentDialog> {
  late TextEditingController _memberIdController;
  late TextEditingController _memberNameController;
  late TextEditingController _amountController;
  String _membershipType = 'Standard';
  String _paymentType = 'Membership';
  DateTime _dueDate = DateTime.now().add(const Duration(days: 30));

  @override
  void initState() {
    super.initState();
    _memberIdController = TextEditingController();
    _memberNameController = TextEditingController();
    _amountController = TextEditingController();
  }

  @override
  void dispose() {
    _memberIdController.dispose();
    _memberNameController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Thêm Thanh Toán'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _memberNameController,
              decoration: const InputDecoration(
                labelText: 'Tên Hội Viên',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _amountController,
              decoration: const InputDecoration(
                labelText: 'Số Tiền',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _membershipType,
              items: ['Standard', 'Pro Elite', 'Trial']
                  .map((type) =>
                      DropdownMenuItem(value: type, child: Text(type)))
                  .toList(),
              onChanged: (value) =>
                  setState(() => _membershipType = value ?? 'Standard'),
              decoration: const InputDecoration(
                labelText: 'Loại Thành Viên',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Hủy'),
        ),
        ElevatedButton(
          onPressed: () {
            Provider.of<PaymentController>(context, listen: false)
                .createPayment(
              memberId: _memberIdController.text,
              memberName: _memberNameController.text,
              membershipType: _membershipType,
              amount: double.tryParse(_amountController.text) ?? 0,
              dueDate: _dueDate,
              paymentType: _paymentType,
            );
            Navigator.pop(context);
          },
          child: const Text('Thêm'),
        ),
      ],
    );
  }
}
