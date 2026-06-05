import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../home_social_feed/home_social_feed_theme.dart';

class CustomerHomeProfileTab extends StatefulWidget {
  const CustomerHomeProfileTab({
    super.key,
    required this.onLogout,
    required this.loading,
  });

  final Future<void> Function() onLogout;
  final bool loading;

  @override
  State<CustomerHomeProfileTab> createState() => _CustomerHomeProfileTabState();
}

class _CustomerHomeProfileTabState extends State<CustomerHomeProfileTab> {
  bool _appNotifications = true;
  bool _remindersEnabled = true;

  // Function to show edit dialog / bottom sheet
  void _showEditProfileSheet(BuildContext context, Map<String, dynamic> userData, String uid) {
    final nameController = TextEditingController(text: userData['fullName'] ?? '');
    final phoneController = TextEditingController(text: userData['phone'] ?? userData['phoneNumber'] ?? '');
    final addressController = TextEditingController(text: userData['address'] ?? '');
    String selectedGender = userData['gender'] ?? 'Khác';
    final List<String> genders = ['Nam', 'Nữ', 'Khác'];

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF14161A),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                left: 24,
                right: 24,
                top: 18,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 44,
                      height: 5,
                      decoration: BoxDecoration(
                        color: Colors.white24,
                        borderRadius: BorderRadius.circular(99),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  const Text(
                    'CẬP NHẬT THÔNG TIN',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Họ & Tên
                  const Text('HỌ VÀ TÊN', style: TextStyle(color: Color(0xFF8E9196), fontSize: 10, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF20242B),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: TextField(
                      controller: nameController,
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                      cursorColor: HomeSocialFeedTheme.accent,
                      decoration: const InputDecoration(
                        hintText: 'Nhập họ và tên...',
                        hintStyle: TextStyle(color: Colors.white30, fontSize: 13),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Số điện thoại
                  const Text('SỐ ĐIỆN THOẠI', style: TextStyle(color: Color(0xFF8E9196), fontSize: 10, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF20242B),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: TextField(
                      controller: phoneController,
                      keyboardType: TextInputType.phone,
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                      cursorColor: HomeSocialFeedTheme.accent,
                      decoration: const InputDecoration(
                        hintText: 'Nhập số điện thoại...',
                        hintStyle: TextStyle(color: Colors.white30, fontSize: 13),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Giới tính
                  const Text('GIỚI TÍNH', style: TextStyle(color: Color(0xFF8E9196), fontSize: 10, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Row(
                    children: genders.map((gender) {
                      final isSelected = selectedGender == gender;
                      return GestureDetector(
                        onTap: () => setSheetState(() => selectedGender = gender),
                        child: Container(
                          margin: const EdgeInsets.only(right: 12),
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                          decoration: BoxDecoration(
                            color: isSelected ? HomeSocialFeedTheme.accent : const Color(0xFF20242B),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            gender,
                            style: TextStyle(
                              color: isSelected ? Colors.black : Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),

                  // Địa chỉ
                  const Text('ĐỊA CHỈ', style: TextStyle(color: Color(0xFF8E9196), fontSize: 10, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF20242B),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: TextField(
                      controller: addressController,
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                      cursorColor: HomeSocialFeedTheme.accent,
                      decoration: const InputDecoration(
                        hintText: 'Nhập địa chỉ của bạn...',
                        hintStyle: TextStyle(color: Colors.white30, fontSize: 13),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Nút Lưu
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: FilledButton(
                      onPressed: () async {
                        try {
                          await FirebaseFirestore.instance.collection('users').doc(uid).update({
                            'fullName': nameController.text.trim(),
                            'phone': phoneController.text.trim(),
                            'phoneNumber': phoneController.text.trim(),
                            'gender': selectedGender,
                            'address': addressController.text.trim(),
                            'updatedAt': FieldValue.serverTimestamp(),
                          });
                          if (context.mounted) {
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                backgroundColor: HomeSocialFeedTheme.accent,
                                content: Text(
                                  'Cập nhật thông tin thành công!',
                                  style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                                ),
                              ),
                            );
                          }
                        } catch (e) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Lỗi cập nhật: $e')),
                            );
                          }
                        }
                      },
                      style: FilledButton.styleFrom(
                        backgroundColor: HomeSocialFeedTheme.accent,
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text(
                        'LƯU THAY ĐỔI',
                        style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.1),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showUnimplementedToast(BuildContext context, String featureName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF14161A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          featureName.toUpperCase(),
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
        ),
        content: const Text(
          'Chức năng này đang được phát triển và sẽ sớm ra mắt trong các phiên bản cập nhật tiếp theo.',
          style: TextStyle(color: Colors.white70, fontSize: 14, height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'ĐỒNG Ý',
              style: TextStyle(color: HomeSocialFeedTheme.accent, fontWeight: FontWeight.bold),
            ),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const Center(
        child: Text(
          'Vui lòng đăng nhập.',
          style: TextStyle(color: Colors.white),
        ),
      );
    }

    return Scaffold(
      backgroundColor: HomeSocialFeedTheme.bg,
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance.collection('users').doc(user.uid).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: HomeSocialFeedTheme.accent),
            );
          }

          final userData = snapshot.data?.data() as Map<String, dynamic>? ?? {};
          final name = userData['fullName'] ?? user.displayName ?? user.email?.split('@').first ?? 'Thành viên';
          final email = userData['email'] ?? user.email ?? '';
          final phone = userData['phone'] ?? userData['phoneNumber'] ?? 'Chưa cập nhật';
          final address = userData['address'] ?? 'Chưa cập nhật';
          final gender = userData['gender'] ?? 'Chưa cập nhật';

          return CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // 1. APP BAR HEADER
              SliverAppBar(
                expandedHeight: 110,
                backgroundColor: HomeSocialFeedTheme.bg,
                floating: false,
                pinned: true,
                elevation: 0,
                flexibleSpace: const FlexibleSpaceBar(
                  centerTitle: true,
                  title: Text(
                    'TÀI KHOẢN CỦA TÔI',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
              ),

              // 2. USER OVERVIEW CARD
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF1B1D22), Color(0xFF121418)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: Colors.white.withOpacity(0.08)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 15,
                          offset: const Offset(0, 8),
                        )
                      ],
                    ),
                    padding: const EdgeInsets.all(24),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 36,
                          backgroundColor: const Color(0xFF2C2F36),
                          child: Text(
                            name.isNotEmpty ? name[0].toUpperCase() : 'U',
                            style: const TextStyle(
                              color: HomeSocialFeedTheme.accent,
                              fontSize: 28,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                name,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                email,
                                style: const TextStyle(
                                  color: HomeSocialFeedTheme.muted,
                                  fontSize: 13,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 8),
                              GestureDetector(
                                onTap: () => _showEditProfileSheet(context, userData, user.uid),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: HomeSocialFeedTheme.accent.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: HomeSocialFeedTheme.accent.withOpacity(0.3)),
                                  ),
                                  child: const Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.edit_rounded, color: HomeSocialFeedTheme.accent, size: 12),
                                      SizedBox(width: 6),
                                      Text(
                                        'Chỉnh sửa hồ sơ',
                                        style: TextStyle(
                                          color: HomeSocialFeedTheme.accent,
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // 3. PERSONAL INFORMATION SECTION
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'THÔNG TIN CÁ NHÂN',
                        style: TextStyle(
                          color: HomeSocialFeedTheme.muted,
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.5,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        decoration: BoxDecoration(
                          color: HomeSocialFeedTheme.card,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.white.withOpacity(0.05)),
                        ),
                        padding: const EdgeInsets.all(18),
                        child: Column(
                          children: [
                            _buildInfoRow(Icons.phone_iphone_rounded, 'Số điện thoại', phone),
                            const Divider(color: Colors.white12, height: 24),
                            _buildInfoRow(Icons.face_rounded, 'Giới tính', gender),
                            const Divider(color: Colors.white12, height: 24),
                            _buildInfoRow(Icons.location_on_rounded, 'Địa chỉ', address),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // 4. NOTIFICATION SETTINGS SECTION
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'CÀI ĐẶT THÔNG BÁO',
                        style: TextStyle(
                          color: HomeSocialFeedTheme.muted,
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.5,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        decoration: BoxDecoration(
                          color: HomeSocialFeedTheme.card,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.white.withOpacity(0.05)),
                        ),
                        child: Column(
                          children: [
                            SwitchListTile(
                              title: const Text(
                                'Thông báo từ ứng dụng',
                                style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                              ),
                              subtitle: const Text(
                                'Cập nhật tin tức, ưu đãi và bài viết mới',
                                style: TextStyle(color: HomeSocialFeedTheme.muted, fontSize: 12),
                              ),
                              value: _appNotifications,
                              activeColor: HomeSocialFeedTheme.accent,
                              activeTrackColor: HomeSocialFeedTheme.accent.withOpacity(0.2),
                              inactiveTrackColor: Colors.white12,
                              onChanged: (val) => setState(() => _appNotifications = val),
                            ),
                            const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 16),
                              child: Divider(color: Colors.white10, height: 1),
                            ),
                            SwitchListTile(
                              title: const Text(
                                'Nhắc nhở lịch tập',
                                style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                              ),
                              subtitle: const Text(
                                'Thông báo trước ca tập với HLV cá nhân',
                                style: TextStyle(color: HomeSocialFeedTheme.muted, fontSize: 12),
                              ),
                              value: _remindersEnabled,
                              activeColor: HomeSocialFeedTheme.accent,
                              activeTrackColor: HomeSocialFeedTheme.accent.withOpacity(0.2),
                              inactiveTrackColor: Colors.white12,
                              onChanged: (val) => setState(() => _remindersEnabled = val),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // 5. PERSONAL TRAINER (PT) SECTION
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'HUẤN LUYỆN VIÊN (PT)',
                        style: TextStyle(
                          color: HomeSocialFeedTheme.muted,
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.5,
                        ),
                      ),
                      const SizedBox(height: 12),
                      // Query active PT contracts or bookings
                      StreamBuilder<QuerySnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection('schedules')
                            .where('studentUid', isEqualTo: user.uid)
                            .where('status', isEqualTo: 'approved')
                            .snapshots(),
                        builder: (context, schedSnapshot) {
                          final hasPT = schedSnapshot.hasData && schedSnapshot.data!.docs.isNotEmpty;
                          String trainerName = 'Chưa đăng ký HLV';
                          String infoText = 'Bạn chưa có lịch tập nào được duyệt với HLV';

                          if (hasPT) {
                            final doc = schedSnapshot.data!.docs.first;
                            final data = doc.data() as Map<String, dynamic>;
                            trainerName = data['staffName'] ?? 'HLV Cá Nhân';
                            infoText = 'Có lịch tập được xếp với huấn luyện viên này.';
                          }

                          return Container(
                            decoration: BoxDecoration(
                              color: HomeSocialFeedTheme.card,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: Colors.white.withOpacity(0.05)),
                            ),
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: HomeSocialFeedTheme.accent.withOpacity(0.05),
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(color: HomeSocialFeedTheme.accent.withOpacity(0.15)),
                                  ),
                                  child: const Icon(
                                    Icons.sports_gymnastics_rounded,
                                    color: HomeSocialFeedTheme.accent,
                                    size: 24,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        trainerName,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        infoText,
                                        style: const TextStyle(
                                          color: HomeSocialFeedTheme.muted,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),

              // 6. OTHER UTILITIES (PLACEHOLDERS FOR UNIMPLEMENTED FEATURES)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'TIỆN ÍCH KHÁC',
                        style: TextStyle(
                          color: HomeSocialFeedTheme.muted,
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.5,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        decoration: BoxDecoration(
                          color: HomeSocialFeedTheme.card,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.white.withOpacity(0.05)),
                        ),
                        child: Column(
                          children: [
                            _buildUtilityTile(
                              context,
                              icon: Icons.receipt_long_rounded,
                              title: 'Lịch sử thanh toán & Đơn hàng',
                              onTap: () => _showUnimplementedToast(context, 'Lịch sử thanh toán & Đơn hàng'),
                            ),
                            const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 16),
                              child: Divider(color: Colors.white10, height: 1),
                            ),
                            _buildUtilityTile(
                              context,
                              icon: Icons.vpn_key_rounded,
                              title: 'Nhật ký sử dụng Tủ đồ (Locker)',
                              onTap: () => _showUnimplementedToast(context, 'Nhật ký sử dụng Tủ đồ'),
                            ),
                            const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 16),
                              child: Divider(color: Colors.white10, height: 1),
                            ),
                            _buildUtilityTile(
                              context,
                              icon: Icons.lock_reset_rounded,
                              title: 'Đổi mật khẩu tài khoản',
                              onTap: () async {
                                try {
                                  if (email.isNotEmpty) {
                                    await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          backgroundColor: HomeSocialFeedTheme.accent,
                                          content: Text(
                                            'Đã gửi email đặt lại mật khẩu đến $email',
                                            style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                      );
                                    }
                                  }
                                } catch (e) {
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('Lỗi: $e')),
                                    );
                                  }
                                }
                              },
                            ),
                            const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 16),
                              child: Divider(color: Colors.white10, height: 1),
                            ),
                            _buildUtilityTile(
                              context,
                              icon: Icons.info_outline_rounded,
                              title: 'Điều khoản & Hỗ trợ kỹ thuật',
                              onTap: () => _showUnimplementedToast(context, 'Điều khoản & Hỗ trợ kỹ thuật'),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // 7. LOGOUT BUTTON
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  child: SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton.icon(
                      onPressed: widget.loading ? null : widget.onLogout,
                      icon: const Icon(Icons.logout_rounded, color: Colors.white70),
                      label: Text(
                        widget.loading ? 'ĐANG ĐĂNG XUẤT...' : 'ĐĂNG XUẤT TÀI KHOẢN',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.1,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF231416),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                          side: const BorderSide(color: Color(0xFF421E22)),
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // BOTTOM SPACING FOR FLOATING BOTTOM NAV BAR
              const SliverToBoxAdapter(
                child: SizedBox(height: 120),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: HomeSocialFeedTheme.muted, size: 20),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label.toUpperCase(),
                style: const TextStyle(
                  color: HomeSocialFeedTheme.muted,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildUtilityTile(BuildContext context, {required IconData icon, required String title, required VoidCallback onTap}) {
    return ListTile(
      leading: Icon(icon, color: Colors.white70, size: 20),
      title: Text(
        title,
        style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
      ),
      trailing: const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white30, size: 14),
      onTap: onTap,
    );
  }
}
