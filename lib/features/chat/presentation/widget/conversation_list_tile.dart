import 'package:flutter/material.dart';
import 'package:hawiah_driver/core/custom_widgets/custom_image/custom_network_image.dart';
import 'package:hawiah_driver/core/theme/app_colors.dart';
import 'package:hawiah_driver/core/theme/app_text_style.dart';
import 'package:hawiah_driver/core/utils/date_methods.dart';
import 'package:hawiah_driver/core/utils/navigator_methods.dart';
import 'package:hawiah_driver/features/chat/cubit/chat_cubit.dart';
import 'package:hawiah_driver/features/chat/model/chat_model.dart';
import 'package:hawiah_driver/features/chat/presentation/screens/single-chat-screen.dart';

class ConversationListTile extends StatelessWidget {
  const ConversationListTile({
    super.key,
    required this.chat,
    required this.userId,
    required this.chatCubit,
  });

  final RecentChatModel chat;
  final String userId;
  final ChatCubit chatCubit;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Stack(
        children: [
          CustomNetworkImage(
            imageUrl: chat.receiverImage,
            fit: BoxFit.fill,
            height: 50,
            width: 50,
            radius: 35,
          ),
          chat.isOnline == true
              ? Positioned(
                  bottom: 2,
                  left: 0,
                  child: Container(
                    width: 14,
                    height: 14,
                    decoration: BoxDecoration(
                      color: AppColor.greenColor,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColor.whiteColor, width: 1.5),
                    ),
                  ),
                )
              : SizedBox(),
        ],
      ),
      title: Text(
        chat.receiverName,
        style: AppTextStyle.text14_400,
      ),
      subtitle: Text(
        chat.lastMessage,
        style: AppTextStyle.text12_400.copyWith(
          color: AppColor.greyColor,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: Padding(
        padding: const EdgeInsets.only(bottom: 24),
        child: Text(
          chat.lastMessageTime != null ? DateMethods.timeAgo(chat.lastMessageTime, context) : '',
          style: AppTextStyle.text12_400.copyWith(
            color: AppColor.greyColor,
          ),
        ),
      ),
      onTap: () {
        NavigatorMethods.pushNamed(
          context,
          SingleChatScreen.routeName,
          arguments: SingleChatScreenArgs(
            receiverId: chat.receiverId,
            receiverType: 'driver',
            receiverName: chat.receiverName,
            receiverImage: chat.receiverImage,
            senderId: userId,
            senderType: 'user',
            orderId: chat.orderId,
            onMessageSent: () {
              chatCubit.fetchRecentChats(
                currentId: userId,
                currentType: 'user',
              );
            },
          ),
        );
      },
    );
  }
}
