import 'dart:math';
import 'dart:developer' as dev;
import 'package:injectable/injectable.dart';
import '../../domain/repositories/group_repository.dart';
import '../../../students/data/datasources/student_remote_datasource.dart';
import '../../../students/domain/entities/student_entity.dart';
import '../../../../shared/utils/import_parser.dart';

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
/// All line parsing is delegated to [ImportParser] (shared, DRY).
///
/// Supported column layouts:
///   5 cols : Nom | Prénom | Classe | Chambre | NomGroupe
///   4 cols : Nom Complet | Classe | Chambre | NomGroupe
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

  /// Normalize group name: 'hugue' → 'Hugue', 'POL-SUP' → 'Pol-sup'
  String _normalizeName(String raw) {
    final t = raw.trim();
    if (t.isEmpty) return t;
    return t[0].toUpperCase() + t.substring(1).toLowerCase();
  }

  Future<GlobalImportResult> call(
    String rawText, {
    bool clearDatabase = false,
  }) async {
    final lines = rawText
        .split('\n')
        .where((l) => l.trim().isNotEmpty)
        .toList();

    if (lines.isEmpty) {
      return const GlobalImportResult(imported: 0, skipped: 0, errors: []);
    }

    if (clearDatabase) {
      dev.log('[GlobalImport] Clearing students database before import');
      await _studentDataSource.deleteAllStudents();
    }

    // Load existing groups once
    final existingGroups = await _groupRepository.getGroups();
    dev.log(
      '[GlobalImport] Existing groups: ${existingGroups.map((g) => g.name).join(', ')}',
    );

    final usedColors = existingGroups
        .map((g) => g.color.toUpperCase())
        .toList();
    final groupIdCache = <String, String>{
      for (final g in existingGroups) g.name.toLowerCase().trim(): g.id,
    };

    final students = <StudentEntity>[];
    final skippedLines = <String>[];
    int lineIndex = 0;

    for (final line in lines) {
      lineIndex++;
      try {
        // Extract group name first — needed before delegating to ImportParser
        final groupName = ImportParser.extractGroupName(line);
        if (groupName.isEmpty) {
          skippedLines.add('Ligne $lineIndex : colonne Groupe manquante');
          continue;
        }

        final canonicalName = _normalizeName(groupName);
        final groupKey = canonicalName.toLowerCase();

        if (!groupIdCache.containsKey(groupKey)) {
          final color = _randomColor(usedColors);
          usedColors.add(color);
          
          final bool isPoleSup = canonicalName.toLowerCase().contains('alternant') ||
              canonicalName.toLowerCase().contains('pole-sup') ||
              canonicalName.toLowerCase().contains('pôle-sup') ||
              canonicalName.toLowerCase().contains('meca') ||
              canonicalName.toLowerCase().contains('méca') ||
              canonicalName.toLowerCase().contains('sécurité') ||
              canonicalName.toLowerCase().contains('securite');

          dev.log(
            '[GlobalImport] Creating group "$canonicalName" (PôleSup: $isPoleSup) color #$color',
          );
          
          // Cast repository to GroupRepositoryImpl to access the extended parameter if needed,
          // OR verify that ensureGroupExists supports it? Wait, we didn't add isPoleSup to ensureGroupExists. Let's fix ensureGroupExists.
          final newId = await _groupRepository.ensureGroupExists(
            canonicalName,
            color,
            isPoleSup: isPoleSup,
          );
          groupIdCache[groupKey] = newId;
          dev.log('[GlobalImport] Group "$canonicalName" → id=$newId');
        }

        // Delegate line parsing to shared ImportParser
        final parsed = ImportParser.parseLine(
          line,
          groupIdCache[groupKey]!,
          lineIndex,
        );
        if (!parsed.isValid) {
          dev.log('[GlobalImport] Line $lineIndex SKIPPED: ${parsed.error}');
          skippedLines.add(parsed.error!);
          continue;
        }

        dev.log(
          '[GlobalImport] Line $lineIndex OK: ${parsed.student!.lastName} ${parsed.student!.firstName}',
        );
        students.add(parsed.student!);
      } catch (e, stack) {
        dev.log('[GlobalImport] Line $lineIndex ERROR: $e\n$stack');
        skippedLines.add('Ligne $lineIndex : erreur inattendue ($e)');
      }
    }

    dev.log(
      '[GlobalImport] Parsed ${students.length} valid, ${skippedLines.length} skipped',
    );

    if (students.isNotEmpty) {
      try {
        await _studentDataSource.addStudents(students);
        dev.log('[GlobalImport] Upsert OK for ${students.length} students');
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
