import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../models/company_charger.dart';
import '../models/company_location.dart';
import '../providers/auth_provider.dart';
import '../providers/companies_provider.dart';
import '../theme/colors.dart';
import '../theme/dimensions.dart';
import '../theme/text_styles.dart';
import '../utils/maps.dart';
import '../widgets/app_text.dart';
import '../widgets/back_button.dart';
import '../widgets/connector_info.dart';
import '../widgets/horizontal_separator.dart';

class LocationScreen extends ConsumerStatefulWidget {
  final String locationRef;

  const LocationScreen({super.key, required this.locationRef});

  @override
  ConsumerState<LocationScreen> createState() => _LocationScreenState();
}

class _LocationScreenState extends ConsumerState<LocationScreen> {
  CompanyLocation? _location;
  List<CompanyCharger> _chargers = const [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    final api = ref.read(apiClientProvider);
    try {
      final location = await api.referenceApi
          .findByReference(widget.locationRef, CompanyLocation.fromJson);
      if (!mounted) return;
      setState(() => _location = location);

      final companies = await ref.read(companiesProvider.future);
      final isMember =
          companies.any((c) => c.company == location.company);
      final visibility = isMember ? null : 'public';

      final page = await api.companyChargerApi.getPaged(
        location: location.self,
        visibility: visibility,
      );
      if (!mounted) return;
      setState(() => _chargers = page.data);
    } catch (_) {
      if (mounted) _goBack();
    }
  }

  void _goBack() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go('/main');
    }
  }

  @override
  Widget build(BuildContext context) {
    final location = _location;
    if (location == null) {
      return const ColoredBox(
        color: AppColors.background,
        child: Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );
    }

    final width = MediaQuery.of(context).size.width;

    return ColoredBox(
      color: AppColors.background,
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(
                width: double.infinity,
                height: width * 9 / 16,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    location.imageUrl != null
                        ? CachedNetworkImage(
                            imageUrl: location.imageUrl!,
                            fit: BoxFit.cover,
                            placeholder: (_, _) => Image.asset(
                              'assets/images/location-placeholder.png',
                              fit: BoxFit.cover,
                            ),
                            errorWidget: (_, _, _) => Image.asset(
                              'assets/images/location-placeholder.png',
                              fit: BoxFit.cover,
                            ),
                          )
                        : Image.asset(
                            'assets/images/location-placeholder.png',
                            fit: BoxFit.cover,
                          ),
                    const DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Colors.transparent, AppColors.background],
                          stops: [0.6, 1.0],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.paddingHorizontal,
                  vertical: 16,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AppText(location.name, type: AppTextType.subtitle),
                          AppText(location.city, type: AppTextType.label),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 12),
                      child: SizedBox(
                        width: 56,
                        height: 48,
                        child: Material(
                          color: Colors.transparent,
                          borderRadius: BorderRadius.circular(16),
                          child: InkWell(
                            onTap: () =>
                                openMapsTravel(location.lat, location.lng),
                            borderRadius: BorderRadius.circular(16),
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: AppColors.highlight,
                                  width: 1,
                                ),
                              ),
                              alignment: Alignment.center,
                              child: const Icon(
                                Icons.directions,
                                size: 32,
                                color: AppColors.surface,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDimensions.paddingHorizontal,
                  ),
                  itemCount: _chargers.length,
                  itemBuilder: (context, index) =>
                      _ChargerListCard(charger: _chargers[index]),
                ),
              ),
            ],
          ),
          Positioned(
            top: MediaQuery.of(context).padding.top,
            left: 0,
            child: const BackButtonWidget(),
          ),
        ],
      ),
    );
  }
}

class _ChargerListCard extends StatelessWidget {
  final CompanyCharger charger;

  const _ChargerListCard({required this.charger});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.card, width: 1),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppText(charger.name, type: AppTextType.subtitle),
                      AppText(charger.model, type: AppTextType.hint),
                    ],
                  ),
                ),
                AppText(
                  '${charger.powerKw} kW',
                  type: AppTextType.title,
                  color: AppColors.primary,
                ),
              ],
            ),
          ),
          const HorizontalSeparator(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Wrap(
              alignment: WrapAlignment.spaceAround,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                for (final connector in charger.connectors)
                  ConnectorInfo(
                    online: charger.online,
                    connector: connector,
                    format: ConnectorFormat.small,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
