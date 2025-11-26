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
    timeStamp = json['timestamp'] is Timestamp ? (json['timestamp'] as Timestamp).toDate() : null;
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

class RecentChatModel {
  final String orderId;
  final String lastMessage;
  final DateTime? lastMessageTime;
  final String receiverId;
  final String receiverName;
  final String receiverImage;
  final bool? isOnline;
  final DateTime? lastSeen;

  RecentChatModel(
      {required this.orderId,
      required this.lastMessage,
      this.lastMessageTime,
      required this.receiverId,
      required this.receiverName,
      required this.receiverImage,
      this.isOnline,
      this.lastSeen});

  factory RecentChatModel.fromJson(Map<String, dynamic> json) {
    return RecentChatModel(
      orderId: json['order_id'] ?? '',
      lastMessage: json['last_message'] ?? '',
      lastMessageTime: json['last_message_time'] != null
          ? (json['last_message_time'] as Timestamp).toDate()
          : null,
      receiverId: json['receiver_id'] ?? '',
      receiverName: json['receiver_name'] ?? '',
      receiverImage: json['receiver_image'] ?? '',
      isOnline: json['is_online'] ?? false,
      lastSeen: json['last_seen'] != null ? (json['last_seen'] as Timestamp).toDate() : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'order_id': orderId,
      'last_message': lastMessage,
      if (lastMessageTime != null) 'last_message_time': Timestamp.fromDate(lastMessageTime!),
      'receiver_id': receiverId,
      'receiver_name': receiverName,
      'receiver_image': receiverImage,
      'is_online': isOnline ?? false,
      'last_seen': lastSeen != null ? Timestamp.fromDate(lastSeen!) : null
    };
  }
}
