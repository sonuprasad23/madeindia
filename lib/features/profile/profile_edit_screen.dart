import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/indian_data.dart';
import '../../core/theme/design_tokens.dart';
import '../../core/widgets/rakshak_button.dart';
import '../../core/widgets/rakshak_inputs.dart';
import '../../data/repositories/citizen_profile_repository.dart';

class ProfileEditScreen extends ConsumerStatefulWidget {
  const ProfileEditScreen({super.key});

  @override
  ConsumerState<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends ConsumerState<ProfileEditScreen> {
  late final TextEditingController _name;
  late final TextEditingController _mobile;
  late final TextEditingController _email;
  late final TextEditingController _currentAddress;
  late final TextEditingController _pincode;
  String? _state;
  String? _district;
  String? _pincodeError;

  @override
  void initState() {
    super.initState();
    final profile = ref.read(citizenProfileProvider);
    _name = TextEditingController(text: profile.name);
    _mobile = TextEditingController(text: profile.mobile);
    _email = TextEditingController(text: profile.email);
    _currentAddress = TextEditingController(text: profile.currentAddress);
    _pincode = TextEditingController(text: profile.pincode);
    _state = profile.state.isNotEmpty ? profile.state : null;
    _district = profile.district.isNotEmpty ? profile.district : null;
  }

  @override
  void dispose() {
    _name.dispose();
    _mobile.dispose();
    _email.dispose();
    _currentAddress.dispose();
    _pincode.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_pincode.text.isNotEmpty &&
        !IndianData.isPlausiblePincode(_pincode.text)) {
      setState(() => _pincodeError = 'Enter a valid 6-digit pincode');
      return;
    }
    await ref
        .read(citizenProfileProvider.notifier)
        .update(
          (p) => p.copyWith(
            name: _name.text.trim(),
            mobile: _mobile.text.trim(),
            email: _email.text.trim(),
            currentAddress: _currentAddress.text.trim(),
            state: _state ?? '',
            district: _district ?? '',
            pincode: _pincode.text.trim(),
          ),
        );
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final districtOptions = _state != null
        ? (IndianData.districtsByState[_state] ?? const <String>[])
        : const <String>[];

    return Scaffold(
      appBar: AppBar(title: const Text('Edit Profile')),
      body: ListView(
        padding: const EdgeInsets.all(Spacing.lg),
        children: [
          RakshakTextField(label: 'Full name', controller: _name),
          const SizedBox(height: Spacing.lg),
          RakshakTextField(
            label: 'Mobile number',
            controller: _mobile,
            keyboardType: TextInputType.phone,
            prefixText: '+91 ',
          ),
          const SizedBox(height: Spacing.lg),
          RakshakTextField(
            label: 'Email',
            controller: _email,
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: Spacing.lg),
          RakshakTextField(
            label: 'Current address',
            controller: _currentAddress,
            maxLines: 2,
          ),
          const SizedBox(height: Spacing.lg),
          RakshakDropdown<String>(
            label: 'State',
            value: _state,
            items: IndianData.states,
            itemLabel: (s) => s,
            onChanged: (v) => setState(() {
              _state = v;
              _district = null;
            }),
          ),
          const SizedBox(height: Spacing.lg),
          if (districtOptions.isNotEmpty)
            RakshakDropdown<String>(
              label: 'District',
              value: _district,
              items: districtOptions,
              itemLabel: (d) => d,
              onChanged: (v) => setState(() => _district = v),
            )
          else
            RakshakTextField(
              label: 'District',
              onChanged: (v) => _district = v,
            ),
          const SizedBox(height: Spacing.lg),
          RakshakTextField(
            label: 'Pincode',
            controller: _pincode,
            keyboardType: TextInputType.number,
            maxLength: 6,
            errorText: _pincodeError,
          ),
          const SizedBox(height: Spacing.xl),
          RakshakButton(label: 'Save', onPressed: _save),
        ],
      ),
    );
  }
}
