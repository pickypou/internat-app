import 'dart:math';
import 'dart:developer' as dev;
import 'package:injectable/injectable.dart';
import '../../domain/repositories/group_repository.dart';
import '../../../students/data/datasources/student_remote_datasource.dart';
import '../../../students/domain/entities/student_entity.dart';

/// Result of a global import operation.
class GlobalImportResult {
  final int imported;
  final int skipped;
  final List<String> errors;

  const GlobalImportResult({
    required this.imported,
    required this.skipped,
    required this.errors,
  });

  String get summary {
    if (skipped == 0) return '$imported élève(s) importé(s) avec succès.';
    return '$imported élève(s) importé(s), $skipped ligne(s) ignorée(s).';
  }
}

/// Parses a pasted multi-line string (tab or semicolon separated) and dispatches
/// each student to the right group, creating the group if it doesn't exist.
///
/// Expected columns per line: Nom | Prénom | Classe | Chambre | NomGroupe
@injectable
class GlobalImportUseCase {
  final GroupRepository _groupRepository;
  final StudentRemoteDataSource _studentDataSource;

  GlobalImportUseCase(this._groupRepository, this._studentDataSource);

  // Vivid colors palette for new groups (avoids appel-dimanche orange FF6D00)
  static const _colors = [
    'E53935',
    'D81B60',
    '8E24AA',
    '5E35B1',
    '1E88E5',
    '039BE5',
    '00ACC1',
    '00897B',
    '43A047',
    'C0CA33',
    'F4511E',
    '6D4C41',
  ];

  String _randomColor(List<String> usedColors) {
    final available = _colors.where((c) => !usedColors.contains(c)).toList();
    if (available.isEmpty) return _colors[Random().nextInt(_colors.length)];
    return available[Random().nextInt(available.length)];
  }

  /// Normalizes a group name: trim + capitalize first letter.
  /// 'hugue' -> 'Hugue', 'POL-SUP' -> 'Pol-sup'
  String _normalizeName(String raw) {
    final t = raw.trim();
    if (t.isEmpty) return t;
    return t[0].toUpperCase() + t.substring(1).toLowerCase();
  }

  Future<GlobalImportResult> call(String rawText) async {
    final lines = rawText
        .split('\n')
        .where((l) => l.trim().isNotEmpty)
        .toList();

    if (lines.isEmpty) {
      return const GlobalImportResult(imported: 0, skipped: 0, errors: []);
    }

    // Load existing groups once
    final existingGroups = await _groupRepository.getGroups();
    dev.log(
      '[GlobalImport] Existing groups: ${existingGroups.map((g) => g.name).join(', ')}',
    );

    final usedColors = existingGroups
        .map((g) => g.color.toUpperCase())
        .toList();
    // Cache: groupNameLower → groupId
    final groupIdCache = <String, String>{
      for (final g in existingGroups) g.name.toLowerCase().trim(): g.id,
    };

    final students = <StudentEntity>[];
    final skippedLines = <String>[];
    int lineIndex = 0;

    for (final line in lines) {
      lineIndex++;
      try {
        final parts = line.contains('\t') ? line.split('\t') : line.split(';');

        final lastName = parts.isNotEmpty ? parts[0].trim() : '';
        final firstName = parts.length > 1 ? parts[1].trim() : '';
        final className = parts.length > 2 ? parts[2].trim() : '';
        final roomNumber = parts.length > 3 ? parts[3].trim() : '';
        final groupName = parts.length > 4 ? parts[4].trim() : '';

        dev.log(
          '[GlobalImport] Line $lineIndex: lastName="$lastName" firstName="$firstName" group="$groupName"',
        );

        if (lastName.isEmpty || firstName.isEmpty) {
          dev.log(
            '[GlobalImport] Line $lineIndex SKIPPED: missing Nom or Prénom',
          );
          skippedLines.add('Ligne $lineIndex: Nom ou Prénom manquant');
          continue;
        }
        if (groupName.isEmpty) {
          dev.log(
            '[GlobalImport] Line $lineIndex SKIPPED: missing Groupe column',
          );
          skippedLines.add(
            'Ligne $lineIndex ($lastName $firstName): colonne Groupe manquante',
          );
          continue;
        }

        // Normalize: 'hugue' / 'HUGUE' / 'Hugue' all → 'Hugue'
        final canonicalName = _normalizeName(groupName);
        final groupKey = canonicalName.toLowerCase();

        if (!groupIdCache.containsKey(groupKey)) {
          final color = _randomColor(usedColors);
          usedColors.add(color);
          dev.log(
            '[GlobalImport] Creating/finding group "$canonicalName" with color #$color',
          );
          final newId = await _groupRepository.ensureGroupExists(
            canonicalName,
            color,
          );
          groupIdCache[groupKey] = newId;
          dev.log(
            '[GlobalImport] Group "$canonicalName" resolved to id=$newId',
          );
        }

        students.add(
          StudentEntity(
            id: '',
            firstName: firstName,
            lastName: lastName,
            roomNumber: roomNumber,
            className: className,
            groupId: groupIdCache[groupKey]!,
          ),
        );
      } catch (e, stack) {
        dev.log('[GlobalImport] Line $lineIndex ERROR: $e\n$stack');
        skippedLines.add('Ligne $lineIndex: erreur inattendue ($e)');
      }
    }

    dev.log(
      '[GlobalImport] Parsed ${students.length} valid students, ${skippedLines.length} skipped',
    );

    if (students.isNotEmpty) {
      try {
        await _studentDataSource.addStudents(students);
        dev.log(
          '[GlobalImport] Upsert successful for ${students.length} students',
        );
      } catch (e, stack) {
        dev.log('[GlobalImport] UPSERT ERROR: $e\n$stack');
        rethrow;
      }
    }

    return GlobalImportResult(
      imported: students.length,
      skipped: skippedLines.length,
      errors: skippedLines,
    );
  }
}
