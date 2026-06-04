import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../common/widgets/admin_dashboard_widgets/sidebar_widget.dart';
import '../../../common/widgets/admin_dashboard_widgets/header_widget.dart';
import '../../../data/services/database_seeder.dart';

class DeveloperToolScreen extends StatefulWidget {
  const DeveloperToolScreen({super.key});

  @override
  State<DeveloperToolScreen> createState() => _DeveloperToolScreenState();
}

class _DeveloperToolScreenState extends State<DeveloperToolScreen> {
  late final DatabaseSeeder _seeder;
  final List<String> _logs = [];
  final ScrollController _logScrollController = ScrollController();
  final Map<String, int> _counts = {};
  bool _isLoading = false;

  // Custom counts controllers for generation
  final Map<String, TextEditingController> _generateControllers = {};

  final List<Map<String, String>> _collectionsList = [
    {'name': 'users', 'title': 'Tài khoản (users)', 'desc': 'Tài khoản đăng nhập của hệ thống'},
    {'name': 'members', 'title': 'Hội viên (members)', 'desc': 'Thông tin khách hàng & gói tập'},
    {'name': 'membership_plans', 'title': 'Gói tập (membership_plans)', 'desc': 'Các gói tập mặc định của phòng gym'},
    {'name': 'products', 'title': 'Sản phẩm (products)', 'desc': 'Sản phẩm bổ sung, phụ kiện, nước uống'},
    {'name': 'equipment', 'title': 'Thiết bị (equipment)', 'desc': 'Thiết bị tập luyện & bảo trì'},
    {'name': 'transactions', 'title': 'Tài chính (transactions)', 'desc': 'Các giao dịch Thu nhập & Chi phí'},
    {'name': 'payments', 'title': 'Thanh toán (payments)', 'desc': 'Hóa đơn thanh toán hội viên'},
    {'name': 'payroll', 'title': 'Lương (payroll)', 'desc': 'Bảng lương huấn luyện viên & nhân sự'},
    {'name': 'schedules', 'title': 'Lịch tập (schedules)', 'desc': 'Lịch trực lễ tân & dạy học'},
    {'name': 'feedbacks', 'title': 'Phản hồi (feedbacks)', 'desc': 'Ý kiến phản hồi từ hội viên'},
    {'name': 'checkins', 'title': 'Lượt ra vào (checkins)', 'desc': 'Lịch sử quét QR check-in/out của hội viên'},
    {'name': 'categories', 'title': 'Danh mục (categories)', 'desc': 'Các nhóm danh mục cho nội dung, trang thiết bị...'},
    {'name': 'media_library', 'title': 'Thư viện Media (media_library)', 'desc': 'Tệp hình ảnh phòng tập & sản phẩm'},
    {'name': 'contents', 'title': 'Bài viết & Tin tức (contents)', 'desc': 'Các bài viết tin tức, khuyến mãi trên app'},
    {'name': 'classes', 'title': 'Lớp học (classes)', 'desc': 'Lớp học Yoga, HIIT, Zumba...'},
    {'name': 'roles', 'title': 'Quyền & Vai trò (roles)', 'desc': 'Phân quyền cấp bậc truy cập hệ thống'},
  ];

  @override
  void initState() {
    super.initState();
    _seeder = DatabaseSeeder(onLog: _addLog);
    for (var col in _collectionsList) {
      _generateControllers[col['name']!] = TextEditingController(text: '10');
    }
    _addLog("💻 Hệ thống Công cụ Dev đã khởi động.");
    _fetchCounts();
  }

  @override
  void dispose() {
    for (var controller in _generateControllers.values) {
      controller.dispose();
    }
    _logScrollController.dispose();
    super.dispose();
  }

  void _addLog(String msg) {
    if (!mounted) return;
    setState(() {
      _logs.add("[${_formatTime(DateTime.now())}] $msg");
    });
    // Auto scroll to bottom
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_logScrollController.hasClients) {
        _logScrollController.animateTo(
          _logScrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
        );
      }
    });
  }

  String _formatTime(DateTime time) {
    return "${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}:${time.second.toString().padLeft(2, '0')}";
  }

  Future<void> _fetchCounts() async {
    setState(() {
      _isLoading = true;
    });
    _addLog("📊 Đang đọc số lượng tài liệu từ Firestore...");
    final FirebaseFirestore db = FirebaseFirestore.instance;
    try {
      for (var col in _collectionsList) {
        final name = col['name']!;
        final snapshot = await db.collection(name).get();
        _counts[name] = snapshot.docs.length;
      }
      _addLog("📊 Đọc xong số lượng tài liệu.");
    } catch (e) {
      _addLog("❌ Lỗi khi đọc số lượng tài liệu: $e");
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _runAction(String label, Future<void> Function() action) async {
    if (_isLoading) return;
    setState(() {
      _isLoading = true;
    });
    _addLog("▶️ Bắt đầu thực thi: $label...");
    try {
      await action();
    } catch (e) {
      _addLog("❌ Thao tác gặp lỗi: $e");
    } finally {
      await _fetchCounts();
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showClearConfirmDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.warning, color: Colors.red),
            SizedBox(width: 8),
            Text("Xóa toàn bộ CSDL?"),
          ],
        ),
        content: const Text(
          "Hành động này sẽ xóa sạch hoàn toàn tất cả các bảng dữ liệu trong cơ sở dữ liệu Firestore. Bạn có chắc chắn muốn tiếp tục?",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Hủy bỏ"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _runAction("Xóa sạch toàn bộ CSDL", () => _seeder.clearAll());
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            child: const Text("Xác nhận Xóa sạch"),
          ),
        ],
      ),
    );
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
                        _buildHeaderSection(),
                        const SizedBox(height: 24),
                        _buildMasterControls(),
                        const SizedBox(height: 32),
                        const Text(
                          "Quản lý theo phân hệ dữ liệu",
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0A192F)),
                        ),
                        const SizedBox(height: 16),
                        _buildCollectionsGrid(),
                        const SizedBox(height: 32),
                        _buildConsoleLogs(),
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

  Widget _buildHeaderSection() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Công cụ cho Nhà phát triển (Developer Tools)",
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF0A192F)),
            ),
            SizedBox(height: 4),
            Text(
              "Quản lý việc xóa, khởi tạo và tự động sinh dữ liệu mẫu phục vụ kiểm thử ứng dụng",
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
          ],
        ),
        IconButton(
          icon: const Icon(Icons.refresh, color: Color(0xFFFF6B35)),
          onPressed: _fetchCounts,
          tooltip: "Tải lại số lượng tài liệu",
        )
      ],
    );
  }

  Widget _buildMasterControls() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 12)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Thao tác nhanh trên toàn bộ hệ thống",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0A192F)),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              ElevatedButton.icon(
                onPressed: _isLoading
                    ? null
                    : () => _runAction("Nạp lại toàn bộ dữ liệu gốc", () async {
                          await _seeder.clearAll();
                          await _seeder.seedAllDefaults();
                        }),
                icon: const Icon(Icons.settings_backup_restore),
                label: const Text("Reset & Nạp tất cả dữ liệu gốc"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF6B35),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(width: 16),
              ElevatedButton.icon(
                onPressed: _isLoading ? null : _showClearConfirmDialog,
                icon: const Icon(Icons.delete_forever),
                label: const Text("Xóa sạch toàn bộ CSDL"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCollectionsGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 20,
        mainAxisSpacing: 20,
        childAspectRatio: 1.6,
      ),
      itemCount: _collectionsList.length,
      itemBuilder: (context, index) {
        final col = _collectionsList[index];
        final name = col['name']!;
        final docCount = _counts[name] ?? 0;

        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10)],
            border: Border.all(color: Colors.grey[100]!),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          col['title']!,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF0A192F)),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          col['desc']!,
                          style: TextStyle(color: Colors.grey[500], fontSize: 11),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF6B35).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      "$docCount dòng",
                      style: const TextStyle(color: Color(0xFFFF6B35), fontWeight: FontWeight.bold, fontSize: 11),
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton(
                    onPressed: _isLoading ? null : () => _runAction("Nạp mẫu '$name'", () => _seeder.seedDefault(name)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0A192F).withValues(alpha: 0.05),
                      foregroundColor: const Color(0xFF0A192F),
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text("Nạp mẫu", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                  ),
                  ElevatedButton(
                    onPressed: _isLoading ? null : () => _runAction("Xóa '$name'", () => _seeder.clearCollection(name)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red[50],
                      foregroundColor: Colors.red,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text("Xóa sạch", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Custom generator input
              if (name == 'members' || name == 'transactions' || name == 'products' || name == 'equipment' || name == 'feedbacks' || name == 'users' || name == 'schedules' || name == 'checkins' || name == 'categories' || name == 'media_library' || name == 'contents' || name == 'classes' || name == 'roles')
                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 36,
                        child: TextField(
                          controller: _generateControllers[name],
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                            labelText: "Số lượng sinh",
                            labelStyle: const TextStyle(fontSize: 11),
                            fillColor: Colors.grey[50],
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          style: const TextStyle(fontSize: 12),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton.icon(
                      onPressed: _isLoading
                          ? null
                          : () {
                              final text = _generateControllers[name]?.text ?? '10';
                              final count = int.tryParse(text) ?? 10;
                              _runAction("Tự sinh ngẫu nhiên $count dữ liệu cho '$name'", () async {
                                if (name == 'members') {
                                  await _seeder.generateRandomMembers(count);
                                } else if (name == 'transactions') {
                                  await _seeder.generateRandomTransactions(count);
                                } else if (name == 'products') {
                                  await _seeder.generateRandomProducts(count);
                                } else if (name == 'equipment') {
                                  await _seeder.generateRandomEquipment(count);
                                } else if (name == 'feedbacks') {
                                  await _seeder.generateRandomFeedbacks(count);
                                } else if (name == 'users') {
                                  await _seeder.generateRandomStaff(count);
                                } else if (name == 'schedules') {
                                  await _seeder.generateRandomSchedules(count);
                                } else if (name == 'checkins') {
                                  await _seeder.generateRandomCheckins(count);
                                } else if (name == 'categories') {
                                  await _seeder.generateRandomCategories();
                                } else if (name == 'media_library') {
                                  await _seeder.generateRandomMedia(count);
                                } else if (name == 'contents') {
                                  await _seeder.generateRandomContents(count);
                                } else if (name == 'classes') {
                                  await _seeder.seedDefault('classes');
                                } else if (name == 'roles') {
                                  await _seeder.seedDefault('roles');
                                }
                              });
                            },
                      icon: const Icon(Icons.bolt, size: 14),
                      label: const Text("Sinh dữ liệu", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF6B35),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                  ],
                )
              else
                const SizedBox(height: 36), // Empty space placeholder to align cards
            ],
          ),
        );
      },
    );
  }

  Widget _buildConsoleLogs() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.15), blurRadius: 15)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Logs Window Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: const BoxDecoration(
              color: Color(0xFF2D2D2D),
              borderRadius: BorderRadius.only(topLeft: Radius.circular(16), topRight: Radius.circular(16)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Icon(Icons.terminal, color: Colors.greenAccent, size: 20),
                    SizedBox(width: 8),
                    Text(
                      "Nhật ký bảng điều khiển Dev (Terminal Logs)",
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13, fontFamily: 'monospace'),
                    ),
                  ],
                ),
                TextButton.icon(
                  onPressed: () {
                    setState(() {
                      _logs.clear();
                    });
                  },
                  icon: const Icon(Icons.clear_all, color: Colors.white70, size: 16),
                  label: const Text("Xóa log", style: TextStyle(color: Colors.white70, fontSize: 11)),
                )
              ],
            ),
          ),
          // Logs output list
          Container(
            height: 220,
            padding: const EdgeInsets.all(16),
            child: _logs.isEmpty
                ? const Center(
                    child: Text(
                      "Chưa có hành động nào được ghi nhận.",
                      style: TextStyle(color: Colors.grey, fontFamily: 'monospace', fontSize: 13),
                    ),
                  )
                : ListView.builder(
                    controller: _logScrollController,
                    itemCount: _logs.length,
                    itemBuilder: (context, index) {
                      final log = _logs[index];
                      // Style error, warning and info logs differently
                      Color textColor = Colors.white70;
                      if (log.contains("❌")) {
                        textColor = Colors.redAccent;
                      } else if (log.contains("✔️") || log.contains("🎉")) {
                        textColor = Colors.greenAccent;
                      } else if (log.contains("🗑️") || log.contains("▶️")) {
                        textColor = const Color(0xFFFFCC00);
                      }
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 6.0),
                        child: Text(
                          log,
                          style: TextStyle(
                            color: textColor,
                            fontFamily: 'monospace',
                            fontSize: 12,
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
