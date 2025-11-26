import 'dart:convert';

OrdersModel ordersModelFromJson(String str) => OrdersModel.fromJson(json.decode(str));

String ordersModelToJson(OrdersModel data) => json.encode(data.toJson());

class OrdersModel {
  bool? success;
  String? message;
  OrdersData? data;

  OrdersModel({this.success, this.message, this.data});

  factory OrdersModel.fromJson(Map<String, dynamic> json) {
    return OrdersModel(
      success: json['success'],
      message: json['message'],
      data: json['data'] != null ? OrdersData.fromJson(json['data']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['success'] = success;
    map['message'] = message;
    if (data != null) map['data'] = data!.toJson();
    return map;
  }
}

class OrdersData {
  List<SingleOrderData>? data;
  Pagination? pagination;

  OrdersData({this.data, this.pagination});

  factory OrdersData.fromJson(Map<String, dynamic> json) {
    return OrdersData(
      data: (json['data'] as List?)?.map((v) => SingleOrderData.fromJson(v)).toList(),
      pagination: json['pagination'] != null ? Pagination.fromJson(json['pagination']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (data != null) map['data'] = data!.map((v) => v.toJson()).toList();
    if (pagination != null) map['pagination'] = pagination!.toJson();
    return map;
  }
}

class Pagination {
  int? currentPage;
  int? lastPage;
  int? perPage;
  int? total;

  Pagination({this.currentPage, this.lastPage, this.perPage, this.total});

  factory Pagination.fromJson(Map<String, dynamic> json) {
    return Pagination(
      currentPage: json['current_page'],
      lastPage: json['last_page'],
      perPage: json['per_page'],
      total: json['total'],
    );
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['current_page'] = currentPage;
    map['last_page'] = lastPage;
    map['per_page'] = perPage;
    map['total'] = total;
    return map;
  }
}

class SingleOrderData {
  int? id;
  dynamic referenceNumber;
  String? address;
  double? latitude;
  double? longitude;
  int? orderStatus;
  int? paidStatus;
  Map<String, String>? status; // سيبها كما هي
  int? priceId;
  int? serviceProviderId;
  int? duration;
  String? totalPrice;
  String? fromDate;
  String? toDate;
  int? discount;
  int? discountValue;
  String? createdAt;
  String? product;
  String? image;
  String? driver;
  int? driverId;
  String? driverMobile;
  String? serviceProvider;
  String? serviceProviderMobile;
  List<VehicleModel>? vehicles;
  String? otp;
  String? user;
  int? userId;
  String? userMobile;
  String? userImage;
  String? driverFcmToken;
  String? userFcmToken;
  String? serviceProviderFcmToken;
  String? fcmToken;
  String? contract;
  String? invoice;
  String? support;

  SingleOrderData({
    this.id,
    this.referenceNumber,
    this.address,
    this.latitude,
    this.longitude,
    this.orderStatus,
    this.paidStatus,
    this.status,
    this.priceId,
    this.duration,
    this.totalPrice,
    this.fromDate,
    this.toDate,
    this.discount,
    this.discountValue,
    this.createdAt,
    this.product,
    this.image,
    this.driver,
    this.driverId,
    this.driverMobile,
    this.serviceProvider,
    this.serviceProviderMobile,
    this.vehicles,
    this.otp,
    this.user,
    this.userId,
    this.userMobile,
    this.userImage,
    this.driverFcmToken,
    this.userFcmToken,
    this.serviceProviderFcmToken,
    this.fcmToken,
    this.contract,
    this.invoice,
    this.support,
    this.serviceProviderId,
  });

  factory SingleOrderData.fromJson(Map<String, dynamic> json) {
    return SingleOrderData(
      id: json['id'],
      referenceNumber: json['reference_number'],
      address: json['address'],
      latitude: double.tryParse(json['latitude']?.toString() ?? ''),
      longitude: double.tryParse(json['longitude']?.toString() ?? ''),
      orderStatus: json['order_status'],
      paidStatus: json['paid_status'],
      status: json['status'] != null ? Map<String, String>.from(json['status']) : null,
      priceId: json['price_id'],
      duration: json['duration'],
      totalPrice: json['total_price'],
      fromDate: json['from_date'],
      toDate: json['to_date'],
      discount: json['discount'],
      discountValue: json['discount_value'],
      createdAt: json['created_at'],
      product: json['product'],
      image: json['image'],
      driver: json['driver'],
      driverId: json['driver_id'],
      driverMobile: json['driver_mobile'],
      serviceProvider: json['service_provider'],
      serviceProviderMobile: json['service_provider_mobile'],
      vehicles: (json['vehicles'] as List?)?.map((v) => VehicleModel.fromJson(v)).toList(),
      otp: json['otp'],
      user: json['user'],
      userId: json['user_id'],
      userMobile: json['user_mobile'],
      userImage: json['user_image'],
      driverFcmToken: json['driver_fcm_token'],
      userFcmToken: json['user_fcm_token'],
      serviceProviderFcmToken: json['service_provider_fcm_token'],
      fcmToken: json['fcm_token'],
      contract: json['contract'],
      invoice: json['invoice'],
      support: json['support'],
      serviceProviderId: json['service_provider_id'],
    );
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = id;
    map['reference_number'] = referenceNumber;
    map['address'] = address;
    map['latitude'] = latitude;
    map['longitude'] = longitude;
    map['order_status'] = orderStatus;
    map['paid_status'] = paidStatus;
    map['status'] = status;
    map['price_id'] = priceId;
    map['duration'] = duration;
    map['total_price'] = totalPrice;
    map['from_date'] = fromDate;
    map['to_date'] = toDate;
    map['discount'] = discount;
    map['discount_value'] = discountValue;
    map['created_at'] = createdAt;
    map['product'] = product;
    map['image'] = image;
    map['driver'] = driver;
    map['driver_id'] = driverId;
    map['driver_mobile'] = driverMobile;
    map['service_provider'] = serviceProvider;
    map['service_provider_mobile'] = serviceProviderMobile;
    if (vehicles != null) map['vehicles'] = vehicles!.map((v) => v.toJson()).toList();
    map['otp'] = otp;
    map['user'] = user;
    map['user_id'] = userId;
    map['user_mobile'] = userMobile;
    map['user_image'] = userImage;
    map['driver_fcm_token'] = driverFcmToken;
    map['user_fcm_token'] = userFcmToken;
    map['service_provider_fcm_token'] = serviceProviderFcmToken;
    map['fcm_token'] = fcmToken;
    map['contract'] = contract;
    map['invoice'] = invoice;
    map['support'] = support;
    map['service_provider_id'] = serviceProviderId;
    return map;
  }
}

class VehicleModel {
  final String plateLetters;
  final String plateNumbers;
  final String carType;
  final String carBrand;
  final String carModel;
  final String carYear;

  VehicleModel({
    required this.plateLetters,
    required this.plateNumbers,
    required this.carType,
    required this.carBrand,
    required this.carModel,
    required this.carYear,
  });

  factory VehicleModel.fromJson(Map<String, dynamic> json) {
    return VehicleModel(
      plateLetters: json['plate_letters'] ?? '',
      plateNumbers: json['plate_numbers'] ?? '',
      carType: json['car_type'] ?? '',
      carBrand: json['car_brand'] ?? '',
      carModel: json['car_model'] ?? '',
      carYear: json['car_year'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'plate_letters': plateLetters,
      'plate_numbers': plateNumbers,
      'car_type': carType,
      'car_brand': carBrand,
      'car_model': carModel,
      'car_year': carYear,
    };
  }
}
