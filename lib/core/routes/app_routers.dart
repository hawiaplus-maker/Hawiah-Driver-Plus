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

      default:
        return MaterialPageRoute(builder: (_) => const LayoutScreen());
    }
  }
}
