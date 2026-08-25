import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/theme/design_tokens.dart';
import '../../core/widgets/rakshak_button.dart';
import '../../core/widgets/rakshak_inputs.dart';
import '../../core/widgets/rakshak_overlays.dart';
import '../../data/models/evidence_item.dart';
import '../../data/models/notification_item.dart';
import '../../data/repositories/evidence_repository.dart';
import '../../data/repositories/notification_repository.dart';
import 'evidence_file_service.dart';

Future<void> showAddEvidenceSheet(BuildContext context, WidgetRef ref) {
  return showRakshakBottomSheet(
    context: context,
    builder: (context) => _AddEvidenceSheetContent(ref: ref),
  );
}

class _AddEvidenceSheetContent extends StatefulWidget {
  const _AddEvidenceSheetContent({required this.ref});

  final WidgetRef ref;

  @override
  State<_AddEvidenceSheetContent> createState() =>
      _AddEvidenceSheetContentState();
}

class _AddEvidenceSheetContentState extends State<_AddEvidenceSheetContent> {
  EvidenceCategory _category = EvidenceCategory.financial;
  final _service = const EvidenceFileService();
  bool _busy = false;

  Future<void> _finish(EvidenceItem item) async {
    await widget.ref.read(evidenceRepositoryProvider.notifier).add(item);
    await widget.ref
        .read(notificationRepositoryProvider.notifier)
        .push(
          kind: NotificationKind.evidenceSaved,
          title: 'Evidence saved',
          body: '${item.originalFileName} was added to your Evidence Vault.',
        );
    if (mounted) Navigator.of(context).pop();
  }

  Future<void> _pickPhoto(ImageSource source) async {
    setState(() => _busy = true);
    try {
      final picked = await ImagePicker().pickImage(
        source: source,
        imageQuality: 90,
      );
      if (picked == null) return;
      final item = await _service.ingestFile(
        sourceFile: File(picked.path),
        type: EvidenceType.image,
        category: _category,
        source: source == ImageSource.camera
            ? 'Camera capture'
            : 'Gallery upload',
      );
      await _finish(item);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _pickFile() async {
    setState(() => _busy = true);
    try {
      final result = await FilePicker.pickFiles(type: FileType.any);
      final path = (result == null || result.files.isEmpty)
          ? null
          : result.files.first.path;
      if (path == null) return;
      final ext = path.split('.').last.toLowerCase();
      final type = switch (ext) {
        'pdf' => EvidenceType.pdf,
        'mp4' || 'mov' || 'avi' || 'mkv' => EvidenceType.video,
        'png' || 'jpg' || 'jpeg' || 'webp' => EvidenceType.image,
        _ => EvidenceType.document,
      };
      final item = await _service.ingestFile(
        sourceFile: File(path),
        type: type,
        category: _category,
        source: 'File upload',
      );
      await _finish(item);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _addTextNote() async {
    final controller = TextEditingController();
    final text = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add text note'),
        content: RakshakTextField(
          label: 'Note',
          controller: controller,
          maxLines: 5,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(controller.text.trim()),
            child: const Text('Add'),
          ),
        ],
      ),
    );
    if (text == null || text.isEmpty) return;
    final item = _service.ingestText(
      text: text,
      category: _category,
      source: 'User text note',
    );
    await _finish(item);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Add evidence',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: Spacing.lg),
        RakshakDropdown<EvidenceCategory>(
          label: 'Category',
          value: _category,
          items: EvidenceCategory.values,
          itemLabel: (c) => c.label,
          onChanged: (c) => setState(() => _category = c ?? _category),
        ),
        const SizedBox(height: Spacing.lg),
        if (_busy)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: Spacing.xl),
            child: Center(child: CircularProgressIndicator()),
          )
        else ...[
          RakshakButton(
            label: 'Take a photo',
            icon: Icons.photo_camera_outlined,
            variant: RakshakButtonVariant.secondary,
            onPressed: () => _pickPhoto(ImageSource.camera),
          ),
          const SizedBox(height: Spacing.sm),
          RakshakButton(
            label: 'Choose from gallery',
            icon: Icons.image_outlined,
            variant: RakshakButtonVariant.secondary,
            onPressed: () => _pickPhoto(ImageSource.gallery),
          ),
          const SizedBox(height: Spacing.sm),
          RakshakButton(
            label: 'Upload a file / PDF / video',
            icon: Icons.attach_file_rounded,
            variant: RakshakButtonVariant.secondary,
            onPressed: _pickFile,
          ),
          const SizedBox(height: Spacing.sm),
          RakshakButton(
            label: 'Add a text note',
            icon: Icons.notes_rounded,
            variant: RakshakButtonVariant.secondary,
            onPressed: _addTextNote,
          ),
        ],
      ],
    );
  }
}
