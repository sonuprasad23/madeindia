import 'package:flutter_test/flutter_test.dart';
import 'package:rakshak/data/models/evidence_item.dart';

void main() {
  group('EvidenceItem', () {
    test('formattedSize renders bytes, KB, and MB appropriately', () {
      final small = _item(fileSizeBytes: 512);
      final medium = _item(fileSizeBytes: 20 * 1024);
      final large = _item(fileSizeBytes: 5 * 1024 * 1024);

      expect(small.formattedSize, '512 B');
      expect(medium.formattedSize, endsWith('KB'));
      expect(large.formattedSize, endsWith('MB'));
    });

    test('round-trips through JSON without losing data', () {
      final original = _item(
        fileSizeBytes: 1024,
        extractedData: const ExtractedEvidenceData(
          amount: '₹5,000',
          utr: '123456789012',
        ),
      );
      final restored = EvidenceItem.fromJson(original.toJson());

      expect(restored.id, original.id);
      expect(restored.sha256Hash, original.sha256Hash);
      expect(restored.category, original.category);
      expect(restored.extractedData?.amount, '₹5,000');
      expect(restored.extractedData?.utr, '123456789012');
    });

    test('copyWith only changes the requested fields', () {
      final original = _item(fileSizeBytes: 1024);
      final updated = original.copyWith(userNotes: 'Reviewed');

      expect(updated.userNotes, 'Reviewed');
      expect(updated.id, original.id);
      expect(updated.sha256Hash, original.sha256Hash);
    });
  });
}

EvidenceItem _item({
  required int fileSizeBytes,
  ExtractedEvidenceData? extractedData,
}) {
  return EvidenceItem(
    id: 'evidence-1',
    type: EvidenceType.image,
    category: EvidenceCategory.financial,
    source: 'Test',
    createdAt: DateTime(2026, 8, 24, 10, 30),
    originalFileName: 'screenshot.png',
    fileSizeBytes: fileSizeBytes,
    sha256Hash: 'abc123',
    extractedData: extractedData,
  );
}
