import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collection/collection.dart';

class ChatMessageModel {
  String? id;
  String? message;
  String? senderId;
  String? senderType;
  DateTime? timeStamp;

  ChatMessageModel({
    this.id,
    this.message,
    this.senderId,
    this.senderType,
    this.timeStamp,
  });

  ChatMessageModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    message = json['message'];
    senderId = json['sender_id'];
    senderType = json['sender_type'];
    timeStamp = json['timestamp'] is Timestamp
        ? (json['timestamp'] as Timestamp).toDate()
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (id != null) data['id'] = id;
    if (message != null) data['message'] = message;
    if (senderId != null) data['sender_id'] = senderId;
    if (senderType != null) data['sender_type'] = senderType;
    if (timeStamp != null) data['timestamp'] = Timestamp.fromDate(timeStamp!);
    return data;
  }
}
enum ChatMessageTypeEnum {
  text(0);

  final int value;
  const ChatMessageTypeEnum(this.value);
  static ChatMessageTypeEnum? getByValue(int? i) {
    return ChatMessageTypeEnum.values.firstWhereOrNull((x) => x.value == i);
  }
}