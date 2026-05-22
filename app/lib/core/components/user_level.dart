import 'package:flutter/material.dart';

import '../services/forty_two_api.dart';

class UserLevel extends StatefulWidget {
  final String login;

  const UserLevel({required this.login, super.key});

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
        _error = error.toString();
        _isLoading = false;
      });
    }
  }

  List<Map<String, dynamic>> _extractSkills(List<dynamic>? cursusUsers) {
    if (cursusUsers == null) {
      return [];
    }

    for (final cursus in cursusUsers) {
      if (cursus is! Map<String, dynamic>) {
        continue;
      }
      final skills = cursus['skills'];
      if (skills is List) {
        return skills.whereType<Map<String, dynamic>>().toList();
      }
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
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Habilidades',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _skills.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
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
                  Text(
                    '$name - Nivel ${level.toStringAsFixed(2)} ($percent%)',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 6),
                  LinearProgressIndicator(
                    value: progress,
                    minHeight: 6,
                    backgroundColor: Colors.grey.shade300,
                    color: Colors.blue[700],
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
