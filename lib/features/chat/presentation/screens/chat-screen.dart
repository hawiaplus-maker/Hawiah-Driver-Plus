import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hawiah_driver/core/custom_widgets/custom_app_bar/custom_app_bar.dart';
import 'package:hawiah_driver/core/custom_widgets/custom_image/custom_network_image.dart';
import 'package:hawiah_driver/core/locale/app_locale_key.dart';
import 'package:hawiah_driver/core/theme/app_colors.dart';
import 'package:hawiah_driver/core/theme/app_text_style.dart';
import 'package:hawiah_driver/core/utils/date_methods.dart';
import 'package:hawiah_driver/core/utils/navigator_methods.dart';
import 'package:hawiah_driver/features/chat/cubit/chat_cubit.dart';
import 'package:hawiah_driver/features/chat/presentation/screens/single-chat-screen.dart';
import 'package:hawiah_driver/features/profile/presentation/cubit/cubit_profile.dart';

class AllChatsScreen extends StatefulWidget {
  @override
  State<AllChatsScreen> createState() => _AllChatsScreenState();
}

class _AllChatsScreenState extends State<AllChatsScreen> {
  late ChatCubit chatCubit;
  late String driverId;

  @override
  void initState() {
    super.initState();
    driverId = context.read<ProfileCubit>().user.id.toString();
    chatCubit = ChatCubit();
    chatCubit.fetchRecentChats(driverId);
  }

  @override
  void dispose() {
    chatCubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: chatCubit,
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

                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            child: Card(
                              elevation: 2,
                              color: AppColor.whiteColor,
                              child: ListTile(
                                leading: CircleAvatar(
                                  child: CustomNetworkImage(
                                    imageUrl: chat.receiverImage,
                                    fit: BoxFit.fill,
                                  ),
                                ),
                                title: Text(
                                  chat.receiverName,
                                  style: AppTextStyle.text18_700,
                                ),
                                subtitle: Text(
                                  chat.lastMessage,
                                  style: AppTextStyle.text16_500,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                trailing: Text(
                                  chat.lastMessageTime != null
                                      ? DateMethods.formatToTime(
                                        chat.lastMessageTime,
                                      )
                                      : '',
                                ),
                                onTap: () async {
                                  NavigatorMethods.pushNamed(
                                    context,
                                    SingleChatScreen.routeName,
                                    arguments: SingleChatScreenArgs(
                                      reciverId: chat.receiverId,
                                      reciverType: "user",
                                      reciverName: chat.receiverName,
                                      reciverImage: chat.receiverImage,
                                      senderId:
                                          context
                                              .read<ProfileCubit>()
                                              .user
                                              .id
                                              .toString(),
                                      senderType: "driver",
                                      orderId: chat.orderId,
                                      onMessageSent: () {
                                        context
                                            .read<ChatCubit>()
                                            .fetchRecentChats(driverId);
                                      },
                                    ),
                                  );
                                },
                              ),
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
}
