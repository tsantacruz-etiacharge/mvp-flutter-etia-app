import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../theme/colors.dart';
import '../theme/dimensions.dart';
import '../theme/text_styles.dart';
import '../widgets/app_button.dart';
import '../widgets/app_text.dart';
import '../widgets/screen_view.dart';

class TutorialScreen extends StatefulWidget {
  const TutorialScreen({super.key});

  @override
  State<TutorialScreen> createState() => _TutorialScreenState();
}

class _TutorialScreenState extends State<TutorialScreen> {
  final _controller = PageController();
  int _page = 0;

  static const _pages = 8;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _prev() {
    if (_page == 0) return;
    _controller.animateToPage(
      _page - 1,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
    );
  }

  void _next() {
    if (_page == _pages - 1) {
      if (context.canPop()) {
        context.pop();
      } else {
        context.go('/main');
      }
      return;
    }
    _controller.animateToPage(
      _page + 1,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ScreenView(
      background: const DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: AppColors.greenGradient,
          ),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.only(top: 32, bottom: AppDimensions.paddingBottom),
        child: Column(
          children: [
            Padding(
              padding: AppDimensions.horizontal,
              child: Align(
                alignment: Alignment.centerLeft,
                child: AppText(
                  'page.tutorial.title'.tr(),
                  type: AppTextType.subtitleBold,
                  color: AppColors.textDark,
                ),
              ),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: _pages,
                onPageChanged: (index) => setState(() => _page = index),
                itemBuilder: (context, index) => _TutorialPage(page: index),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (var i = 0; i < _pages; i++)
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: i == _page
                          ? AppColors.blueGradient[1]
                          : Colors.transparent,
                      border: Border.all(
                        color: AppColors.blueGradient[1],
                        width: 2,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 24),
            Padding(
              padding: AppDimensions.horizontal,
              child: Row(
                children: [
                  Expanded(
                    child: Opacity(
                      opacity: _page == 0 ? 0 : 1,
                      child: AppButton(
                        type: AppButtonType.secondary,
                        onPressed: _page == 0 ? null : _prev,
                        child: AppText('common.previous'.tr()),
                      ),
                    ),
                  ),
                  const SizedBox(width: 40),
                  Expanded(
                    child: _BlueButton(
                      onPressed: _next,
                      label: (_page == _pages - 1
                              ? 'common.continue'
                              : 'common.next')
                          .tr(),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BlueButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String label;

  const _BlueButton({required this.onPressed, required this.label});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: Material(
        color: AppColors.blueGradient[1],
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(16),
          child: Center(child: AppText(label)),
        ),
      ),
    );
  }
}

class _TutorialPage extends StatelessWidget {
  final int page;

  const _TutorialPage({required this.page});

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;

    return Column(
      children: [
        Transform.translate(
          offset: const Offset(0, -12),
          child: Image.asset(
            'assets/images/tutorial-$page.png',
            width: double.infinity,
            height: height * 0.45,
            fit: BoxFit.contain,
          ),
        ),
        Expanded(
          child: Padding(
            padding: AppDimensions.horizontal,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AppText(
                  'page.tutorial.subtitle-$page'.tr(),
                  type: AppTextType.subtitleBold,
                  color: AppColors.textDark,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                AppText(
                  'page.tutorial.text-$page'.tr(),
                  color: AppColors.textDark,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
