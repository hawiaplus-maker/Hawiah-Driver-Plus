class CleaningContractDeliveryModel {
  bool? success;
  String? message;
  CleaningContractDeliveryData? data;

  CleaningContractDeliveryModel({this.success, this.message, this.data});

  factory CleaningContractDeliveryModel.fromJson(Map<String, dynamic> json) {
    return CleaningContractDeliveryModel(
      success: json['success'],
      message: json['message'],
      data: json['data'] != null
          ? CleaningContractDeliveryData.fromJson(json['data'])
          : null,
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

class CleaningContractDeliveryData {
  List<CleaningContractDeliveryItem>? data;
  Pagination? pagination;

  CleaningContractDeliveryData({this.data, this.pagination});

  factory CleaningContractDeliveryData.fromJson(Map<String, dynamic> json) {
    return CleaningContractDeliveryData(
      data: (json['data'] as List?)
          ?.map((v) => CleaningContractDeliveryItem.fromJson(v))
          .toList(),
      pagination: json['pagination'] != null
          ? Pagination.fromJson(json['pagination'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (data != null) map['data'] = data!.map((v) => v.toJson()).toList();
    if (pagination != null) map['pagination'] = pagination!.toJson();
    return map;
  }
}

class CleaningContractDeliveryItem {
  int? id;
  String? contractNumber;
  int? companyId;
  String? companyName;
  String? companyPhone;
  int? containerId;
  String? containerName;
  String? containerSize;
  int? containerQuantity;
  String? cityName;
  dynamic district;
  String? address;
  dynamic latitude;
  dynamic longitude;
  dynamic lat;
  dynamic lang;
  dynamic lng;
  dynamic mapUrl;
  String? deliveryStatus;
  String? deliveryStatusLabel;
  String? deliveryAssignedAt;
  String? deliveredAt;
  String? deliveryImage;
  String? deliveryLatitude;
  String? deliveryLongitude;
  dynamic deliveryLat;
  dynamic deliveryLang;
  dynamic deliveryLng;
  dynamic deliveryNotes;
  String? startDate;
  String? endDate;

  CleaningContractDeliveryItem({
    this.id,
    this.contractNumber,
    this.companyId,
    this.companyName,
    this.companyPhone,
    this.containerId,
    this.containerName,
    this.containerSize,
    this.containerQuantity,
    this.cityName,
    this.district,
    this.address,
    this.latitude,
    this.longitude,
    this.lat,
    this.lang,
    this.lng,
    this.mapUrl,
    this.deliveryStatus,
    this.deliveryStatusLabel,
    this.deliveryAssignedAt,
    this.deliveredAt,
    this.deliveryImage,
    this.deliveryLatitude,
    this.deliveryLongitude,
    this.deliveryLat,
    this.deliveryLang,
    this.deliveryLng,
    this.deliveryNotes,
    this.startDate,
    this.endDate,
  });

  factory CleaningContractDeliveryItem.fromJson(Map<String, dynamic> json) {
    return CleaningContractDeliveryItem(
      id: json['id'],
      contractNumber: json['contract_number'],
      companyId: json['company_id'],
      companyName: json['company_name'],
      companyPhone: json['company_phone'],
      containerId: json['container_id'],
      containerName: json['container_name'],
      containerSize: json['container_size'],
      containerQuantity: json['container_quantity'],
      cityName: json['city_name'],
      district: json['district'],
      address: json['address'],
      latitude: json['latitude'],
      longitude: json['longitude'],
      lat: json['lat'],
      lang: json['lang'],
      lng: json['lng'],
      mapUrl: json['map_url'],
      // Accept both delivery_* and discharge_* keys (discharges endpoint).
      deliveryStatus: json['delivery_status'] ?? json['discharge_status'],
      deliveryStatusLabel:
          json['delivery_status_label'] ?? json['discharge_status_label'],
      deliveryAssignedAt:
          json['delivery_assigned_at'] ?? json['discharge_assigned_at'],
      deliveredAt: json['delivered_at'] ?? json['discharged_at'],
      deliveryImage: json['delivery_image'] ?? json['discharge_image'],
      deliveryLatitude:
          json['delivery_latitude'] ?? json['discharge_latitude'],
      deliveryLongitude:
          json['delivery_longitude'] ?? json['discharge_longitude'],
      deliveryLat: json['delivery_lat'],
      deliveryLang: json['delivery_lang'],
      deliveryLng: json['delivery_lng'],
      deliveryNotes: json['delivery_notes'],
      startDate: json['start_date'],
      endDate: json['end_date'],
    );
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = id;
    map['contract_number'] = contractNumber;
    map['company_id'] = companyId;
    map['company_name'] = companyName;
    map['company_phone'] = companyPhone;
    map['container_id'] = containerId;
    map['container_name'] = containerName;
    map['container_size'] = containerSize;
    map['container_quantity'] = containerQuantity;
    map['city_name'] = cityName;
    map['district'] = district;
    map['address'] = address;
    map['latitude'] = latitude;
    map['longitude'] = longitude;
    map['lat'] = lat;
    map['lang'] = lang;
    map['lng'] = lng;
    map['map_url'] = mapUrl;
    map['delivery_status'] = deliveryStatus;
    map['delivery_status_label'] = deliveryStatusLabel;
    map['delivery_assigned_at'] = deliveryAssignedAt;
    map['delivered_at'] = deliveredAt;
    map['delivery_image'] = deliveryImage;
    map['delivery_latitude'] = deliveryLatitude;
    map['delivery_longitude'] = deliveryLongitude;
    map['delivery_lat'] = deliveryLat;
    map['delivery_lang'] = deliveryLang;
    map['delivery_lng'] = deliveryLng;
    map['delivery_notes'] = deliveryNotes;
    map['start_date'] = startDate;
    map['end_date'] = endDate;
    return map;
  }

  /// Whether this delivery is considered "current" (not yet delivered).
  bool get isCurrent => !isCompleted;

  /// Short display label for the card.
  String get displayLabel => contractNumber ?? '---';

  String get deliveryStatusDisplay =>
      deliveryStatusLabel ?? deliveryStatus ?? '';

  /// Normalized status: lower-cased, `_` separated (`in transit` -> `in_trans`).
  String get _normalizedStatus => (deliveryStatus ?? '')
      .trim()
      .toLowerCase()
      .replaceAll('-', '_')
      .replaceAll(' ', '_');

  /// The record is assigned to the driver but the job isn't done yet — the
  /// driver has to complete the discharge.
  bool get isAssigned => _normalizedStatus == 'assigned';

  /// The record is finished — the container was delivered or discharged.
  bool get isCompleted =>
      _normalizedStatus == 'delivered' || _normalizedStatus == 'discharged';
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
