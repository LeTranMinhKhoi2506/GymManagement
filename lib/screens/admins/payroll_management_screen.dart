import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../controllers/payroll_controller.dart';
import '../../data/models/payroll_model.dart';
import '../../common/widgets/admin_dashboard_widgets/sidebar_widget.dart';
import '../../common/widgets/admin_dashboard_widgets/header_widget.dart';

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
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() {});
      }
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
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
        const Text(" Lương nhân viên",
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
            Text("Lương nhân viên",
                style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0A192F))),
          ],
        ),
        ElevatedButton.icon(
          onPressed: _showAddPayrollDialog,
          icon: const Icon(Icons.add_circle_outline, size: 20),
          label: const Text("Tạo bảng lương",
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
        Tab(text: "CHỜ DUYỆT"),
        Tab(text: "ĐÃ THANH TOÁN"),
      ],
    );
  }

  Widget _buildTabContent() {
    switch (_tabController.index) {
      case 1:
        return _buildPayrollsList('Pending');
      case 2:
        return _buildPayrollsList('Paid');
      case 0:
      default:
        return _buildPayrollsList(null);
    }
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
                "Danh sách bảng lương",
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0A192F)),
              ),
              const SizedBox(height: 16),
              if (payrolls.isEmpty)
                const Text('Không có bảng lương nào')
              else
                ListView.builder(
                  itemCount: payrolls.length,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemBuilder: (context, index) {
                    final payroll = payrolls[index];
                    return _buildPayrollCard(context, payroll);
                  },
                ),
            ],
          ),
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

    return InkWell(
      onTap: () => _showPayrollDetailsDialog(context, payroll),
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
                  Text(payroll.staffName,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0A192F))),
                  const SizedBox(height: 2),
                  Text(
                    '${payroll.position} • Tháng: ${DateFormat('MM/yyyy').format(payroll.paymentMonth)}',
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  currencyFormat.format(payroll.netSalary),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Color(0xFF0A192F),
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
          ],
        ),
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
