/// Reference Indian data used to make demo content feel realistic.
///
/// This is reference/demo data only — not sourced from any live registry.
class IndianData {
  const IndianData._();

  static const List<String> states = [
    'Andhra Pradesh',
    'Arunachal Pradesh',
    'Assam',
    'Bihar',
    'Chhattisgarh',
    'Goa',
    'Gujarat',
    'Haryana',
    'Himachal Pradesh',
    'Jharkhand',
    'Karnataka',
    'Kerala',
    'Madhya Pradesh',
    'Maharashtra',
    'Manipur',
    'Meghalaya',
    'Mizoram',
    'Nagaland',
    'Odisha',
    'Punjab',
    'Rajasthan',
    'Sikkim',
    'Tamil Nadu',
    'Telangana',
    'Tripura',
    'Uttar Pradesh',
    'Uttarakhand',
    'West Bengal',
    'Delhi (NCT)',
    'Jammu and Kashmir',
    'Ladakh',
    'Puducherry',
    'Chandigarh',
  ];

  static const Map<String, List<String>> districtsByState = {
    'Maharashtra': [
      'Mumbai City',
      'Mumbai Suburban',
      'Pune',
      'Nagpur',
      'Thane',
      'Nashik',
    ],
    'Gujarat': ['Ahmedabad', 'Surat', 'Vadodara', 'Rajkot', 'Bhavnagar'],
    'Delhi (NCT)': [
      'New Delhi',
      'North Delhi',
      'South Delhi',
      'East Delhi',
      'West Delhi',
    ],
    'Karnataka': ['Bengaluru Urban', 'Mysuru', 'Mangaluru', 'Belagavi'],
    'Tamil Nadu': ['Chennai', 'Coimbatore', 'Madurai', 'Salem'],
    'Uttar Pradesh': [
      'Lucknow',
      'Kanpur Nagar',
      'Ghaziabad',
      'Noida (Gautam Buddh Nagar)',
      'Varanasi',
    ],
    'West Bengal': ['Kolkata', 'Howrah', 'North 24 Parganas', 'Darjeeling'],
    'Rajasthan': ['Jaipur', 'Jodhpur', 'Udaipur', 'Kota'],
    'Telangana': ['Hyderabad', 'Rangareddy', 'Warangal Urban'],
  };

  static const List<String> banks = [
    'State Bank of India',
    'HDFC Bank',
    'ICICI Bank',
    'Axis Bank',
    'Punjab National Bank',
    'Bank of Baroda',
    'Kotak Mahindra Bank',
    'Canara Bank',
    'Union Bank of India',
    'IndusInd Bank',
    'Yes Bank',
    'Paytm Payments Bank',
    'IDFC FIRST Bank',
  ];

  static const List<String> upiApps = [
    'Google Pay',
    'PhonePe',
    'Paytm',
    'BHIM UPI',
    'Amazon Pay',
    'WhatsApp Pay',
  ];

  /// Very small demo phone-number normalization: Indian mobile numbers are
  /// 10 digits, commonly shown with a +91 prefix.
  static bool isPlausibleIndianMobile(String value) {
    final digits = value.replaceAll(RegExp(r'[^0-9]'), '');
    final normalized = digits.length == 12 && digits.startsWith('91')
        ? digits.substring(2)
        : digits;
    return normalized.length == 10 && RegExp(r'^[6-9]').hasMatch(normalized);
  }

  static bool isPlausiblePincode(String value) =>
      RegExp(r'^\d{6}$').hasMatch(value.trim());

  static const String cyberCrimeHelplineNumber = '1930';
  static const String ncrpPortalName =
      'National Cyber Crime Reporting Portal (NCRP)';
}
