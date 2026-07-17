import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../models/charger_connector.dart';
import '../theme/colors.dart';
import '../theme/text_styles.dart';
import 'app_text.dart';

enum ConnectorFormat { large, small }

enum _ConnectorStatus { available, unavailable, ready, occupied }

class ConnectorInfo extends StatelessWidget {
  final bool online;
  final ChargerConnector connector;
  final ConnectorFormat format;

  const ConnectorInfo({
    super.key,
    required this.online,
    required this.connector,
    required this.format,
  });

  _ConnectorStatus _resolveStatus(bool showReady) {
    if (!online) return _ConnectorStatus.unavailable;
    if (connector.error != ChargePointError.noError ||
        connector.status == ChargePointStatus.faulted ||
        connector.status == ChargePointStatus.unavailable) {
      return _ConnectorStatus.unavailable;
    }
    if (connector.status == ChargePointStatus.preparing && showReady) {
      return _ConnectorStatus.ready;
    }
    if (connector.status == ChargePointStatus.available) {
      return _ConnectorStatus.available;
    }
    return _ConnectorStatus.occupied;
  }

  @override
  Widget build(BuildContext context) {
    final isLarge = format == ConnectorFormat.large;
    final status = _resolveStatus(isLarge);

    final Color color;
    if (isLarge && status == _ConnectorStatus.available) {
      color = AppColors.highlight;
    } else {
      switch (status) {
        case _ConnectorStatus.available:
        case _ConnectorStatus.ready:
          color = AppColors.primary;
        case _ConnectorStatus.occupied:
          color = AppColors.warning;
        case _ConnectorStatus.unavailable:
          color = AppColors.highlight;
      }
    }

    final textKey = switch (status) {
      _ConnectorStatus.available => 'page.charger.available',
      _ConnectorStatus.unavailable => 'page.charger.unavailable',
      _ConnectorStatus.ready => 'page.charger.ready',
      _ConnectorStatus.occupied => 'page.charger.occupied',
    };

    final icon = Icon(
      Icons.ev_station,
      size: isLarge ? 96 : 40,
      color: color,
    );

    final label = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AppText(
          'page.charger.connector'.tr(
            namedArgs: {'connectorID': '${connector.connectorID}'},
          ),
        ),
        AppText(textKey.tr(), type: AppTextType.hint),
      ],
    );

    if (isLarge) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [icon, label],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 4),
            child: icon,
          ),
          label,
        ],
      ),
    );
  }
}
