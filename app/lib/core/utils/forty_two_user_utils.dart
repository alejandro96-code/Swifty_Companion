// Get cursus in this priority Zip > cursus > piscine
Map<String, dynamic>? selectPrimaryCursusUser(List<dynamic>? cursusUsers) {
  if (cursusUsers == null || cursusUsers.isEmpty) {
    return null;
  }

  Map<String, dynamic>? zipMatch;
  Map<String, dynamic>? coreMatch;
  Map<String, dynamic>? nonPiscineMatch;
  Map<String, dynamic>? anyMatch;

  for (final entry in cursusUsers) {
    if (entry is! Map<String, dynamic>) {
      continue;
    }

    anyMatch ??= entry;

    final cursus = entry['cursus'] as Map<String, dynamic>?;
    final slug = _normalizedText(cursus?['slug']);
    final name = _normalizedText(cursus?['name']);

    final isPiscine = slug.contains('piscine') || name.contains('piscine');
    final isZip = slug.contains('zip') || name.contains('zip');
    final isCore = slug == '42cursus' || name.contains('42cursus');

    if (isZip) {
      zipMatch ??= entry;
    } else if (isCore) {
      coreMatch ??= entry;
    } else if (!isPiscine) {
      nonPiscineMatch ??= entry;
    }
  }

  return zipMatch ?? coreMatch ?? nonPiscineMatch ?? anyMatch;
}

// Get the level of cursus User
double? extractUserLevel(List<dynamic>? cursusUsers) {
  final primary = selectPrimaryCursusUser(cursusUsers);
  final level = primary?['level'];
  if (level is num) {
    return level.toDouble();
  }
  return null;
}

// Get and sort the skills cursus
List<Map<String, dynamic>> extractUserSkills(List<dynamic>? cursusUsers) {
  final primary = selectPrimaryCursusUser(cursusUsers);
  final skills = primary?['skills'];

  if (skills is! List) {
    return [];
  }

  final list = skills.whereType<Map<String, dynamic>>().toList();
  list.sort((a, b) {
    final aName = (a['name'] ?? '').toString().toLowerCase();
    final bName = (b['name'] ?? '').toString().toLowerCase();
    return aName.compareTo(bName);
  });
  return list;
}

// Formats the account creation date as DD/MM/YYYY.
String formatUserCreatedAt(Map<String, dynamic> user) {
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

// Get the campus name and country
String formatUserCampus(Map<String, dynamic> user) {
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
  final country = primary['country']?.toString();
  if (country != null && country.isNotEmpty) {
    return '$name ($country)';
  }
  final city = primary['city']?.toString();
  return city == null || city.isEmpty ? name : '$name ($city)';
}

// Formats the pool month and year
String formatUserPool(Map<String, dynamic> user) {
  final poolYear = user['pool_year']?.toString();
  final poolMonth = user['pool_month']?.toString();
  if (poolYear == null || poolMonth == null) {
    return '-';
  }
  return '$poolMonth $poolYear';
}

// Get the user's profile image URL from the API
String? extractUserImageUrl(Map<String, dynamic> user) {
  final image = user['image'];
  if (image is String) {
    return image.isEmpty ? null : image;
  }
  if (image is Map<String, dynamic>) {
    final versions = image['versions'];
    if (versions is Map<String, dynamic>) {
      final large = versions['large']?.toString();
      if (large != null && large.isNotEmpty) {
        return large;
      }
    }
  }
  return null;
}

// Normalizes text for case-insensitive comparisons.
String _normalizedText(Object? value) => value?.toString().toLowerCase().trim() ?? '';
