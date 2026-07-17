import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../models/user_company.dart';
import '../../providers/auth_provider.dart';
import '../../providers/message_provider.dart';
import '../../theme/colors.dart';
import '../../theme/dimensions.dart';
import '../../theme/text_styles.dart';
import '../../widgets/app_text.dart';
import '../../widgets/screen_view.dart';

class PrivateScreen extends ConsumerStatefulWidget {
  const PrivateScreen({super.key});

  @override
  ConsumerState<PrivateScreen> createState() => _PrivateScreenState();
}

class _PrivateScreenState extends ConsumerState<PrivateScreen> {
  List<UserCompany> _companies = const [];
  bool _refreshing = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    setState(() => _refreshing = true);
    final auth = ref.read(authProvider);
    final message = ref.read(messageProvider.notifier);
    try {
      final companies =
          await ref.read(apiClientProvider).userApi.getCompanies(auth.user!.self);
      if (!mounted) return;
      setState(() => _companies = companies);
      if (companies.isEmpty && mounted) {
        context.pushReplacement('/more/join');
      }
    } on DioException catch (e) {
      if (e.response != null) {
        message.showError('error.unexpected'.tr());
      } else {
        message.showError('error.connection'.tr());
      }
    } finally {
      if (mounted) setState(() => _refreshing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ScreenView(
      backButton: true,
      bottomInset: false,
      background: const DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: AppColors.greenGradient,
          ),
        ),
      ),
      child: Stack(
        children: [
          RefreshIndicator(
            onRefresh: _load,
            color: AppColors.primary,
            backgroundColor: AppColors.background,
            child: ListView(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.paddingHorizontal,
              ).copyWith(top: AppDimensions.paddingTop, bottom: AppDimensions.paddingBottom),
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  child: AppText(
                    'page.private.title'.tr(),
                    type: AppTextType.subtitleBold,
                  ),
                ),
                for (final company in _companies) _CompanyCard(company: company),
                if (!_refreshing && _companies.isEmpty)
                  const SizedBox(height: 200),
              ],
            ),
          ),
          Positioned(
            right: 24,
            bottom: 24,
            child: Material(
              color: AppColors.background,
              shape: const CircleBorder(),
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: () => context.push('/more/join'),
                child: const SizedBox(
                  width: 64,
                  height: 64,
                  child: Icon(Icons.add, size: 32, color: AppColors.primary),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CompanyCard extends StatelessWidget {
  final UserCompany company;

  const _CompanyCard({required this.company});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 96,
      margin: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.highlight,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Container(
            width: 96,
            height: 96,
            decoration: const BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(14),
                bottomLeft: Radius.circular(14),
                bottomRight: Radius.circular(14),
              ),
            ),
            clipBehavior: Clip.antiAlias,
            alignment: Alignment.center,
            child: company.imageUrl != null
                ? CachedNetworkImage(
                    imageUrl: company.imageUrl!,
                    fit: BoxFit.contain,
                    width: 96,
                    height: 96,
                  )
                : AppText(
                    company.name.isNotEmpty
                        ? company.name.substring(0, 1).toUpperCase()
                        : '',
                    type: AppTextType.title,
                    color: const Color(0xA0FFFFFF),
                  ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: AppText(
              company.name,
              type: AppTextType.subtitleBold,
              color: AppColors.textDark,
            ),
          ),
        ],
      ),
    );
  }
}
