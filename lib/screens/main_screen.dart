import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/session_provider.dart';
import '../theme/colors.dart';
import 'home_screen.dart';
import 'map_screen.dart';
import 'history_screen.dart';
import 'more_screen.dart';

class MainScreen extends ConsumerStatefulWidget {
  const MainScreen({super.key});

  @override
  ConsumerState<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends ConsumerState<MainScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).padding.bottom;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: Column(
          children: [
            Expanded(
              child: IndexedStack(
                index: _currentIndex,
                children: const [
                  HomeScreen(),
                  MapScreen(),
                  HistoryScreen(),
                  MoreScreen(),
                ],
              ),
            ),
            Container(
              color: AppColors.background,
              padding: EdgeInsets.only(bottom: bottomInset),
              child: _TabBar(
                currentIndex: _currentIndex,
                onTap: (index) => setState(() => _currentIndex = index),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TabBar extends ConsumerWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const _TabBar({required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(sessionProvider);

    return Container(
      color: AppColors.background,
      child: Row(
        children: [
          _TabElement(
            label: 'page.home.title'.tr(),
            icon: Icons.home_outlined,
            activeIcon: Icons.home,
            focused: currentIndex == 0,
            onTap: () => onTap(0),
          ),
          _TabElement(
            label: 'page.map.title'.tr(),
            icon: Icons.map_outlined,
            activeIcon: Icons.map,
            focused: currentIndex == 1,
            onTap: () => onTap(1),
          ),
          _CenterButton(session: session),
          _TabElement(
            label: 'page.history.title'.tr(),
            icon: Icons.access_time_outlined,
            activeIcon: Icons.access_time_filled,
            focused: currentIndex == 2,
            onTap: () => onTap(2),
          ),
          _TabElement(
            label: 'page.more.title'.tr(),
            icon: Icons.menu,
            activeIcon: Icons.menu,
            focused: currentIndex == 3,
            onTap: () => onTap(3),
          ),
        ],
      ),
    );
  }
}

class _TabElement extends StatelessWidget {
  final String label;
  final IconData icon;
  final IconData activeIcon;
  final bool focused;
  final VoidCallback onTap;

  const _TabElement({
    required this.label,
    required this.icon,
    required this.activeIcon,
    required this.focused,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = focused ? AppColors.primary : AppColors.inactiveTab;
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(focused ? activeIcon : icon, size: 24, color: color),
              Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(color: color, fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CenterButton extends StatelessWidget {
  final AsyncValue session;

  const _CenterButton({required this.session});

  @override
  Widget build(BuildContext context) {
    final isLoading = session.isLoading;
    final hasActive = session.valueOrNull != null;

    return Transform.translate(
      offset: const Offset(0, -5),
      child: GestureDetector(
        onTap: isLoading
            ? null
            : () => context.push(hasActive ? '/charging' : '/unlock/camera'),
        child: Container(
          width: 68,
          height: 68,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isLoading ? AppColors.separator : AppColors.primary,
            border: Border.all(color: AppColors.card, width: 5),
          ),
          alignment: Alignment.center,
          child: isLoading
              ? const SizedBox(
                  width: 28,
                  height: 28,
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                    color: AppColors.primary,
                  ),
                )
              : Icon(
                  hasActive ? Icons.ev_station : Icons.qr_code_2,
                  size: 34,
                  color: AppColors.textDark,
                ),
        ),
      ),
    );
  }
}
