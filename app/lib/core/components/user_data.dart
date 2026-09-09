import 'package:flutter/material.dart';
import '../utils/forty_two_user_utils.dart';

class UserData extends StatelessWidget {
  final Map<String, dynamic> user;
  final bool forceTwoColumns;
  final bool fillHeight;

  const UserData({
    required this.user,
    this.forceTwoColumns = false,
    this.fillHeight = false,
    super.key,
  });

    // Generate the widget for profile card
  Widget _infoTile(String label, String value, double width) {
    return SizedBox(
      width: width,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFFF5F7FB),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFFE3E7EF)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label.toUpperCase(),
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: Color(0xFF7A869A),
                letterSpacing: 0.6,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF0F172A),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Generate the profile card with all datas
  @override
  Widget build(BuildContext context) {
    final accent = Colors.white.withOpacity(0.92);

    final card = Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: accent,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: Colors.white.withOpacity(0.6)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 18,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(3),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: const Color(0xFF0C2E5A),
                            width: 2,
                          ),
                        ),
                        child: CircleAvatar(
                          radius: 44,
                          backgroundColor: Colors.white,
                          backgroundImage: extractUserImageUrl(user) != null
                              ? NetworkImage(extractUserImageUrl(user)!)
                            : null,
                          child: extractUserImageUrl(user) == null
                              ? Icon(
                                  Icons.person,
                                  size: 34,
                                  color: Colors.blue[700],
                                )
                              : null,
                          onBackgroundImageError: (exception, stackTrace) {
                            debugPrint('Error loading image: $exception');
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              user['displayname'] ?? user['login'] ?? '-',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF0F172A),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              user['email']?.toString() ?? '-',
                              style: const TextStyle(
                                color: Color(0xFF475569),
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Pool: ${formatUserPool(user)}',
                              style: const TextStyle(
                                color: Color(0xFF64748B),
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              '@${user['login'] ?? '-'}',
                              style: const TextStyle(
                                color: Color(0xFF5B6B82),
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFE6F1FF),
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Divider(color: Colors.grey.shade300, height: 1),
                  const SizedBox(height: 16),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final isTwoColumns =
                          forceTwoColumns || constraints.maxWidth >= 520;
                      final columns = isTwoColumns ? 2 : 1;
                      final spacing = 12.0;
                      final tileWidth = (constraints.maxWidth -
                              (spacing * (columns - 1))) /
                          columns;
                      return Wrap(
                        spacing: spacing,
                        runSpacing: spacing,
                        children: [
                          _infoTile('Level', extractUserLevel(user['cursus_users'] as List<dynamic>?)?.toStringAsFixed(2) ?? '-', tileWidth),
                          _infoTile('Location', user['location']?.toString() ?? '-', tileWidth),
                          _infoTile('Wallet', user['wallet']?.toString() ?? '-', tileWidth),
                          _infoTile('Evaluations', user['correction_point']?.toString() ?? '-', tileWidth),
                          _infoTile('Campus', formatUserCampus(user), tileWidth),
                          _infoTile('Joined', formatUserCreatedAt(user), tileWidth),
                        ],
                      );
                    },
                  ),
                ],
              ),
          );

    return Align(
      alignment: Alignment.topLeft,
      child: fillHeight ? SizedBox.expand(child: card) : card,
    );
  }
}
