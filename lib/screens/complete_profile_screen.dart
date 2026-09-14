import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/country.dart';
import '../providers/auth_provider.dart';
import '../providers/message_provider.dart';
import '../theme/colors.dart';
import '../theme/dimensions.dart';
import '../theme/text_styles.dart';
import '../utils/app_logger.dart';
import '../widgets/app_button.dart';
import '../widgets/app_text.dart';
import '../widgets/app_text_field.dart';
import '../widgets/icon_header.dart';
import '../widgets/picker.dart';
import '../widgets/screen_scroll_view.dart';

/// Mirrors complete-profile.tsx in etia-user-app.
/// Shown (via router guard) when signed in but the backend has no user
/// profile yet (GET user ref -> 404).
class CompleteProfileScreen extends ConsumerStatefulWidget {
  const CompleteProfileScreen({super.key});

  @override
  ConsumerState<CompleteProfileScreen> createState() =>
      _CompleteProfileScreenState();
}

class _CompleteProfileScreenState extends ConsumerState<CompleteProfileScreen> {
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  String _gender = '';
  String _countryCode = '';
  DateTime? _dateOfBirth;

  List<Country>? _countries;
  bool _submitted = false;
  bool _loading = false;

  DateTime get _today => DateTime.now();

  /// Prod: maximumDate = today - 18y (must be 18+), minimumDate = today - 150y.
  DateTime get _maxDate =>
      DateTime(_today.year - 18, _today.month, _today.day);
  DateTime get _minDate =>
      DateTime(_today.year - 150, _today.month, _today.day);

  @override
  void initState() {
    super.initState();
    _fetchCountries();
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    super.dispose();
  }

  Future<void> _fetchCountries() async {
    try {
      final countries = await ref.read(apiClientProvider).countryApi.getAll();
      if (mounted) setState(() => _countries = countries);
    } catch (e) {
      AppLogger.warning('Failed to fetch countries', e);
      // Prod shows a raw 'Failed to fetch information' toast here.
      ref.read(messageProvider.notifier).showError('error.connection'.tr());
    }
  }

  bool get _firstNameValid => _firstNameController.text.trim().isNotEmpty;
  bool get _lastNameValid => _lastNameController.text.trim().isNotEmpty;
  bool get _genderValid => _gender == 'female' || _gender == 'male';
  bool get _countryValid => _countryCode.isNotEmpty;
  bool get _birthdateValid => _dateOfBirth != null;

  bool get _formValid =>
      _firstNameValid &&
      _lastNameValid &&
      _genderValid &&
      _countryValid &&
      _birthdateValid;

  String get _genderLabel {
    switch (_gender) {
      case 'female':
        return 'form.gender.female'.tr();
      case 'male':
        return 'form.gender.male'.tr();
      default:
        return 'form.gender'.tr();
    }
  }

  String get _countryLabel {
    final countries = _countries;
    if (countries == null) return 'form.country'.tr();
    for (final c in countries) {
      if (c.countryCode == _countryCode) return c.name;
    }
    return 'form.country'.tr();
  }

  String get _birthdateLabel {
    final dob = _dateOfBirth;
    if (dob == null) return 'form.birthdate'.tr();
    return '${dob.year.toString().padLeft(4, '0')}-'
        '${dob.month.toString().padLeft(2, '0')}-'
        '${dob.day.toString().padLeft(2, '0')}';
  }

  void _pickGender() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Picker<String>(
            selected: _gender,
            onSelected: (value) {
              setState(() => _gender = value);
              Navigator.of(sheetContext).pop();
            },
            items: [
              PickerItem(value: 'female', label: 'form.gender.female'.tr()),
              PickerItem(value: 'male', label: 'form.gender.male'.tr()),
            ],
          ),
        ),
      ),
    );
  }

  void _pickCountry() {
    final countries = _countries;
    if (countries == null) return;
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: SingleChildScrollView(
            child: Picker<String>(
              selected: _countryCode,
              onSelected: (value) {
                setState(() => _countryCode = value);
                Navigator.of(sheetContext).pop();
              },
              items: [
                for (final c in countries)
                  PickerItem(value: c.countryCode, label: c.name),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _pickBirthdate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dateOfBirth ?? _maxDate,
      firstDate: _minDate,
      lastDate: _maxDate,
    );
    if (picked != null && mounted) setState(() => _dateOfBirth = picked);
  }

  Future<void> _submit() async {
    setState(() => _submitted = true);
    if (!_formValid || _loading) return;

    setState(() => _loading = true);
    final message = ref.read(messageProvider.notifier);
    try {
      await ref.read(apiClientProvider).userApi.create(
            firstName: _firstNameController.text.trim(),
            lastName: _lastNameController.text.trim(),
            gender: _gender,
            countryCode: _countryCode,
            dateOfBirth: _dateOfBirth!,
          );
      await ref.read(authProvider.notifier).refreshUser();
      // No explicit navigation: the router guard leaves /complete-profile
      // automatically once user != null.
    } on DioException catch (e) {
      if (e.response != null) {
        if (e.response!.statusCode == 403) {
          message.showError('error.profile-exists'.tr());
          await ref.read(authProvider.notifier).refreshUser();
        } else {
          message.showError('error.unexpected'.tr());
        }
      } else {
        message.showError('error.connection'.tr());
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Widget _selectorBox({
    required String label,
    required bool hasError,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 48,
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: hasError ? AppColors.error : AppColors.highlight,
          ),
        ),
        child: Row(
          children: [
            Expanded(child: AppText(label)),
            const Icon(
              Icons.keyboard_arrow_down,
              color: AppColors.highlight,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_countries == null) {
      return const ColoredBox(
        color: AppColors.background,
        child: Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );
    }

    return ScreenScrollView(
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.paddingHorizontal,
      ).copyWith(bottom: AppDimensions.paddingBottom),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const IconHeader(),
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: AppText(
                  'page.complete-profile.title'.tr(),
                  type: AppTextType.subtitleBold,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 24, bottom: 8),
                child: AppTextField(
                  controller: _firstNameController,
                  label: 'form.name'.tr(),
                  textInputAction: TextInputAction.next,
                  hasError: _submitted && !_firstNameValid,
                  onChanged: (_) {
                    if (_submitted) setState(() {});
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 24, bottom: 8),
                child: AppTextField(
                  controller: _lastNameController,
                  label: 'form.surname'.tr(),
                  textInputAction: TextInputAction.next,
                  hasError: _submitted && !_lastNameValid,
                  onChanged: (_) {
                    if (_submitted) setState(() {});
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 24, bottom: 8),
                child: _selectorBox(
                  label: _genderLabel,
                  hasError: _submitted && !_genderValid,
                  onTap: _pickGender,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 24, bottom: 8),
                child: _selectorBox(
                  label: _countryLabel,
                  hasError: _submitted && !_countryValid,
                  onTap: _pickCountry,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 24, bottom: 8),
                child: _selectorBox(
                  label: _birthdateLabel,
                  hasError: _submitted && !_birthdateValid,
                  onTap: _pickBirthdate,
                ),
              ),
            ],
          ),
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 24).copyWith(top: 24),
            child: AppButton(
              type: AppButtonType.primary,
              sharpCorner: AppButtonCorner.bottomLeft,
              loading: _loading,
              onPressed: _submit,
              child: AppText(
                'common.continue'.tr(),
                type: AppTextType.subtitle,
                color: AppColors.textDark,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
