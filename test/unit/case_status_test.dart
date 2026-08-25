import 'package:flutter_test/flutter_test.dart';
import 'package:rakshak/data/models/case_record.dart';
import 'package:rakshak/data/models/incident.dart';

void main() {
  group('CaseStatus', () {
    test('every status has a non-empty label and explanation', () {
      for (final status in CaseStatus.values) {
        expect(status.label, isNotEmpty);
        expect(status.explanation, isNotEmpty);
      }
    });

    test('explanations never claim a guaranteed outcome', () {
      const bannedPhrases = [
        'guarantee',
        'definitely',
        'will be recovered',
        'will be resolved',
      ];
      for (final status in CaseStatus.values) {
        final lower = status.explanation.toLowerCase();
        for (final phrase in bannedPhrases) {
          expect(
            lower.contains(phrase),
            isFalse,
            reason: '${status.name} explanation contains "$phrase"',
          );
        }
      }
    });

    test('CaseRecord.copyWith preserves fields that are not overridden', () {
      final record = CaseRecord(
        id: 'RKS-100000',
        category: IncidentCategory.upiFraud,
        createdAt: DateTime(2026, 1, 1),
        status: CaseStatus.submitted,
        timeline: const [],
      );
      final updated = record.copyWith(status: CaseStatus.underReview);

      expect(updated.status, CaseStatus.underReview);
      expect(updated.id, record.id);
      expect(updated.category, record.category);
    });

    test('CaseRecord round-trips through JSON', () {
      final record = CaseRecord(
        id: 'RKS-100001',
        category: IncidentCategory.socialMediaHarassment,
        createdAt: DateTime(2026, 8, 20),
        status: CaseStatus.underInvestigation,
        amountInPaise: 500000,
        timeline: [
          CaseTimelineStep(
            status: CaseStatus.submitted,
            occurredAt: DateTime(2026, 8, 20),
          ),
          CaseTimelineStep(
            status: CaseStatus.underInvestigation,
            occurredAt: DateTime(2026, 8, 21),
            note: 'Demo',
          ),
        ],
      );
      final restored = CaseRecord.fromJson(record.toJson());

      expect(restored.id, record.id);
      expect(restored.status, record.status);
      expect(restored.amountInPaise, record.amountInPaise);
      expect(restored.timeline.length, 2);
      expect(restored.timeline.last.note, 'Demo');
    });
  });
}
