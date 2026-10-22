/// Model for `GET {{base_url}}/drivers/project-discharges`
///
/// Shape:
/// {
///   "success": true,
///   "message": "Driver project pickups retrieved successfully",
///   "data": {
///     "data": [ { ...pickup item... } ],
///     "pagination": { "current_page": 1, "last_page": 1, "per_page": 15, "total": 1 }
///   }
/// }
import 'package:hawiah_driver/features/order/presentation/model/cleaning_contract_delivery_model.dart'
    show Pagination;

class ProjectDischargeModel {
  final bool success;
  final String message;
  final ProjectDischargeData? data;

  const ProjectDischargeModel({
    required this.success,
    required this.message,
    this.data,
  });

  factory ProjectDischargeModel.fromJson(Map<String, dynamic> json) {
    final raw = json['data'];
    return ProjectDischargeModel(
      success: json['success']?.toString() == 'true',
      message: json['message']?.toString() ?? '',
      data: raw is Map<String, dynamic> ? ProjectDischargeData.fromJson(raw) : null,
    );
  }
}

class ProjectDischargeData {
  final List<ProjectDischargeItem> data;
  final Pagination? pagination;

  const ProjectDischargeData({required this.data, this.pagination});

  factory ProjectDischargeData.fromJson(Map<String, dynamic> json) {
    final list = json['data'];
    return ProjectDischargeData(
      data: list is List
          ? list
              .whereType<Map<String, dynamic>>()
              .map(ProjectDischargeItem.fromJson)
              .toList()
          : [],
      pagination: json['pagination'] is Map<String, dynamic>
          ? Pagination.fromJson(json['pagination'])
          : null,
    );
  }
}

class ProjectDischargeItem {
  final int? id;
  final String? referenceNumber;
  final int? pickupNumber;
  final int? projectId;
  final String? projectNumber;
  final String? projectName;
  final String? containerName;
  final int? containerSize;
  final String? clientName;
  final String? clientMobile;
  final String? locationAddress;
  final double? locationLatitude;
  final double? locationLongitude;
  final String? scheduledDate;
  final String? scheduledTime;
  final int? dischargesCount;
  final int? totalPickups;
  final int? completedPickups;
  final int? remainingPickups;
  final String? status;
  final String? statusLabel;
  final String? assignedAt;
  final String? startedAt;
  final String? completedAt;
  final String? proofImage;
  final String? imageBefore;
  final String? imageAfter;
  final String? completedLatitude;
  final String? completedLongitude;
  final String? driverNotes;
  final String? clientNotes;
  final ProjectDriver? driver;

  const ProjectDischargeItem({
    this.id,
    this.referenceNumber,
    this.pickupNumber,
    this.projectId,
    this.projectNumber,
    this.projectName,
    this.containerName,
    this.containerSize,
    this.clientName,
    this.clientMobile,
    this.locationAddress,
    this.locationLatitude,
    this.locationLongitude,
    this.scheduledDate,
    this.scheduledTime,
    this.dischargesCount,
    this.totalPickups,
    this.completedPickups,
    this.remainingPickups,
    this.status,
    this.statusLabel,
    this.assignedAt,
    this.startedAt,
    this.completedAt,
    this.proofImage,
    this.imageBefore,
    this.imageAfter,
    this.completedLatitude,
    this.completedLongitude,
    this.driverNotes,
    this.clientNotes,
    this.driver,
  });

  factory ProjectDischargeItem.fromJson(Map<String, dynamic> json) {
    return ProjectDischargeItem(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? ''),
      referenceNumber: json['reference_number']?.toString(),
      pickupNumber:
          json['pickup_number'] is int ? json['pickup_number'] : int.tryParse(json['pickup_number']?.toString() ?? ''),
      projectId:
          json['project_id'] is int ? json['project_id'] : int.tryParse(json['project_id']?.toString() ?? ''),
      projectNumber: json['project_number']?.toString(),
      projectName: json['project_name']?.toString(),
      containerName: json['container_name']?.toString(),
      containerSize: json['container_size'] is int
          ? json['container_size']
          : int.tryParse(json['container_size']?.toString() ?? ''),
      clientName: json['client_name']?.toString(),
      clientMobile: json['client_mobile']?.toString(),
      locationAddress: json['location_address']?.toString(),
      locationLatitude: json['location_latitude'] == null
          ? null
          : json['location_latitude'] is num
              ? (json['location_latitude'] as num).toDouble()
              : double.tryParse(json['location_latitude'].toString()),
      locationLongitude: json['location_longitude'] == null
          ? null
          : json['location_longitude'] is num
              ? (json['location_longitude'] as num).toDouble()
              : double.tryParse(json['location_longitude'].toString()),
      scheduledDate: json['scheduled_date']?.toString(),
      scheduledTime: json['scheduled_time']?.toString(),
      dischargesCount: json['discharges_count'] is int
          ? json['discharges_count']
          : int.tryParse(json['discharges_count']?.toString() ?? ''),
      totalPickups: json['total_pickups'] is int
          ? json['total_pickups']
          : int.tryParse(json['total_pickups']?.toString() ?? ''),
      completedPickups: json['completed_pickups'] is int
          ? json['completed_pickups']
          : int.tryParse(json['completed_pickups']?.toString() ?? ''),
      remainingPickups: json['remaining_pickups'] is int
          ? json['remaining_pickups']
          : int.tryParse(json['remaining_pickups']?.toString() ?? ''),
      status: json['status']?.toString(),
      statusLabel: json['status_label']?.toString(),
      assignedAt: json['assigned_at']?.toString(),
      startedAt: json['started_at']?.toString(),
      completedAt: json['completed_at']?.toString(),
      proofImage: json['proof_image']?.toString(),
      imageBefore: json['image_before']?.toString(),
      imageAfter: json['image_after']?.toString(),
      completedLatitude: json['completed_latitude'] == null
          ? null
          : json['completed_latitude'].toString(),
      completedLongitude: json['completed_longitude'] == null
          ? null
          : json['completed_longitude'].toString(),
      driverNotes: json['driver_notes']?.toString(),
      clientNotes: json['client_notes']?.toString(),
      driver: json['driver'] is Map<String, dynamic>
          ? ProjectDriver.fromJson(json['driver'])
          : null,
    );
  }

  /// Completed pickups go to the Old tab; everything else is current.
  bool get isCompleted => _normalizedStatus == 'completed';

  /// The pickup is assigned to the driver but the trip has not started yet —
  /// the driver has to capture `image_before` and call the start-trip endpoint.
  bool get isAssigned => _normalizedStatus == 'assigned';

  /// The trip already started — the API reports it as `in_transit` (older
  /// payloads used `in_trans`) — the driver has to capture `image_after` and
  /// call the complete endpoint.
  bool get isInTransit => _normalizedStatus.contains('trans');

  /// Normalized status: lower-cased, `_` separated (`in transit` -> `in_trans`).
  String get _normalizedStatus => (status ?? '')
      .trim()
      .toLowerCase()
      .replaceAll('-', '_')
      .replaceAll(' ', '_');

  String get statusDisplay => statusLabel ?? status ?? '';
}

class ProjectDriver {
  final int? id;
  final String? name;
  final String? mobile;

  const ProjectDriver({this.id, this.name, this.mobile});

  factory ProjectDriver.fromJson(Map<String, dynamic> json) {
    return ProjectDriver(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? ''),
      name: json['name']?.toString(),
      mobile: json['mobile']?.toString(),
    );
  }
}
