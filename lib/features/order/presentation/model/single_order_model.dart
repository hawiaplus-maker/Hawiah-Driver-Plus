import 'dart:convert';

SingleOrderModel singleOrderModelFromJson(String str) =>
    SingleOrderModel.fromJson(json.decode(str));

String singleOrderModelToJson(SingleOrderModel data) => json.encode(data.toJson());

class SingleOrderModel {
  bool? success;
  String? message;
  SingleOrderData? data;

  SingleOrderModel({this.success, this.message, this.data});

  factory SingleOrderModel.fromJson(Map<String, dynamic> json) => SingleOrderModel(
        success: json['success'],
        message: json['message'],
        data: json['data'] != null ? SingleOrderData.fromJson(json['data']) : null,
      );

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['success'] = success;
    map['message'] = message;
    if (data != null) map['data'] = data!.toJson();
    return map;
  }
}

class SingleOrderData {
  int? id;
  String? otp; // Added
  String? referenceNumber;
  String? address;
  String? latitude;
  String? longitude;
  int? orderStatus;
  int? paidStatus;
  LocalizedTitle? status;
  int? duration;
  String? fromDate;
  String? fromTime;
  String? toDate;
  String? createdAt;
  String? product;
  String? image;
  int? serviceProviderId; // Added
  String? serviceProvider; // Added
  String? user; // Added
  String? userMobile;
  int? userId;
  String? driverFcmToken;
  String? userFcmToken;
  List<ContainerImage>? containerImages;

  SingleOrderData({
    this.id,
    this.otp,
    this.referenceNumber,
    this.address,
    this.latitude,
    this.longitude,
    this.orderStatus,
    this.paidStatus,
    this.status,
    this.duration,
    this.fromDate,
    this.fromTime,
    this.toDate,
    this.createdAt,
    this.product,
    this.image,
    this.serviceProviderId,
    this.serviceProvider,
    this.user,
    this.userMobile,
    this.userId,
    this.driverFcmToken,
    this.userFcmToken,
    this.containerImages,
  });

  factory SingleOrderData.fromJson(Map<String, dynamic> json) => SingleOrderData(
        id: json['id'],
        otp: json['otp'],
        referenceNumber: json['reference_number'],
        address: json['address'],
        latitude: json['latitude'],
        longitude: json['longitude'],
        orderStatus: json['order_status'],
        paidStatus: json['paid_status'],
        status: json['status'] != null ? LocalizedTitle.fromJson(json['status']) : null,
        duration: json['duration'],
        fromDate: json['from_date'],
        fromTime: json['from_time'],
        toDate: json['to_date'],
        createdAt: json['created_at'],
        product: json['product'],
        image: json['image'],
        serviceProviderId: json['service_provider_id'],
        serviceProvider: json['service_provider'],
        user: json['user'],
        userMobile: json['user_mobile'],
        userId: json['user_id'],
        driverFcmToken: json['driver_fcm_token'],
        userFcmToken: json['user_fcm_token'],
        containerImages:
            (json['container_images'] as List?)?.map((v) => ContainerImage.fromJson(v)).toList(),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'otp': otp,
        'reference_number': referenceNumber,
        'address': address,
        'latitude': latitude,
        'longitude': longitude,
        'order_status': orderStatus,
        'paid_status': paidStatus,
        'status': status?.toJson(),
        'duration': duration,
        'from_date': fromDate,
        'from_time': fromTime,
        'to_date': toDate,
        'created_at': createdAt,
        'product': product,
        'image': image,
        'service_provider_id': serviceProviderId,
        'service_provider': serviceProvider,
        'user': user,
        'user_mobile': userMobile,
        'user_id': userId,
        'driver_fcm_token': driverFcmToken,
        'user_fcm_token': userFcmToken,
        'container_images': containerImages?.map((v) => v.toJson()).toList(),
      };
}

class LocalizedTitle {
  String? en;
  String? ar;

  LocalizedTitle({this.en, this.ar});

  factory LocalizedTitle.fromJson(Map<String, dynamic> json) => LocalizedTitle(
        en: json['en'],
        ar: json['ar'],
      );

  Map<String, dynamic> toJson() => {
        'en': en,
        'ar': ar,
      };
}

class ContainerImage {
  final int id;
  final String url;

  ContainerImage({
    required this.id,
    required this.url,
  });

  factory ContainerImage.fromJson(Map<String, dynamic> json) {
    return ContainerImage(
      id: json['id'],
      url: json['url'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'url': url,
    };
  }
}
