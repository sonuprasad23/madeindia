import 'package:flutter/material.dart';

import '../../../core/constants/indian_data.dart';
import '../../../data/models/incident.dart';
import 'incident_form_field.dart';

/// Crime-specific dynamic form definitions. See [IncidentFormField] for why
/// this is data rather than one screen per category.
class IncidentFormRegistry {
  const IncidentFormRegistry._();

  static List<IncidentFormField> fieldsFor(IncidentCategory category) {
    return switch (category) {
      IncidentCategory.financialFraud || IncidentCategory.upiFraud => const [
        IncidentFormField(
          id: 'incidentDate',
          label: 'Incident date',
          type: IncidentFieldType.date,
          required: true,
        ),
        IncidentFormField(
          id: 'incidentTime',
          label: 'Incident time',
          type: IncidentFieldType.time,
        ),
        IncidentFormField(
          id: 'bankWalletMerchant',
          label: 'Bank / wallet / merchant',
          required: true,
        ),
        IncidentFormField(id: 'transactionId', label: 'Transaction ID / UTR'),
        IncidentFormField(
          id: 'transactionDate',
          label: 'Transaction date',
          type: IncidentFieldType.date,
        ),
        IncidentFormField(
          id: 'fraudAmount',
          label: 'Fraud amount (₹)',
          keyboardType: TextInputType.number,
          required: true,
        ),
        IncidentFormField(id: 'upiId', label: 'UPI ID'),
        IncidentFormField(id: 'suspectMobile', label: 'Suspect mobile number'),
        IncidentFormField(
          id: 'suspectBankAccount',
          label: 'Suspect bank account',
        ),
      ],
      IncidentCategory.cardFraud => const [
        IncidentFormField(
          id: 'incidentDate',
          label: 'Incident date',
          type: IncidentFieldType.date,
          required: true,
        ),
        IncidentFormField(
          id: 'bankWalletMerchant',
          label: 'Card-issuing bank',
          required: true,
        ),
        IncidentFormField(
          id: 'transactionId',
          label: 'Transaction reference / RRN',
        ),
        IncidentFormField(
          id: 'fraudAmount',
          label: 'Fraud amount (₹)',
          keyboardType: TextInputType.number,
          required: true,
        ),
        IncidentFormField(
          id: 'merchantName',
          label: 'Merchant name shown on statement',
        ),
        IncidentFormField(
          id: 'cardBlocked',
          label: 'Has the card been blocked?',
          type: IncidentFieldType.boolean,
        ),
      ],
      IncidentCategory.phishing => const [
        IncidentFormField(id: 'suspiciousUrl', label: 'URL', required: true),
        IncidentFormField(
          id: 'sender',
          label: 'Sender (phone number / email / name)',
        ),
        IncidentFormField(
          id: 'message',
          label: 'Message received',
          type: IncidentFieldType.multiline,
        ),
        IncidentFormField(
          id: 'incidentDate',
          label: 'Incident date/time',
          type: IncidentFieldType.date,
          required: true,
        ),
        IncidentFormField(id: 'email', label: 'Your email (if relevant)'),
        IncidentFormField(
          id: 'whatHappenedAfterClick',
          label: 'What happened after clicking?',
          type: IncidentFieldType.multiline,
        ),
        IncidentFormField(
          id: 'credentialsEntered',
          label: 'Were credentials entered?',
          type: IncidentFieldType.boolean,
        ),
        IncidentFormField(
          id: 'financialLoss',
          label: 'Was there a financial loss?',
          type: IncidentFieldType.boolean,
        ),
      ],
      IncidentCategory.socialMediaHarassment ||
      IncidentCategory.cyberbullying => const [
        IncidentFormField(
          id: 'platform',
          label: 'Platform',
          type: IncidentFieldType.dropdown,
          options: [
            'Instagram',
            'Facebook',
            'X (Twitter)',
            'WhatsApp',
            'Telegram',
            'Other',
          ],
          required: true,
        ),
        IncidentFormField(id: 'username', label: 'Username'),
        IncidentFormField(id: 'profileUrl', label: 'Profile URL'),
        IncidentFormField(id: 'postUrl', label: 'Post URL'),
        IncidentFormField(id: 'commentUrl', label: 'Comment URL'),
        IncidentFormField(
          id: 'threatType',
          label: 'Type of harassment',
          type: IncidentFieldType.dropdown,
          options: [
            'Harassment',
            'Bullying',
            'Impersonation',
            'Threats',
            'Sexual harassment',
            'Other',
          ],
          required: true,
        ),
        IncidentFormField(
          id: 'incidentDate',
          label: 'Incident date/time',
          type: IncidentFieldType.date,
          required: true,
        ),
        IncidentFormField(
          id: 'description',
          label: 'Description',
          type: IncidentFieldType.multiline,
        ),
      ],
      IncidentCategory.fakeProfile => const [
        IncidentFormField(
          id: 'platform',
          label: 'Platform',
          type: IncidentFieldType.dropdown,
          options: [
            'Instagram',
            'Facebook',
            'X (Twitter)',
            'LinkedIn',
            'Other',
          ],
          required: true,
        ),
        IncidentFormField(
          id: 'fakeUsername',
          label: 'Fake username',
          required: true,
        ),
        IncidentFormField(
          id: 'fakeProfileUrl',
          label: 'Fake profile URL',
          required: true,
        ),
        IncidentFormField(
          id: 'originalProfileUrl',
          label: 'Your original profile (if impersonated)',
        ),
        IncidentFormField(
          id: 'messagesSent',
          label: 'Messages sent by the fake profile',
          type: IncidentFieldType.multiline,
        ),
        IncidentFormField(
          id: 'peopleContacted',
          label: 'People contacted by the fake profile',
          type: IncidentFieldType.multiline,
        ),
        IncidentFormField(
          id: 'description',
          label: 'Incident details',
          type: IncidentFieldType.multiline,
          required: true,
        ),
      ],
      IncidentCategory.accountHacking => const [
        IncidentFormField(id: 'platform', label: 'Platform / service'),
        IncidentFormField(
          id: 'accountIdentifier',
          label: 'Account (username / email / phone)',
          required: true,
        ),
        IncidentFormField(
          id: 'incidentDate',
          label: 'When did you notice this?',
          type: IncidentFieldType.date,
          required: true,
        ),
        IncidentFormField(
          id: 'recoveryAttempted',
          label: 'Have you attempted account recovery?',
          type: IncidentFieldType.boolean,
        ),
        IncidentFormField(
          id: 'suspiciousActivity',
          label: 'Suspicious activity observed',
          type: IncidentFieldType.multiline,
        ),
      ],
      IncidentCategory.threatBlackmail => const [
        IncidentFormField(
          id: 'platform',
          label: 'Platform used for the threat',
        ),
        IncidentFormField(
          id: 'suspectIdentifier',
          label: 'Suspect contact (number / username)',
        ),
        IncidentFormField(
          id: 'demandDescription',
          label: 'What is being demanded?',
          type: IncidentFieldType.multiline,
          required: true,
        ),
        IncidentFormField(
          id: 'incidentDate',
          label: 'Incident date/time',
          type: IncidentFieldType.date,
          required: true,
        ),
        IncidentFormField(
          id: 'evidenceOfThreat',
          label: 'Description of evidence (messages, media, etc.)',
          type: IncidentFieldType.multiline,
        ),
      ],
      IncidentCategory.ransomware => const [
        IncidentFormField(
          id: 'deviceAffected',
          label: 'Device / system affected',
          required: true,
        ),
        IncidentFormField(
          id: 'incidentDate',
          label: 'When was it first noticed?',
          type: IncidentFieldType.date,
          required: true,
        ),
        IncidentFormField(
          id: 'ransomDemand',
          label: 'Ransom amount/method demanded',
        ),
        IncidentFormField(
          id: 'filesEncrypted',
          label: 'Were files encrypted/locked?',
          type: IncidentFieldType.boolean,
        ),
        IncidentFormField(
          id: 'ransomNoteText',
          label: 'Ransom note text (if any)',
          type: IncidentFieldType.multiline,
        ),
      ],
      IncidentCategory.onlineShoppingFraud => const [
        IncidentFormField(
          id: 'platformOrSeller',
          label: 'Website / seller name',
          required: true,
        ),
        IncidentFormField(id: 'orderId', label: 'Order ID'),
        IncidentFormField(
          id: 'incidentDate',
          label: 'Order/incident date',
          type: IncidentFieldType.date,
          required: true,
        ),
        IncidentFormField(
          id: 'amountPaid',
          label: 'Amount paid (₹)',
          keyboardType: TextInputType.number,
          required: true,
        ),
        IncidentFormField(id: 'paymentMethod', label: 'Payment method'),
        IncidentFormField(
          id: 'itemDescription',
          label: 'What was ordered vs. what happened?',
          type: IncidentFieldType.multiline,
        ),
      ],
      IncidentCategory.investmentFraud => const [
        IncidentFormField(
          id: 'platformOrApp',
          label: 'Platform / app / scheme name',
          required: true,
        ),
        IncidentFormField(
          id: 'incidentDate',
          label: 'First contact date',
          type: IncidentFieldType.date,
          required: true,
        ),
        IncidentFormField(
          id: 'amountInvested',
          label: 'Amount invested (₹)',
          keyboardType: TextInputType.number,
          required: true,
        ),
        IncidentFormField(id: 'promisedReturns', label: 'Promised returns'),
        IncidentFormField(
          id: 'contactDetails',
          label: 'Contact details of the promoter',
        ),
        IncidentFormField(
          id: 'description',
          label: 'How were you contacted / convinced?',
          type: IncidentFieldType.multiline,
        ),
      ],
      IncidentCategory.identityTheft => const [
        IncidentFormField(
          id: 'documentType',
          label: 'Which identity document was misused?',
          required: true,
        ),
        IncidentFormField(
          id: 'howDiscovered',
          label: 'How did you discover this?',
          type: IncidentFieldType.multiline,
          required: true,
        ),
        IncidentFormField(
          id: 'incidentDate',
          label: 'When did you discover this?',
          type: IncidentFieldType.date,
          required: true,
        ),
        IncidentFormField(
          id: 'misuseDescription',
          label: 'How was it misused?',
          type: IncidentFieldType.multiline,
        ),
      ],
      IncidentCategory.emailFraud => const [
        IncidentFormField(
          id: 'senderEmail',
          label: 'Sender email address',
          required: true,
        ),
        IncidentFormField(id: 'subjectLine', label: 'Subject line'),
        IncidentFormField(
          id: 'incidentDate',
          label: 'Received date/time',
          type: IncidentFieldType.date,
          required: true,
        ),
        IncidentFormField(
          id: 'message',
          label: 'Email content summary',
          type: IncidentFieldType.multiline,
        ),
        IncidentFormField(
          id: 'financialLoss',
          label: 'Was there a financial loss?',
          type: IncidentFieldType.boolean,
        ),
      ],
      IncidentCategory.cryptocurrencyFraud => const [
        IncidentFormField(
          id: 'platformOrExchange',
          label: 'Exchange / platform / wallet app',
          required: true,
        ),
        IncidentFormField(
          id: 'walletAddress',
          label: 'Wallet address involved',
        ),
        IncidentFormField(
          id: 'incidentDate',
          label: 'Transaction date',
          type: IncidentFieldType.date,
          required: true,
        ),
        IncidentFormField(
          id: 'amountInvested',
          label: 'Amount involved (₹ equivalent)',
          keyboardType: TextInputType.number,
          required: true,
        ),
        IncidentFormField(
          id: 'description',
          label: 'What happened?',
          type: IncidentFieldType.multiline,
        ),
      ],
      IncidentCategory.other => const [
        IncidentFormField(
          id: 'incidentDate',
          label: 'Incident date',
          type: IncidentFieldType.date,
          required: true,
        ),
        IncidentFormField(
          id: 'description',
          label: 'What happened?',
          type: IncidentFieldType.multiline,
          required: true,
        ),
      ],
    };
  }

  static List<String> get commonBanks => IndianData.banks;
  static List<String> get commonUpiApps => IndianData.upiApps;
}
