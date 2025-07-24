import 'dart:convert';

NotificationsModel notificationsModelFromJson(String str) =>
    NotificationsModel.fromJson(json.decode(str));

String notificationsModelToJson(NotificationsModel data) =>
    json.encode(data.toJson());

class NotificationsModel {
  bool success;
  Notifications notifications;

  NotificationsModel({required this.success, required this.notifications});

  factory NotificationsModel.fromJson(Map<String, dynamic> json) =>
      NotificationsModel(
        success: json["success"],
        notifications: Notifications.fromJson(json["notifications"]),
      );

  Map<String, dynamic> toJson() => {
    "success": success,
    "notifications": notifications.toJson(),
  };
}

class Notifications {
  int currentPage;
  List<Datum> data;
  String firstPageUrl;
  int from;
  int lastPage;
  String lastPageUrl;
  List<Link> links;
  dynamic nextPageUrl;
  String path;
  int perPage;
  dynamic prevPageUrl;
  int to;
  int total;

  Notifications({
    required this.currentPage,
    required this.data,
    required this.firstPageUrl,
    required this.from,
    required this.lastPage,
    required this.lastPageUrl,
    required this.links,
    required this.nextPageUrl,
    required this.path,
    required this.perPage,
    required this.prevPageUrl,
    required this.to,
    required this.total,
  });

  factory Notifications.fromJson(Map<String, dynamic> json) => Notifications(
    currentPage: json["current_page"],
    data: List<Datum>.from(json["data"].map((x) => Datum.fromJson(x))),
    firstPageUrl: json["first_page_url"],
    from: json["from"],
    lastPage: json["last_page"],
    lastPageUrl: json["last_page_url"],
    links: List<Link>.from(json["links"].map((x) => Link.fromJson(x))),
    nextPageUrl: json["next_page_url"],
    path: json["path"],
    perPage: json["per_page"],
    prevPageUrl: json["prev_page_url"],
    to: json["to"],
    total: json["total"],
  );

  Map<String, dynamic> toJson() => {
    "current_page": currentPage,
    "data": List<dynamic>.from(data.map((x) => x.toJson())),
    "first_page_url": firstPageUrl,
    "from": from,
    "last_page": lastPage,
    "last_page_url": lastPageUrl,
    "links": List<dynamic>.from(links.map((x) => x.toJson())),
    "next_page_url": nextPageUrl,
    "path": path,
    "per_page": perPage,
    "prev_page_url": prevPageUrl,
    "to": to,
    "total": total,
  };
}

class Datum {
  int id;
  Message title;
  Message message;
  String notifiableType;
  int notifiableId;
  String modelType;
  int modelId;
  int seen;
  int userId;
  Data data;
  DateTime createdAt;
  DateTime updatedAt;
  int showClient;
  int showCompany;
  int showPuncher;
  int showEmployee;

  Datum({
    required this.id,
    required this.title,
    required this.message,
    required this.notifiableType,
    required this.notifiableId,
    required this.modelType,
    required this.modelId,
    required this.seen,
    required this.userId,
    required this.data,
    required this.createdAt,
    required this.updatedAt,
    required this.showClient,
    required this.showCompany,
    required this.showPuncher,
    required this.showEmployee,
  });

  factory Datum.fromJson(Map<String, dynamic> json) => Datum(
    id: json["id"],
    title: Message.fromJson(json["title"]),
    message: Message.fromJson(json["message"]),
    notifiableType: json["notifiable_type"],
    notifiableId: json["notifiable_id"],
    modelType: json["model_type"],
    modelId: json["model_id"],
    seen: json["seen"],
    userId: json["user_id"],
    data: Data.fromJson(json["data"]),
    createdAt: DateTime.parse(json["created_at"]),
    updatedAt: DateTime.parse(json["updated_at"]),
    showClient: json["show_client"],
    showCompany: json["show_company"],
    showPuncher: json["show_puncher"],
    showEmployee: json["show_employee"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "title": title.toJson(),
    "message": message.toJson(),
    "notifiable_type": notifiableType,
    "notifiable_id": notifiableId,
    "model_type": modelType,
    "model_id": modelId,
    "seen": seen,
    "user_id": userId,
    "data": data.toJson(),
    "created_at": createdAt.toIso8601String(),
    "updated_at": updatedAt.toIso8601String(),
    "show_client": showClient,
    "show_company": showCompany,
    "show_puncher": showPuncher,
    "show_employee": showEmployee,
  };
}

class Data {
  String type;

  Data({required this.type});

  factory Data.fromJson(Map<String, dynamic> json) => Data(type: json["type"]);

  Map<String, dynamic> toJson() => {"type": type};
}

class Message {
  String en;
  String ar;

  Message({required this.en, required this.ar});

  factory Message.fromJson(Map<String, dynamic> json) =>
      Message(en: json["en"] ?? "", ar: json["ar"] ?? "");

  Map<String, dynamic> toJson() => {"en": en, "ar": ar};
}

class Link {
  String? url;
  String label;
  bool active;

  Link({required this.url, required this.label, required this.active});

  factory Link.fromJson(Map<String, dynamic> json) =>
      Link(url: json["url"], label: json["label"], active: json["active"]);

  Map<String, dynamic> toJson() => {
    "url": url,
    "label": label,
    "active": active,
  };
}
