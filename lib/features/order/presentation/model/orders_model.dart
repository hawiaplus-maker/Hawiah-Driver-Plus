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
        data!.add(new Data.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
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
  String? latitude;
  String? longitude;
  int? orderStatus;
  Map<String, dynamic>? status;
  int? priceId;
  int? duration;
  String? totalPrice;
  int? discount;
  int? discountValue;
  String? createdAt;
  String? product;
  String? image;
  String? driver;
  String? driverMobile;
  String? otp;
  String? user;
  String? userMobile;
  String? userImage;

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
    this.discount,
    this.discountValue,
    this.createdAt,
    this.product,
    this.image,
    this.driver,
    this.driverMobile,
    this.otp,
    this.user,
    this.userMobile,
    this.userImage,
  });

  Data.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    referenceNumber = json['reference_number'];
    address = json['address'];
    latitude = json['latitude'];
    longitude = json['longitude'];
    orderStatus = json['order_status'];
    status = json['status'];
    priceId = json['price_id'];
    duration = json['duration'];
    totalPrice = json['total_price'];
    discount = json['discount'];
    discountValue = json['discount_value'];
    createdAt = json['created_at'];
    product = json['product'];
    image = json['image'];
    driver = json['driver'];
    driverMobile = json['driver mobile'];
    otp = json['otp'];
    user = json['user'];
    userMobile = json['user_mobile'];
    userImage = json['user_image'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
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
    data['discount'] = this.discount;
    data['discount_value'] = this.discountValue;
    data['created_at'] = this.createdAt;
    data['product'] = this.product;
    data['image'] = this.image;
    data['driver'] = this.driver;
    data['driver mobile'] = this.driverMobile;
    data['otp'] = this.otp;
    data['user'] = this.user;
    data['user_mobile'] = this.userMobile;
    data['user_image'] = this.userImage;
    return data;
  }
}
