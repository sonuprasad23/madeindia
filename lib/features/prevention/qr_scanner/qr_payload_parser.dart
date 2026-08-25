/// What kind of content a scanned QR code contained.
enum QrPayloadKind { url, upi, text }

class UpiPaymentDetails {
  const UpiPaymentDetails({
    required this.payeeAddress,
    this.payeeName,
    this.amount,
    this.note,
  });

  final String payeeAddress;
  final String? payeeName;
  final String? amount;
  final String? note;
}

class QrPayload {
  const QrPayload({required this.kind, required this.raw, this.upi});

  final QrPayloadKind kind;
  final String raw;
  final UpiPaymentDetails? upi;
}

/// Classifies and parses a scanned QR code's raw payload.
///
/// UPI deep links follow the `upi://pay?pa=<vpa>&pn=<name>&am=<amount>...`
/// convention used by BHIM/GPay/PhonePe-style QR codes.
class QrPayloadParser {
  const QrPayloadParser._();

  static QrPayload parse(String raw) {
    final trimmed = raw.trim();

    if (trimmed.toLowerCase().startsWith('upi://')) {
      final uri = Uri.tryParse(trimmed);
      if (uri != null) {
        final params = uri.queryParameters;
        return QrPayload(
          kind: QrPayloadKind.upi,
          raw: trimmed,
          upi: UpiPaymentDetails(
            payeeAddress: params['pa'] ?? 'unknown@upi',
            payeeName: params['pn'],
            amount: params['am'],
            note: params['tn'],
          ),
        );
      }
    }

    final looksLikeUrl =
        RegExp(r'^https?://', caseSensitive: false).hasMatch(trimmed) ||
        RegExp(r'^[\w-]+(\.[\w-]+)+(/\S*)?$').hasMatch(trimmed);
    if (looksLikeUrl) {
      return QrPayload(kind: QrPayloadKind.url, raw: trimmed);
    }

    return QrPayload(kind: QrPayloadKind.text, raw: trimmed);
  }
}
