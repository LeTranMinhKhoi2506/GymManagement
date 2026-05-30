import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../controllers/payment_controller.dart';
import '../../data/models/payment_model.dart';

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
      appBar: AppBar(
        title: const Text('Quản Lý Thanh Toán'),
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Tất Cả'),
            Tab(text: 'Chưa Thanh Toán'),
            Tab(text: 'Quá Hạn'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildPaymentsList(null),
          _buildPaymentsList('Pending'),
          _buildPaymentsList('Overdue'),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddPaymentDialog(),
        child: const Icon(Icons.add),
      ),
    );
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

        if (payments.isEmpty) {
          return const Center(
            child: Text('Không có thanh toán nào'),
          );
        }

        return ListView.builder(
          itemCount: payments.length,
          padding: const EdgeInsets.all(8),
          itemBuilder: (context, index) {
            final payment = payments[index];
            return _buildPaymentCard(context, payment);
          },
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

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: ListTile(
        leading: Icon(Icons.person, color: statusColor),
        title: Text(payment.memberName),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(payment.membershipType),
            Text(
              'Hạn: ${DateFormat('dd/MM/yyyy').format(payment.dueDate)}',
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              currencyFormat.format(payment.amount),
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
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
        onTap: () => _showPaymentDetailsDialog(context, payment),
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
