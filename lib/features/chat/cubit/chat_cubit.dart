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

  void _handleMessages(QuerySnapshot snapshot) {
    try {
      final messages = snapshot.docs.map((doc) {
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
      emit(ChatError('Failed to parse messages: $e'));
    }
  }

  Future<void> sendMessage({
    required String message,
    required String senderId,
    required String senderType,
  }) async {
    if (_orderId == null) {
      emit(ChatError('Order ID not initialized'));
      return;
    }

    try {
      final messageId = const Uuid().v4();
      await _firestore
          .collection('orders')
          .doc(_orderId)
          .collection('messages')
          .doc(messageId)
          .set({
        'sender_id': senderId,
        'message': message,
        'timestamp': Timestamp.now(),
        'sender_type': senderType,
      });
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
