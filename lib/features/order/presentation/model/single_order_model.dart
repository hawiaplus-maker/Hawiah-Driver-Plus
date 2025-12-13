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
  String? otp;
  String? referenceNumber;
  String? address;
  String? latitude;
  String? longitude;
  int? orderStatus;
  int? paidStatus;
  LocalizedTitle? status;
  int? priceId;
  int? duration;
  double? totalPrice;
  double? priceBeforeTax;
  double? vat;
  double? vatValue;
  String? fromDate;
  String? toDate;
  double? discount;
  double? discountValue;
  String? createdAt;
  String? product;
  String? image;
  String? driver;
  String? driverMobile;
  List<dynamic>? vehicles;
  int? serviceProviderId;
  String? serviceProvider;
  String? serviceProviderMobile;
  double? serviceProviderRating;
  String? user;
  String? userMobile;
  String? driverFcmToken;
  String? userFcmToken;
  String? serviceProviderFcmToken;
  String? contract;
  String? invoice;
  String? support;
  int? driverId;

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
    this.priceId,
    this.duration,
    this.totalPrice,
    this.priceBeforeTax,
    this.vat,
    this.vatValue,
    this.fromDate,
    this.toDate,
    this.discount,
    this.discountValue,
    this.createdAt,
    this.product,
    this.image,
    this.driver,
    this.driverMobile,
    this.vehicles,
    this.serviceProviderId,
    this.serviceProvider,
    this.serviceProviderMobile,
    this.serviceProviderRating,
    this.user,
    this.userMobile,
    this.driverFcmToken,
    this.userFcmToken,
    this.serviceProviderFcmToken,
    this.contract,
    this.invoice,
    this.support,
    this.driverId,
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
        priceId: json['price_id'],
        duration: json['duration'],
        totalPrice:
            json['total_price'] != null ? double.tryParse(json['total_price'].toString()) : 0,
        priceBeforeTax: json['price_before_tax'] != null
            ? double.tryParse(json['price_before_tax'].toString())
            : 0,
        vat: json['vat'] != null ? double.tryParse(json['vat'].toString()) : 0,
        vatValue: json['vat_value'] != null ? double.tryParse(json['vat_value'].toString()) : 0,
        fromDate: json['from_date'],
        toDate: json['to_date'],
        discount: json['discount'] != null ? double.tryParse(json['discount'].toString()) : 0,
        discountValue:
            json['discount_value'] != null ? double.tryParse(json['discount_value'].toString()) : 0,
        createdAt: json['created_at'],
        product: json['product'],
        image: json['image'],
        driver: json['driver'],
        driverMobile: json['driver_mobile'],
        vehicles: json['vehicles'] ?? [],
        serviceProviderId: json['service_provider_id'],
        serviceProvider: json['service_provider'],
        serviceProviderMobile: json['service_provider_mobile'],
        serviceProviderRating: json['service_provider_rating'] != null
            ? double.tryParse(json['service_provider_rating'].toString())
            : 0,
        user: json['user'],
        userMobile: json['user_mobile'],
        driverFcmToken: json['driver_fcm_token'],
        userFcmToken: json['user_fcm_token'],
        serviceProviderFcmToken: json['service_provider_fcm_token'],
        contract: json['contract'],
        invoice: json['invoice'],
        support: json['support'],
        driverId: json['driver_id'],
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
        'price_id': priceId,
        'duration': duration,
        'total_price': totalPrice,
        'price_before_tax': priceBeforeTax,
        'vat': vat,
        'vat_value': vatValue,
        'from_date': fromDate,
        'to_date': toDate,
        'discount': discount,
        'discount_value': discountValue,
        'created_at': createdAt,
        'product': product,
        'image': image,
        'driver': driver,
        'driver_mobile': driverMobile,
        'vehicles': vehicles,
        'service_provider_id': serviceProviderId,
        'service_provider': serviceProvider,
        'service_provider_mobile': serviceProviderMobile,
        'service_provider_rating': serviceProviderRating,
        'user': user,
        'user_mobile': userMobile,
        'driver_fcm_token': driverFcmToken,
        'user_fcm_token': userFcmToken,
        'service_provider_fcm_token': serviceProviderFcmToken,
        'contract': contract,
        'invoice': invoice,
        'support': support,
        'driver_id': driverId,
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
