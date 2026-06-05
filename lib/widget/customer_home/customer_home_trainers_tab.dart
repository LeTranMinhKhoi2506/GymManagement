import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../app/route/routes.dart';
import '../home_social_feed/home_social_feed_theme.dart';

class CustomerTrainersTab extends StatefulWidget {
  const CustomerTrainersTab({super.key});

  @override
  State<CustomerTrainersTab> createState() => _CustomerTrainersTabState();
}

class _CustomerTrainersTabState extends State<CustomerTrainersTab> {
  String _searchQuery = '';
  String _selectedCategory = 'ALL TRAINERS';

  final List<String> _categories = [
    'ALL TRAINERS',
    'WEIGHT LOSS',
    'MUSCLE BUILDING',
    'CROSSFIT',
    'HIIT',
    'PILATES',
  ];

  // Mock data for trainers to enrich Firestore users or use as fallback
  final List<Map<String, dynamic>> _mockTrainers = [
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
    return Scaffold(
      backgroundColor: const Color(0xFF070809),
      body: SafeArea(
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('users')
              .where('role', isEqualTo: 'trainer')
              .snapshots(),
          builder: (context, snapshot) {
            // Merge actual database trainers with mock data for aesthetic portrait URLs
            final List<Map<String, dynamic>> trainers = [];

            // Helper lists to map specialty tags
            final List<List<String>> specOptions = [
              ['BODYBUILDING', 'NUTRITION'],
              ['HIIT', 'PILATES'],
              ['CROSSFIT', 'KETTLEBELL'],
            ];

            if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
              int mockIdx = 0;
              for (final doc in snapshot.data!.docs) {
                final data = doc.data() as Map<String, dynamic>;
                final uid = doc.id;
                final fullName = data['fullName'] ?? 'Huấn luyện viên';
                final position = data['position'] ?? 'PT/Trainer';
                final avatarUrl = data['avatarUrl'] as String?;
                final hasAvatar = avatarUrl != null && avatarUrl.trim().isNotEmpty;

                // Assign details
                trainers.add({
                  'uid': uid,
                  'fullName': fullName.toUpperCase(),
                  'rating': 4.5 + (mockIdx % 5) * 0.1,
                  'experience': '${3 + (mockIdx % 10)} Yrs',
                  'clients': '${40 + (mockIdx * 15)}',
                  'specialities': specOptions[mockIdx % specOptions.length],
                  'price': 50 + (mockIdx % 6) * 10,
                  'position': position,
                  'imageUrl': hasAvatar
                      ? avatarUrl
                      : (mockIdx < _mockTrainers.length 
                          ? _mockTrainers[mockIdx]['imageUrl'] 
                          : 'https://images.unsplash.com/photo-1534438327276-14e5300c3a48?w=500&auto=format&fit=crop&q=60'),
                });
                mockIdx++;
              }
            }

            // Fallback to fully mocks if db is empty
            if (trainers.isEmpty) {
              trainers.addAll(_mockTrainers);
            }

            // Apply search filter
            final filteredTrainers = trainers.where((t) {
              final matchesSearch = t['fullName'].toLowerCase().contains(_searchQuery.toLowerCase());
              if (!matchesSearch) return false;

              if (_selectedCategory == 'ALL TRAINERS') return true;

              final specs = (t['specialities'] as List).map((s) => s.toString().toUpperCase()).toList();
              return specs.contains(_selectedCategory.toUpperCase());
            }).toList();

            // Find recommended trainer (e.g. Alex Thorne)
            final recommended = trainers.firstWhere(
              (t) => t['fullName'].toString().contains('ALEX'),
              orElse: () => trainers.first,
            );

            return CustomScrollView(
              slivers: [
                // APP BAR / HEADER
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 10),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 18,
                          backgroundColor: const Color(0xFF14161A),
                          child: const Icon(Icons.person, color: Colors.white70, size: 18),
                        ),
                        const SizedBox(width: 10),
                        const Text(
                          'KINETIC',
                          style: TextStyle(
                            color: Color(0xFFE7F0BD),
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                        const Spacer(),
                        const Icon(Icons.notifications_none, color: Colors.white, size: 24),
                      ],
                    ),
                  ),
                ),

                // SEARCH BAR
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    child: Row(
                      children: [
                        Expanded(
                          child: Container(
                            height: 52,
                            decoration: BoxDecoration(
                              color: const Color(0xFF070809),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: TextField(
                              onChanged: (value) => setState(() => _searchQuery = value),
                              style: const TextStyle(color: Colors.white, fontSize: 15),
                              cursorColor: const Color(0xFFE7F0BD),
                              decoration: const InputDecoration(
                                hintText: 'Find your trainer...',
                                hintStyle: TextStyle(color: Color(0xFF686B72), fontSize: 15),
                                prefixIcon: Icon(Icons.search, color: Color(0xFF686B72)),
                                filled: true,
                                fillColor: Colors.transparent,
                                border: InputBorder.none,
                                enabledBorder: InputBorder.none,
                                focusedBorder: InputBorder.none,
                                disabledBorder: InputBorder.none,
                                errorBorder: InputBorder.none,
                                focusedErrorBorder: InputBorder.none,
                                contentPadding: EdgeInsets.symmetric(vertical: 14),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Container(
                          height: 52,
                          width: 52,
                          decoration: BoxDecoration(
                            color: const Color(0xFF14161A),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.white10),
                          ),
                          child: const Icon(Icons.tune_rounded, color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ),

                // RECOMMENDED SECTION
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'RECOMMENDED FOR YOU',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.2,
                          ),
                        ),
                        const SizedBox(height: 14),
                        // Featured Trainer Card
                        Container(
                          height: 380,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(28),
                            image: DecorationImage(
                              image: NetworkImage(recommended['imageUrl']),
                              fit: BoxFit.cover,
                            ),
                          ),
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(28),
                              gradient: const LinearGradient(
                                colors: [Colors.transparent, Colors.black87],
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                stops: [0.4, 0.95],
                              ),
                            ),
                            padding: const EdgeInsets.all(24),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFE7F0BD),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(Icons.star_rounded, color: Colors.black, size: 14),
                                      const SizedBox(width: 4),
                                      Text(
                                        'TRAINER OF THE MONTH',
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 9,
                                          fontWeight: FontWeight.w900,
                                          letterSpacing: .4,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  recommended['fullName'],
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 32,
                                    fontWeight: FontWeight.w900,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${recommended['position']} • ${recommended['experience']}',
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 20),
                                SizedBox(
                                  width: double.infinity,
                                  height: 50,
                                  child: ElevatedButton(
                                    onPressed: () => _showTrainerDetailsDialog(context, recommended),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.white,
                                      foregroundColor: Colors.black,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                    ),
                                    child: const Text(
                                      'VIEW PROFILE',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w900,
                                        letterSpacing: .8,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // CATEGORIES HORIZONTAL LIST
                SliverToBoxAdapter(
                  child: SizedBox(
                    height: 46,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: _categories.length,
                      itemBuilder: (context, index) {
                        final cat = _categories[index];
                        final isSelected = _selectedCategory == cat;

                        return Padding(
                          padding: const EdgeInsets.only(right: 10),
                          child: ChoiceChip(
                            label: Text(
                              cat,
                              style: TextStyle(
                                color: isSelected ? Colors.black : Colors.white60,
                                fontSize: 11,
                                fontWeight: FontWeight.w900,
                                letterSpacing: .5,
                              ),
                            ),
                            selected: isSelected,
                            onSelected: (val) {
                              if (val) setState(() => _selectedCategory = cat);
                            },
                            selectedColor: const Color(0xFFE7F0BD),
                            backgroundColor: const Color(0xFF14161A),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(99),
                              side: BorderSide.none,
                            ),
                            showCheckmark: false,
                          ),
                        );
                      },
                    ),
                  ),
                ),

                // TRAINERS VERTICAL LIST
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
                  sliver: filteredTrainers.isEmpty
                      ? const SliverToBoxAdapter(
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 40),
                            child: Center(
                              child: Text(
                                'No trainers found.',
                                style: TextStyle(color: Colors.white38, fontSize: 15),
                              ),
                            ),
                          ),
                        )
                      : SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              final trainer = filteredTrainers[index];
                              return _buildTrainerCard(context, trainer);
                            },
                            childCount: filteredTrainers.length,
                          ),
                        ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildTrainerCard(BuildContext context, Map<String, dynamic> trainer) {
    return GestureDetector(
      onTap: () {
        context.push('${Routes.userProfile}/${trainer['uid']}');
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF14161A),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white10),
        ),
        child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Photo
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.network(
              trainer['imageUrl'],
              width: 90,
              height: 110,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 16),
          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        trainer['fullName'],
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Row(
                      children: [
                        const Icon(Icons.star_rounded, color: Color(0xFFE7F0BD), size: 16),
                        const SizedBox(width: 2),
                        Text(
                          trainer['rating'].toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '${trainer['experience']} Experience • ${trainer['clients']} Clients',
                  style: const TextStyle(
                    color: Color(0xFF8E9196),
                    fontSize: 11,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                // Specialty Tags
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: (trainer['specialities'] as List).map<Widget>((spec) {
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF20242B),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        spec.toString().toUpperCase(),
                        style: const TextStyle(
                          color: Color(0xFF8E9196),
                          fontSize: 8,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 12),
                // Price & Button
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => context.push('${Routes.userProfile}/${trainer['uid']}'),
                      style: TextButton.styleFrom(
                        foregroundColor: const Color(0xFFE7F0BD),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      ),
                      child: const Text(
                        'Xem profile PT',
                        style: TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 13,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

  void _showTrainerDetailsDialog(BuildContext context, Map<String, dynamic> trainer) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFF14161A),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: Colors.white10),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.network(trainer['imageUrl'], height: 200, width: double.infinity, fit: BoxFit.cover),
                ),
                const SizedBox(height: 16),
                Text(
                  trainer['fullName'],
                  style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 4),
                Text(
                  trainer['position'],
                  style: const TextStyle(color: Color(0xFFE7F0BD), fontSize: 13, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildStatItem('Rating', '${trainer['rating']} ★'),
                    _buildStatItem('Experience', trainer['experience']),
                    _buildStatItem('Price/hr', '\$${trainer['price']}'),
                  ],
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: FilledButton(
                    onPressed: () {
                      Navigator.pop(context);
                      _showBookingSheet(context, trainer);
                    },
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFFE7F0BD),
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: const Text('BOOK NOW', style: TextStyle(fontWeight: FontWeight.w900)),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w900)),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(color: Color(0xFF8E9196), fontSize: 11)),
      ],
    );
  }

  void _showBookingSheet(BuildContext context, Map<String, dynamic> trainer) {
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
                    'ĐẶT LỊCH HẸN VỚI ${trainer['fullName']}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 1. CHỌN NGÀY (7 ngày tiếp theo)
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
                            'staffUid': trainer['uid'],
                            'staffName': trainer['fullName'],
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
                            'ptId': trainer['uid'],
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
