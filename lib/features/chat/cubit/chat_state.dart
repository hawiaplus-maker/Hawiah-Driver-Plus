part of 'chat_cubit.dart';

abstract class ChatState extends Equatable {
  const ChatState();

  @override
  List<Object> get props => [];
}

class ChatInitial extends ChatState {}

class ChatLoading extends ChatState {}

class ChatEmpty extends ChatState {}

class ChatLoaded extends ChatState {
  final List<ChatMessageModel> messages;

  const ChatLoaded(this.messages);

  @override
  List<Object> get props => [messages];
}

class ChatError extends ChatState {
  final String message;

  const ChatError(this.message);

  @override
  List<Object> get props => [message];
}

class RecentChatsLoaded extends ChatState {
  final List<RecentChatModel> chats;

  RecentChatsLoaded(this.chats);
}

class OrdersStatusLoaded extends ChatState {
  final List<Map<String, dynamic>> statuses;

  OrdersStatusLoaded(this.statuses);

  @override
  List<Object> get props => [statuses];
}
