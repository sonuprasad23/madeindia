import '../../core/constants/indian_data.dart';
import '../../data/models/case_record.dart';

/// Rule-based "Ask Rakshak" response engine.
///
/// Deliberately not a generative model: every response is a fixed,
/// conservative template selected by keyword matching, optionally filled
/// in with facts already present in [focusedCase] — nothing is invented.
/// See [ComplaintGenerator] for the equivalent "don't invent facts" rule
/// applied to complaint data.
class AssistantEngine {
  const AssistantEngine._();

  static const List<String> suggestedQuestions = [
    'What should I do now?',
    'What does this status mean?',
    'What evidence should I keep?',
    'Should I call 1930?',
    'What happens after submitting?',
    'What does "under investigation" mean?',
    'Why is additional information required?',
    'What does account lien mean?',
    'How do I use this feature?',
  ];

  static String respond(String question, {CaseRecord? focusedCase}) {
    final q = question.toLowerCase();

    if (q.contains('what should i do now') ||
        (q.contains('what') && q.contains('do now'))) {
      if (focusedCase != null) {
        return 'Based on the information available, your case #${focusedCase.id} is currently shown as '
            '"${focusedCase.status.label}". ${focusedCase.status.explanation} '
            'If you have new evidence, you can add it from the Evidence Vault and attach it to this case. '
            'This is guidance based on the demo data available — it is not a determination by any authority.';
      }
      return 'A good next step is usually: preserve any evidence (screenshots, messages, transaction details) '
          'in the Evidence Vault, then use "Report Incident" to describe what happened. '
          'If money was lost, contact your bank and the national cyber helpline ${IndianData.cyberCrimeHelplineNumber} as soon as possible.';
    }

    if (q.contains('under investigation')) {
      return 'In this demo, "Under Investigation" means the case is currently shown as being actively looked '
          'into by the relevant authority in the mock system. It does not guarantee a particular outcome or timeline.';
    }

    if (q.contains('additional information')) {
      return 'A status of "Additional Information Required" means more details or evidence have been '
          'requested before the case can move forward. Check the case detail screen for what is missing and '
          'add it from the Evidence Vault or by editing the incident.';
    }

    if (q.contains('account lien')) {
      return 'An account lien generally refers to a bank temporarily restricting access to funds in an account, '
          'often while a fraud-related transaction is investigated. If your case mentions this, it is worth '
          'contacting your bank directly for the specifics — Rakshak does not have access to real bank systems in this demo.';
    }

    if (q.contains('what does this status mean') || q.contains('status mean')) {
      if (focusedCase != null) {
        return '"${focusedCase.status.label}" — ${focusedCase.status.explanation}';
      }
      return 'Open a specific case from "My Cases" and tap the status, or ask me again from that case\'s screen, '
          'so I can explain that exact status.';
    }

    if (q.contains('evidence')) {
      return 'Useful evidence usually includes: screenshots of messages or profiles, transaction confirmations '
          'or bank statements, the URLs involved, and a clear timeline of what happened and when. '
          'Save these in the Evidence Vault — the original file is never modified once added.';
    }

    if (q.contains('1930') || q.contains('helpline') || q.contains('call')) {
      return 'If you have lost money through a financial fraud, calling the national cyber crime helpline '
          '${IndianData.cyberCrimeHelplineNumber} promptly can help — banks and telecom providers can sometimes act faster on an active complaint. '
          'This is general guidance, not a guarantee of recovery.';
    }

    if (q.contains('after submitting') || q.contains('after i submit')) {
      return 'After a complaint is submitted in this demo, it moves to "Submitted", then typically '
          '"Forwarded to Authority" and "Under Review". You can track this in "My Cases" at any time. '
          'In this prototype, no data is actually sent to a real government system.';
    }

    if (q.contains('how do i') || q.contains('how to use')) {
      return 'Tell me which screen or feature you\'re on (e.g. "Link Checker", "Evidence Vault", "Report Incident") '
          'and I can walk you through it. In general: Protect is for checking links/QR codes, Report starts a new '
          'complaint, and Cases tracks anything already submitted.';
    }

    return 'I can help explain how Rakshak works, what a case status means, what evidence to keep, or general '
        'next steps — I\'m not able to determine outcomes or guarantee results. Could you rephrase your question, '
        'or try one of the suggestions below?';
  }
}
