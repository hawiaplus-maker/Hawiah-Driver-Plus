class OrdersModel {
  bool? success;
  String? message;
  List<Data>? data;

  OrdersModel({this.success, this.message, this.data});

  OrdersModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    message = json['message'];
    if (json['data'] != null) {
      data = <Data>[];
      json['data'].forEach((v) {
        data!.add(Data.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['success'] = this.success;
    data['message'] = this.message;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Data {
  int? id;
  String? referenceNumber;
  String? address;
  double? latitude;
  double? longitude;
  int? orderStatus;
  Map<String, String>? status;
  int? priceId;
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
  List<VehicleModel>? vehicles;
  String? otp;
  String? user;
  int? userId;
  String? userMobile;
  String? userImage;
  String? fcmToken;
  String? contract;
  String? invoice;

  Data({
    this.id,
    this.referenceNumber,
    this.address,
    this.latitude,
    this.longitude,
    this.orderStatus,
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
    this.vehicles,
    this.otp,
    this.user,
    this.userId,
    this.userMobile,
    this.userImage,
    this.fcmToken,
    this.contract,
    this.invoice,
  });

  Data.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    referenceNumber = json['reference_number'];
    address = json['address'];
    latitude = double.tryParse(json['latitude'].toString());
    longitude = double.tryParse(json['longitude'].toString());
    orderStatus = json['order_status'];
    status = Map<String, String>.from(json['status']);
    priceId = json['price_id'];
    duration = json['duration'];
    totalPrice = json['total_price'];
    fromDate = json['from_date'];
    toDate = json['to_date'];
    discount = json['discount'];
    discountValue = json['discount_value'];
    createdAt = json['created_at'];
    product = json['product'];
    image = json['image'];
    driver = json['driver'];
    driverId = json['driver_id'];
    driverMobile = json['driver_mobile'];
    otp = json['otp'];
    user = json['user'];
    userId = json['user_id'];
    userMobile = json['user_mobile'];
    userImage = json['user_image'];
    fcmToken = json['fcm_token'];
    contract = json['contract'];
    invoice = json['invoice'];
    vehicles =
        (json['vehicles'] as List?)
            ?.map((v) => VehicleModel.fromJson(v))
            .toList();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['id'] = this.id;
    data['reference_number'] = this.referenceNumber;
    data['address'] = this.address;
    data['latitude'] = this.latitude;
    data['longitude'] = this.longitude;
    data['order_status'] = this.orderStatus;
    data['status'] = this.status;
    data['price_id'] = this.priceId;
    data['duration'] = this.duration;
    data['total_price'] = this.totalPrice;
    data['from_date'] = this.fromDate;
    data['to_date'] = this.toDate;
    data['discount'] = this.discount;
    data['discount_value'] = this.discountValue;
    data['created_at'] = this.createdAt;
    data['product'] = this.product;
    data['image'] = this.image;
    data['driver'] = this.driver;
    data['driver_id'] = this.driverId;
    data['driver_mobile'] = this.driverMobile;
    data['otp'] = this.otp;
    data['user'] = this.user;
    data['user_id'] = this.userId;
    data['user_mobile'] = this.userMobile;
    data['user_image'] = this.userImage;
    data['fcm_token'] = this.fcmToken;
    data['contract'] = this.contract;
    data['invoice'] = this.invoice;

    if (this.vehicles != null) {
      data['vehicles'] = this.vehicles!.map((v) => v.toJson()).toList();
    }

    return data;
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
      plateLetters: json['plate_letters'],
      plateNumbers: json['plate_numbers'],
      carType: json['car_type'],
      carBrand: json['car_brand'],
      carModel: json['car_model'],
      carYear: json['car_year'],
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
