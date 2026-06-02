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

  @override
  void initState() {
    super.initState();
    _captionController = TextEditingController(
      text: context.read<HomeProvider>().draftCaption,
    );
    _captionController.addListener(_onCaptionChanged);
  }

  void _onCaptionChanged() {
    context.read<HomeProvider>().updateDraftCaption(_captionController.text);
  }

  @override
  void dispose() {
    _captionController.removeListener(_onCaptionChanged);
    _captionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final canPost = context.select<HomeProvider, bool>((p) => p.canPost);

    return Scaffold(
      backgroundColor: const Color(0xFF070809),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close, color: Color(0xFFECEBC4)),
                  ),
                  const Text(
                    'KINETIC',
                    style: TextStyle(
                      color: Color(0xFFECEBC4),
                      fontSize: 25,
                      fontWeight: FontWeight.w800,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                children: [
                  TextField(
                    controller: _captionController,
                    maxLines: 4,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      hintText: "What's on your mind?",
                      hintStyle: TextStyle(color: Colors.white24, fontSize: 26),
                      border: InputBorder.none,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const _MediaActionsRow(),
                  const SizedBox(height: 14),
                  const _SelectedMediaSection(),
                  const SizedBox(height: 18),
                  const _SelectedExercisesSection(),
                  const SizedBox(height: 18),
                  SizedBox(
                    height: 52,
                    child: FilledButton(
                      onPressed: !canPost
                          ? null
                          : () async {
                              final error = await context
                                  .read<HomeProvider>()
                                  .createPost();
                              if (!context.mounted) return;
                              if (error != null) {
                                ScaffoldMessenger.of(context)
                                  ..hideCurrentSnackBar()
                                  ..showSnackBar(
                                    SnackBar(content: Text(error)),
                                  );
                                return;
                              }
                              Navigator.of(context).pop();
                            },
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFFE7F0BD),
                        foregroundColor: Colors.black,
                        disabledBackgroundColor: const Color(0xFF2B2D30),
                        disabledForegroundColor: const Color(0xFF8E9196),
                      ),
                      child: const Text(
                        'DANG BAI',
                        style: TextStyle(fontWeight: FontWeight.w800),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
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
            icon: Icons.add_a_photo_outlined,
            title: 'PHOTO',
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
            title: 'VIDEO',
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
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Ink(
        height: 150,
        decoration: BoxDecoration(
          color: const Color(0xFF15171B),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white54, size: 34),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white54,
                letterSpacing: 2,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
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
      return const Text(
        'Chua co media. Chon nhieu anh/video de dang cung luc.',
        style: TextStyle(color: Colors.white54),
      );
    }

    return SizedBox(
      height: 110,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemBuilder: (context, index) {
          final item = mediaItems[index];
          final isLocal = context.read<HomeProvider>().isLocalFile(item.path);
          return Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  width: 110,
                  height: 110,
                  color: const Color(0xFF16181C),
                  child: item.type == SocialMediaType.video
                      ? const Center(
                          child: Icon(
                            Icons.play_circle_fill,
                            color: Colors.white70,
                            size: 34,
                          ),
                        )
                      : (isLocal
                            ? Image.file(File(item.path), fit: BoxFit.cover)
                            : Image.network(item.path, fit: BoxFit.cover)),
                ),
              ),
              Positioned(
                right: 4,
                top: 4,
                child: InkWell(
                  onTap: () =>
                      context.read<HomeProvider>().removeDraftMediaAt(index),
                  child: const CircleAvatar(
                    radius: 10,
                    backgroundColor: Colors.black87,
                    child: Icon(Icons.close, size: 12, color: Colors.white),
                  ),
                ),
              ),
            ],
          );
        },
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemCount: mediaItems.length,
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
        const Text(
          'SELECTED EXERCISES',
          style: TextStyle(
            color: Colors.white70,
            letterSpacing: 1.8,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 10),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFF15171B),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white10),
          ),
          padding: const EdgeInsets.all(14),
          child: Column(
            children: [
              ...List.generate(drafts.length, (index) {
                final item = drafts[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    children: [
                      const CircleAvatar(
                        radius: 20,
                        backgroundColor: Colors.white,
                        child: Icon(
                          Icons.fitness_center,
                          color: Colors.black54,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          children: [
                            TextFormField(
                              initialValue: item.name,
                              onChanged: (value) => context
                                  .read<HomeProvider>()
                                  .updateExerciseName(index, value),
                              style: const TextStyle(color: Colors.white),
                              decoration: _fieldDecoration('Exercise name'),
                            ),
                            const SizedBox(height: 6),
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
                                    decoration: _fieldDecoration('sets'),
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: TextFormField(
                                    initialValue: item.reps,
                                    keyboardType: TextInputType.number,
                                    onChanged: (value) => context
                                        .read<HomeProvider>()
                                        .updateExerciseReps(index, value),
                                    style: const TextStyle(color: Colors.white),
                                    decoration: _fieldDecoration('reps'),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: drafts.length == 1
                            ? null
                            : () => context
                                  .read<HomeProvider>()
                                  .removeExerciseDraft(index),
                        icon: const Icon(
                          Icons.delete_outline,
                          color: Colors.white38,
                        ),
                      ),
                    ],
                  ),
                );
              }),
              TextButton.icon(
                onPressed: context.read<HomeProvider>().addExerciseDraft,
                icon: const Icon(
                  Icons.add_circle_outline,
                  color: Color(0xFFE7F0BD),
                ),
                label: const Text(
                  'ADD EXERCISE',
                  style: TextStyle(
                    color: Color(0xFFE7F0BD),
                    letterSpacing: 1.4,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  InputDecoration _fieldDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.white38),
      contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      filled: true,
      fillColor: const Color(0xFF1C1F24),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide.none,
      ),
      isDense: true,
    );
  }
}
