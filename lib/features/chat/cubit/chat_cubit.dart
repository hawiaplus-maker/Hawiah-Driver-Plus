import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:hawiah_driver/features/chat/model/chat_model.dart';
import 'package:uuid/uuid.dart';

part '../cubit/chat_state.dart';

class ChatCubit extends Cubit<ChatState> {
  ChatCubit() : super(ChatInitial());

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String? _orderId;
  StreamSubscription<QuerySnapshot>? _messageSubscription;

  /// لعرض رسائل محادثة معينة
  void initialize(String orderId) {
    if (state is ChatLoading) return;

    emit(ChatLoading());
    _orderId = orderId;

    _messageSubscription?.cancel();
    _messageSubscription = _firestore
        .collection('orders')
        .doc(orderId)
        .collection('messages')
        .orderBy('timestamp', descending: false)
        .snapshots()
        .listen(
          (snapshot) => _handleMessages(snapshot),
          onError: (error) => emit(ChatError(error.toString())),
        );
  }

  /// تحديث الرسائل عند الاستماع
  void _handleMessages(QuerySnapshot snapshot) {
    try {
      final messages =
          snapshot.docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return ChatMessageModel(
              id: doc.id,
              senderId: data['sender_id'] as String,
              message: data['message'] as String,
              timeStamp: (data['timestamp'] as Timestamp).toDate(),
              senderType: data['sender_type'] as String,
            );
          }).toList();

      emit(ChatLoaded(messages));
    } catch (e) {
      emit(ChatError('فشل قراءة الرسائل: $e'));
    }
  }

  /// إرسال رسالة وتحديث `last_message` و `last_message_time`
  Future<void> sendMessage({
    required String message,
    required String senderId,
    required String senderType,
    required String receiverId,
    required String receiverType,
    required String receiverName,
    required String receiverImage,
  }) async {
    if (_orderId == null) {
      emit(ChatError('Order ID not initialized'));
      return;
    }

    final orderRef = _firestore.collection('orders').doc(_orderId);
    final messagesRef = orderRef.collection('messages');

    try {
      final messageId = const Uuid().v4();
      await messagesRef.doc(messageId).set({
        'sender_id': senderId,
        'message': message,
        'timestamp': Timestamp.now(),
        'sender_type': senderType,
      });

      await orderRef.set({
        'last_message': message,
        'last_message_time': FieldValue.serverTimestamp(),
        'driver_id': senderType == 'driver' ? senderId : receiverId,
        'user_id': senderType == 'user' ? senderId : receiverId,
        'driver_name': senderType == 'driver' ? 'اسم السواق' : receiverName,
        'driver_image': senderType == 'driver' ? 'صورة السواق' : receiverImage,
        'user_name': senderType == 'user' ? 'اسم العميل' : receiverName,
        'user_image': senderType == 'user' ? 'صورة العميل' : receiverImage,
      }, SetOptions(merge: true));
    } catch (e) {
      emit(ChatError('فشل إرسال الرسالة: $e'));
      rethrow;
    }
  }
  StreamSubscription<QuerySnapshot>? _recentChatsSubscription;

void fetchRecentChats(String driverId) {
  emit(ChatLoading());

  _recentChatsSubscription?.cancel();
  _recentChatsSubscription = _firestore
      .collection('orders')
      .where('driver_id', isEqualTo: driverId)
      .where('last_message', isGreaterThan: '')
      .orderBy('last_message_time', descending: true)
      .snapshots()
      .listen((snapshot) {
    final chats = snapshot.docs.map((doc) {
      final data = doc.data();
      return RecentChatModel(
        orderId: doc.id,
        lastMessage: data['last_message'] ?? '',
        lastMessageTime:
            (data['last_message_time'] as Timestamp?)?.toDate(),
        receiverId: data['user_id'] ?? '',
        receiverName: data['user_name'] ?? 'عميل',
        receiverImage: data['user_image'] ?? '',
      );
    }).toList();

    emit(RecentChatsLoaded(chats));
  }, onError: (error) {
    emit(ChatError('فشل تحميل المحادثات: $error'));
  });
}


  @override
  Future<void> close() {
    _messageSubscription?.cancel();
     _recentChatsSubscription?.cancel();
    return super.close();
  }
}
