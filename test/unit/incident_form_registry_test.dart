import 'package:flutter_test/flutter_test.dart';
import 'package:rakshak/data/models/incident.dart';
import 'package:rakshak/features/incidents/form_specs/incident_form_registry.dart';

void main() {
  group('IncidentFormRegistry', () {
    test('every category has at least one field', () {
      for (final category in IncidentCategory.values) {
        final fields = IncidentFormRegistry.fieldsFor(category);
        expect(
          fields,
          isNotEmpty,
          reason: '${category.name} has no fields defined',
        );
      }
    });

    test('field ids are unique within a category', () {
      for (final category in IncidentCategory.values) {
        final ids = IncidentFormRegistry.fieldsFor(
          category,
        ).map((f) => f.id).toList();
        expect(
          ids.toSet().length,
          ids.length,
          reason: '${category.name} has duplicate field ids',
        );
      }
    });

    test('financial fraud requires a fraud amount field', () {
      final fields = IncidentFormRegistry.fieldsFor(
        IncidentCategory.financialFraud,
      );
      final amountField = fields.where((f) => f.id == 'fraudAmount');
      expect(amountField, isNotEmpty);
      expect(amountField.first.required, isTrue);
    });

    test('social media harassment exposes a platform dropdown', () {
      final fields = IncidentFormRegistry.fieldsFor(
        IncidentCategory.socialMediaHarassment,
      );
      final platformField = fields.firstWhere((f) => f.id == 'platform');
      expect(platformField.options, contains('Instagram'));
    });
  });
}
