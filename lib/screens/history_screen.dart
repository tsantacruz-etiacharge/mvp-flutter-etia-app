import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/charging_session.dart';
import '../models/pagination.dart';
import '../providers/auth_provider.dart';
import '../providers/message_provider.dart';
import '../theme/colors.dart';
import '../theme/dimensions.dart';
import '../theme/text_styles.dart';
import '../widgets/app_button.dart';
import '../widgets/app_text.dart';
import '../widgets/icon_header.dart';

class HistoryScreen extends ConsumerStatefulWidget {
  const HistoryScreen({super.key});

  @override
  ConsumerState<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends ConsumerState<HistoryScreen> {
  final List<Pagination<ChargingSession>> _pages = [];
  bool _refreshing = false;
  bool _loadingMore = false;

  List<ChargingSession> get _sessions =>
      _pages.expand((p) => p.data).toList();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _refresh());
  }

  Future<void> _refresh() async {
    setState(() => _refreshing = true);
    final auth = ref.read(authProvider);
    final message = ref.read(messageProvider.notifier);
    try {
      final page = await ref.read(apiClientProvider).sessionApi.getPaged(
            user: auth.userRef,
            state: 'finished',
          );
      if (mounted) {
        setState(() => _pages
          ..clear()
          ..add(page));
      }
    } catch (_) {
      message.showError('error.connection'.tr());
    } finally {
      if (mounted) setState(() => _refreshing = false);
    }
  }

  Future<void> _loadMore() async {
    setState(() => _loadingMore = true);
    final auth = ref.read(authProvider);
    final message = ref.read(messageProvider.notifier);
    try {
      final last = _pages.last;
      final page = await ref.read(apiClientProvider).sessionApi.getPaged(
            user: auth.userRef,
            state: 'finished',
            page: last.page + 1,
            pageSize: last.pageSize,
          );
      if (mounted) setState(() => _pages.add(page));
    } catch (_) {
      message.showError('error.connection'.tr());
    } finally {
      if (mounted) setState(() => _loadingMore = false);
    }
  }

  List<_Section> get _sections {
    final result = <_Section>[];
    for (final session in _sessions) {
      final date = DateTime.tryParse(session.timeStart);
      final key = date != null
          ? DateFormat('yyyy-MM-dd').format(date)
          : session.timeStart;
      final index = result.indexWhere((s) => s.dateKey == key);
      if (index != -1) {
        result[index].data.add(session);
      } else {
        result.add(_Section(dateKey: key, data: [session]));
      }
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    final locale = context.locale.toString();
    final sessions = _sessions;
    final total = _pages.isNotEmpty ? _pages.first.count : 0;

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
          child: Column(
            children: [
              const IconHeader(),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: _refresh,
                  color: AppColors.primary,
                  backgroundColor: AppColors.background,
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppDimensions.paddingHorizontal,
                    ).copyWith(bottom: AppDimensions.paddingBottom),
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(bottom: 24),
                        child: AppText(
                          'page.history.title'.tr(),
                          type: AppTextType.subtitleBold,
                        ),
                      ),
                      for (final section in _sections) ...[
                        AppText(_formatSectionDate(section.dateKey, locale)),
                        for (final session in section.data)
                          _SessionCard(session: session, locale: locale),
                      ],
                      if (sessions.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 16),
                          child: AppButton(
                            type: AppButtonType.secondary,
                            loading: _loadingMore,
                            disabled: total == sessions.length,
                            onPressed: _loadMore,
                            child: AppText(
                              'common.load-more'.tr(),
                              type: AppTextType.subtitle,
                            ),
                          ),
                        ),
                      if (sessions.isEmpty && !_refreshing)
                        AppText('page.history.empty'.tr()),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _formatSectionDate(String key, String locale) {
    final date = DateTime.tryParse(key);
    if (date == null) return key;
    return DateFormat.yMMMMd(locale).format(date);
  }
}

class _Section {
  final String dateKey;
  final List<ChargingSession> data;

  _Section({required this.dateKey, required this.data});
}

class _SessionCard extends StatelessWidget {
  final ChargingSession session;
  final String locale;

  const _SessionCard({required this.session, required this.locale});

  @override
  Widget build(BuildContext context) {
    final start = DateTime.tryParse(session.timeStart);
    final stop =
        session.timeStop != null ? DateTime.tryParse(session.timeStop!) : null;
    final duration = (start != null && stop != null)
        ? stop.difference(start)
        : Duration.zero;
    final kwh = NumberFormat.decimalPattern(locale)
        .format((session.energyWh / 1000).round());

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.highlight,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: AppText(
                  session.location.name,
                  type: AppTextType.defaultBold,
                  color: AppColors.textDark,
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  AppText(
                    '$kwh kWh',
                    type: AppTextType.defaultBold,
                    color: AppColors.textDark,
                  ),
                  AppText(
                    start != null && stop != null
                        ? '${DateFormat('HH:mm').format(start)} - ${DateFormat('HH:mm').format(stop)}hs'
                        : '',
                    type: AppTextType.hint,
                    color: AppColors.textDark,
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: AppText(
                  session.location.address,
                  type: AppTextType.hint,
                  color: const Color(0x90000000),
                ),
              ),
              AppText(
                '${duration.inHours}h ${duration.inMinutes % 60}m',
                type: AppTextType.hint,
                color: AppColors.textDark,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
