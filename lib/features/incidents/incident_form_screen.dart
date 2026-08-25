import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';

import '../../core/constants/app_constants.dart';
import '../../core/routing/app_routes.dart';
import '../../core/theme/design_tokens.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/rakshak_button.dart';
import '../../core/widgets/rakshak_inputs.dart';
import '../../core/widgets/rakshak_surfaces.dart';
import '../../core/widgets/rakshak_timeline.dart';
import '../../data/models/evidence_item.dart';
import '../../data/models/incident.dart';
import '../../data/repositories/evidence_repository.dart';
import '../../data/repositories/incident_repository.dart';
import 'form_specs/incident_form_field.dart';
import 'form_specs/incident_form_registry.dart';

const _notAvailable = 'Not available';

class IncidentFormScreen extends ConsumerStatefulWidget {
  const IncidentFormScreen({super.key, required this.incidentId});

  final String incidentId;

  @override
  ConsumerState<IncidentFormScreen> createState() => _IncidentFormScreenState();
}

class _IncidentFormScreenState extends ConsumerState<IncidentFormScreen> {
  final Map<String, TextEditingController> _controllers = {};
  late TextEditingController _descriptionController;
  bool _initialized = false;

  @override
  void dispose() {
    for (final c in _controllers.values) {
      c.dispose();
    }
    _descriptionController.dispose();
    super.dispose();
  }

  void _initFrom(Incident incident) {
    if (_initialized) return;
    for (final field in IncidentFormRegistry.fieldsFor(incident.category)) {
      _controllers[field.id] = TextEditingController(
        text: incident.formData[field.id] ?? '',
      );
    }
    _descriptionController = TextEditingController(text: incident.description);
    _initialized = true;
  }

  Future<void> _pickDate(TextEditingController controller) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: DateTime(now.year - 5),
      lastDate: now,
    );
    if (picked != null) controller.text = AppFormatters.date(picked);
  }

  Future<void> _pickTime(TextEditingController controller) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      final now = DateTime.now();
      final dt = DateTime(
        now.year,
        now.month,
        now.day,
        picked.hour,
        picked.minute,
      );
      controller.text = AppFormatters.time(dt);
    }
  }

  Future<void> _attachExistingEvidence(Incident incident) async {
    final evidence = ref.read(evidenceRepositoryProvider);
    final selected = await showModalBottomSheet<List<String>>(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        final chosen = {...incident.evidenceIds};
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(Spacing.lg),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Attach evidence',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: Spacing.md),
                    if (evidence.isEmpty)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: Spacing.lg),
                        child: Text(
                          'No evidence saved yet. Add evidence from the Evidence Vault first.',
                        ),
                      )
                    else
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxHeight: 320),
                        child: ListView(
                          shrinkWrap: true,
                          children: evidence.map((e) {
                            return CheckboxListTile(
                              value: chosen.contains(e.id),
                              title: Text(e.originalFileName),
                              subtitle: Text(e.category.label),
                              onChanged: (v) => setSheetState(() {
                                if (v ?? false) {
                                  chosen.add(e.id);
                                } else {
                                  chosen.remove(e.id);
                                }
                              }),
                            );
                          }).toList(),
                        ),
                      ),
                    const SizedBox(height: Spacing.md),
                    RakshakButton(
                      label: 'Done',
                      onPressed: () =>
                          Navigator.of(context).pop(chosen.toList()),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
    if (selected != null) {
      await ref
          .read(incidentRepositoryProvider.notifier)
          .update(incident.id, (i) => i.copyWith(evidenceIds: selected));
    }
  }

  Future<void> _addTimelineEvent(Incident incident) async {
    final descController = TextEditingController();
    DateTime picked = DateTime.now();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Add timeline event'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RakshakTextField(
                    label: 'What happened',
                    controller: descController,
                    maxLines: 2,
                  ),
                  const SizedBox(height: Spacing.md),
                  OutlinedButton.icon(
                    icon: const Icon(Icons.schedule_rounded),
                    label: Text(AppFormatters.dateTime(picked)),
                    onPressed: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: picked,
                        firstDate: DateTime(2015),
                        lastDate: DateTime.now(),
                      );
                      if (date == null || !context.mounted) return;
                      final time = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.fromDateTime(picked),
                      );
                      if (time == null) return;
                      setDialogState(() {
                        picked = DateTime(
                          date.year,
                          date.month,
                          date.day,
                          time.hour,
                          time.minute,
                        );
                      });
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text('Add'),
                ),
              ],
            );
          },
        );
      },
    );

    if (confirmed == true && descController.text.trim().isNotEmpty) {
      await ref
          .read(incidentRepositoryProvider.notifier)
          .addTimelineEvent(
            incident.id,
            TimelineEvent(
              id: const Uuid().v4(),
              occurredAt: picked,
              description: descController.text.trim(),
            ),
          );
    }
  }

  Future<void> _continue(Incident incident) async {
    final fields = IncidentFormRegistry.fieldsFor(incident.category);
    final missing = <String>[];
    for (final field in fields) {
      if (field.required &&
          (_controllers[field.id]?.text.trim().isEmpty ?? true)) {
        missing.add(field.label);
      }
    }
    if (_descriptionController.text.trim().length <
        AppConstants.minIncidentDescriptionLength) {
      missing.add(
        'Incident details (${AppConstants.minIncidentDescriptionLength} characters minimum)',
      );
    }

    if (missing.isNotEmpty) {
      showDialog<void>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('A few things need attention'),
          content: Text(
            'Please complete or mark "Not available" for:\n\n${missing.join('\n')}',
          ),
          actions: [
            FilledButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        ),
      );
      return;
    }

    final formData = {
      for (final f in fields) f.id: _controllers[f.id]!.text.trim(),
    };
    await ref
        .read(incidentRepositoryProvider.notifier)
        .update(
          incident.id,
          (i) => i.copyWith(
            formData: formData,
            description: _descriptionController.text.trim(),
          ),
        );
    if (mounted) context.push('${AppRoutes.complaintReview}/${incident.id}');
  }

  @override
  Widget build(BuildContext context) {
    final incidents = ref.watch(incidentRepositoryProvider);
    final matches = incidents.where((i) => i.id == widget.incidentId);
    if (matches.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Incident')),
        body: const Center(child: Text('This incident could not be found.')),
      );
    }
    final incident = matches.first;
    _initFrom(incident);

    final fields = IncidentFormRegistry.fieldsFor(incident.category);
    final descLength = _descriptionController.text.trim().length;

    return Scaffold(
      appBar: AppBar(title: Text(incident.category.label)),
      body: ListView(
        padding: const EdgeInsets.all(Spacing.lg),
        children: [
          ...fields.map(
            (field) => Padding(
              padding: const EdgeInsets.only(bottom: Spacing.lg),
              child: _buildField(field),
            ),
          ),

          const RakshakSectionHeader(title: 'Timeline'),
          if (incident.timeline.isEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: Spacing.md),
              child: Text(
                'No events added yet.',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            )
          else
            Padding(
              padding: const EdgeInsets.only(bottom: Spacing.md),
              child: RakshakTimeline(
                entries: incident.timeline
                    .map(
                      (e) => RakshakTimelineEntry(
                        title: e.description,
                        subtitle: AppFormatters.dateTime(e.occurredAt),
                        state: RakshakTimelineState.done,
                      ),
                    )
                    .toList(),
              ),
            ),
          RakshakButton(
            label: 'Add timeline event',
            icon: Icons.add_rounded,
            variant: RakshakButtonVariant.text,
            onPressed: () => _addTimelineEvent(incident),
          ),
          const SizedBox(height: Spacing.lg),

          RakshakSectionHeader(
            title: 'Evidence',
            subtitle: '${incident.evidenceIds.length} attached',
          ),
          RakshakButton(
            label: 'Attach evidence',
            icon: Icons.attach_file_rounded,
            variant: RakshakButtonVariant.secondary,
            onPressed: () => _attachExistingEvidence(incident),
          ),
          const SizedBox(height: Spacing.xl),

          Text(
            'Incident details',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: Spacing.sm),
          RakshakTextField(
            label: 'Describe what happened',
            controller: _descriptionController,
            maxLines: 6,
            onChanged: (_) => setState(() {}),
            helperText:
                '$descLength / ${AppConstants.minIncidentDescriptionLength} characters minimum',
          ),
          const SizedBox(height: Spacing.xl),
          RakshakButton(
            label: 'Continue',
            icon: Icons.arrow_forward_rounded,
            onPressed: () => _continue(incident),
          ),
        ],
      ),
    );
  }

  Widget _buildField(IncidentFormField field) {
    final controller = _controllers[field.id]!;

    switch (field.type) {
      case IncidentFieldType.date:
        return _tapField(
          field,
          controller,
          Icons.calendar_today_outlined,
          () => _pickDate(controller),
        );
      case IncidentFieldType.time:
        return _tapField(
          field,
          controller,
          Icons.access_time_rounded,
          () => _pickTime(controller),
        );
      case IncidentFieldType.dropdown:
        return RakshakDropdown<String>(
          label: field.label,
          value: controller.text.isEmpty ? null : controller.text,
          items: field.options,
          itemLabel: (o) => o,
          onChanged: (v) => setState(() => controller.text = v ?? ''),
        );
      case IncidentFieldType.boolean:
        return _booleanField(field, controller);
      case IncidentFieldType.multiline:
        return RakshakTextField(
          label: field.label,
          controller: controller,
          maxLines: 3,
          helperText: field.helperText,
        );
      case IncidentFieldType.text:
      case IncidentFieldType.evidence:
        return RakshakTextField(
          label: field.label,
          controller: controller,
          keyboardType: field.keyboardType,
          helperText: field.helperText,
          suffixIcon: field.required && field.allowNotAvailable
              ? TextButton(
                  onPressed: () =>
                      setState(() => controller.text = _notAvailable),
                  child: const Text('N/A'),
                )
              : null,
        );
    }
  }

  Widget _tapField(
    IncidentFormField field,
    TextEditingController controller,
    IconData icon,
    VoidCallback onTap,
  ) {
    return TextField(
      controller: controller,
      readOnly: true,
      onTap: onTap,
      decoration: InputDecoration(
        labelText: field.label,
        suffixIcon: Icon(icon),
      ),
    );
  }

  Widget _booleanField(
    IncidentFormField field,
    TextEditingController controller,
  ) {
    final value = controller.text;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(field.label, style: Theme.of(context).textTheme.bodyMedium),
        const SizedBox(height: Spacing.sm),
        SegmentedButton<String>(
          segments: const [
            ButtonSegment(value: 'Yes', label: Text('Yes')),
            ButtonSegment(value: 'No', label: Text('No')),
            ButtonSegment(value: _notAvailable, label: Text('Unknown')),
          ],
          selected: {value.isEmpty ? _notAvailable : value},
          onSelectionChanged: (s) => setState(() => controller.text = s.first),
        ),
      ],
    );
  }
}
