import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../models/benefit.dart';
import '../models/country.dart';
import '../providers/auth_provider.dart';
import '../providers/message_provider.dart';
import '../theme/colors.dart';
import '../theme/dimensions.dart';
import '../theme/text_styles.dart';
import '../widgets/app_text.dart';
import '../widgets/benefit_card.dart';
import '../widgets/credits_button.dart';
import '../widgets/credits_card.dart';
import '../widgets/icon_header.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  List<Benefit> _benefits = const [];
  Country? _country;

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
      final api = ref.read(apiClientProvider);
      final results = await Future.wait([
        api.benefitApi.getAll(lang: lang),
        api.countryApi.getAll(),
      ]);
      if (mounted) {
        final userCountry = (results[1] as List<Country>).where(
          (c) => c.countryCode == ref.read(authProvider).user?.countryCode,
        );
        setState(() {
          _benefits = results[0] as List<Benefit>;
          _country = userCountry.isEmpty ? null : userCountry.first;
        });
      }
    } catch (_) {
      message.showError('error.connection'.tr());
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authProvider).user;
    final width = MediaQuery.of(context).size.width;
    final contentWidth = width - 2 * AppDimensions.paddingHorizontal;
    final benefitWidth = contentWidth / 2 - 4;
    final cardBenefits =
        _benefits.where((b) => b.cardImageUrl != null).toList();

    return Stack(
      fit: StackFit.expand,
      children: [
        const DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: AppColors.blueGradient,
            ),
          ),
        ),
        SafeArea(
          bottom: false,
          child: RefreshIndicator(
            onRefresh: _refresh,
            color: AppColors.primary,
            backgroundColor: AppColors.background,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.paddingHorizontal,
              ).copyWith(bottom: AppDimensions.paddingBottom),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const IconHeader(),
                  Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: AppText(
                      'page.home.welcome'.tr(
                        namedArgs: {'name': user?.firstName ?? ''},
                      ),
                      type: AppTextType.subtitle,
                    ),
                  ),
                  const SizedBox(height: 16),
                  CreditsCard(credits: user?.credits ?? 0),
                  const SizedBox(height: 32),
                  _tutorialButton(contentWidth),
                  const SizedBox(height: 32),
                  _creditsSection(),
                  const SizedBox(height: 32),
                  AppText('page.benefits.title'.tr()),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: benefitWidth / 2,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: cardBenefits.length,
                      separatorBuilder: (_, _) => const SizedBox(width: 8),
                      itemBuilder: (context, index) => BenefitCard(
                        benefit: cardBenefits[index],
                        width: benefitWidth,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _tutorialButton(double contentWidth) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: () => context.push('/tutorial'),
        child: Stack(
          children: [
            Image.asset(
              'assets/images/car-charging-2.png',
              width: contentWidth,
              height: contentWidth * (438 / 997),
              fit: BoxFit.cover,
            ),
            Positioned.fill(
              child: Align(
                alignment: Alignment.bottomLeft,
                child: Padding(
                  padding: const EdgeInsets.only(left: 14, bottom: 8),
                  child: AppText(
                    'page.tutorial.title'.tr(),
                    type: AppTextType.defaultBold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _creditsSection() {
    // TODO(Fase 4): quick buttons purchase directly via UserApi.createPayment
    // (prod CreditsOptions.onCredits). Until then they open /credits.
    void goCredits() => context.push('/credits');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppText('page.credits.title'.tr()),
        const SizedBox(height: 12),
        InkWell(
          onTap: goCredits,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            decoration: BoxDecoration(
              color: const Color(0xFF3D3D3D),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                AppText('page.home.enter-amount'.tr()),
                const Icon(Icons.add, size: 24, color: AppColors.textLight),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            CreditsButton(
              color: const Color(0xFF5A999E),
              amount: 25,
              country: _country,
              onPressed: goCredits,
            ),
            const SizedBox(width: 8),
            CreditsButton(
              color: const Color(0xFF36A377),
              amount: 50,
              country: _country,
              onPressed: goCredits,
            ),
            const SizedBox(width: 8),
            CreditsButton(
              color: const Color(0xFFB1CE36),
              amount: 75,
              country: _country,
              onPressed: goCredits,
            ),
          ],
        ),
      ],
    );
  }
}
