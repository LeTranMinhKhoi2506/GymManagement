import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/models/comment_model.dart';
import '../../provider/home_provider.dart';

class HomeLatestCommentHint extends StatelessWidget {
  const HomeLatestCommentHint({super.key, required this.postId});

  final String postId;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<CommentModel>>(
      stream: context.read<HomeProvider>().watchComments(postId),
      builder: (context, snapshot) {
        final comments = snapshot.data ?? const <CommentModel>[];
        if (comments.isEmpty) return const SizedBox.shrink();
        final latest = comments.last;
        return Text(
          '${latest.authorName}: ${latest.content}',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: Colors.white54,
            fontSize: 12,
          ),
        );
      },
    );
  }
}
