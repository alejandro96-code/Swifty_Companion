import 'package:flutter/material.dart';
import '../services/forty_two_api.dart';

class UserProjects extends StatefulWidget {
  final String login;
  final double? maxListHeight;

  const UserProjects({
    required this.login,
    this.maxListHeight,
    super.key,
  });

  @override
  State<UserProjects> createState() => _UserProjectsState();
}

class _UserProjectsState extends State<UserProjects> {
  final _api = FortyTwoApi();
  Map<String, List<Map<String, dynamic>>> _sections = {};
  String? _activeSection;
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
      final userId = user['id'];

      if (userId is! int) {
        throw Exception('Identificador de usuario invalido');
      }

      final projectsUsers = await _api.fetchUserProjects(userId);
      final cursusUsers = user['cursus_users'] as List<dynamic>?;

      final sections = _extractFinishedProjectsBySection(
        projectsUsers,
        cursusUsers,
      );

      if (!mounted) return;

      setState(() {
        _sections = sections;
        _activeSection =
            sections.keys.isNotEmpty ? sections.keys.first : null;
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

  Map<String, List<Map<String, dynamic>>> _extractFinishedProjectsBySection(
    List<dynamic>? projectsUsers,
    List<dynamic>? cursusUsers,
  ) {
    if (projectsUsers == null) {
      return {};
    }

    final cPiscineIds = <int>{};
    var coreCompleted = false;

    if (cursusUsers != null) {
      var i = 0;

      while (i < cursusUsers.length) {
        final entry = cursusUsers[i];

        if (entry is Map<String, dynamic>) {
          final cursus = entry['cursus'] as Map<String, dynamic>?;
          final id = cursus?['id'];

          if (id is int) {
            final slug = cursus?['slug']?.toString().toLowerCase() ?? '';

            final name = cursus?['name']?.toString().toLowerCase() ?? '';
            final isCPiscine = slug == 'piscine-c' ||
                slug == 'c-piscine' ||
                name == 'c piscine' ||
                name == 'piscine c';

            if (slug == '42cursus') {
              coreCompleted = coreCompleted || entry['completed'] == true;
            } else if (isCPiscine) {
              cPiscineIds.add(id);
            }
          }
        }

        i++;
      }
    }

    /*
     * Si el 42cursus está completado mostramos
     * "Cursus + Outer", si no mostramos "Cursus".
     */
    final cursusSectionName =
        coreCompleted ? 'Cursus + Outer' : 'Cursus';

    final sections = <String, List<Map<String, dynamic>>>{
      'C Piscine': [],
      cursusSectionName: [],
    };

    /*
     * Recorremos todos los proyectos del usuario.
     *
     * IMPORTANTE:
     * Solo mostramos proyectos con resultado de validacion, tanto aprobados
     * como fallidos. No usamos el campo "status".
     */
    var i = 0;

    while (i < projectsUsers.length) {
      final entry = projectsUsers[i];

      if (entry is Map<String, dynamic>) {
        if (entry['validated?'] is! bool) {
          i++;
          continue;
        }

        final cursusIds = entry['cursus_ids'] as List<dynamic>?;

        final ids =
            cursusIds?.whereType<int>().toSet() ?? <int>{};

        final isPiscineProject =
            cPiscineIds.isNotEmpty &&
            ids.intersection(cPiscineIds).isNotEmpty;

        if (isPiscineProject) {
          sections['C Piscine']!.add(entry);
        } else {
          sections[cursusSectionName]!.add(entry);
        }
      }
      i++;
    }

    /*
     * Ordenamos los proyectos alfabéticamente
     * dentro de cada sección.
     */
    for (final list in sections.values) {
      list.sort((a, b) {
        final aProject =
            a['project'] as Map<String, dynamic>?;
        final bProject =
            b['project'] as Map<String, dynamic>?;

        final aName =
            (aProject?['name'] ?? '')
                .toString()
                .toLowerCase();

        final bName =
            (bProject?['name'] ?? '')
                .toString()
                .toLowerCase();

        return aName.compareTo(bName);
      });
    }

    return sections;
  }

  int get _totalCount {
    var total = 0;

    for (final list in _sections.values) {
      total += list
          .where((project) => project['validated?'] == true)
          .length;
    }

    return total;
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          color: Colors.white,
        ),
      );
    }

    if (_error != null) {
      return Text(
        _error!,
        textAlign: TextAlign.left,
        style: const TextStyle(
          color: Colors.white,
        ),
      );
    }

    if (_sections.isEmpty) {
      return const Text(
        'Sin proyectos finalizados.',
        style: TextStyle(
          color: Colors.white,
        ),
      );
    }

    final activeKey =
        _activeSection ?? _sections.keys.first;

    final activeProjects =
        _sections[activeKey] ?? [];

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.92),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: Colors.white.withOpacity(0.6),
        ),
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
          Align(
            alignment: Alignment.centerLeft,
            child: Wrap(
              spacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                const Text(
                  'Proyectos finalizados',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF0F172A),
                  ),
                ),
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
                    '$_totalCount',
                    style: const TextStyle(
                      color: Color(0xFF1E3A8A),
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _sections.keys.map((key) {
              final isActive = key == activeKey;

              return ChoiceChip(
                label: Text(key),
                selected: isActive,
                onSelected: (_) {
                  setState(() {
                    _activeSection = key;
                  });
                },
                labelStyle: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: isActive
                      ? const Color(0xFF1E3A8A)
                      : const Color(0xFF475569),
                ),
                backgroundColor:
                    const Color(0xFFF1F5FF),
                selectedColor:
                    const Color(0xFFE6F1FF),
                side: BorderSide(
                  color: isActive
                      ? const Color(0xFF93C5FD)
                      : const Color(0xFFE2E8F0),
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 14),

          SizedBox(
            height: widget.maxListHeight,
            child: ListView.separated(
              shrinkWrap:
                  widget.maxListHeight == null,
              physics: widget.maxListHeight == null
                  ? const NeverScrollableScrollPhysics()
                  : const BouncingScrollPhysics(),
              itemCount: activeProjects.length,
              separatorBuilder: (_, __) =>
                  const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final projectUser =
                    activeProjects[index];

                final project =
                    projectUser['project']
                        as Map<String, dynamic>?;

                final name =
                    (project?['name'] ?? '-').toString();

                final finalMark =
                    projectUser['final_mark'];

                /*
                 * El estado visual también depende de
                 * validated?, no de status.
                 */
                final validated =
                    projectUser['validated?'] == true;

                final statusText =
                    validated ? 'OK' : 'Fallido';

                final badgeColor = validated
                    ? const Color(0xFFDCFCE7)
                    : const Color(0xFFFEE2E2);

                final badgeText = validated
                    ? const Color(0xFF166534)
                    : const Color(0xFF991B1B);

                return Container(
                  padding:
                      const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFF),
                    borderRadius:
                        BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFFE3E7EF),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          name,
                          style: const TextStyle(
                            fontWeight:
                                FontWeight.w600,
                            color:
                                Color(0xFF0F172A),
                          ),
                        ),
                      ),

                      const SizedBox(width: 10),

                      Text(
                        finalMark == null
                            ? '-'
                            : finalMark.toString(),
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF475569),
                        ),
                      ),

                      const SizedBox(width: 10),

                      Container(
                        padding:
                            const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: badgeColor,
                          borderRadius:
                              BorderRadius.circular(12),
                        ),
                        child: Text(
                          statusText,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight:
                                FontWeight.w700,
                            color: badgeText,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}