import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hawiah_driver/core/custom_widgets/custom_loading/custom_loading.dart';
import 'package:hawiah_driver/features/chat/cubit/chat_cubit.dart';
import 'package:hawiah_driver/features/chat/presentation/widget/chat_grouped_list_view.dart';
import 'package:hawiah_driver/features/chat/presentation/widget/send_message_text_field_widget.dart';
import 'package:hawiah_driver/features/chat/presentation/widget/single_chat_app_bar.dart';

class SingleChatScreenArgs {
  final String senderId;
  final String receiverId;
  final String receiverImage;
  final String receiverName;
  final String senderType;
  final String receiverType;
  final String orderId;
  final VoidCallback onMessageSent;

  SingleChatScreenArgs({
    required this.senderId,
    required this.senderType,
    required this.orderId,
    required this.receiverImage,
    required this.receiverName,
    required this.receiverId,
    required this.receiverType,
    required this.onMessageSent,
  });
}

class SingleChatScreen extends StatefulWidget {
  final SingleChatScreenArgs args;
  static const routeName = 'ChatScreen';

  const SingleChatScreen({super.key, required this.args});

  @override
  State<SingleChatScreen> createState() => _SingleChatScreenState();
}

class _SingleChatScreenState extends State<SingleChatScreen> {
  final _messageEC = TextEditingController();
  late ChatCubit _chatCubit;

  @override
  void initState() {
    super.initState();
    _chatCubit = ChatCubit();
    _chatCubit.initialize(widget.args.orderId);

    _chatCubit.updateUserStatus(
      orderId: widget.args.orderId,
      userType: widget.args.senderType,
      isOnline: true,
    );
  }

  @override
  void dispose() {
    _chatCubit.updateUserStatus(
      orderId: widget.args.orderId,
      userType: widget.args.senderType,
      isOnline: false,
    );
    _chatCubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) {
          widget.args.onMessageSent.call();
        }
      },
      child: BlocProvider(
        create: (context) => _chatCubit,
        child: Scaffold(
          appBar: PreferredSize(
            preferredSize: const Size.fromHeight(70),
            child: SingleChatAppBar(widget: widget),
          ),
          body: Column(
            children: [
              Expanded(
                child: BlocBuilder<ChatCubit, ChatState>(
                  builder: (context, state) {
                    if (state is ChatLoading) {
                      return const Center(child: CustomLoading());
                    } else if (state is ChatError) {
                      return Center(child: Text(state.message));
                    } else if (state is ChatLoaded) {
                      return SingleChatGroupedListView(
                        state: state.messages,
                      );
                    } else {
                      return const SizedBox();
                    }
                  },
                ),
              ),
              SendMessageTextField(messageEC: _messageEC, chatCubit: _chatCubit, widget: widget),
            ],
          ),
        ),
      ),
    );
  }
}
