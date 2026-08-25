import '../../data/models/citizen_profile.dart';
import '../../data/models/evidence_item.dart';
import '../../data/models/incident.dart';
import '../incidents/form_specs/incident_form_registry.dart';

/// One line item in the Complaint Review checklist.
class ReviewItem {
  const ReviewItem({required this.label, required this.present, this.value});
  final String label;
  final bool present;
  final String? value;
}

class ReviewSection {
  const ReviewSection({required this.title, required this.items});
  final String title;
  final List<ReviewItem> items;

  bool get allPresent => items.every((i) => i.present);
}

/// Structures ONLY user-provided facts (from [Incident.formData]/[Incident.
/// description], [CitizenProfile], and attached [EvidenceItem]s) into a
/// review-ready shape.
///
/// This deliberately does not call any generative model — there is
/// nothing here for an LLM to hallucinate over. If/when a real AI-assisted
/// summary is added, it must only ever rephrase facts already present in
/// these sections, never introduce new ones.
class ComplaintGenerator {
  const ComplaintGenerator._();

  static bool _isNotAvailable(String? v) =>
      v == null || v.trim().isEmpty || v.trim() == 'Not available';

  static List<ReviewSection> buildSections({
    required Incident incident,
    required CitizenProfile profile,
    required List<EvidenceItem> evidence,
  }) {
    final complainant = ReviewSection(
      title: 'Complainant',
      items: [
        ReviewItem(
          label: 'Name',
          present: profile.name.isNotEmpty,
          value: profile.name,
        ),
        ReviewItem(
          label: 'Mobile',
          present: profile.mobile.isNotEmpty,
          value: profile.mobile,
        ),
        ReviewItem(
          label: 'Address',
          present: profile.currentAddress.isNotEmpty,
          value: profile.currentAddress,
        ),
      ],
    );

    final fields = IncidentFormRegistry.fieldsFor(incident.category);
    final suspectFields = fields.where((f) => _isSuspectField(f.id)).toList();
    final incidentFields = fields.where((f) => !_isSuspectField(f.id)).toList();

    final incidentSection = ReviewSection(
      title: 'Incident',
      items: [
        ReviewItem(
          label: 'Category',
          present: true,
          value: incident.category.label,
        ),
        ReviewItem(
          label: 'Incident details',
          present: incident.description.trim().length >= 200,
        ),
        for (final f in incidentFields)
          ReviewItem(
            label: f.label,
            present: !_isNotAvailable(incident.formData[f.id]),
            value: incident.formData[f.id],
          ),
      ],
    );

    final suspectSection = ReviewSection(
      title: 'Suspect',
      items: suspectFields.isEmpty
          ? const [
              ReviewItem(
                label: 'No suspect information applicable to this category',
                present: true,
              ),
            ]
          : [
              for (final f in suspectFields)
                ReviewItem(
                  label: f.label,
                  present: !_isNotAvailable(incident.formData[f.id]),
                  value: incident.formData[f.id],
                ),
            ],
    );

    final evidenceSection = ReviewSection(
      title: 'Evidence',
      items: [
        ReviewItem(
          label: 'Files and notes attached',
          present: evidence.isNotEmpty,
          value: '${evidence.length}',
        ),
        ReviewItem(
          label: 'URLs included',
          present: evidence.any((e) => e.type == EvidenceType.url),
          value: '${evidence.where((e) => e.type == EvidenceType.url).length}',
        ),
        ReviewItem(
          label: 'Screenshots included',
          present: evidence.any((e) => e.type == EvidenceType.image),
          value:
              '${evidence.where((e) => e.type == EvidenceType.image).length}',
        ),
      ],
    );

    return [complainant, incidentSection, suspectSection, evidenceSection];
  }

  static bool _isSuspectField(String id) =>
      id.toLowerCase().contains('suspect') ||
      id.toLowerCase().contains('fake') ||
      id == 'demandDescription';

  /// A deterministic, template-based explanation of what happens after
  /// submission — built only from the category and known facts, never
  /// from a generative model. Always shown with the "review required"
  /// label by the caller.
  static String aiAssistedSummary(Incident incident) {
    final category = incident.category.label;
    return 'Based on the information you provided, this will be recorded as a "$category" complaint. '
        'After submission, it will show as "Submitted" and then move through the demo review stages shown in '
        'My Cases. You can add more evidence or timeline events to this case later. '
        'This summary only reflects what you entered — it does not add any new facts.';
  }
}
