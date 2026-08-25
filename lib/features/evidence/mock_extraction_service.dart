import '../../core/constants/indian_data.dart';
import '../../core/utils/formatters.dart';
import '../../data/models/evidence_item.dart';

/// Simulates OCR/ML extraction of transaction details from a screenshot.
///
/// This demo has no real OCR pipeline. Rather than faking a network call
/// that "reads" the image, this derives deterministic-but-plausible values
/// from the file's SHA-256 hash, so the same file always extracts the same
/// values and results are inspectable/testable. Everything returned here
/// is surfaced in the UI labelled "Extracted from evidence — please
/// verify" and is never written into a complaint without user confirmation.
class MockExtractionService {
  const MockExtractionService._();

  static bool supportsExtraction(EvidenceCategory category) =>
      category == EvidenceCategory.financial ||
      category == EvidenceCategory.transactions;

  static ExtractedEvidenceData extract({
    required String sha256Hash,
    required EvidenceType type,
  }) {
    final n = int.parse(sha256Hash.substring(0, 8), radix: 16);

    final amount = 500 + (n % 49500);
    final bank = IndianData.banks[n % IndianData.banks.length];
    final utr = (100000000000 + (n % 899999999999)).toString();
    final upiUser = sha256Hash.substring(8, 14);
    final daysAgo = n % 5;
    final date = DateTime.now().subtract(Duration(days: daysAgo));

    return ExtractedEvidenceData(
      amount: AppFormatters.rupees(amount),
      utr: utr,
      bankOrWallet: bank,
      transactionDate: AppFormatters.date(date),
      upiId: '$upiUser@upi',
    );
  }
}
