import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

import '../../../data/models/social_post_model.dart';
import '../../../data/models/user_model.dart';
import '../../../provider/home_provider.dart';
import '../../../widget/home_social_feed/home_post_card.dart';
import '../../../widget/home_social_feed/home_social_feed_theme.dart';

class UserProfileScreen extends StatelessWidget {
  const UserProfileScreen({super.key, required this.userId});

  final String userId;

  static final List<Map<String, dynamic>> _mockTrainers = [
    {
      'uid': 'mock_alex',
      'fullName': 'ALEX THORNE',
      'rating': 5.0,
      'experience': '12+ Yrs',
      'clients': '310',
      'specialities': ['STRENGTH', 'CONDITIONING'],
      'price': 90,
      'position': 'Elite Strength & Conditioning',
      'imageUrl': 'https://images.unsplash.com/photo-1567013127542-490d757e51fc?w=500&auto=format&fit=crop&q=60',
    },
    {
      'uid': 'mock_marcus',
      'fullName': 'COACH MARCUS',
      'rating': 4.9,
      'experience': '8+ Yrs',
      'clients': '124',
      'specialities': ['BODYBUILDING', 'NUTRITION'],
      'price': 65,
      'position': 'PT/Trainer',
      'imageUrl': 'https://images.unsplash.com/photo-1534438327276-14e5300c3a48?w=500&auto=format&fit=crop&q=60',
    },
    {
      'uid': 'mock_sarah',
      'fullName': 'SARAH CHEN',
      'rating': 5.0,
      'experience': '6+ Yrs',
      'clients': '89',
      'specialities': ['HIIT', 'PILATES'],
      'price': 80,
      'position': 'PT/Trainer',
      'imageUrl': 'https://images.unsplash.com/photo-1548690312-e3b507d8c110?w=500&auto=format&fit=crop&q=60',
    },
    {
      'uid': 'mock_david',
      'fullName': 'DAVID MILLER',
      'rating': 4.8,
      'experience': '10+ Yrs',
      'clients': '210',
      'specialities': ['CROSSFIT', 'KETTLEBELL'],
      'price': 75,
      'position': 'PT/Trainer',
      'imageUrl': 'https://images.unsplash.com/photo-1507398941214-572c25f4b1bc?w=500&auto=format&fit=crop&q=60',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final provider = context.read<HomeProvider>();

    return Scaffold(
      backgroundColor: HomeSocialFeedTheme.bg,
      appBar: AppBar(
        backgroundColor: HomeSocialFeedTheme.bg,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'TRANG CÁ NHÂN',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.1,
          ),
        ),
        centerTitle: true,
      ),
      body: FutureBuilder<UserModel?>(
        future: provider.getUserById(userId),
        builder: (context, userSnapshot) {
          if (userSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                color: HomeSocialFeedTheme.accent,
              ),
            );
          }

          final user = userSnapshot.data;
          UserModel? resolvedUser = user;
          String? mockImageUrl;

          if (userId.startsWith('mock_')) {
            final mock = _mockTrainers.firstWhere((t) => t['uid'] == userId, orElse: () => {});
            if (mock.isNotEmpty) {
              resolvedUser = UserModel(
                uid: mock['uid'],
                fullName: mock['fullName'],
                email: '${mock['uid']}@kinetic.com',
                role: 'trainer',
                position: mock['position'],
              );
              mockImageUrl = mock['imageUrl'];
            }
          }

          final displayName = resolvedUser?.fullName ?? 'Thành viên';
          final email = resolvedUser?.email ?? '';
          final position = resolvedUser?.position ?? (resolvedUser?.role == 'admin' ? 'Quản trị viên' : 'Hội viên');

          // Check if this user is a Trainer (PT)
          final isTrainer = resolvedUser?.role == 'trainer' || 
                            resolvedUser?.position?.toLowerCase().contains('trainer') == true ||
                            resolvedUser?.position?.toLowerCase().contains('pt') == true;

          return CustomScrollView(
            slivers: [
              // PROFILE HEADER CARD
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: HomeSocialFeedTheme.card,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: Colors.white10),
                    ),
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        Builder(
                          builder: (context) {
                            final displayAvatarUrl = mockImageUrl ?? resolvedUser?.avatarUrl;
                            final hasAvatar = displayAvatarUrl != null && displayAvatarUrl.trim().isNotEmpty;
                            return CircleAvatar(
                              radius: 48,
                              backgroundColor: HomeSocialFeedTheme.cardAlt,
                              backgroundImage: hasAvatar ? NetworkImage(displayAvatarUrl) : null,
                              child: !hasAvatar
                                  ? Text(
                                      displayName.isNotEmpty ? displayName[0].toUpperCase() : '?',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 36,
                                        fontWeight: FontWeight.w900,
                                      ),
                                    )
                                  : null,
                            );
                          }
                        ),
                        const SizedBox(height: 16),
                        Text(
                          displayName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFF20242B),
                            borderRadius: BorderRadius.circular(99),
                            border: Border.all(color: Colors.white10),
                          ),
                          child: Text(
                            position.toUpperCase(),
                            style: const TextStyle(
                              color: HomeSocialFeedTheme.accent,
                              fontSize: 10,
                              fontWeight: FontWeight.w900,
                              letterSpacing: .8,
                            ),
                          ),
                        ),
                        if (email.isNotEmpty) ...[
                          const SizedBox(height: 12),
                          Text(
                            email,
                            style: const TextStyle(
                              color: HomeSocialFeedTheme.muted,
                              fontSize: 14,
                            ),
                          ),
                        ],
                        if (user?.phoneNumber != null && user!.phoneNumber!.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            user.phoneNumber!,
                            style: const TextStyle(
                              color: HomeSocialFeedTheme.muted,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),



              // SECTION POSTS LABEL
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(20, 16, 20, 8),
                  child: Text(
                    'BÀI ĐĂNG GẦN ĐÂY',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
              ),

              // LIST OF POSTS
              StreamBuilder<List<SocialPostModel>>(
                stream: provider.watchPostsByUserId(userId),
                builder: (context, postsSnapshot) {
                  if (postsSnapshot.connectionState == ConnectionState.waiting) {
                    return const SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.all(32.0),
                        child: Center(
                          child: CircularProgressIndicator(
                            color: HomeSocialFeedTheme.accent,
                          ),
                        ),
                      ),
                    );
                  }

                  final posts = postsSnapshot.data ?? const <SocialPostModel>[];
                  if (posts.isEmpty) {
                    return const SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.all(40.0),
                        child: Center(
                          child: Text(
                            'Chưa có bài đăng nào.',
                            style: TextStyle(
                              color: HomeSocialFeedTheme.muted,
                              fontSize: 15,
                            ),
                          ),
                        ),
                      ),
                    );
                  }

                  return SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 16.0),
                            child: HomePostCard(post: posts[index]),
                          );
                        },
                        childCount: posts.length,
                      ),
                    ),
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }

  void _showBookingSheet(BuildContext context, UserModel trainer) {
    DateTime now = DateTime.now();
    DateTime selectedDate = now;
    String selectedSlot = '08:00 - 09:30';
    final TextEditingController noteController = TextEditingController();

    final List<String> slots = [
      '08:00 - 09:30',
      '10:00 - 11:30',
      '14:00 - 15:30',
      '16:00 - 17:30',
      '18:00 - 19:30',
    ];

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
                  Text(
                    'ĐẶT LỊCH HẸN VỚI ${trainer.fullName.toUpperCase()}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 1. CHỌN NGÀY
                  const Text('CHỌN NGÀY TẬP', style: TextStyle(color: Color(0xFF8E9196), fontSize: 10, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 70,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: 7,
                      itemBuilder: (context, index) {
                        final date = now.add(Duration(days: index));
                        final isSame = DateUtils.isSameDay(date, selectedDate);
                        final weekday = DateFormat('E').format(date).toUpperCase();
                        final dayStr = date.day.toString();

                        return GestureDetector(
                          onTap: () => setSheetState(() => selectedDate = date),
                          child: Container(
                            width: 60,
                            margin: const EdgeInsets.only(right: 8),
                            decoration: BoxDecoration(
                              color: isSame ? const Color(0xFFE7F0BD) : const Color(0xFF20242B),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  weekday,
                                  style: TextStyle(
                                    color: isSame ? Colors.black : Colors.white60,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  dayStr,
                                  style: TextStyle(
                                    color: isSame ? Colors.black : Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 20),

                  // 2. CHỌN KHUNG GIỜ
                  const Text('CHỌN KHUNG GIỜ', style: TextStyle(color: Color(0xFF8E9196), fontSize: 10, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: slots.map((slot) {
                      final isSelected = selectedSlot == slot;
                      return GestureDetector(
                        onTap: () => setSheetState(() => selectedSlot = slot),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          decoration: BoxDecoration(
                            color: isSelected ? const Color(0xFFE7F0BD) : const Color(0xFF20242B),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            slot,
                            style: TextStyle(
                              color: isSelected ? Colors.black : Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),

                  // 3. GHI CHÚ
                  const Text('MỤC TIÊU & GHI CHÚ BUỔI TẬP', style: TextStyle(color: Color(0xFF8E9196), fontSize: 10, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF20242B),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: TextField(
                      controller: noteController,
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                      maxLines: 3,
                      cursorColor: const Color(0xFFE7F0BD),
                      decoration: const InputDecoration(
                        hintText: 'VD: Tập trung nâng cơ ngực, sửa tư thế squat...',
                        hintStyle: TextStyle(color: Colors.white30, fontSize: 13),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // NÚT BOOKING
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: FilledButton(
                      onPressed: () async {
                        final user = FirebaseAuth.instance.currentUser;
                        if (user == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Vui lòng đăng nhập để đặt lịch.')),
                          );
                          return;
                        }

                        // Parse time from slot
                        final startHour = int.parse(selectedSlot.split(' - ')[0].split(':')[0]);
                        final startMin = int.parse(selectedSlot.split(' - ')[0].split(':')[1]);
                        final startTime = DateTime(
                          selectedDate.year,
                          selectedDate.month,
                          selectedDate.day,
                          startHour,
                          startMin,
                        );

                        final endHour = int.parse(selectedSlot.split(' - ')[1].split(':')[0]);
                        final endMin = int.parse(selectedSlot.split(' - ')[1].split(':')[1]);
                        final endTime = DateTime(
                          selectedDate.year,
                          selectedDate.month,
                          selectedDate.day,
                          endHour,
                          endMin,
                        );

                        // Save to Firebase collection 'schedules'
                        try {
                          await FirebaseFirestore.instance.collection('schedules').add({
                            'staffUid': trainer.uid,
                            'staffName': trainer.fullName,
                            'studentUid': user.uid,
                            'studentName': user.displayName ?? (user.email ?? 'Client').split('@').first,
                            'startTime': Timestamp.fromDate(startTime),
                            'endTime': Timestamp.fromDate(endTime),
                            'status': 'pending',
                            'task': noteController.text.trim().isNotEmpty 
                                ? 'Ca tập: ${noteController.text.trim()}' 
                                : 'Ca tập cá nhân với HLV',
                            'createdAt': FieldValue.serverTimestamp(),
                          });

                          // Add activity track
                          await FirebaseFirestore.instance.collection('pt_activities').add({
                            'ptId': trainer.uid,
                            'type': 'booking',
                            'title': 'Lịch hẹn mới',
                            'subtitle': 'Học viên đặt lịch tập vào ${DateFormat('dd/MM HH:mm').format(startTime)}',
                            'timestamp': FieldValue.serverTimestamp(),
                          });

                          if (context.mounted) {
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                backgroundColor: Color(0xFFE7F0BD),
                                content: Text(
                                  'Đăng ký ca tập thành công! HLV sẽ duyệt lịch sớm.',
                                  style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                                ),
                              ),
                            );
                          }
                        } catch (e) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Đặt lịch thất bại: $e')),
                            );
                          }
                        }
                      },
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFFE7F0BD),
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text(
                        'XÁC NHẬN ĐẶT LỊCH',
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
}
