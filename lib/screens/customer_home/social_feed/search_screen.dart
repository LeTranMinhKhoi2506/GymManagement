import 'package:flutter/material.dart';

class SearchScreen extends StatelessWidget {
  const SearchScreen({super.key});

  static const routeName = '/social-search';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1C1C1E),
      body: SafeArea(
        child: Column(
          children: [
            // HEADER SEARCH
            Padding(
              padding: const EdgeInsets.fromLTRB(28, 14, 30, 12),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),

                  const SizedBox(width: 28),

                  Expanded(
                    child: SizedBox(
                      height: 52,
                      child: TextField(
                        cursorColor: const Color(0xFF1E9BFF),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w400,
                        ),
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.black,

                          hintText: 'Search on Hevy',
                          hintStyle: const TextStyle(
                            color: Color(0xFF777A82),
                            fontSize: 18,
                            fontWeight: FontWeight.w400,
                          ),

                          prefixIcon: const Icon(
                            Icons.search_rounded,
                            color: Color(0xFF8A8D93),
                            size: 30,
                          ),

                          prefixIconConstraints: const BoxConstraints(
                            minWidth: 48,
                            minHeight: 52,
                          ),

                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 15,
                            horizontal: 0,
                          ),

                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(0),
                            borderSide: BorderSide.none,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(0),
                            borderSide: BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(0),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const Divider(height: 1, thickness: 1, color: Color(0xFF2A2A2C)),

            // BODY LIST
            Expanded(
              child: Container(
                color: Colors.black,
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(30, 28, 30, 24),
                  children: [
                    const Text(
                      'Suggested Athletes',
                      style: TextStyle(
                        color: Color(0xFF7C7F86),
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    const SizedBox(height: 18),

                    _InviteRow(
                      title: 'Invite a friend',
                      icon: Icons.send_rounded,
                      onTap: () {},
                    ),

                    const SizedBox(height: 8),

                    ...List.generate(users.length, (index) {
                      final user = users[index];

                      return _SuggestedUserTile(
                        username: user.username,
                        fullName: user.fullName,
                        imageUrl: user.imageUrl,
                        onFollow: () {},
                        onDismiss: () {},
                      );
                    }),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// DATA DEMO
const List<_SuggestedUser> users = [
  _SuggestedUser(username: 'jeffcd', fullName: 'Jeff', imageUrl: ''),
  _SuggestedUser(username: 'maxou2601', fullName: 'Clara', imageUrl: ''),
  _SuggestedUser(username: 'batu', fullName: 'Batuhan Demir', imageUrl: ''),
  _SuggestedUser(username: 'aneta', fullName: 'aneta', imageUrl: ''),
  _SuggestedUser(
    username: 'britmicheli',
    fullName: 'Brit Micheli',
    imageUrl: '',
  ),
  _SuggestedUser(
    username: 'noahanderson14',
    fullName: 'Noah Anderson',
    imageUrl: '',
  ),
  _SuggestedUser(username: 'gerard', fullName: 'gerard', imageUrl: ''),
];

class _SuggestedUser {
  const _SuggestedUser({
    required this.username,
    required this.fullName,
    required this.imageUrl,
  });

  final String username;
  final String fullName;
  final String imageUrl;
}

class _InviteRow extends StatelessWidget {
  const _InviteRow({
    required this.title,
    required this.icon,
    required this.onTap,
  });

  final String title;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            Container(
              width: 58,
              height: 58,
              decoration: const BoxDecoration(
                color: Color(0xFF1C1D21),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: Colors.white, size: 30),
            ),

            const SizedBox(width: 18),

            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SuggestedUserTile extends StatelessWidget {
  const _SuggestedUserTile({
    required this.username,
    required this.fullName,
    required this.imageUrl,
    required this.onFollow,
    required this.onDismiss,
  });

  final String username;
  final String fullName;
  final String imageUrl;
  final VoidCallback onFollow;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 15),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFF1F2024), width: 1)),
      ),
      child: Row(
        children: [
          _UserAvatar(username: username, imageUrl: imageUrl),

          const SizedBox(width: 16),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  username,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    height: 1.2,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  fullName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF8A8D93),
                    fontSize: 17,
                    fontWeight: FontWeight.w400,
                    height: 1.2,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 12),

          SizedBox(
            height: 50,
            child: TextButton(
              onPressed: onFollow,
              style: TextButton.styleFrom(
                backgroundColor: const Color(0xFF1597FF),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 22),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Follow',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
              ),
            ),
          ),

          const SizedBox(width: 14),

          GestureDetector(
            onTap: onDismiss,
            child: const Icon(
              Icons.close_rounded,
              color: Color(0xFF8A8D93),
              size: 28,
            ),
          ),
        ],
      ),
    );
  }
}

class _UserAvatar extends StatelessWidget {
  const _UserAvatar({required this.username, required this.imageUrl});

  final String username;
  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    if (imageUrl.isNotEmpty) {
      return CircleAvatar(
        radius: 27,
        backgroundColor: const Color(0xFF20242A),
        backgroundImage: NetworkImage(imageUrl),
      );
    }

    return CircleAvatar(
      radius: 27,
      backgroundColor: const Color(0xFF20242A),
      child: Text(
        username.isNotEmpty ? username[0].toUpperCase() : '?',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
