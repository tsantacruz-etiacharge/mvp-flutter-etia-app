import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../models/calculated_cost.dart';
import '../../models/charger_connector.dart';
import '../../models/company_charger.dart';
import '../../models/company_location.dart';
import '../../providers/auth_provider.dart';
import '../../providers/message_provider.dart';
import '../../providers/session_provider.dart';
import '../../theme/colors.dart';
import '../../theme/dimensions.dart';
import '../../theme/text_styles.dart';
import '../../widgets/app_text.dart';
import '../../widgets/connector_info.dart';
import '../../widgets/screen_view.dart';
import '../../widgets/time_field.dart';

class ChargerUnlockScreen extends ConsumerStatefulWidget {
  final String serial;
  final String connectorID;

  const ChargerUnlockScreen({
    super.key,
    required this.serial,
    required this.connectorID,
  });

  @override
  ConsumerState<ChargerUnlockScreen> createState() =>
      _ChargerUnlockScreenState();
}

class _ChargerUnlockScreenState extends ConsumerState<ChargerUnlockScreen> {
  CompanyCharger? _charger;
  CompanyLocation? _location;
  CalculatedCost? _cost;
  ChargerConnector? _connector;

  int _hours = 1;
  int _minutes = 0;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  void _goBack() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go('/main');
    }
  }

  Future<void> _load() async {
    final api = ref.read(apiClientProvider);
    final message = ref.read(messageProvider.notifier);
    final id = int.tryParse(widget.connectorID) ?? 1;
    try {
      final charger = await api.companyChargerApi.findBySerial(widget.serial);
      final results = await Future.wait([
        api.companyChargerApi.calculateCost(charger),
        api.referenceApi
            .findByReference(charger.location, CompanyLocation.fromJson),
      ]);
      final cost = results[0] as CalculatedCost;
      final location = results[1] as CompanyLocation;

      final connector =
          charger.connectors.where((c) => c.connectorID == id).firstOrNull;
      if (connector == null) {
        message.showError('error.invalid-code'.tr());
        if (mounted) _goBack();
        return;
      }

      if (!mounted) return;
      setState(() {
        _charger = charger;
        _location = location;
        _cost = cost;
        _connector = connector;
      });
    } on DioException catch (e) {
      final status = e.response?.statusCode;
      if (status == null) {
        message.showError('error.connection'.tr());
      } else if (status == 404) {
        message.showError('error.invalid-code'.tr());
      } else if (status == 403) {
        message.showError('error.private-charger'.tr());
      } else {
        message.showError('error.unexpected'.tr());
      }
      if (mounted) _goBack();
    } catch (_) {
      if (mounted) _goBack();
    }
  }

  int _calculateCredits(double hourlyRate) {
    if (hourlyRate == 0) return 0;
    final value = (_hours + _minutes / 60) * hourlyRate;
    return value.round() < 1 ? 1 : value.round();
  }

  Future<void> _submit() async {
    final api = ref.read(apiClientProvider);
    final message = ref.read(messageProvider.notifier);
    // Prod accepts 0h0m (backend decides); block it early with a clear error.
    if (_hours * 60 + _minutes <= 0) {
      message.showError('page.unlock.invalid-time'.tr());
      return;
    }
    // Fully unavailable chargers fail server-side anyway (400/502);
    // surface it immediately instead of a round trip.
    if (_charger?.status == ChargerStatus.unavailable) {
      message.showError('error.charger.unavailable'.tr());
      return;
    }
    setState(() => _submitting = true);
    try {
      await api.sessionApi.start(
        serial: widget.serial,
        connectorID: int.tryParse(widget.connectorID) ?? 1,
        limitMinutes: _hours * 60 + _minutes,
      );
      ref.invalidate(sessionProvider);
      if (!mounted) return;
      context.replace('/charging');
    } on DioException catch (e) {
      final status = e.response?.statusCode;
      if (status == null) {
        message.showError('error.connection'.tr());
      } else if (status == 400) {
        message.showError('error.charger.not-ready'.tr());
      } else if (status == 402) {
        message.showError('error.not-enough-credits'.tr());
      } else if (status == 502) {
        message.showError('error.charger.unavailable'.tr());
      } else if (status == 410) {
        message.showError('error.benefit.expired'.tr());
        if (mounted) _goBack();
      } else {
        message.showError('error.unexpected'.tr());
        if (mounted) _goBack();
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final charger = _charger;
    final location = _location;
    final connector = _connector;
    final cost = _cost;

    if (charger == null ||
        location == null ||
        connector == null ||
        cost == null) {
      return const ColoredBox(
        color: AppColors.background,
        child: Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );
    }

    final benefit = cost.benefit;

    return ScreenView(
      backButton: true,
      background: const ColoredBox(color: AppColors.background),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(
                top: AppDimensions.paddingTop,
                left: AppDimensions.paddingHorizontal,
                right: AppDimensions.paddingHorizontal,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    margin: const EdgeInsets.symmetric(vertical: 16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.card,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              AppText(location.name, type: AppTextType.subtitle),
                              AppText(charger.model, type: AppTextType.label),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            AppText(
                              'page.unlock.power'.tr(),
                              type: AppTextType.subtitle,
                            ),
                            AppText(
                              '${charger.powerKw} kW',
                              type: AppTextType.defaultBold,
                              color: AppColors.primary,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  TimeField(
                    hours: List<int>.generate(25, (i) => i),
                    minutes: const [0, 15, 30, 45],
                    initialHours: 1,
                    initialMinutes: 0,
                    onChanged: (h, m) => setState(() {
                      _hours = h;
                      _minutes = m;
                    }),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      ConnectorInfo(
                        online: charger.online,
                        connector: connector,
                        format: ConnectorFormat.large,
                      ),
                    ],
                  ),
                  const SizedBox.shrink(),
                ],
              ),
            ),
          ),
          if (benefit != null)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 24),
              color: benefit.colorPalette.banner.background,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (benefit.bannerIconUrl != null)
                    Padding(
                      padding: const EdgeInsets.only(right: 32),
                      child: CachedNetworkImage(
                        imageUrl: benefit.bannerIconUrl!,
                        width: 80,
                        height: 40,
                        fit: BoxFit.contain,
                      ),
                    ),
                  Column(
                    children: [
                      AppText(
                        'page.unlock.discount'.tr(),
                        type: AppTextType.hint,
                        color: benefit.colorPalette.banner.text,
                      ),
                      AppText(
                        'page.unlock.savings'.tr(
                          namedArgs: {
                            'credits':
                                '${_calculateCredits(cost.baseHourlyRate) - _calculateCredits(cost.hourlyRate)}',
                          },
                        ),
                        type: AppTextType.hint,
                        color: benefit.colorPalette.banner.text,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          Container(
            color: AppColors.blueGradient[1],
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Column(
                  children: [
                    AppText(
                      '${_calculateCredits(cost.hourlyRate)}',
                      type: AppTextType.title,
                      color: AppColors.textDark,
                    ),
                    AppText(
                      'page.unlock.credits'.tr(),
                      type: AppTextType.hint,
                      color: AppColors.textDark,
                    ),
                  ],
                ),
                SizedBox(
                  height: 48,
                  child: Material(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(16),
                    child: InkWell(
                      onTap: _submitting ? null : _submit,
                      borderRadius: BorderRadius.circular(16),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Center(
                          child: _submitting
                              ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    color: AppColors.textDark,
                                    strokeWidth: 3,
                                  ),
                                )
                              : AppText(
                                  'page.unlock.start'.tr(),
                                  color: AppColors.textDark,
                                ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
