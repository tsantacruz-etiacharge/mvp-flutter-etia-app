import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../config/env.dart';
import '../providers/auth_provider.dart';
import '../services/mercado_pago_channel.dart';
import '../theme/colors.dart';
import '../theme/dimensions.dart';
import '../theme/text_styles.dart';
import '../utils/app_logger.dart';
import '../widgets/app_button.dart';
import '../widgets/app_text.dart';
import '../widgets/icon_header.dart';
import '../widgets/screen_scroll_view.dart';

/// In-app card payment, ported from prueba-flutter-MP's PaymentTestScreen
/// into the app's design system and credits flow.
///
/// Scope (same as the PoC): opens the native CoreMethods card form and
/// obtains a card token. The token is NOT charged here — charging requires
/// a backend `POST /v1/payments` endpoint that does not exist yet, so on
/// success the screen only confirms the card was verified. The raw token
/// is never displayed (unlike the PoC's copyable token card).
class CardPaymentScreen extends ConsumerStatefulWidget {
  final int credits;

  const CardPaymentScreen({super.key, required this.credits});

  @override
  ConsumerState<CardPaymentScreen> createState() => _CardPaymentScreenState();
}

class _CardPaymentScreenState extends ConsumerState<CardPaymentScreen> {
  static const _channel = MercadoPagoChannel();

  bool _loading = false;
  bool _verified = false;
  String? _error;

  Future<void> _pay() async {
    if (_loading) return;
    final publicKey = Env.mpPublicKey;
    if (publicKey.isEmpty) {
      setState(() => _error = 'page.payment.card.no-key'.tr());
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final dni = ref.read(authProvider).user?.dni;
      final token = await _channel.createCardToken(
        publicKey: publicKey,
        identificationNumber: dni?.toString(),
      );
      AppLogger.debug('Card token obtained (${token.length} chars)');
      if (mounted) setState(() => _verified = true);
    } on MercadoPagoException catch (e) {
      AppLogger.warning('Card token failed', e);
      if (!mounted) return;
      setState(() {
        _error = e.cancelled
            ? 'page.payment.card.cancelled'.tr()
            : 'page.payment.card.error'.tr();
      });
    } catch (e) {
      AppLogger.warning('Card token failed', e);
      if (mounted) setState(() => _error = 'error.connection'.tr());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _finish() => context.go('/main');

  @override
  Widget build(BuildContext context) {
    return ScreenScrollView(
      backButton: true,
      background: const DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: AppColors.aquaGradient,
          ),
        ),
      ),
      contentPadding: const EdgeInsets.only(
        top: AppDimensions.paddingTop,
        left: AppDimensions.paddingHorizontal,
        right: AppDimensions.paddingHorizontal,
        bottom: AppDimensions.paddingBottom,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const IconHeader(),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: AppText(
                  'page.payment.card.title'.tr(),
                  type: AppTextType.subtitleBold,
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(right: 4),
                    child: Image.asset(
                      'assets/icons/e-power.png',
                      height: 48,
                      width: 48,
                    ),
                  ),
                  AppText(
                    '${widget.credits}',
                    type: AppTextType.titleBold,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              AppText(
                'page.home.x-amount'
                    .tr(namedArgs: {'amount': '${widget.credits}'}),
                textAlign: TextAlign.center,
                type: AppTextType.hint,
              ),
              const SizedBox(height: 24),
              if (_verified)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.card,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.primary),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.check_circle,
                          color: AppColors.primary),
                      const SizedBox(width: 12),
                      Expanded(
                        child: AppText(
                          'page.payment.card.success'.tr(),
                        ),
                      ),
                    ],
                  ),
                ),
              if (_error != null)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.card,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.error),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error, color: AppColors.error),
                      const SizedBox(width: 12),
                      Expanded(child: AppText(_error!)),
                    ],
                  ),
                ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(top: 24),
            child: _verified
                ? AppButton(
                    sharpCorner: AppButtonCorner.bottomLeft,
                    onPressed: _finish,
                    child: AppText(
                      'common.continue'.tr(),
                      type: AppTextType.subtitle,
                      color: AppColors.textDark,
                    ),
                  )
                : AppButton(
                    sharpCorner: AppButtonCorner.bottomLeft,
                    loading: _loading,
                    onPressed: _pay,
                    child: AppText(
                      'page.payment.card.pay'.tr(),
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
