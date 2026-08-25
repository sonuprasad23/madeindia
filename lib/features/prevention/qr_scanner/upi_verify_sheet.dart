import 'package:flutter/material.dart';

import '../../../core/theme/design_tokens.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/rakshak_button.dart';
import '../../../core/widgets/rakshak_overlays.dart';
import 'qr_payload_parser.dart';

Future<void> showUpiVerifySheet(BuildContext context, UpiPaymentDetails upi) {
  return showRakshakBottomSheet(
    context: context,
    builder: (context) => _UpiVerifySheetContent(upi: upi),
  );
}

class _UpiVerifySheetContent extends StatelessWidget {
  const _UpiVerifySheetContent({required this.upi});

  final UpiPaymentDetails upi;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final amount = double.tryParse(upi.amount ?? '');

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.qr_code_2_rounded, color: theme.colorScheme.primary),
            const SizedBox(width: Spacing.sm),
            Text(
              'UPI payment detected',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        const SizedBox(height: Spacing.lg),
        _row(context, 'Merchant', upi.payeeName ?? 'Not provided in QR'),
        _row(context, 'UPI ID', upi.payeeAddress),
        if (amount != null)
          _row(context, 'Amount', AppFormatters.rupees(amount)),
        if (upi.note != null && upi.note!.isNotEmpty)
          _row(context, 'Note', upi.note!),
        const SizedBox(height: Spacing.lg),
        Container(
          padding: const EdgeInsets.all(Spacing.md),
          decoration: BoxDecoration(
            color: theme.colorScheme.tertiaryContainer,
            borderRadius: BorderRadius.circular(Radii.md),
          ),
          child: Text(
            'Rakshak does not process payments. Verify the merchant name and UPI ID carefully in your payment app before paying — this screen is for your review only.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onTertiaryContainer,
            ),
          ),
        ),
        const SizedBox(height: Spacing.lg),
        RakshakButton(
          label: 'Close',
          variant: RakshakButtonVariant.secondary,
          onPressed: () => Navigator.of(context).pop(),
        ),
      ],
    );
  }

  Widget _row(BuildContext context, String label, String value) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Flexible(
            child: Text(
              value,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }
}
