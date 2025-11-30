class Urls {
  static const String testBlueCarImage =
      'https://images.pexels.com/photos/170811/pexels-photo-170811.jpeg?cs=srgb&amp;dl=pexels-mike-b-170811.jpg&amp;fm=jpg';
  static const String testWhiteCarImage =
      'https://images.pexels.com/photos/116675/pexels-photo-116675.jpeg?cs=srgb&amp;dl=pexels-mike-b-116675.jpg&amp;fm=jpg';
  static const String testCarLogoImage = 'https://cdn.worldvectorlogo.com/logos/bmw-logo.svg';
  static const String testUserImage =
      'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSLlsHCzHU2GndYsMJQscyixYSlDVggHDzbXtXSuEmLAc309Z-6e1TUhHJFCLCw40Kicw0';
  static const String testAppleLogo =
      'https://justcreative.com/wp-content/uploads/2022/01/Apple-Logo-600x400.png';
  static const String testNoonLogo =
      'https://www.elmin7a.com/wp-content/uploads/2021/08/noon-egypt-jobs-customer-service-agent.png';
  static const String testVideo =
      "https://flutter.github.io/assets-for-api-docs/assets/videos/butterfly.mp4";

  //! ===================> Live Api <=================== !//
  static const String baseUrl = 'https://hawiaplus.com/api/';
  static const String login = '${baseUrl}service-providers/login';
  static const String validateMobile = '${baseUrl}validate-mobile';
  static const String companyRegister = '${baseUrl}company/register';
  static const String individualRegister = '${baseUrl}complete-register';
  static const String settings = '${baseUrl}settings';

  static const String logout = '${baseUrl}logout';
  static const String register = '${baseUrl}register';
  static const String verify = '${baseUrl}verify-otp';
  static const String resend = '${baseUrl}resend-otp';
  static const String forgetPassword = '${baseUrl}forget-password';
  static const String resetPassword = '${baseUrl}reset-password';
  static String showServices(int id) => '${baseUrl}services/$id';
  static const String services = '${baseUrl}services';
  static const String profile = '${baseUrl}users/profile';
  static const String updateProfile = '${baseUrl}users/update-profile';
  static const String categories = '${baseUrl}categories';
  static String showCategory(int id) => '${baseUrl}categories/$id';
  static const String completeRegister = '${baseUrl}complete-register';
  static const String getNearbyProviders = '${baseUrl}get-nearby-providers';
  static const String createOrder = '${baseUrl}users/orders';
  static const String onBoarding = '${baseUrl}on-boarding';
  static String orders(int id) => '${baseUrl}drivers/orders?order_status=$id';
  static String confirmOrders(int id) => '${baseUrl}drivers/orders/confirm-order/$id';
  static const String cities = '${baseUrl}cities';
  static const String addresses = '${baseUrl}user-addresses';
  static const String storeAddress = '${baseUrl}user-addresses';
  static String neighborhoodsByCity(int id) => '${baseUrl}neighborhoods/$id';
  static String updateAddress(int id) => '${baseUrl}user-addresses/$id';
  static String getNotifications = '${baseUrl}notifications';
  static String notifications(int? seen, String search) {
    if (seen == null) {
      return "${baseUrl}notifications?search=$search";
    }
    return "${baseUrl}notifications?search=$search&seen=$seen";
  }

  static String deleteNotification(int id) => '${baseUrl}notifications/$id';
  static String applayCoupon = '${baseUrl}coupon/check';
  static String questions = '${baseUrl}faq';
}
