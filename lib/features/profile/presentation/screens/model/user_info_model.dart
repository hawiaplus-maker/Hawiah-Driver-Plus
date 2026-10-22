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
      success: json['success'] is bool
          ? json['success'] as bool
          : json['success']?.toString() == 'true',
      message: json['message']?.toString() ?? '',
      data: raw is Map<String, dynamic> ? UserInfoData.fromJson(raw) : null,
    );
  }
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
      active: json['active']?.toString() == '1' || json['active'] == true || json['active'] == 1,
      orderWork: json['order_work']?.toString() == 'true',
      projectWork: json['project_work']?.toString() == 'true',
      cleaningContractWork: json['cleaning_contract_work']?.toString() == 'true',
    );
  }
}
