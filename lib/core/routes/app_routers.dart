part of 'app_routers_import.dart';

class AppRouters {
  static GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    dynamic args;
    if (settings.arguments != null) args = settings.arguments;
    switch (settings.name) {
      case ZoomImageScreen.routeName:
        return MaterialPageRoute(builder: (_) => ZoomImageScreen(args: args));
      case SingleChatScreen.routeName:
        return MaterialPageRoute(builder: (_) => SingleChatScreen(args: args));
      case UserProfile.routeName:
        return MaterialPageRoute(builder: (_) => UserProfile());
      case SupportScreen.routeName:
        return MaterialPageRoute(builder: (_) => const SupportScreen());
      case FaqScreen.routeName:
        return MaterialPageRoute(builder: (_) => const FaqScreen());
      case LanguageScreen.routeName:
        return MaterialPageRoute(builder: (_) => const LanguageScreen());
      case PrivacyPolicyScreen.routeName:
        return MaterialPageRoute(builder: (_) => const PrivacyPolicyScreen());
      case TermsAndConditionsScreen.routeName:
        return MaterialPageRoute(builder: (_) => const TermsAndConditionsScreen());
      default:
        return MaterialPageRoute(builder: (_) => const LayoutScreen());
    }
  }
}
