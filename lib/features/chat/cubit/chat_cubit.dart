import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
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

  /// لعرض جميع المحادثات السابقة الخاصة بالسائق
  Future<void> fetchRecentChatsForDriver(String driverId) async {
    emit(ChatLoading());

    try {
      final querySnapshot =
          await _firestore
              .collection('orders')
              .where('participants', arrayContains: driverId) // ← هنا
              .orderBy('last_message_time', descending: true)
              .get();

      final chats =
          querySnapshot.docs.map((doc) {
            final data = doc.data();
            return RecentChat(
              orderId: doc.id,
              name: data['user'] ?? '',
              image: data['userImage'] ?? '',
              lastMessage: data['last_message'] ?? '',
              lastMessageTime:
                  (data['last_message_time'] as Timestamp?)?.toDate(),
            );
          }).toList();

      emit(RecentChatsLoaded(chats));
    } catch (e) {
      emit(ChatError('فشل تحميل المحادثات: $e'));
    }
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
  }) async {
    if (_orderId == null) {
      emit(ChatError('Order ID not initialized'));
      return;
    }

    final orderRef = _firestore.collection('orders').doc(_orderId);
    final messagesRef = orderRef.collection('messages');

    try {
      // 1) أرسل الرسالة في الـ subcollection
      final messageId = const Uuid().v4();
      await messagesRef.doc(messageId).set({
        'sender_id': senderId,
        'message': message,
        'timestamp': Timestamp.now(),
        'sender_type': senderType,
      });

      // 2) حدّث أو أنشئ وثيقة الـ order مع بيانات آخر رسالة
      await orderRef.set({
        'last_message': message,
        'last_message_time': FieldValue.serverTimestamp(),
        'last_sender_id': senderId,
        'last_sender_type': senderType,
      }, SetOptions(merge: true));

      // 3) إذا كنت تستخدم participants مثلاً:
      // await orderRef.set({
      //   'participants': FieldValue.arrayUnion([senderId]),
      // }, SetOptions(merge: true));
    } catch (e) {
      debugPrint('Error sending message: $e');
      emit(ChatError('Failed to send message: $e'));
      rethrow;
    }
  }

  @override
  Future<void> close() {
    _messageSubscription?.cancel();
    return super.close();
  }
}
