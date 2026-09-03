import 'package:flutter/material.dart';

import '../services/forty_two_api.dart';

class UserLevel extends StatefulWidget {
  final String login;
  final double? maxListHeight;

  const UserLevel({
    required this.login,
    this.maxListHeight,
    super.key,
  });

  @override
  State<UserLevel> createState() => _UserLevelState();
}

class _UserLevelState extends State<UserLevel> {
  final _api = FortyTwoApi();
  List<Map<String, dynamic>> _skills = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchSkills();
  }

  Future<void> _fetchSkills() async {
    try {
      final user = await _api.fetchUser(widget.login);
      final cursusUsers = user['cursus_users'] as List<dynamic>?;
      final skills = _extractSkills(cursusUsers);
      if (!mounted) return;
      setState(() {
        _skills = skills;
        _isLoading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _error = _api.errorMessage(error);
        _isLoading = false;
      });
    }
  }

  List<Map<String, dynamic>> _extractSkills(List<dynamic>? cursusUsers) {
    if (cursusUsers == null) {
      return [];
    }

    Map<String, dynamic>? fallback;
    for (final cursus in cursusUsers) {
      if (cursus is! Map<String, dynamic>) {
        continue;
      }
      final skills = cursus['skills'];
      if (skills is! List) {
        continue;
      }
      final cursusInfo = cursus['cursus'] as Map<String, dynamic>?;
      final slug = cursusInfo?['slug']?.toString();
      if (slug == '42cursus') {
        return skills.whereType<Map<String, dynamic>>().toList();
      }
      fallback ??= cursus;
    }

    final skills = fallback?['skills'];
    if (skills is List) {
      final list = skills.whereType<Map<String, dynamic>>().toList();
      list.sort((a, b) {
        final aName = (a['name'] ?? '').toString().toLowerCase();
        final bName = (b['name'] ?? '').toString().toLowerCase();
        return aName.compareTo(bName);
      });
      return list;
    }
    return [];
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.white),
      );
    }

    if (_error != null) {
      return Text(
        _error!,
        textAlign: TextAlign.left,
        style: const TextStyle(color: Colors.white),
      );
    }

    if (_skills.isEmpty) {
      return const Text(
        'Sin habilidades disponibles.',
        style: TextStyle(color: Colors.white),
      );
    }

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.92),
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
              const Text(
                'Habilidades',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF0F172A),
                ),
              ),
              const SizedBox(width: 10),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFE6F1FF),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${_skills.length}',
                  style: const TextStyle(
                    color: Color(0xFF1E3A8A),
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          SizedBox(
            height: widget.maxListHeight,
            child: ListView.separated(
              shrinkWrap: widget.maxListHeight == null,
              physics: widget.maxListHeight == null
                  ? const NeverScrollableScrollPhysics()
                  : const BouncingScrollPhysics(),
              itemCount: _skills.length,
              separatorBuilder: (_, __) => const SizedBox(height: 14),
              itemBuilder: (context, index) {
                final skill = _skills[index];
                final name = (skill['name'] ?? '-').toString();
                final level = (skill['level'] as num?)?.toDouble() ?? 0.0;
                final fraction = level - level.floorToDouble();
                final percent = (fraction * 100).round();
                final progress = fraction.clamp(0.0, 1.0).toDouble();

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            name,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                        ),
                        Text(
                          'Lvl ${level.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF64748B),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '$percent%',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF1E3A8A),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: LinearProgressIndicator(
                        value: progress,
                        minHeight: 7,
                        backgroundColor: const Color(0xFFE8ECF5),
                        color: const Color(0xFF1D4ED8),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
