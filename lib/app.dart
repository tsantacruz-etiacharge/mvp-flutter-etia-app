import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easy_localization/easy_localization.dart';

import 'router/app_router.dart';
import 'theme/colors.dart';
import 'widgets/message_banner.dart';

class EtiaApp extends ConsumerWidget {
  const EtiaApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      title: 'ETIA',
      debugShowCheckedModeBanner: false,
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: AppColors.background,
        colorScheme: const ColorScheme.dark(
          primary: AppColors.primary,
          surface: AppColors.background,
        ),
      ),
      routerConfig: router,
      builder: (context, child) {
        return Material(
          type: MaterialType.transparency,
          child: Stack(
            children: [
              child ?? const SizedBox.shrink(),
              const MessageOverlay(),
            ],
          ),
        );
      },
    );
  }
}
