import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:excel/excel.dart' hide Border;
import '../../../utils/file_saver/file_saver.dart';
import '../../../controllers/financial_controller.dart';
import '../../../controllers/payment_controller.dart';
import '../../../controllers/payroll_controller.dart';
import '../../../common/widgets/admin_dashboard_widgets/sidebar_widget.dart';
import '../../../common/widgets/admin_dashboard_widgets/header_widget.dart';
import '../../../common/widgets/transaction_table_widget.dart';
import '../../../app/route/routes.dart';

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
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() {});
      }
    });
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
            Text("Quản lý tài chính",
                style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0A192F))),
          ],
        ),
        ElevatedButton.icon(
          onPressed: () => _showAddTransactionDialog('Revenue'),
          icon: const Icon(Icons.add_circle_outline, size: 20),
          label:
              const Text("Thêm giao dịch", style: TextStyle(fontWeight: FontWeight.bold)),
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
        Tab(text: "TỔNG QUAN"),
        Tab(text: "GIAO DỊCH"),
        Tab(text: "BÁO CÁO"),
      ],
    );
  }

  Widget _buildTabContent() {
    switch (_tabController.index) {
      case 1:
        return _buildTransactionsTab();
      case 2:
        return _buildReportsTab();
      case 0:
      default:
        return _buildOverviewTab();
    }
  }

  Widget _buildOverviewTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Consumer<FinancialController>(
          builder: (context, controller, _) => _buildSummaryCards(controller),
        ),
        const SizedBox(height: 24),
        _buildQuickActions(),
      ],
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
    return Container(
      padding: const EdgeInsets.all(20),
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 22),
              ),
              const Text(
                "STABLE",
                style: TextStyle(
                  color: Color(0xFF475569),
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            title.toUpperCase(),
            style: TextStyle(
              color: Colors.grey[500],
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              color: Color(0xFF0A192F),
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Hành động nhanh',
          style:
              TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF0A192F)),
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
              onTap: () => context.go(Routes.paymentManagement),
            ),
            _buildActionButton(
              title: 'Quản Lý Lương',
              icon: Icons.people,
              onTap: () => context.go(Routes.payrollManagement),
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
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.grey.withValues(alpha: 0.15)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFFF6B35).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: const Color(0xFFFF6B35), size: 22),
              ),
              const SizedBox(height: 10),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Color(0xFF0A192F),
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
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
                "Giao dịch gần đây",
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0A192F)),
              ),
              const SizedBox(height: 16),
              TransactionTableWidget(
                transactions: controller.transactions,
                onTap: (_) {},
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildReportsTab() {
    return Consumer<FinancialController>(
      builder: (context, controller, _) {
        final currencyFormat = NumberFormat.currency(
          symbol: '₫',
          locale: 'vi_VN',
          decimalDigits: 0,
        );

        final totalRev = controller.totalRevenue;
        final totalExp = controller.totalExpense;

        return Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Revenue Breakdown Card
                Expanded(
                  child: Container(
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
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              "CƠ CẤU DOANH THU",
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF0A192F),
                              ),
                            ),
                            Icon(Icons.trending_up, color: Colors.green[700]),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          currencyFormat.format(totalRev),
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                        const SizedBox(height: 24),
                        if (totalRev == 0)
                          const Text("Chưa có dữ liệu doanh thu tháng này",
                              style: TextStyle(color: Colors.grey, fontSize: 13))
                        else
                          ...controller.revenueByCategory.entries.map((entry) {
                            final double pct = totalRev > 0 ? (entry.value / totalRev) : 0;
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(entry.key,
                                          style: const TextStyle(
                                              fontWeight: FontWeight.w600,
                                              fontSize: 13,
                                              color: Color(0xFF475569))),
                                      Text(
                                          '${currencyFormat.format(entry.value)} (${(pct * 100).toStringAsFixed(1)}%)',
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 13,
                                              color: Color(0xFF0A192F))),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(4),
                                    child: LinearProgressIndicator(
                                      value: pct,
                                      backgroundColor: const Color(0xFFF1F5F9),
                                      color: Colors.green,
                                      minHeight: 8,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 24),
                // Expense Breakdown Card
                Expanded(
                  child: Container(
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
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              "CƠ CẤU CHI PHÍ",
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF0A192F),
                              ),
                            ),
                            Icon(Icons.trending_down, color: Colors.red[700]),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          currencyFormat.format(totalExp),
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.red,
                          ),
                        ),
                        const SizedBox(height: 24),
                        if (totalExp == 0)
                          const Text("Chưa có dữ liệu chi phí tháng này",
                              style: TextStyle(color: Colors.grey, fontSize: 13))
                        else
                          ...controller.expenseByCategory.entries.map((entry) {
                            final double pct = totalExp > 0 ? (entry.value / totalExp) : 0;
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(entry.key,
                                          style: const TextStyle(
                                              fontWeight: FontWeight.w600,
                                              fontSize: 13,
                                              color: Color(0xFF475569))),
                                      Text(
                                          '${currencyFormat.format(entry.value)} (${(pct * 100).toStringAsFixed(1)}%)',
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 13,
                                              color: Color(0xFF0A192F))),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(4),
                                    child: LinearProgressIndicator(
                                      value: pct,
                                      backgroundColor: const Color(0xFFF1F5F9),
                                      color: Colors.red,
                                      minHeight: 8,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            // Bottom Action Area
            Container(
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
              child: Row(
                children: [
                  const Icon(Icons.assessment, size: 40, color: Color(0xFFFF6B35)),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Báo cáo phân tích thu chi chi tiết",
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF0A192F)),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Xuất toàn bộ báo cáo doanh thu phòng tập và chi phí nhân sự sang định dạng Excel/PDF.',
                          style: TextStyle(color: Colors.grey[600], fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () => _exportToExcel(controller),
                    icon: const Icon(Icons.download, size: 18),
                    label: const Text('Tải báo cáo'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF6B35),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 18),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _exportToExcel(FinancialController controller) async {
    try {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Đang tạo file báo cáo tài chính...'),
          backgroundColor: Colors.blueAccent,
          duration: Duration(seconds: 1),
        ),
      );

      final excel = Excel.createExcel();
      
      // Sheet 1: Overview
      final Sheet overviewSheet = excel['Tong_Quan'];
      overviewSheet.appendRow([TextCellValue('BÁO CÁO TÀI CHÍNH - TỔNG QUAN')]);
      overviewSheet.appendRow([TextCellValue('')]);
      overviewSheet.appendRow([TextCellValue('Chỉ số'), TextCellValue('Giá trị')]);
      
      final currencyFormat = NumberFormat.currency(
        symbol: '₫',
        locale: 'vi_VN',
        decimalDigits: 0,
      );
      
      overviewSheet.appendRow([TextCellValue('Tổng Doanh Thu'), TextCellValue(currencyFormat.format(controller.totalRevenue))]);
      overviewSheet.appendRow([TextCellValue('Tổng Chi Phí'), TextCellValue(currencyFormat.format(controller.totalExpense))]);
      overviewSheet.appendRow([TextCellValue('Lợi Nhuận Thuần'), TextCellValue(currencyFormat.format(controller.netProfit))]);
      overviewSheet.appendRow([TextCellValue('Tỷ Suất Lợi Nhuận'), TextCellValue('${controller.profitMargin.toStringAsFixed(1)}%')]);
      
      // Sheet 2: Doanh Thu
      final Sheet revSheet = excel['Doanh_Thu'];
      revSheet.appendRow([
        TextCellValue('Mã Giao Dịch'),
        TextCellValue('Danh Mục'),
        TextCellValue('Mô Tả'),
        TextCellValue('Số Tiền'),
        TextCellValue('Ngày'),
        TextCellValue('Hình Thức')
      ]);
      for (final tx in controller.revenues) {
        revSheet.appendRow([
          TextCellValue(tx.id),
          TextCellValue(tx.category),
          TextCellValue(tx.description),
          DoubleCellValue(tx.amount),
          TextCellValue(DateFormat('yyyy-MM-dd HH:mm').format(tx.transactionDate)),
          TextCellValue(tx.paymentMethod)
        ]);
      }
      
      // Sheet 3: Chi Phí
      final Sheet expSheet = excel['Chi_Phi'];
      expSheet.appendRow([
        TextCellValue('Mã Giao Dịch'),
        TextCellValue('Danh Mục'),
        TextCellValue('Mô Tả'),
        TextCellValue('Số Tiền'),
        TextCellValue('Ngày'),
        TextCellValue('Hình Thức')
      ]);
      for (final tx in controller.expenses) {
        expSheet.appendRow([
          TextCellValue(tx.id),
          TextCellValue(tx.category),
          TextCellValue(tx.description),
          DoubleCellValue(tx.amount),
          TextCellValue(DateFormat('yyyy-MM-dd HH:mm').format(tx.transactionDate)),
          TextCellValue(tx.paymentMethod)
        ]);
      }
      
      // Delete the default sheet if it exists
      excel.delete('Sheet1');
      
      final fileBytes = excel.encode();
      if (fileBytes != null) {
        final fileName = 'Bao_Cao_Tai_Chinh_${DateTime.now().year}_${DateTime.now().month}.xlsx';
        await saveFile(fileBytes, fileName, 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet');
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Xuất báo cáo tài chính Excel thành công!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi khi xuất Excel: $e'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  void _showAddTransactionDialog(String type) {
    showDialog(
      context: context,
      builder: (context) => _AddTransactionDialog(type: type),
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
          onPressed: () => context.pop(),
          child: const Text('Hủy'),
        ),
        ElevatedButton(
          onPressed: () {
            _addTransaction();
            context.pop();
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
