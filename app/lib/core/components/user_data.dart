import 'package:flutter/material.dart';

class UserData extends StatelessWidget {
  final Map<String, dynamic> user;

  const UserData({required this.user, super.key});

  double? _extractLevel() {
    final cursusUsers = user['cursus_users'] as List<dynamic>?;
    if (cursusUsers == null || cursusUsers.isEmpty) {
      return null;
    }

    Map<String, dynamic>? primary;
    for (final entry in cursusUsers) {
      if (entry is! Map<String, dynamic>) {
        continue;
      }
      final cursus = entry['cursus'] as Map<String, dynamic>?;
      final slug = cursus?['slug']?.toString();
      if (slug == '42cursus') {
        primary = entry;
        break;
      }
      primary ??= entry;
    }

    final level = primary?['level'];
    if (level is num) {
      return level.toDouble();
    }
    return null;
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  String _formatCreatedAt() {
    final raw = user['created_at']?.toString();
    if (raw == null || raw.isEmpty) {
      return '-';
    }
    final parsed = DateTime.tryParse(raw);
    if (parsed == null) {
      return raw;
    }
    final year = parsed.year.toString().padLeft(4, '0');
    final month = parsed.month.toString().padLeft(2, '0');
    final day = parsed.day.toString().padLeft(2, '0');
    return '$day/$month/$year';
  }

  String _formatCampus() {
    final campuses = user['campus'] as List<dynamic>?;
    if (campuses == null || campuses.isEmpty) {
      return '-';
    }
    final primary = campuses.firstWhere(
      (campus) => campus is Map<String, dynamic>,
      orElse: () => campuses.first,
    );
    if (primary is! Map<String, dynamic>) {
      return '-';
    }
    final name = primary['name']?.toString() ?? '-';
    final city = primary['city']?.toString();
    return city == null || city.isEmpty ? name : '$name ($city)';
  }

  String _formatStatus() {
    final isStaff = user['staff?'] == true;
    final poolYear = user['pool_year']?.toString();
    final poolMonth = user['pool_month']?.toString();
    final isAlumni = user['alumni?'] == true;

    if (isStaff) {
      return 'staff';
    }
    if (poolYear != null && poolMonth != null) {
      return 'pool ($poolMonth $poolYear)';
    }
    if (isAlumni) {
      return 'alumni';
    }
    return 'student';
  }


  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topLeft,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 24,
          vertical: 16,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (user['image'] != null)
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white,
                    width: 4,
                  ),
                ),
                child: CircleAvatar(
                  radius: 80,
                  backgroundImage: NetworkImage(
                    (user['image'] is String
                            ? user['image']
                            : user['image']['versions']?['large']) ??
                        '',
                  ),
                  onBackgroundImageError: (exception, stackTrace) {
                    debugPrint('Error cargando imagen: $exception');
                  },
                ),
              )
            else
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white,
                    width: 4,
                  ),
                ),
                child: CircleAvatar(
                  radius: 80,
                  backgroundColor: Colors.white,
                  child: Icon(
                    Icons.person,
                    size: 60,
                    color: Colors.blue[700],
                  ),
                ),
              ),
            const SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user['displayname'] ?? user['login'] ?? '-',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _infoRow('Login', user['login']?.toString() ?? '-'),
                  _infoRow('Correo', user['email']?.toString() ?? '-'),
                  _infoRow('Movil', user['phone']?.toString() ?? '-'),
                  _infoRow(
                    'Nivel',
                    _extractLevel()?.toStringAsFixed(2) ?? '-',
                  ),
                  _infoRow('Ubicacion', user['location']?.toString() ?? '-'),
                  _infoRow('Billetera', user['wallet']?.toString() ?? '-'),
                  _infoRow(
                    'Evaluaciones',
                    user['correction_point']?.toString() ?? '-',
                  ),
                  _infoRow('Campus', _formatCampus()),
                  _infoRow('Estado', _formatStatus()),
                  _infoRow('Ingreso', _formatCreatedAt()),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
