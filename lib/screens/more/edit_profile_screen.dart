import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../providers/auth_provider.dart';
import '../../providers/message_provider.dart';
import '../../theme/colors.dart';
import '../../theme/dimensions.dart';
import '../../theme/text_styles.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_text.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/icon_header.dart';
import '../../widgets/picker.dart';
import '../../widgets/screen_scroll_view.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  late final TextEditingController _firstNameController;
  late final TextEditingController _lastNameController;
  late String _gender;
  bool _submitted = false;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    final user = ref.read(authProvider).user;
    _firstNameController = TextEditingController(text: user?.firstName ?? '');
    _lastNameController = TextEditingController(text: user?.lastName ?? '');
    _gender = user?.gender ?? '';
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    super.dispose();
  }

  bool get _firstNameValid => _firstNameController.text.trim().isNotEmpty;
  bool get _lastNameValid => _lastNameController.text.trim().isNotEmpty;

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

  Future<void> _submit() async {
    setState(() => _submitted = true);
    if (!_firstNameValid || !_lastNameValid) return;

    setState(() => _loading = true);
    final auth = ref.read(authProvider);
    final message = ref.read(messageProvider.notifier);
    try {
      await ref.read(apiClientProvider).userApi.update(auth.user!.self, {
        'firstName': _firstNameController.text,
        'lastName': _lastNameController.text,
        'gender': _gender,
      });
      await ref.read(authProvider.notifier).refreshUser();
      message.showSuccess('page.edit-profile.updated'.tr());
      if (mounted) {
        if (context.canPop()) {
          context.pop();
        } else {
          context.go('/more/account');
        }
      }
    } on DioException catch (e) {
      if (e.response != null) {
        message.showError('error.unexpected'.tr());
      } else {
        message.showError('error.connection'.tr());
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Widget _fieldBox({required String label, required String value}) {
    return Container(
      height: 48,
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.highlight.withValues(alpha: 0.5)),
      ),
      child: AppText(
        value.isEmpty ? label : value,
        color: AppColors.highlight.withValues(alpha: 0.6),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authProvider).user;

    return ScreenScrollView(
      backButton: true,
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
                  'page.edit-profile.title'.tr(),
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
                child: GestureDetector(
                  onTap: _pickGender,
                  child: Container(
                    height: 48,
                    alignment: Alignment.centerLeft,
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.highlight),
                    ),
                    child: Row(
                      children: [
                        Expanded(child: AppText(_genderLabel)),
                        const Icon(
                          Icons.keyboard_arrow_down,
                          color: AppColors.highlight,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 24, bottom: 8),
                child: _fieldBox(
                  label: 'form.country'.tr(),
                  value: user?.countryCode ?? '',
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 24, bottom: 8),
                child: _fieldBox(
                  label: 'form.birthdate'.tr(),
                  value: user?.dateOfBirth ?? '',
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24).copyWith(top: 24),
            child: AppButton(
              type: AppButtonType.primary,
              sharpCorner: AppButtonCorner.bottomLeft,
              loading: _loading,
              onPressed: _submit,
              child: AppText(
                'page.edit-profile.save'.tr(),
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
