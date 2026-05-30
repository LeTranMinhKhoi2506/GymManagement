import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../controllers/payroll_controller.dart';
import '../../data/models/payroll_model.dart';

class PayrollManagementScreen extends StatefulWidget {
  const PayrollManagementScreen({super.key});

  @override
  State<PayrollManagementScreen> createState() =>
      _PayrollManagementScreenState();
}

class _PayrollManagementScreenState extends State<PayrollManagementScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    Future.microtask(() {
      Provider.of<PayrollController>(context, listen: false).fetchAllPayrolls();
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
        title: const Text('Quản Lý Lương Nhân Viên'),
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Tất Cả'),
            Tab(text: 'Chờ Duyệt'),
            Tab(text: 'Đã Thanh Toán'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildPayrollsList(null),
          _buildPayrollsList('Pending'),
          _buildPayrollsList('Paid'),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddPayrollDialog(),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildPayrollsList(String? filter) {
    return Consumer<PayrollController>(
      builder: (context, controller, _) {
        if (controller.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        List<PayrollModel> payrolls;
        if (filter == null) {
          payrolls = controller.payrolls;
        } else if (filter == 'Pending') {
          payrolls = controller.pendingPayrolls;
        } else {
          payrolls = controller.paidPayrolls;
        }

        if (payrolls.isEmpty) {
          return const Center(
            child: Text('Không có bảng lương nào'),
          );
        }

        return ListView.builder(
          itemCount: payrolls.length,
          padding: const EdgeInsets.all(8),
          itemBuilder: (context, index) {
            final payroll = payrolls[index];
            return _buildPayrollCard(context, payroll);
          },
        );
      },
    );
  }

  Widget _buildPayrollCard(BuildContext context, PayrollModel payroll) {
    final currencyFormat = NumberFormat.currency(
      symbol: '₫',
      locale: 'vi_VN',
      decimalDigits: 0,
    );

    final statusColor = payroll.status == 'Paid'
        ? Colors.green
        : payroll.status == 'Approved'
            ? Colors.blue
            : Colors.orange;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: ListTile(
        leading: Icon(Icons.person, color: statusColor),
        title: Text(payroll.staffName),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(payroll.position),
            Text(
              'Tháng: ${DateFormat('MM/yyyy').format(payroll.paymentMonth)}',
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              currencyFormat.format(payroll.netSalary),
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            Text(
              payroll.status,
              style: TextStyle(
                fontSize: 12,
                color: statusColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        onTap: () => _showPayrollDetailsDialog(context, payroll),
      ),
    );
  }

  void _showPayrollDetailsDialog(BuildContext context, PayrollModel payroll) {
    showDialog(
      context: context,
      builder: (context) => _PayrollDetailsDialog(payroll: payroll),
    );
  }

  void _showAddPayrollDialog() {
    showDialog(
      context: context,
      builder: (context) => const _AddPayrollDialog(),
    );
  }
}

class _PayrollDetailsDialog extends StatelessWidget {
  final PayrollModel payroll;

  const _PayrollDetailsDialog({required this.payroll});

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(
      symbol: '₫',
      locale: 'vi_VN',
      decimalDigits: 0,
    );

    return AlertDialog(
      title: const Text('Chi Tiết Bảng Lương'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow('Nhân Viên', payroll.staffName),
            _buildDetailRow('Chức Vụ', payroll.position),
            _buildDetailRow('Lương Cơ Bản',
                currencyFormat.format(payroll.baseSalary)),
            _buildDetailRow('Thưởng', currencyFormat.format(payroll.bonus)),
            _buildDetailRow('Khấu Trừ',
                currencyFormat.format(payroll.deductions)),
            const Divider(),
            _buildDetailRow('Lương Ròng',
                currencyFormat.format(payroll.netSalary)),
            _buildDetailRow('Ngày Công', '${payroll.workingDays}'),
            _buildDetailRow('Trạng Thái', payroll.status),
          ],
        ),
      ),
      actions: [
        if (payroll.status == 'Pending')
          ElevatedButton(
            onPressed: () {
              Provider.of<PayrollController>(context, listen: false)
                  .approvePayroll(payroll.id);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
            child: const Text('Duyệt'),
          ),
        if (payroll.status == 'Approved')
          ElevatedButton(
            onPressed: () {
              Provider.of<PayrollController>(context, listen: false)
                  .markPayrollAsPaid(payroll.id, 'Bank Transfer');
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: const Text('Thanh Toán'),
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

class _AddPayrollDialog extends StatefulWidget {
  const _AddPayrollDialog();

  @override
  State<_AddPayrollDialog> createState() => _AddPayrollDialogState();
}

class _AddPayrollDialogState extends State<_AddPayrollDialog> {
  late TextEditingController _staffNameController;
  late TextEditingController _positionController;
  late TextEditingController _baseSalaryController;
  late TextEditingController _bonusController;
  late TextEditingController _deductionsController;
  late TextEditingController _workingDaysController;

  @override
  void initState() {
    super.initState();
    _staffNameController = TextEditingController();
    _positionController = TextEditingController();
    _baseSalaryController = TextEditingController();
    _bonusController = TextEditingController(text: '0');
    _deductionsController = TextEditingController(text: '0');
    _workingDaysController = TextEditingController(text: '22');
  }

  @override
  void dispose() {
    _staffNameController.dispose();
    _positionController.dispose();
    _baseSalaryController.dispose();
    _bonusController.dispose();
    _deductionsController.dispose();
    _workingDaysController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Thêm Bảng Lương'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _staffNameController,
              decoration: const InputDecoration(
                labelText: 'Tên Nhân Viên',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _positionController,
              decoration: const InputDecoration(
                labelText: 'Chức Vụ',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _baseSalaryController,
              decoration: const InputDecoration(
                labelText: 'Lương Cơ Bản',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _bonusController,
                    decoration: const InputDecoration(
                      labelText: 'Thưởng',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _deductionsController,
                    decoration: const InputDecoration(
                      labelText: 'Khấu Trừ',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
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
            Provider.of<PayrollController>(context, listen: false)
                .createPayroll(
              staffId: '',
              staffName: _staffNameController.text,
              position: _positionController.text,
              baseSalary: double.tryParse(_baseSalaryController.text) ?? 0,
              paymentMonth: DateTime.now(),
              workingDays: int.tryParse(_workingDaysController.text) ?? 22,
              bonus: double.tryParse(_bonusController.text) ?? 0,
              deductions: double.tryParse(_deductionsController.text) ?? 0,
              createdBy: 'admin',
            );
            Navigator.pop(context);
          },
          child: const Text('Thêm'),
        ),
      ],
    );
  }
}
