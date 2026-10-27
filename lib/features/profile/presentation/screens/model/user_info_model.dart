/// Reads a boolean flag that the API may send as `true`/`false`, `1`/`0` or
/// `"true"`/`"false"`.
bool _flag(dynamic value) {
  if (value is bool) return value;
  if (value is num) return value != 0;
  final normalized = value?.toString().trim().toLowerCase();
  return normalized == 'true' || normalized == '1';
}

/// Model for `GET {{base_url}}/service-providers/user-info`
/// Shape:
/// {
///   "success": true,
///   "message": "User information retrieved successfully.",
///   "data": {
///     "id": 536,
///     "type": "employee",
///     "name": "...",
///     "email": null,
///     "mobile": "0560498210",
///     "image": "...",
///     "api_token": "...",
///     "fcm_token": "...",
///     "active": 1,
///     "order_work": false,
///     "project_work": false,
///     "cleaning_contract_work": true
///   }
/// }
class UserInfoModel {
  final bool success;
  final String message;
  final UserInfoData? data;

  const UserInfoModel({
    required this.success,
    required this.message,
    this.data,
  });

  factory UserInfoModel.fromJson(Map<String, dynamic> json) {
    final raw = json['data'];
    return UserInfoModel(
      success: _flag(json['success']),
      message: json['message']?.toString() ?? '',
      data: raw is Map<String, dynamic> ? UserInfoData.fromJson(raw) : null,
    );
  }

  /// Whether the server currently allows this account to use the app.
  ///
  /// A stored token only proves that a session was created at some point; the
  /// account may have been deactivated since then. `user-info` is the source
  /// of truth, so entry is allowed only when the call succeeds and the user is
  /// marked as active.
  bool get canUseApp => success && (data?.active ?? false);
}

class UserInfoData {
  final int id;
  final String type;
  final String name;
  final String email;
  final String mobile;
  final String image;
  final String apiToken;
  final String fcmToken;
  final bool active;
  final bool orderWork;
  final bool projectWork;
  final bool cleaningContractWork;

  const UserInfoData({
    required this.id,
    required this.type,
    required this.name,
    required this.email,
    required this.mobile,
    required this.image,
    required this.apiToken,
    required this.fcmToken,
    required this.active,
    required this.orderWork,
    required this.projectWork,
    required this.cleaningContractWork,
  });

  factory UserInfoData.fromJson(Map<String, dynamic> json) {
    return UserInfoData(
      id: json['id'] is int ? json['id'] as int : int.tryParse(json['id'].toString()) ?? 0,
      type: json['type']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      mobile: json['mobile']?.toString() ?? '',
      image: json['image']?.toString() ?? '',
      apiToken: json['api_token']?.toString() ?? '',
      fcmToken: json['fcm_token']?.toString() ?? '',
      active: _flag(json['active']),
      orderWork: _flag(json['order_work']),
      projectWork: _flag(json['project_work']),
      cleaningContractWork: _flag(json['cleaning_contract_work']),
    );
  }
}
