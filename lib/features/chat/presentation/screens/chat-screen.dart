import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hawiah_driver/core/custom_widgets/custom_app_bar/custom_app_bar.dart';
import 'package:hawiah_driver/core/locale/app_locale_key.dart';
import 'package:hawiah_driver/core/theme/app_colors.dart';
import 'package:hawiah_driver/core/utils/navigator_methods.dart';
import 'package:hawiah_driver/features/chat/cubit/chat_cubit.dart';
import 'package:hawiah_driver/features/chat/presentation/screens/single-chat-screen.dart';
import 'package:hawiah_driver/features/profile/presentation/cubit/cubit_profile.dart';

class AllChatsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final driverId = context.read<ProfileCubit>().user.id.toString();

    return BlocProvider(
      create: (_) => ChatCubit()..fetchRecentChatsForDriver(driverId),
      child: Scaffold(
        appBar: CustomAppBar(
          context,
          title: Text(
            AppLocaleKey.chat.tr(),
            style: TextStyle(color: Colors.black),
          ),
          centerTitle: true,
        ),
        body: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: Column(
            children: [
              _buildSearchField(),
              Expanded(
                child: BlocBuilder<ChatCubit, ChatState>(
                  builder: (context, state) {
                    if (state is ChatLoading) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (state is RecentChatsLoaded) {
                      return ListView.builder(
                        itemCount: state.chats.length,
                        itemBuilder: (context, index) {
                          final chat = state.chats[index];
                          return Container(
                            color: AppColor.mainAppColor,
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundImage: NetworkImage(chat.image),
                              ),
                              title: Text(chat.name),
                              subtitle: Text(chat.lastMessage),
                              trailing: Text(
                                chat.lastMessageTime != null
                                    ? DateFormat.Hm().format(
                                      chat.lastMessageTime!,
                                    )
                                    : '',
                              ),
                              onTap: () {
                                // افتح شاشة الشات مع orderId
                                NavigatorMethods.pushNamed(
                                  context,
                                  SingleChatScreen.routeName,
                                  arguments: SingleChatScreenArgs(
                                    reciverName: 'kkk',
                                    reciverImage: '',
                                    senderId:
                                        context
                                            .read<ProfileCubit>()
                                            .user
                                            .id
                                            .toString(),
                                    senderType: "driver",
                                    orderId: chat.orderId,
                                  ),
                                );
                              },
                            ),
                          );
                        },
                      );
                    } else if (state is ChatError) {
                      return Center(child: Text(state.message));
                    } else {
                      return const SizedBox.shrink();
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchField() {
    return TextFormField(
      decoration: InputDecoration(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 10,
        ),
        hintText: AppLocaleKey.findAConversation.tr(),
        hintStyle: TextStyle(color: Color(0xff979797), fontSize: 15.sp),
        filled: true,
        fillColor: Color(0xFFF9F9F9),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(40.0),
          borderSide: BorderSide.none,
        ),
        suffixIcon: Icon(Icons.search, color: AppColor.mainAppColor, size: 25),
      ),
    );
  }

  Widget _chatItem(
    BuildContext context, {
    required String name,
    required String message,
    required String time,
    required String imageUrl,
    required VoidCallback onTap,
  }) {
    return Column(
      children: [
        ListTile(
          leading: CircleAvatar(
            backgroundImage: NetworkImage(imageUrl),
            radius: 25,
          ),
          title: Text(name, style: TextStyle(fontWeight: FontWeight.bold)),
          subtitle: Text(
            message,
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
            style: TextStyle(color: Color(0xffADB5BD), fontSize: 12.sp),
          ),
          trailing: Text(
            time,
            style: TextStyle(color: Color(0xff000912), fontSize: 12.sp),
          ),
          onTap: onTap,
        ),
        Divider(color: Colors.grey, thickness: 0.5),
      ],
    );
  }

  String _formatTime(DateTime? dateTime) {
    if (dateTime == null) return '';
    final now = DateTime.now();
    final diff = now.difference(dateTime);

    if (diff.inMinutes < 60) {
      return '${diff.inMinutes} دقيقة';
    } else if (diff.inHours < 24) {
      return '${diff.inHours} ساعة';
    } else {
      return DateFormat('dd/MM/yyyy').format(dateTime);
    }
  }
}
