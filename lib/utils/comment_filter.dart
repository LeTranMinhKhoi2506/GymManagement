import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class CommentFilter {
  // Thay thế bằng API Key thực tế của bạn thu thập từ Google Cloud Console
  // Nếu để trống hoặc dùng key mặc định bị lỗi, hệ thống sẽ bỏ qua kiểm tra API này để tránh chặn người dùng.
  static const String perspectiveApiKey =
      'AIzaSyCudM-PTj2qxitdfoa8OxWBS_C83H-6Ra0';

  // Danh sách từ thô tục, nhạy cảm tiếng Việt để lọc cục bộ (offline)
  static const List<String> _vietnameseProfanityList = [
    'đm', 'dm', 'đéo', 'deo', 'vcl', 'vkl', 'vl', 'cl', 'cđm', 'dkm', 'lìn', 'lin',
    'buồi', 'buoi', 'cứt', 'cut', 'chó', 'cho', 'đĩ', 'di', 'ngu', 'mẹ kiếp', 'me kiep',
    'đụ', 'du', 'bú', 'bu', 'cặc', 'cac', 'lờ', 'lo', 'nứng', 'nung', 'hãm', 'ham',
    'mọe', 'moe', 'đệt', 'det', 'óc chó', 'oc cho', 'ngu lờ', 'ngu lo'
  ];

  static Future<String?> validateComment({
    required String content,
    required String? lastCommentText,
    required DateTime? lastCommentTime,
  }) async {
    final cleanContent = content.trim();
    debugPrint('CommentFilter: Starting validation for text: "$cleanContent"');

    // 1. Kiểm tra rate limit cục bộ (tối thiểu 5 giây giữa các bình luận)
    if (lastCommentTime != null) {
      final difference = DateTime.now().difference(lastCommentTime);
      debugPrint('CommentFilter: Rate limit check. Seconds since last: ${difference.inSeconds}');
      if (difference.inSeconds < 5) {
        debugPrint('CommentFilter: Blocked by rate limit');
        return 'Bạn đang bình luận quá nhanh, vui lòng đợi vài giây!';
      }
    }

    // 2. Kiểm tra trùng lặp nội dung liên tiếp
    if (lastCommentText != null &&
        lastCommentText.trim().toLowerCase() == cleanContent.toLowerCase()) {
      debugPrint('CommentFilter: Blocked by duplicate content check');
      return 'Bình luận trùng lặp, vui lòng không spam cùng một câu!';
    }

    // 3. Kiểm tra ký tự vô nghĩa / keyboard mashing
    // 3.1. Ký tự lặp liên tục nhiều lần (ví dụ: aaaaa, hhhhh, .......)
    final repeatRegex = RegExp(r'(.)\1{4,}'); // Lặp từ 5 lần trở lên
    if (repeatRegex.hasMatch(cleanContent)) {
      debugPrint('CommentFilter: Blocked by repeat character check');
      return 'Bình luận chứa các ký tự vô nghĩa hoặc lặp lại quá nhiều!';
    }

    // 3.2. Từ quá dài bất thường (thường do gõ phím bừa bãi không khoảng trắng)
    final words = cleanContent.split(RegExp(r'\s+'));
    for (final word in words) {
      if (word.length > 20) {
        debugPrint('CommentFilter: Blocked by word length check: "$word"');
        return 'Bình luận chứa các từ quá dài hoặc vô nghĩa!';
      }
    }

    // 4. Kiểm tra từ ngữ thô tục tiếng Việt bằng từ điển cục bộ
    final lowerContent = cleanContent.toLowerCase();
    for (final badWord in _vietnameseProfanityList) {
      final regex = RegExp(r'\b' + RegExp.escape(badWord) + r'\b');
      if (regex.hasMatch(lowerContent)) {
        debugPrint('CommentFilter: Blocked by local Vietnamese profanity: "$badWord"');
        return 'Bình luận chứa từ ngữ không phù hợp, vui lòng điều chỉnh!';
      }
    }

    // 5. Kiểm tra độc hại qua Perspective API (dành cho tiếng Anh hoặc ngôn ngữ được hỗ trợ)
    if (perspectiveApiKey.isNotEmpty &&
        perspectiveApiKey != 'YOUR_API_KEY_HERE') {
      debugPrint('CommentFilter: Requesting Perspective API...');
      try {
        final url = Uri.parse(
          'https://commentanalyzer.googleapis.com/v1alpha1/comments:analyze?key=$perspectiveApiKey',
        );

        final response = await http
            .post(
              url,
              headers: {'Content-Type': 'application/json'},
              body: jsonEncode({
                'comment': {'text': cleanContent},
                'requestedAttributes': {'TOXICITY': {}},
              }),
            )
            .timeout(const Duration(seconds: 4));

        debugPrint('CommentFilter: Perspective API response status: ${response.statusCode}');
        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          final score =
              data['attributeScores']?['TOXICITY']?['summaryScore']?['value']
                  as double?;
          debugPrint('CommentFilter: Perspective API Toxicity Score: $score');
          if (score != null && score > 0.7) {
            debugPrint('CommentFilter: Blocked by Perspective API Toxicity (> 0.7)');
            return 'Bình luận chứa từ ngữ không phù hợp, vui lòng điều chỉnh!';
          }
        } else {
          debugPrint('CommentFilter: Perspective API returned status ${response.statusCode}: ${response.body}');
        }
      } catch (e) {
        debugPrint('CommentFilter: Perspective API request failed with exception: $e');
      }
    }

    debugPrint('CommentFilter: Validation passed successfully!');

    return null; // Không phát hiện vi phạm
  }
}
