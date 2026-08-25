import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

import '../../data/models/evidence_item.dart';
import 'mock_extraction_service.dart';

/// Copies a picked file into the app's private evidence directory and
/// computes its SHA-256 hash. The original file selected by the user is
/// never mutated — this only ever reads it once, to copy bytes and hash.
class EvidenceFileService {
  const EvidenceFileService();

  static const _uuid = Uuid();

  Future<EvidenceItem> ingestFile({
    required File sourceFile,
    required EvidenceType type,
    required EvidenceCategory category,
    required String source,
    String description = '',
  }) async {
    final bytes = await sourceFile.readAsBytes();
    final hash = sha256.convert(bytes).toString();

    final dir = await getApplicationDocumentsDirectory();
    final evidenceDir = Directory('${dir.path}/evidence');
    await evidenceDir.create(recursive: true);

    final originalName = p.basename(sourceFile.path);
    final storedName = '${_uuid.v4()}_$originalName';
    final storedFile = await sourceFile.copy('${evidenceDir.path}/$storedName');

    return EvidenceItem(
      id: _uuid.v4(),
      type: type,
      category: category,
      source: source,
      createdAt: DateTime.now(),
      originalFileName: originalName,
      fileSizeBytes: bytes.length,
      sha256Hash: hash,
      filePath: storedFile.path,
      description: description,
      extractedData: MockExtractionService.supportsExtraction(category)
          ? MockExtractionService.extract(sha256Hash: hash, type: type)
          : null,
    );
  }

  EvidenceItem ingestText({
    required String text,
    required EvidenceCategory category,
    required String source,
  }) {
    final bytes = text.codeUnits;
    final hash = sha256.convert(bytes).toString();
    return EvidenceItem(
      id: _uuid.v4(),
      type: EvidenceType.text,
      category: category,
      source: source,
      createdAt: DateTime.now(),
      originalFileName: 'Text note',
      fileSizeBytes: bytes.length,
      sha256Hash: hash,
      textContent: text,
    );
  }
}
