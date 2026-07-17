import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/benefit.dart';
import '../providers/auth_provider.dart';
import '../providers/message_provider.dart';
import '../theme/colors.dart';
import '../theme/dimensions.dart';
import '../theme/text_styles.dart';
import '../widgets/app_text.dart';
import '../widgets/screen_scroll_view.dart';

class BenefitDetailScreen extends ConsumerStatefulWidget {
  final String benefitRef;

  const BenefitDetailScreen({super.key, required this.benefitRef});

  @override
  ConsumerState<BenefitDetailScreen> createState() =>
      _BenefitDetailScreenState();
}

class _BenefitDetailScreenState extends ConsumerState<BenefitDetailScreen> {
  Benefit? _benefit;
  bool _loading = true;
  bool _activating = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _refresh());
  }

  Future<void> _refresh() async {
    final message = ref.read(messageProvider.notifier);
    final lang = context.locale.languageCode;
    try {
      await ref.read(authProvider.notifier).refreshUser();
      final benefits =
          await ref.read(apiClientProvider).benefitApi.getAll(lang: lang);
      if (!mounted) return;
      setState(() {
        _benefit = benefits.where((b) => b.self == widget.benefitRef).firstOrNull;
        _loading = false;
      });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
      message.showError('error.connection'.tr());
    }
  }

  Future<void> _activate() async {
    final benefit = _benefit;
    final user = ref.read(authProvider).user;
    if (benefit == null || user == null) return;

    if (user.dni == null) {
      context.replace('/home/enter-dni?benefitRef=${Uri.encodeComponent(widget.benefitRef)}');
      return;
    }

    final message = ref.read(messageProvider.notifier);
    setState(() => _activating = true);
    try {
      await ref.read(apiClientProvider).benefitApi.activate(benefit, user.dni!);
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
      if (mounted) setState(() => _activating = false);
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

    final width = MediaQuery.of(context).size.width;
    final active = benefit.active ?? false;

    return ScreenScrollView(
      backButton: true,
      backButtonColor: benefit.colorPalette.detailUi,
      topInset: false,
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
          SizedBox(
            width: double.infinity,
            height: width / 2,
            child: Stack(
              fit: StackFit.expand,
              children: [
                if (benefit.detailImageUrl != null)
                  CachedNetworkImage(
                    imageUrl: benefit.detailImageUrl!,
                    fit: BoxFit.contain,
                  ),
                const DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Color(0x4D064789), Colors.transparent],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: AppDimensions.horizontal,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 24, bottom: 16),
                  child: AppText(benefit.title, type: AppTextType.title),
                ),
                AppText(benefit.description),
                if (benefit.termsUrl != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: Center(
                      child: GestureDetector(
                        onTap: () => launchUrl(
                          Uri.parse(benefit.termsUrl!),
                          mode: LaunchMode.externalApplication,
                        ),
                        child: AppText(
                          'page.benefits.terms'.tr(),
                          type: AppTextType.link,
                        ),
                      ),
                    ),
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
            child: _ActivateButton(
              active: active,
              loading: _activating,
              onPressed: active ? null : _activate,
            ),
          ),
        ],
      ),
    );
  }
}

class _ActivateButton extends StatelessWidget {
  final bool active;
  final bool loading;
  final VoidCallback? onPressed;

  const _ActivateButton({
    required this.active,
    required this.loading,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: Opacity(
        opacity: active ? 0.45 : 1,
        child: Material(
          color: AppColors.textLight,
          borderRadius: BorderRadius.circular(16),
          child: InkWell(
            onTap: loading ? null : onPressed,
            borderRadius: BorderRadius.circular(16),
            child: Center(
              child: loading
                  ? SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        color: AppColors.blueGradient[1],
                        strokeWidth: 3,
                      ),
                    )
                  : AppText(
                      (active
                              ? 'page.benefits.active'
                              : 'page.benefits.activate')
                          .tr(),
                      type: AppTextType.subtitle,
                      color: AppColors.blueGradient[1],
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
