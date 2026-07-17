import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../models/benefit.dart';
import '../providers/auth_provider.dart';
import '../providers/message_provider.dart';
import '../theme/colors.dart';
import '../theme/dimensions.dart';
import '../theme/text_styles.dart';
import '../widgets/app_text.dart';
import '../widgets/screen_scroll_view.dart';

class _DniInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    var digits = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.length > 8) digits = digits.substring(0, 8);

    final buffer = StringBuffer();
    for (var i = 0; i < digits.length; i++) {
      if (i == 2 || i == 5) buffer.write('.');
      buffer.write(digits[i]);
    }
    final text = buffer.toString();
    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}

class EnterDniScreen extends ConsumerStatefulWidget {
  final String benefitRef;

  const EnterDniScreen({super.key, required this.benefitRef});

  @override
  ConsumerState<EnterDniScreen> createState() => _EnterDniScreenState();
}

class _EnterDniScreenState extends ConsumerState<EnterDniScreen> {
  final _controller = TextEditingController();
  Benefit? _benefit;
  bool _loading = true;
  bool _submitting = false;
  bool _touched = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(() => setState(() {}));
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final lang = context.locale.languageCode;
    try {
      final benefits =
          await ref.read(apiClientProvider).benefitApi.getAll(lang: lang);
      if (!mounted) return;
      setState(() {
        _benefit =
            benefits.where((b) => b.self == widget.benefitRef).firstOrNull;
        _loading = false;
      });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  String get _rawDni => _controller.text.replaceAll('.', '');

  bool get _valid => RegExp(r'^[1-9][0-9]{7}$').hasMatch(_rawDni);

  Future<void> _submit() async {
    final benefit = _benefit;
    if (benefit == null || !_valid) {
      setState(() => _touched = true);
      return;
    }

    final message = ref.read(messageProvider.notifier);
    setState(() => _submitting = true);
    try {
      await ref
          .read(apiClientProvider)
          .benefitApi
          .activate(benefit, int.parse(_rawDni));
      message.showSuccess('page.benefits.activated'.tr());
      if (!mounted) return;
      if (context.canPop()) {
        context.pop();
      } else {
        context.go('/main');
      }
    } on DioException catch (e) {
      final status = e.response?.statusCode;
      if (status == null) {
        message.showError('error.connection'.tr());
      } else if (status == 400) {
        message.showError('error.subscription'.tr());
      } else if (status == 403) {
        message.showError('error.dni'.tr());
      } else {
        message.showError('error.unexpected'.tr());
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const ColoredBox(
        color: AppColors.background,
        child: Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );
    }

    final benefit = _benefit;
    if (benefit == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) context.go('/main');
      });
      return const ColoredBox(color: AppColors.background);
    }

    final hasError = _touched && !_valid;

    return ScreenScrollView(
      backButton: true,
      bottomInset: false,
      background: const DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: AppColors.blueGradient,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.only(
              top: AppDimensions.paddingTop,
              left: AppDimensions.paddingHorizontal,
              right: AppDimensions.paddingHorizontal,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText(
                  'page.benefits.activate'.tr(),
                  type: AppTextType.subtitleBold,
                ),
                const SizedBox(height: 12),
                Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: 'page.benefits.enter-dni'.tr(),
                        style: AppTextStyles.defaultType
                            .copyWith(color: AppColors.textLight),
                      ),
                      TextSpan(
                        text: benefit.name,
                        style: AppTextStyles.defaultBold
                            .copyWith(color: AppColors.textLight),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 32),
                  child: TextField(
                    controller: _controller,
                    keyboardType: TextInputType.number,
                    inputFormatters: [_DniInputFormatter()],
                    textInputAction: TextInputAction.done,
                    onSubmitted: (_) => _submit(),
                    style: const TextStyle(
                      color: AppColors.textLight,
                      fontSize: 16,
                    ),
                    cursorColor: AppColors.textLight,
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.all(14),
                      hintText: '99.999.999',
                      hintStyle: TextStyle(
                        color: hasError
                            ? AppColors.error
                            : AppColors.textLight.withValues(alpha: 0.7),
                        fontSize: 16,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(
                          color:
                              hasError ? AppColors.error : AppColors.textLight,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(
                          color:
                              hasError ? AppColors.error : AppColors.textLight,
                        ),
                      ),
                    ),
                  ),
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.3,
                      child: Image.asset(
                        'assets/images/etia-benefits.png',
                        fit: BoxFit.contain,
                        height: 150,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 24),
                        child: AppText('page.benefits.dni-info'.tr()),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(
              top: 16,
              bottom: AppDimensions.paddingBottom,
              left: AppDimensions.paddingHorizontal + 32,
              right: AppDimensions.paddingHorizontal + 32,
            ),
            child: SizedBox(
              height: 48,
              child: Opacity(
                opacity: _valid ? 1 : 0.45,
                child: Material(
                  color: AppColors.textLight,
                  borderRadius: BorderRadius.circular(16),
                  child: InkWell(
                    onTap: _submitting ? null : _submit,
                    borderRadius: BorderRadius.circular(16),
                    child: Center(
                      child: _submitting
                          ? SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                color: AppColors.blueGradient[1],
                                strokeWidth: 3,
                              ),
                            )
                          : AppText(
                              'page.benefits.save-dni'.tr(),
                              type: AppTextType.subtitle,
                              color: AppColors.blueGradient[1],
                            ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
