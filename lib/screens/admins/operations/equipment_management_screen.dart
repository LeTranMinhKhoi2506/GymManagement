import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../controllers/equipment_controller.dart';
import '../../../data/models/equipment_model.dart';
import '../../../common/widgets/admin_dashboard_widgets/sidebar_widget.dart';
import '../../../common/widgets/admin_dashboard_widgets/header_widget.dart';

class EquipmentManagementScreen extends StatefulWidget {
  const EquipmentManagementScreen({super.key});

  @override
  State<EquipmentManagementScreen> createState() =>
      _EquipmentManagementScreenState();
}

class _EquipmentManagementScreenState extends State<EquipmentManagementScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() {});
      }
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<EquipmentController>(context, listen: false)
          .fetchAllEquipment();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<EquipmentController>(context);

    if (controller.errorMessage != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.error_outline, color: Colors.white),
                  const SizedBox(width: 12),
                  Expanded(
                      child: Text(
                          "Lỗi thiết bị: ${controller.errorMessage ?? ''}")),
                ],
              ),
              backgroundColor: Colors.redAccent,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
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
                        _buildBreadcrumbs(),
                        const SizedBox(height: 12),
                        _buildHeaderSection(),
                        const SizedBox(height: 24),
                        _buildTabs(),
                        const SizedBox(height: 24),
                        _buildTabContent(controller),
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
        const Text(" Quản lý thiết bị",
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
            Text("Quản lý thiết bị",
                style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0A192F))),
          ],
        ),
        ElevatedButton.icon(
          onPressed: _showAddEquipmentDialog,
          icon: const Icon(Icons.add_circle_outline, size: 20),
          label:
              const Text("Thêm thiết bị", style: TextStyle(fontWeight: FontWeight.bold)),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFFF6B35),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
        Tab(text: "DANH MỤC THIẾT BỊ"),
        Tab(text: "LỊCH BẢO TRÌ"),
      ],
    );
  }

  Widget _buildTabContent(EquipmentController controller) {
    switch (_tabController.index) {
      case 1:
        return _buildMaintenanceTab(controller);
      case 0:
      default:
        return _buildEquipmentTab(controller);
    }
  }

  Widget _buildEquipmentTab(EquipmentController controller) {
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
            "Danh sách thiết bị",
            style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0A192F)),
          ),
          const SizedBox(height: 16),
          if (controller.equipment.isEmpty)
            const Text('Chưa có thiết bị nào')
          else
            ListView.builder(
              itemCount: controller.equipment.length,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemBuilder: (context, index) {
                final equipment = controller.equipment[index];
                return _buildEquipmentCard(equipment);
              },
            ),
        ],
      ),
    );
  }

  Widget _buildEquipmentCard(EquipmentModel equipment) {
    final status = _statusLabel(equipment.status);
    final statusColor = _statusColor(equipment.status);
    final format = DateFormat('dd/MM/yyyy');

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(Icons.fitness_center, color: statusColor, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(equipment.name,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0A192F))),
                const SizedBox(height: 4),
                Text(
                  '${equipment.category} • Vị trí: ${equipment.location ?? 'N/A'}',
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
                const SizedBox(height: 2),
                Text(
                  'Bảo trì kế tiếp: ${format.format(equipment.nextMaintenanceDate)}',
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'edit') {
                    _showEditEquipmentDialog(equipment);
                  } else if (value == 'delete') {
                    _confirmDeleteEquipment(equipment);
                  }
                },
                itemBuilder: (context) => const [
                  PopupMenuItem(value: 'edit', child: Text('Chỉnh sửa')),
                  PopupMenuItem(value: 'delete', child: Text('Xóa thiết bị')),
                ],
                icon: const Icon(Icons.more_vert, size: 20),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMaintenanceTab(EquipmentController controller) {
    if (controller.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final overdue = controller.overdueMaintenance;
    final upcoming = controller.upcomingMaintenance;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (overdue.isNotEmpty)
          _buildMaintenanceSection(
            title: 'Cần bảo trì ngay',
            subtitle: 'Thiết bị đã quá hạn bảo trì',
            items: overdue,
            highlightColor: Colors.red,
          ),
        if (upcoming.isNotEmpty) const SizedBox(height: 16),
        if (upcoming.isNotEmpty)
          _buildMaintenanceSection(
            title: 'Sắp đến hạn',
            subtitle: 'Thiết bị sẽ đến hạn trong 7 ngày tới',
            items: upcoming,
            highlightColor: Colors.orange,
          ),
        if (overdue.isEmpty && upcoming.isEmpty)
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
            child: const Text('Không có lịch bảo trì cần nhắc nhở'),
          ),
      ],
    );
  }

  Widget _buildMaintenanceSection({
    required String title,
    required String subtitle,
    required List<EquipmentModel> items,
    required Color highlightColor,
  }) {
    final format = DateFormat('dd/MM/yyyy');

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
          Text(
            title,
            style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0A192F)),
          ),
          const SizedBox(height: 4),
          Text(subtitle, style: TextStyle(color: Colors.grey[600])),
          const SizedBox(height: 16),
          ListView.builder(
            itemCount: items.length,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemBuilder: (context, index) {
              final equipment = items[index];
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: highlightColor.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: highlightColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(Icons.build,
                          color: highlightColor, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(equipment.name,
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF0A192F))),
                          const SizedBox(height: 2),
                          Text(
                            '${equipment.category} • Hạn: ${format.format(equipment.nextMaintenanceDate)}',
                            style: TextStyle(
                                color: Colors.grey[600], fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Provider.of<EquipmentController>(context, listen: false)
                            .markMaintenanceCompleted(equipment);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF6B35),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                      child: const Text('Đã bảo trì'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'UnderMaintenance':
        return Colors.orange;
      case 'OutOfService':
        return Colors.red;
      case 'Operational':
      default:
        return Colors.green;
    }
  }

  String _statusLabel(String status) {
    switch (status) {
      case 'UnderMaintenance':
        return 'Đang bảo trì';
      case 'OutOfService':
        return 'Ngưng sử dụng';
      case 'Operational':
      default:
        return 'Hoạt động';
    }
  }

  void _showAddEquipmentDialog() {
    showDialog(
      context: context,
      builder: (context) => const _EquipmentFormDialog(),
    );
  }

  void _showEditEquipmentDialog(EquipmentModel equipment) {
    showDialog(
      context: context,
      builder: (context) => _EquipmentFormDialog(equipment: equipment),
    );
  }

  void _confirmDeleteEquipment(EquipmentModel equipment) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xóa thiết bị'),
        content: Text('Bạn có chắc muốn xóa "${equipment.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () {
              Provider.of<EquipmentController>(context, listen: false)
                  .deleteEquipment(equipment.id);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );
  }
}

class _EquipmentFormDialog extends StatefulWidget {
  final EquipmentModel? equipment;

  const _EquipmentFormDialog({this.equipment});

  @override
  State<_EquipmentFormDialog> createState() => _EquipmentFormDialogState();
}

class _EquipmentFormDialogState extends State<_EquipmentFormDialog> {
  late TextEditingController _nameController;
  late TextEditingController _serialController;
  late TextEditingController _locationController;
  late TextEditingController _intervalController;
  late TextEditingController _notesController;
  String _category = 'Máy chạy bộ';
  String _status = 'Operational';
  DateTime _purchaseDate = DateTime.now();

  final List<String> _categories = [
    'Máy chạy bộ',
    'Máy cơ',
    'Tạ',
    'Xe đạp',
    'Máy chèo thuyền',
    'Khác',
  ];

  final List<String> _statuses = [
    'Operational',
    'UnderMaintenance',
    'OutOfService',
  ];

  @override
  void initState() {
    super.initState();
    _nameController =
        TextEditingController(text: widget.equipment?.name ?? '');
    _serialController =
        TextEditingController(text: widget.equipment?.serialNumber ?? '');
    _locationController =
        TextEditingController(text: widget.equipment?.location ?? '');
    _intervalController = TextEditingController(
        text: (widget.equipment?.maintenanceIntervalDays ?? 30).toString());
    _notesController =
        TextEditingController(text: widget.equipment?.notes ?? '');
    _category = widget.equipment?.category ?? _category;
    _status = widget.equipment?.status ?? _status;
    _purchaseDate = widget.equipment?.purchaseDate ?? DateTime.now();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _serialController.dispose();
    _locationController.dispose();
    _intervalController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final format = DateFormat('dd/MM/yyyy');

    return AlertDialog(
      title: Text(widget.equipment == null ? 'Thêm thiết bị' : 'Chỉnh sửa thiết bị'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Tên thiết bị',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: _category,
              items: _categories
                  .map((cat) => DropdownMenuItem(value: cat, child: Text(cat)))
                  .toList(),
              onChanged: (value) =>
                  setState(() => _category = value ?? _category),
              decoration: const InputDecoration(
                labelText: 'Danh mục',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: _status,
              items: _statuses
                  .map((s) => DropdownMenuItem(
                      value: s, child: Text(_statusText(s))))
                  .toList(),
              onChanged: (value) => setState(() => _status = value ?? _status),
              decoration: const InputDecoration(
                labelText: 'Tình trạng',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _serialController,
              decoration: const InputDecoration(
                labelText: 'Số serial',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _locationController,
              decoration: const InputDecoration(
                labelText: 'Vị trí đặt',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _intervalController,
              decoration: const InputDecoration(
                labelText: 'Chu kỳ bảo trì (ngày)',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _notesController,
              decoration: const InputDecoration(
                labelText: 'Ghi chú',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Ngày mua: ${format.format(_purchaseDate)}',
                    style: TextStyle(color: Colors.grey[700]),
                  ),
                ),
                TextButton(
                  onPressed: _pickPurchaseDate,
                  child: const Text('Chọn ngày'),
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
          onPressed: _saveEquipment,
          child: const Text('Lưu'),
        ),
      ],
    );
  }

  Future<void> _pickPurchaseDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _purchaseDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() => _purchaseDate = picked);
    }
  }

  void _saveEquipment() {
    final interval = int.tryParse(_intervalController.text) ?? 30;
    final controller =
        Provider.of<EquipmentController>(context, listen: false);

    if (widget.equipment == null) {
      controller.createEquipment(
        name: _nameController.text.trim(),
        category: _category,
        status: _status,
        serialNumber: _serialController.text.trim().isEmpty
            ? null
            : _serialController.text.trim(),
        location: _locationController.text.trim().isEmpty
            ? null
            : _locationController.text.trim(),
        purchaseDate: _purchaseDate,
        maintenanceIntervalDays: interval,
        notes:
            _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
        createdBy: 'admin',
      );
    } else {
      final equipment = widget.equipment!.copyWith(
        name: _nameController.text.trim(),
        category: _category,
        status: _status,
        serialNumber: _serialController.text.trim().isEmpty
            ? null
            : _serialController.text.trim(),
        location: _locationController.text.trim().isEmpty
            ? null
            : _locationController.text.trim(),
        purchaseDate: _purchaseDate,
        maintenanceIntervalDays: interval,
        notes:
            _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
      );
      controller.updateEquipment(equipment);
    }

    Navigator.pop(context);
  }

  String _statusText(String status) {
    switch (status) {
      case 'UnderMaintenance':
        return 'Đang bảo trì';
      case 'OutOfService':
        return 'Ngưng sử dụng';
      case 'Operational':
      default:
        return 'Hoạt động';
    }
  }
}
