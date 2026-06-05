import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import '../../app/route/routes.dart';
import '../home_social_feed/home_social_feed_theme.dart';

class CustomerHomeWorkoutsTab extends StatefulWidget {
  const CustomerHomeWorkoutsTab({super.key});

  @override
  State<CustomerHomeWorkoutsTab> createState() => _CustomerHomeWorkoutsTabState();
}

class _CustomerHomeWorkoutsTabState extends State<CustomerHomeWorkoutsTab> {
  DateTime selectedDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const Scaffold(
        backgroundColor: HomeSocialFeedTheme.bg,
        body: Center(
          child: Text(
            'Vui lòng đăng nhập để xem lịch tập.',
            style: TextStyle(color: Colors.white),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: HomeSocialFeedTheme.bg,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(user.uid),
            const SizedBox(height: 16),
            _buildHorizontalCalendar(),
            const SizedBox(height: 24),
            _buildSectionTitle(),
            const SizedBox(height: 12),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('schedules')
                    .where('studentUid', isEqualTo: user.uid)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Center(
                      child: Text(
                        "Lỗi: ${snapshot.error}",
                        style: const TextStyle(color: Colors.redAccent),
                      ),
                    );
                  }
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(color: Color(0xFFD0FD3E)),
                    );
                  }

                  final docs = snapshot.data?.docs ?? [];
                  
                  // Filter by selectedDate at local level
                  final dailySessions = docs.where((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    if (data['startTime'] == null) return false;
                    final startTime = (data['startTime'] as Timestamp).toDate();
                    return DateUtils.isSameDay(startTime, selectedDate);
                  }).toList();

                  // Sort chronologically
                  dailySessions.sort((a, b) {
                    final aTime = (a.data() as Map<String, dynamic>)['startTime'] as Timestamp;
                    final bTime = (b.data() as Map<String, dynamic>)['startTime'] as Timestamp;
                    return aTime.compareTo(bTime);
                  });

                  if (dailySessions.isEmpty) {
                    return _buildEmptyState();
                  }

                  return ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: dailySessions.length,
                    itemBuilder: (context, index) {
                      final doc = dailySessions[index];
                      final data = doc.data() as Map<String, dynamic>;
                      return _buildSessionCard(doc.id, data);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(String currentUserId) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "LỊCH TRÌNH TẬP LUYỆN",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                DateFormat('MMMM yyyy', 'vi_VN').format(selectedDate).toUpperCase(),
                style: const TextStyle(
                  color: HomeSocialFeedTheme.muted,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.0,
                ),
              ),
            ],
          ),
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('schedules')
                .where('studentUid', isEqualTo: currentUserId)
                .limit(1)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
                final data = snapshot.data!.docs.first.data() as Map<String, dynamic>;
                final ptUid = data['staffUid'];
                final ptName = data['staffName'] ?? 'HLV Cá Nhân';
                if (ptUid != null && ptUid.toString().isNotEmpty) {
                  return IconButton(
                    icon: const Icon(
                      Icons.chat_bubble_outline_rounded,
                      color: Color(0xFFD0FD3E),
                      size: 28,
                    ),
                    onPressed: () {
                      final List<String> ids = [currentUserId, ptUid];
                      ids.sort();
                      final chatRoomId = ids.join('_');
                      context.push(
                        '${Routes.chat}?chatRoomId=$chatRoomId&otherUserId=$ptUid&otherUserName=$ptName'
                      );
                    },
                  );
                }
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildHorizontalCalendar() {
    DateTime now = DateTime.now();
    // Show 14 days starting from 3 days ago to plan ahead
    DateTime startPoint = now.subtract(const Duration(days: 3));
    
    return SizedBox(
      height: 75,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        physics: const BouncingScrollPhysics(),
        itemCount: 14,
        itemBuilder: (context, index) {
          DateTime date = startPoint.add(Duration(days: index));
          bool isSelected = DateUtils.isSameDay(date, selectedDate);
          bool isToday = DateUtils.isSameDay(date, now);

          String weekday = DateFormat('E', 'vi_VN').format(date).toUpperCase();
          if (weekday.startsWith('THỨ')) {
            weekday = weekday.replaceAll('THỨ ', 'T');
          } else if (weekday == 'CHỦ NHẬT') {
            weekday = 'CN';
          }

          return GestureDetector(
            onTap: () => setState(() => selectedDate = date),
            child: Container(
              width: 58,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFFD0FD3E) : const Color(0xFF14161A),
                borderRadius: BorderRadius.circular(16),
                border: isToday && !isSelected
                    ? Border.all(color: const Color(0xFFD0FD3E), width: 1.5)
                    : Border.all(color: Colors.white.withOpacity(0.05)),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    weekday,
                    style: TextStyle(
                      color: isSelected ? Colors.black : HomeSocialFeedTheme.muted,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    date.day.toString(),
                    style: TextStyle(
                      color: isSelected ? Colors.black : Colors.white,
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
    );
  }

  Widget _buildSectionTitle() {
    final formatDay = DateFormat('dd/MM/yyyy').format(selectedDate);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            "DANH SÁCH CA TẬP",
            style: TextStyle(
              color: HomeSocialFeedTheme.muted,
              fontSize: 11,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.5,
            ),
          ),
          Text(
            formatDay,
            style: const TextStyle(
              color: Color(0xFFD0FD3E),
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF14161A),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white.withOpacity(0.05)),
            ),
            child: const Icon(
              Icons.fitness_center_rounded,
              color: HomeSocialFeedTheme.muted,
              size: 40,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            "Không có lịch tập nào",
            style: TextStyle(
              color: Colors.white70,
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            "Lịch tập do PT sắp xếp sẽ hiển thị tại đây",
            style: TextStyle(
              color: HomeSocialFeedTheme.muted,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSessionCard(String id, Map<String, dynamic> data) {
    final DateTime startTime = (data['startTime'] as Timestamp).toDate();
    final DateTime endTime = (data['endTime'] as Timestamp).toDate();
    final String timeStr = "${DateFormat('HH:mm').format(startTime)} - ${DateFormat('HH:mm').format(endTime)}";
    final String ptName = data['staffName'] ?? 'HLV Cá Nhân';
    final String task = data['task'] ?? 'Luyện tập thể hình';
    final String status = (data['status'] ?? 'pending').toString().toLowerCase();

    Color statusColor = Colors.orangeAccent;
    String statusLabel = "SẮP TỚI";
    if (status == 'ongoing') {
      statusColor = const Color(0xFFD0FD3E);
      statusLabel = "ĐANG TẬP";
    } else if (status == 'completed') {
      statusColor = Colors.grey;
      statusLabel = "ĐÃ TẬP";
    }

    final hasNotes = status == 'completed' && (data['focus'] != null || data['notes'] != null);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: HomeSocialFeedTheme.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: status == 'ongoing' 
              ? const Color(0xFFD0FD3E).withOpacity(0.2) 
              : Colors.white.withOpacity(0.05),
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.access_time_rounded, color: HomeSocialFeedTheme.accent, size: 16),
                          const SizedBox(width: 8),
                          Text(
                            timeStr,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.black45,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: statusColor.withOpacity(0.3)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 6,
                              height: 6,
                              decoration: BoxDecoration(color: statusColor, shape: BoxShape.circle),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              statusLabel,
                              style: TextStyle(
                                color: statusColor,
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Text(
                    task,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.person_outline_rounded, color: HomeSocialFeedTheme.muted, size: 14),
                          const SizedBox(width: 6),
                          Text(
                            "HLV: $ptName",
                            style: const TextStyle(
                              color: HomeSocialFeedTheme.muted,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      if (data['staffUid'] != null && data['staffUid'].toString().isNotEmpty)
                        GestureDetector(
                          onTap: () {
                            final customerUid = FirebaseAuth.instance.currentUser?.uid ?? '';
                            final ptUid = data['staffUid'];
                            final List<String> ids = [customerUid, ptUid];
                            ids.sort();
                            final chatRoomId = ids.join('_');
                            
                            context.push(
                              '${Routes.chat}?chatRoomId=$chatRoomId&otherUserId=$ptUid&otherUserName=$ptName'
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: HomeSocialFeedTheme.accent.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: HomeSocialFeedTheme.accent.withOpacity(0.3)),
                            ),
                            child: const Row(
                              children: [
                                Icon(Icons.chat_bubble_outline_rounded, color: HomeSocialFeedTheme.accent, size: 12),
                                SizedBox(width: 4),
                                Text(
                                  "Trò chuyện",
                                  style: TextStyle(color: HomeSocialFeedTheme.accent, fontSize: 10, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            if (hasNotes)
              InkWell(
                onTap: () => _showSessionSummary(context, ptName, data),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                  color: Colors.white.withOpacity(0.02),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Text(
                        "Xem nhận xét & Nhật ký của HLV",
                        style: TextStyle(
                          color: Color(0xFFD0FD3E),
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Icon(
                        Icons.arrow_forward_ios_rounded,
                        color: Color(0xFFD0FD3E),
                        size: 12,
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _showSessionSummary(BuildContext context, String ptName, Map<String, dynamic> data) {
    final String focus = data['focus'] ?? 'Không ghi nhận';
    final String notes = data['notes'] ?? 'Không có ghi chú';

    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xFF14161A),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white12),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "NHẬT KÝ BUỔI TẬP",
                    style: TextStyle(
                      color: Color(0xFFD0FD3E),
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.0,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close, color: Colors.grey, size: 20),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  )
                ],
              ),
              const SizedBox(height: 10),
              Text(
                "PT: $ptName",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                "TRỌNG TÂM LUYỆN TẬP",
                style: TextStyle(
                  color: HomeSocialFeedTheme.muted,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                focus,
                style: const TextStyle(color: Colors.white, fontSize: 14),
              ),
              const SizedBox(height: 18),
              const Text(
                "NHẬN XÉT CỦA HLV PT",
                style: TextStyle(
                  color: HomeSocialFeedTheme.muted,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                notes,
                style: const TextStyle(color: Colors.white70, fontSize: 14, height: 1.3),
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }
}
