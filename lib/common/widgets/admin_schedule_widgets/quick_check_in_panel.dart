import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class QuickCheckInPanel extends StatefulWidget {
  final TextEditingController controller;
  const QuickCheckInPanel({super.key, required this.controller});

  @override
  State<QuickCheckInPanel> createState() => _QuickCheckInPanelState();
}

class _QuickCheckInPanelState extends State<QuickCheckInPanel> {
  bool _isProcessing = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Check-in nhanh",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0A192F)),
              ),
              Icon(Icons.qr_code_scanner, color: Color(0xFFFF6B35)),
            ],
          ),
          const SizedBox(height: 24),
          TextField(
            controller: widget.controller,
            decoration: InputDecoration(
              hintText: "Tên thành viên hoặc ID QR",
              filled: true,
              fillColor: const Color(0xFFF3F4F5),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            ),
            enabled: !_isProcessing,
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isProcessing ? null : _handleQuickCheckIn,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0A192F),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: _isProcessing 
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                  )
                : const Text("XÁC NHẬN TRUY CẬP", style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1)),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleQuickCheckIn() async {
    final input = widget.controller.text.trim();
    if (input.isEmpty) return;

    setState(() {
      _isProcessing = true;
    });

    try {
      final db = FirebaseFirestore.instance;
      
      // Search by ID first
      var doc = await db.collection('members').doc(input).get();
      DocumentSnapshot? memberDoc;

      if (doc.exists) {
        memberDoc = doc;
      } else {
        // Search by fullName (exact match)
        final queryByName = await db.collection('members')
            .where('fullName', isEqualTo: input)
            .limit(1)
            .get();
        if (queryByName.docs.isNotEmpty) {
          memberDoc = queryByName.docs.first;
        } else {
          // Fallback: search by name starting with input (case-sensitive)
          final queryPartial = await db.collection('members')
              .orderBy('fullName')
              .startAt([input])
              .endAt(['$input\uf8ff'])
              .limit(1)
              .get();
          if (queryPartial.docs.isNotEmpty) {
            memberDoc = queryPartial.docs.first;
          }
        }
      }

      if (memberDoc == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Không tìm thấy hội viên nào có tên hoặc ID khớp!"),
              backgroundColor: Colors.redAccent,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
        return;
      }

      final memberId = memberDoc.id;
      final memberData = memberDoc.data() as Map<String, dynamic>;
      final fullName = memberData['fullName'] ?? 'Hội viên';
      final bool isTraining = memberData['isCurrentlyTraining'] ?? false;
      final bool newTrainingState = !isTraining;

      // Update training state
      await db.collection('members').doc(memberId).update({
        'isCurrentlyTraining': newTrainingState,
      });

      // Write to checkins log
      await db.collection('checkins').add({
        'memberId': memberId,
        'userName': fullName,
        'timestamp': FieldValue.serverTimestamp(),
        'zone': newTrainingState ? 'Khu vực chính (Check-in)' : 'Khu vực chính (Check-out)',
      });

      // Write activity log
      await db.collection('members').doc(memberId).collection('activity_logs').add({
        'title': newTrainingState ? 'Check-in thành công (Admin)' : 'Check-out thành công (Admin)',
        'timestamp': FieldValue.serverTimestamp(),
        'amount': 0.0,
        'status': 'Paid',
        'type': 'Session',
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(newTrainingState 
                ? "✔️ Check-in thành công cho $fullName" 
                : "✔️ Check-out thành công cho $fullName"),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
        widget.controller.clear();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Lỗi check-in: $e"),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }
}
