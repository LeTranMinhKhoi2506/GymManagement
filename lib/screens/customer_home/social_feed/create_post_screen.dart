import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../data/models/workout_exercise_model.dart';
import '../../../provider/home_provider.dart';

class CreatePostScreen extends StatefulWidget {
  const CreatePostScreen({super.key});

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  late final TextEditingController _captionController;
  bool _hasText = false;

  static const Color bg = Color(0xFF070809);
  static const Color accent = Color(0xFFE7F0BD);

  @override
  void initState() {
    super.initState();
    final initialCaption = context.read<HomeProvider>().draftCaption;
    _captionController = TextEditingController(text: initialCaption);
    _hasText = initialCaption.trim().isNotEmpty;
    _captionController.addListener(_onCaptionChanged);
  }

  void _onCaptionChanged() {
    final isNotEmpty = _captionController.text.trim().isNotEmpty;
    if (_hasText != isNotEmpty) {
      setState(() {
        _hasText = isNotEmpty;
      });
    }
  }

  @override
  void dispose() {
    _captionController.removeListener(_onCaptionChanged);
    _captionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hasMedia = context.select<HomeProvider, bool>(
      (p) => p.draftMediaItems.isNotEmpty,
    );
    final isPosting = context.select<HomeProvider, bool>((p) => p.isPosting);
    final canPost = !isPosting && (_hasText || hasMedia);

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: Column(
          children: [
            _Header(onClose: () => Navigator.of(context).pop()),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(18, 8, 18, 110),
                children: [
                  _CaptionBox(controller: _captionController),
                  const SizedBox(height: 16),
                  const _MediaActionsRow(),
                  const SizedBox(height: 14),
                  const _SelectedMediaSection(),
                  const SizedBox(height: 22),
                  const _SelectedExercisesSection(),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.fromLTRB(18, 10, 18, 14),
          decoration: const BoxDecoration(
            color: bg,
            border: Border(top: BorderSide(color: Color(0xFF1C1F24))),
          ),
          child: SizedBox(
            height: 54,
            child: FilledButton(
              onPressed: !canPost
                  ? null
                  : () async {
                      // Cập nhật caption từ controller cục bộ vào Provider trước khi đăng bài
                      context
                          .read<HomeProvider>()
                          .updateDraftCaption(_captionController.text);

                      final error = await context
                          .read<HomeProvider>()
                          .createPost();

                      if (!context.mounted) return;

                      if (error != null) {
                        ScaffoldMessenger.of(context)
                          ..hideCurrentSnackBar()
                          ..showSnackBar(SnackBar(content: Text(error)));
                        return;
                      }

                      Navigator.of(context).pop();
                    },
              style: FilledButton.styleFrom(
                backgroundColor: accent,
                foregroundColor: Colors.black,
                disabledBackgroundColor: const Color(0xFF25272B),
                disabledForegroundColor: const Color(0xFF777A80),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
              child: const Text(
                'ĐĂNG BÀI',
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.1,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.onClose});

  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 8, 18, 10),
      child: Row(
        children: [
          IconButton(
            onPressed: onClose,
            icon: const Icon(Icons.close_rounded),
            color: const Color(0xFFECEBC4),
          ),
          const SizedBox(width: 2),
          const Text(
            'KINETIC',
            style: TextStyle(
              color: Color(0xFFECEBC4),
              fontSize: 25,
              fontWeight: FontWeight.w900,
              fontStyle: FontStyle.italic,
              letterSpacing: .4,
            ),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            decoration: BoxDecoration(
              color: const Color(0xFF15171B),
              borderRadius: BorderRadius.circular(99),
              border: Border.all(color: Colors.white10),
            ),
            child: const Row(
              children: [
                Icon(
                  Icons.local_fire_department_rounded,
                  color: Color(0xFFE7F0BD),
                  size: 16,
                ),
                SizedBox(width: 5),
                Text(
                  'WORKOUT POST',
                  style: TextStyle(
                    color: Color(0xFFE7F0BD),
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: .8,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CaptionBox extends StatelessWidget {
  const _CaptionBox({required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF14161A),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white10),
      ),
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      child: TextField(
        controller: controller,
        maxLines: 5,
        minLines: 4,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 15.5,
          height: 1.35,
        ),
        cursorColor: const Color(0xFFE7F0BD),
        decoration: InputDecoration(
          hintText: 'Chia sẻ buổi tập hôm nay của bạn...',
          hintStyle: const TextStyle(color: Color(0xFF686B72), fontSize: 16),

          // Quan trọng: chặn nền trắng
          filled: true,
          fillColor: Colors.transparent,

          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          disabledBorder: InputBorder.none,
          errorBorder: InputBorder.none,
          focusedErrorBorder: InputBorder.none,

          contentPadding: EdgeInsets.zero,
        ),
      ),
    );
  }
}

class _MediaActionsRow extends StatelessWidget {
  const _MediaActionsRow();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _MediaActionTile(
            icon: Icons.add_photo_alternate_outlined,
            title: 'Ảnh',
            subtitle: 'Thêm nhiều ảnh',
            onTap: () async {
              final error = await context
                  .read<HomeProvider>()
                  .pickWorkoutPhotos();

              if (!context.mounted || error == null) return;

              ScaffoldMessenger.of(context)
                ..hideCurrentSnackBar()
                ..showSnackBar(SnackBar(content: Text(error)));
            },
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _MediaActionTile(
            icon: Icons.videocam_outlined,
            title: 'Video',
            subtitle: 'Thêm clip tập',
            onTap: () async {
              final error = await context
                  .read<HomeProvider>()
                  .pickWorkoutVideos();

              if (!context.mounted || error == null) return;

              ScaffoldMessenger.of(context)
                ..hideCurrentSnackBar()
                ..showSnackBar(SnackBar(content: Text(error)));
            },
          ),
        ),
      ],
    );
  }
}

class _MediaActionTile extends StatelessWidget {
  const _MediaActionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFF14161A),
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: Container(
          height: 104,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: Colors.white10),
          ),
          child: Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: const Color(0xFF20242B),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(icon, color: const Color(0xFFE7F0BD), size: 25),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: Color(0xFF8E9196),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SelectedMediaSection extends StatelessWidget {
  const _SelectedMediaSection();

  @override
  Widget build(BuildContext context) {
    final mediaItems = context.select<HomeProvider, List<SocialMediaModel>>(
      (provider) => provider.draftMediaItems,
    );

    if (mediaItems.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFF101216),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.white10),
        ),
        child: const Row(
          children: [
            Icon(
              Icons.info_outline_rounded,
              color: Color(0xFF8E9196),
              size: 18,
            ),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                'Chưa có media. Bạn có thể chọn nhiều ảnh hoặc video cùng lúc.',
                style: TextStyle(
                  color: Color(0xFF8E9196),
                  fontSize: 13,
                  height: 1.35,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return SizedBox(
      height: 112,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: mediaItems.length,
        separatorBuilder: (context, index) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final item = mediaItems[index];
          final isLocal = context.read<HomeProvider>().isLocalFile(item.path);

          return Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: Container(
                  width: 112,
                  height: 112,
                  color: const Color(0xFF16181C),
                  child: item.type == SocialMediaType.video
                      ? const Center(
                          child: Icon(
                            Icons.play_circle_fill_rounded,
                            color: Color(0xFFE7F0BD),
                            size: 42,
                          ),
                        )
                      : item.bytes != null
                      ? Image.memory(item.bytes!, fit: BoxFit.cover)
                      : isLocal
                      ? Image.file(File(item.path), fit: BoxFit.cover)
                      : Image.network(item.path, fit: BoxFit.cover),
                ),
              ),
              Positioned(
                right: 6,
                top: 6,
                child: GestureDetector(
                  onTap: () =>
                      context.read<HomeProvider>().removeDraftMediaAt(index),
                  child: Container(
                    width: 24,
                    height: 24,
                    decoration: const BoxDecoration(
                      color: Colors.black87,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.close_rounded,
                      size: 15,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _SelectedExercisesSection extends StatelessWidget {
  const _SelectedExercisesSection();

  @override
  Widget build(BuildContext context) {
    final drafts = context.select<HomeProvider, List<DraftExerciseInput>>(
      (provider) => provider.draftExercises,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionTitle(
          title: 'BÀI TẬP ĐÃ CHỌN',
          icon: Icons.fitness_center_rounded,
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFF14161A),
            borderRadius: BorderRadius.circular(26),
            border: Border.all(color: Colors.white10),
          ),
          padding: const EdgeInsets.all(14),
          child: Column(
            children: [
              ...List.generate(drafts.length, (index) {
                final item = drafts[index];

                return Padding(
                  padding: EdgeInsets.only(
                    bottom: index == drafts.length - 1 ? 6 : 14,
                  ),
                  child: _ExerciseDraftCard(
                    index: index,
                    item: item,
                    canDelete: drafts.length > 1,
                  ),
                );
              }),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                height: 46,
                child: OutlinedButton.icon(
                  onPressed: context.read<HomeProvider>().addExerciseDraft,
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFFE7F0BD)),
                    foregroundColor: const Color(0xFFE7F0BD),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  icon: const Icon(Icons.add_rounded),
                  label: const Text(
                    'THÊM BÀI TẬP',
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      letterSpacing: .9,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ExerciseDraftCard extends StatelessWidget {
  const _ExerciseDraftCard({
    required this.index,
    required this.item,
    required this.canDelete,
  });

  final int index;
  final DraftExerciseInput item;
  final bool canDelete;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1A1D22),
        borderRadius: BorderRadius.circular(20),
      ),
      padding: const EdgeInsets.all(12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: const BoxDecoration(
              color: Color(0xFFE7F0BD),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.fitness_center_rounded,
              color: Colors.black,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              children: [
                TextFormField(
                  initialValue: item.name,
                  onChanged: (value) => context
                      .read<HomeProvider>()
                      .updateExerciseName(index, value),
                  style: const TextStyle(color: Colors.white),
                  cursorColor: const Color(0xFFE7F0BD),
                  decoration: _fieldDecoration('Tên bài tập'),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        initialValue: item.sets,
                        keyboardType: TextInputType.number,
                        onChanged: (value) => context
                            .read<HomeProvider>()
                            .updateExerciseSets(index, value),
                        style: const TextStyle(color: Colors.white),
                        cursorColor: const Color(0xFFE7F0BD),
                        decoration: _fieldDecoration('Sets'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextFormField(
                        initialValue: item.reps,
                        keyboardType: TextInputType.number,
                        onChanged: (value) => context
                            .read<HomeProvider>()
                            .updateExerciseReps(index, value),
                        style: const TextStyle(color: Colors.white),
                        cursorColor: const Color(0xFFE7F0BD),
                        decoration: _fieldDecoration('Reps'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 6),
          IconButton(
            onPressed: !canDelete
                ? null
                : () => context.read<HomeProvider>().removeExerciseDraft(index),
            icon: Icon(
              Icons.delete_outline_rounded,
              color: canDelete ? Colors.white38 : Colors.white12,
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration _fieldDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Color(0xFF777A80)),
      filled: true,
      fillColor: const Color(0xFF242830),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFE7F0BD)),
      ),
      isDense: true,
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title, required this.icon});

  final String title;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFFE7F0BD), size: 18),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            letterSpacing: 1.3,
            fontWeight: FontWeight.w900,
            fontSize: 13,
          ),
        ),
      ],
    );
  }
}
