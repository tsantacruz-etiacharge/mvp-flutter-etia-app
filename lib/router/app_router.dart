import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/auth_provider.dart';
import '../providers/force_update_provider.dart';
import '../screens/auth/welcome_screen.dart';
import '../screens/auth/sign_in_screen.dart';
import '../screens/auth/sign_up_screen.dart';
import '../screens/auth/verify_email_screen.dart';
import '../screens/auth/reset_password_screen.dart';
import '../screens/auth/reset_password_check_screen.dart';
import '../screens/auth/reset_password_new_screen.dart';
import '../screens/auth/change_language_screen.dart';
import '../screens/auth/restoring_session_screen.dart';
import '../screens/main_screen.dart';
import '../screens/more/account_screen.dart';
import '../screens/more/private_screen.dart';
import '../screens/more/join_screen.dart';
import '../screens/more/support_screen.dart';
import '../screens/more/faq_screen.dart';
import '../screens/more/contact_screen.dart';
import '../screens/more/about_screen.dart';
import '../screens/more/edit_profile_screen.dart';
import '../screens/more/change_password_screen.dart';
import '../screens/complete_profile_screen.dart';
import '../screens/force_update_screen.dart';
import '../screens/tutorial_screen.dart';
import '../screens/credits_screen.dart';
import '../screens/benefit_detail_screen.dart';
import '../screens/enter_dni_screen.dart';
import '../screens/location_screen.dart';
import '../screens/charging_screen.dart';
import '../screens/unlock/camera_screen.dart';
import '../screens/unlock/charger_screen.dart';
import '../screens/unlock/manual_screen.dart';

const _publicRoutes = <String>{
  '/',
  '/signin',
  '/signup',
  '/verify-email',
  '/reset-password',
  '/reset-password/check-code',
  '/reset-password/new-password',
};

const _signedInRoutes = <String>{
  '/main',
  '/more/account',
  '/more/private',
  '/more/join',
  '/more/support',
  '/more/support/faq',
  '/more/support/contact',
  '/more/about',
  '/edit-profile',
  '/change-password',
  '/unlock/camera',
  '/charging',
  '/tutorial',
  '/credits',
  '/home/benefit-detail',
  '/home/enter-dni',
  '/unlock/charger',
  '/unlock/manual',
  '/location',
};

final appRouterProvider = Provider<GoRouter>((ref) {
  final auth = ref.read(authProvider);
  final forceUpdate = ref.read(forceUpdateProvider);

  return GoRouter(
    initialLocation: '/restoring-session',
    refreshListenable: Listenable.merge([auth, forceUpdate]),
    redirect: (context, state) {
      final authState = auth.authState;
      final location = state.matchedLocation;

      if (authState == AuthState.loading ||
          authState == AuthState.restoringSession ||
          authState == AuthState.offline) {
        return location == '/restoring-session' ? null : '/restoring-session';
      }

      // Guard 1 (prod order): force-update blocks everything.
      if (forceUpdate.isForceUpdateRequired) {
        return location == '/force-update' ? null : '/force-update';
      }

      if (location == '/change-language') return null;

      if (authState == AuthState.signedOut) {
        return _publicRoutes.contains(location) ? null : '/';
      }

      // signedIn. Profile fetch unsettled -> stay (avoids flashing onboarding
      // before the 404/200 distinction is known).
      if (!auth.userLoaded) return null;

      // Guard 4 (prod order): signed-in without profile -> onboarding.
      if (auth.user == null) {
        return location == '/complete-profile' ? null : '/complete-profile';
      }

      // Profile exists: /complete-profile is no longer reachable.
      if (location == '/complete-profile') return '/main';

      return _signedInRoutes.contains(location) ? null : '/main';
    },
    routes: [
      GoRoute(path: '/', builder: (context, state) => const WelcomeScreen()),
      GoRoute(path: '/signin', builder: (context, state) => const SignInScreen()),
      GoRoute(path: '/signup', builder: (context, state) => const SignUpScreen()),
      GoRoute(
        path: '/verify-email',
        builder: (context, state) => VerifyEmailScreen(
          email: state.uri.queryParameters['email'] ?? '',
          password: state.uri.queryParameters['password'] ?? '',
        ),
      ),
      GoRoute(
        path: '/reset-password',
        builder: (context, state) => const ResetPasswordScreen(),
      ),
      GoRoute(
        path: '/reset-password/check-code',
        builder: (context, state) => ResetPasswordCheckScreen(
          email: state.uri.queryParameters['email'] ?? '',
        ),
      ),
      GoRoute(
        path: '/reset-password/new-password',
        builder: (context, state) => ResetPasswordNewScreen(
          email: state.uri.queryParameters['email'] ?? '',
          code: state.uri.queryParameters['code'] ?? '',
        ),
      ),
      GoRoute(
        path: '/change-language',
        builder: (context, state) => const ChangeLanguageScreen(),
      ),
      GoRoute(
        path: '/restoring-session',
        builder: (context, state) => const RestoringSessionScreen(),
      ),
      GoRoute(
        path: '/complete-profile',
        builder: (context, state) => const CompleteProfileScreen(),
      ),
      GoRoute(
        path: '/force-update',
        builder: (context, state) => const ForceUpdateScreen(),
      ),
      GoRoute(path: '/main', builder: (context, state) => const MainScreen()),
      GoRoute(
        path: '/more/account',
        builder: (context, state) => const AccountScreen(),
      ),
      GoRoute(
        path: '/more/private',
        builder: (context, state) => const PrivateScreen(),
      ),
      GoRoute(
        path: '/more/join',
        builder: (context, state) => const JoinScreen(),
      ),
      GoRoute(
        path: '/more/support',
        builder: (context, state) => const SupportScreen(),
      ),
      GoRoute(
        path: '/more/support/faq',
        builder: (context, state) => const FaqScreen(),
      ),
      GoRoute(
        path: '/more/support/contact',
        builder: (context, state) => const ContactScreen(),
      ),
      GoRoute(
        path: '/more/about',
        builder: (context, state) => const AboutScreen(),
      ),
      GoRoute(
        path: '/edit-profile',
        builder: (context, state) => const EditProfileScreen(),
      ),
      GoRoute(
        path: '/change-password',
        builder: (context, state) => const ChangePasswordScreen(),
      ),
      GoRoute(
        path: '/unlock/camera',
        builder: (context, state) => const CameraUnlockScreen(),
      ),
      GoRoute(
        path: '/unlock/manual',
        builder: (context, state) => const ManualUnlockScreen(),
      ),
      GoRoute(
        path: '/unlock/charger',
        builder: (context, state) => ChargerUnlockScreen(
          serial: state.uri.queryParameters['serial'] ?? '',
          connectorID: state.uri.queryParameters['connectorID'] ?? '1',
        ),
      ),
      GoRoute(
        path: '/charging',
        builder: (context, state) => const ChargingScreen(),
      ),
      GoRoute(
        path: '/location',
        builder: (context, state) => LocationScreen(
          locationRef: state.uri.queryParameters['locationRef'] ?? '',
        ),
      ),
      GoRoute(
        path: '/tutorial',
        builder: (context, state) => const TutorialScreen(),
      ),
      GoRoute(
        path: '/credits',
        builder: (context, state) => const CreditsScreen(),
      ),
      GoRoute(
        path: '/home/benefit-detail',
        builder: (context, state) => BenefitDetailScreen(
          benefitRef: state.uri.queryParameters['benefitRef'] ?? '',
        ),
      ),
      GoRoute(
        path: '/home/enter-dni',
        builder: (context, state) => EnterDniScreen(
          benefitRef: state.uri.queryParameters['benefitRef'] ?? '',
        ),
      ),
    ],
  );
});
