import 'package:flutter/material.dart';

enum IncidentFieldType {
  text,
  multiline,
  date,
  time,
  dropdown,
  boolean,
  evidence,
}

/// Declarative description of one field in a crime-specific incident form.
///
/// Forms are data, not bespoke screens — [IncidentFormRegistry] maps each
/// [IncidentCategory] to a `List<IncidentFormField>`, and a single
/// [IncidentFormScreen] renders whichever list applies. Adding a new crime
/// category means adding a spec list, not a new screen.
class IncidentFormField {
  const IncidentFormField({
    required this.id,
    required this.label,
    this.type = IncidentFieldType.text,
    this.required = false,
    this.options = const [],
    this.keyboardType,
    this.helperText,
    this.allowNotAvailable = true,
  });

  final String id;
  final String label;
  final IncidentFieldType type;
  final bool required;
  final List<String> options;
  final TextInputType? keyboardType;
  final String? helperText;

  /// Whether this field can be explicitly marked "Not available" instead
  /// of forcing the user to guess — see spec's complaint-review rule.
  final bool allowNotAvailable;
}
