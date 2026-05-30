import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../controllers/financial_controller.dart';
import '../../controllers/payment_controller.dart';
import '../../controllers/payroll_controller.dart';

class FinancialManagementScreen extends StatefulWidget {
  const FinancialManagementScreen({super.key});

  @override
  State<FinancialManagementScreen> createState() =>
      _FinancialManagementScreenState();
}

class _FinancialManagementScreenState extends State<FinancialManagementScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<FinancialController>(context, listen: false)
          .fetchAllTransactions();
      Provider.of<PaymentController>(context, listen: false).fetchAllPayments();
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
        title: const Text('Quản Lý Tài Chính'),
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Tổng Quan'),
            Tab(text: 'Giao Dịch'),
            Tab(text: 'Báo Cáo'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildOverviewTab(),
          _buildTransactionsTab(),
          _buildReportsTab(),
        ],
      ),
    );
  }

  Widget _buildOverviewTab() {
    return Consumer<FinancialController>(
      builder: (context, controller, _) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _buildSummaryCards(controller),
              const SizedBox(height: 24),
              _buildQuickActions(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSummaryCards(FinancialController controller) {
    final currencyFormat = NumberFormat.currency(
      symbol: '₫',
      locale: 'vi_VN',
      decimalDigits: 0,
    );

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildCard(
                title: 'Tổng Doanh Thu',
                value: currencyFormat.format(controller.totalRevenue),
                color: Colors.green,
                icon: Icons.trending_up,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildCard(
                title: 'Tổng Chi Phí',
                value: currencyFormat.format(controller.totalExpense),
                color: Colors.red,
                icon: Icons.trending_down,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildCard(
                title: 'Lợi Nhuận',
                value: currencyFormat.format(controller.netProfit),
                color: controller.netProfit > 0 ? Colors.blue : Colors.orange,
                icon: Icons.monetization_on,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildCard(
                title: 'Tỷ Lợi Nhuận',
                value: '${controller.profitMargin.toStringAsFixed(1)}%',
                color: Colors.purple,
                icon: Icons.percent,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCard({
    required String title,
    required String value,
    required Color color,
    required IconData icon,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            colors: [color.withValues(alpha: 0.8), color.withValues(alpha: 0.4)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: Colors.white, size: 24),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Hành Động Nhanh',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 2.0,
          children: [
            _buildActionButton(
              title: 'Thêm Doanh Thu',
              icon: Icons.add_circle,
              onTap: () => _showAddTransactionDialog('Revenue'),
            ),
            _buildActionButton(
              title: 'Thêm Chi Phí',
              icon: Icons.add_circle,
              onTap: () => _showAddTransactionDialog('Expense'),
            ),
            _buildActionButton(
              title: 'Quản Lý Thanh Toán',
              icon: Icons.payment,
              onTap: () => _navigateToPayments(),
            ),
            _buildActionButton(
              title: 'Quản Lý Lương',
              icon: Icons.people,
              onTap: () => _navigateToPayroll(),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required String title,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: LinearGradient(
              colors: [Colors.blue.withValues(alpha: 0.8), Colors.blue.withValues(alpha: 0.4)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.white, size: 32),
              const SizedBox(height: 8),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTransactionsTab() {
    return Consumer<FinancialController>(
      builder: (context, controller, _) {
        if (controller.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.transactions.isEmpty) {
          return const Center(
            child: Text('Không có giao dịch nào'),
          );
        }

        return ListView.builder(
          itemCount: controller.transactions.length,
          padding: const EdgeInsets.all(8),
          itemBuilder: (context, index) {
            final transaction = controller.transactions[index];
            final isRevenue = transaction.type == 'Revenue';

            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: ListTile(
                leading: Icon(
                  isRevenue ? Icons.arrow_upward : Icons.arrow_downward,
                  color: isRevenue ? Colors.green : Colors.red,
                ),
                title: Text(transaction.category),
                subtitle: Text(transaction.description),
                trailing: Text(
                  '${isRevenue ? '+' : '-'} ${NumberFormat.currency(symbol: '₫', locale: 'vi_VN', decimalDigits: 0).format(transaction.amount)}',
                  style: TextStyle(
                    color: isRevenue ? Colors.green : Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildReportsTab() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.assessment, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          const Text('Báo Cáo tài chính sẽ được cập nhật'),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Tính năng sẽ sớm ra mắt')),
              );
            },
            child: const Text('Tạo Báo Cáo'),
          ),
        ],
      ),
    );
  }

  void _showAddTransactionDialog(String type) {
    showDialog(
      context: context,
      builder: (context) => _AddTransactionDialog(type: type),
    );
  }

  void _navigateToPayments() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Điều hướng tới quản lý thanh toán')),
    );
  }

  void _navigateToPayroll() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Điều hướng tới quản lý lương')),
    );
  }
}

class _AddTransactionDialog extends StatefulWidget {
  final String type;

  const _AddTransactionDialog({required this.type});

  @override
  State<_AddTransactionDialog> createState() => _AddTransactionDialogState();
}

class _AddTransactionDialogState extends State<_AddTransactionDialog> {
  late TextEditingController _descriptionController;
  late TextEditingController _amountController;
  String _selectedCategory = '';
  final String _selectedPaymentMethod = 'Cash';
  final DateTime _selectedDate = DateTime.now();

  final List<String> _revenueCategories = [
    'Membership',
    'Training',
    'Product',
    'Service'
  ];
  final List<String> _expenseCategories = [
    'Equipment',
    'Utilities',
    'Maintenance',
    'Marketing',
    'Other'
  ];

  @override
  void initState() {
    super.initState();
    _descriptionController = TextEditingController();
    _amountController = TextEditingController();
    _selectedCategory = widget.type == 'Revenue'
        ? _revenueCategories[0]
        : _expenseCategories[0];
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final categories = widget.type == 'Revenue'
        ? _revenueCategories
        : _expenseCategories;

    return AlertDialog(
      title: Text('Thêm ${widget.type == 'Revenue' ? 'Doanh Thu' : 'Chi Phí'}'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Mô Tả',
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
              initialValue: _selectedCategory,
              items: categories
                  .map((cat) => DropdownMenuItem(value: cat, child: Text(cat)))
                  .toList(),
              onChanged: (value) =>
                  setState(() => _selectedCategory = value ?? ''),
              decoration: const InputDecoration(
                labelText: 'Danh Mục',
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
            _addTransaction();
            Navigator.pop(context);
          },
          child: const Text('Thêm'),
        ),
      ],
    );
  }

  void _addTransaction() {
    final controller =
        Provider.of<FinancialController>(context, listen: false);
    controller.createTransaction(
      type: widget.type,
      category: _selectedCategory,
      description: _descriptionController.text,
      amount: double.tryParse(_amountController.text) ?? 0,
      transactionDate: _selectedDate,
      paymentMethod: _selectedPaymentMethod,
      notes: null,
      createdBy: 'admin',
    );
  }
}
