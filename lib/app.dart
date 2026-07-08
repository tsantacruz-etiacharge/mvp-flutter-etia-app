import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'theme/colors.dart';
import 'screens/home_screen.dart';
import 'screens/map_screen.dart';
import 'screens/history_screen.dart';
import 'screens/more_screen.dart';

class EtiaMapsApp extends StatelessWidget {
  const EtiaMapsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ETIA Maps',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: AppColors.background,
        colorScheme: const ColorScheme.dark(
          primary: AppColors.primary,
          surface: AppColors.background,
        ),
      ),
      home: const MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 1;

  final List<Widget> _screens = const [
    HomeScreen(),
    MapScreen(),
    HistoryScreen(),
    MoreScreen(),
  ];

  void _onTabTapped(int index) {
    if (index == 2) return;
    setState(() => _currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        body: IndexedStack(
          index: _currentIndex,
          children: _screens,
        ),
        bottomNavigationBar: _buildBottomBar(),
        extendBody: true,
      ),
    );
  }

  Widget _buildBottomBar() {
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    return Container(
      color: Colors.transparent,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: 80,
            child: Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.bottomCenter,
              children: [
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    height: 70,
                    decoration: const BoxDecoration(
                      color: Color(0xFF1A1A1A),
                      border: Border(
                        top: BorderSide(
                          color: AppColors.separator,
                          width: 0.5,
                        ),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildTabItem(0, Icons.home, 'Inicio'),
                        _buildTabItem(1, Icons.map, 'Mapa'),
                        const SizedBox(width: 72),
                        _buildTabItem(3, Icons.history, 'Historial'),
                        _buildTabItem(4, Icons.menu, 'Menú'),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  bottom: 42,
                  child: _buildCenterButton(),
                ),
              ],
            ),
          ),
          Container(
            height: bottomPadding,
            color: const Color(0xFF1A1A1A),
          ),
        ],
      ),
    );
  }

  Widget _buildTabItem(int index, IconData icon, String label) {
    final isActive = _currentIndex == index;
    return GestureDetector(
      onTap: () => _onTabTapped(index),
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 64,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isActive ? AppColors.primary : AppColors.inactiveTab,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isActive ? AppColors.primary : AppColors.inactiveTab,
                fontSize: 10,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCenterButton() {
    return GestureDetector(
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Escáner QR - Demo'),
            duration: Duration(seconds: 1),
          ),
        );
      },
      child: Container(
        width: 68,
        height: 68,
        decoration: BoxDecoration(
          color: AppColors.primary,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.4),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: const Icon(
          Icons.qr_code_scanner,
          color: AppColors.textLight,
          size: 30,
        ),
      ),
    );
  }
}
