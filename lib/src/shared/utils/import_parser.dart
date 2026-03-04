import '../../features/students/domain/entities/student_entity.dart';

/// Result of parsing a single raw import line.
class ParsedStudentLine {
  final StudentEntity? student;
  final String? error; // non-null when parsing failed

  const ParsedStudentLine.ok(this.student) : error = null;
  const ParsedStudentLine.err(this.error) : student = null;

  bool get isValid => student != null;
}

/// Stateless parser shared by ALL student import entry points.
///
/// Supports two tab-or-semicolon column layouts:
///   5 cols : Nom | Prénom | Classe | Chambre | Groupe
///   4 cols : Nom Complet | Classe | Chambre | Groupe
///
/// Normalisation:
///   • lastName   → MAJUSCULES
///   • firstName  → Title Case (handles Jean-Pierre, Marie France, etc.)
///   • all fields → trimmed
abstract final class ImportParser {
  // ── Public API ─────────────────────────────────────────────────────────────

  /// Parse [line] into a student entity belonging to [groupId].
  ///
  /// When the caller is the _global_ importer (group resolved externally),
  /// use [groupId] as the already-resolved id.
  ///
  /// Returns [ParsedStudentLine.err] if the format is invalid or required
  /// fields are empty.
  static ParsedStudentLine parseLine(
    String line,
    String groupId,
    int lineIndex,
  ) {
    final parts = line.contains('\t') ? line.split('\t') : line.split(';');
    final cols = parts.map((p) => p.trim()).toList();

    String lastName;
    String firstName;
    String className;
    String roomNumber;

    if (cols.length >= 5) {
      // ── Cas A : Nom | Prénom | Classe | Chambre | Groupe ──────────────────
      lastName = cols[0];
      firstName = cols[1];
      className = cols[2];
      roomNumber = cols[3];
      // cols[4] = groupe
    } else if (cols.length == 4) {
      // ── Cas B : Nom Complet | Classe | Chambre | Groupe ───────────────────
      final names = _splitFullName(cols[0]);
      lastName = names[0];
      firstName = names[1];
      className = cols[1];
      roomNumber = cols[2];
      // cols[3] = groupe
    } else if (cols.length >= 2) {
      // ── Cas C : Nom | Prénom (sans groupe) — utilisé par BulkImport ───────
      lastName = cols[0];
      firstName = cols[1];
      className = cols.length > 2 ? cols[2] : '';
      roomNumber = cols.length > 3 ? cols[3] : '';
    } else {
      return ParsedStudentLine.err(
        'Format de ligne invalide à la ligne $lineIndex '
        '(${cols.length} colonne(s) reçue(s), 2+ attendues)',
      );
    }

    // ── Normalisation ────────────────────────────────────────────────────────
    lastName = lastName.toUpperCase();
    firstName = titleCase(firstName);

    if (lastName.isEmpty) {
      return ParsedStudentLine.err('Ligne $lineIndex : nom vide');
    }
    if (firstName.isEmpty) {
      return ParsedStudentLine.err('Ligne $lineIndex : prénom vide');
    }

    return ParsedStudentLine.ok(
      StudentEntity(
        id: '',
        firstName: firstName,
        lastName: lastName,
        className: className,
        roomNumber: roomNumber,
        groupId: groupId,
      ),
    );
  }

  /// Returns the group name token from a raw line (last column).
  /// Returns empty string if not enough columns.
  static String extractGroupName(String line) {
    final parts = line.contains('\t') ? line.split('\t') : line.split(';');
    final cols = parts.map((p) => p.trim()).toList();
    if (cols.length == 5) return cols[4];
    if (cols.length == 4) return cols[3];
    return '';
  }

  // ── Helpers (public for tests) ─────────────────────────────────────────────

  /// Title-cases a name string.
  /// 'jean-pierre' → 'Jean Pierre'  |  'MARIE france' → 'Marie France'
  static String titleCase(String raw) {
    final t = raw.trim();
    if (t.isEmpty) return t;
    return t
        .split(RegExp(r'[\s\-]+'))
        .map(
          (w) =>
              w.isEmpty ? w : w[0].toUpperCase() + w.substring(1).toLowerCase(),
        )
        .join(' ');
  }

  /// Splits a full name string into [LastName, FirstName]
  static List<String> _splitFullName(String fullName) {
    final t = fullName.trim();
    if (t.isEmpty) return ['', ''];
    if (t.contains(',')) {
      final p = t.split(',');
      return [p[0].trim(), p.sublist(1).join(' ').trim()];
    }
    // User requirement:
    // First word is Last Name (forced to uppercase later by normalize)
    // Everything else after the first space is First Name
    final firstSpaceIndex = t.indexOf(' ');
    if (firstSpaceIndex == -1) {
      return [t, ''];
    }

    final lastName = t.substring(0, firstSpaceIndex).trim();
    final firstName = t.substring(firstSpaceIndex + 1).trim();
    return [lastName, firstName];
  }
}
