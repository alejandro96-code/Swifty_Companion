import 'package:flutter/material.dart';

import '../services/forty_two_api.dart';

class UserProjects extends StatefulWidget {
  final String login;

  const UserProjects({required this.login, super.key});

  @override
  State<UserProjects> createState() => _UserProjectsState();
}

class _UserProjectsState extends State<UserProjects> {
  final _api = FortyTwoApi();
  List<Map<String, dynamic>> _projects = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchProjects();
  }

  Future<void> _fetchProjects() async {
    try {
      final user = await _api.fetchUser(widget.login);
      final projectsUsers = user['projects_users'] as List<dynamic>?;
      final projects = _extractFinishedProjects(projectsUsers);
      if (!mounted) return;
      setState(() {
        _projects = projects;
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

  List<Map<String, dynamic>> _extractFinishedProjects(
    List<dynamic>? projectsUsers,
  ) {
    if (projectsUsers == null) {
      return [];
    }

    final filtered = <Map<String, dynamic>>[];
    for (final entry in projectsUsers) {
      if (entry is! Map<String, dynamic>) {
        continue;
      }
      if (entry['status'] != 'finished') {
        continue;
      }
      filtered.add(entry);
    }

    return filtered;
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

    if (_projects.isEmpty) {
      return const Text(
        'Sin proyectos finalizados.',
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
            'Proyectos finalizados',
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
            itemCount: _projects.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final projectUser = _projects[index];
              final project = projectUser['project'] as Map<String, dynamic>?;
              final name = (project?['name'] ?? '-').toString();
              final finalMark = projectUser['final_mark'];
              final validated = projectUser['validated?'] == true;
              final statusText = validated ? 'OK' : 'Fallido';

              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      name,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    finalMark == null ? '-' : finalMark.toString(),
                    style: const TextStyle(fontSize: 12),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    statusText,
                    style: TextStyle(
                      fontSize: 12,
                      color: validated ? Colors.green : Colors.red,
                    ),
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
