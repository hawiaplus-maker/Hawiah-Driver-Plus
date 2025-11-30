import 'dart:developer';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:hawiah_driver/core/custom_widgets/custom-text-field-widget.dart';
import 'package:hawiah_driver/core/custom_widgets/custom_app_bar/custom_app_bar.dart';
import 'package:hawiah_driver/core/custom_widgets/custom_loading/custom_loading.dart';
import 'package:hawiah_driver/core/hive/hive_methods.dart';
import 'package:hawiah_driver/core/images/app_images.dart';
import 'package:hawiah_driver/core/locale/app_locale_key.dart';
import 'package:hawiah_driver/core/theme/app_colors.dart';
import 'package:hawiah_driver/core/theme/app_text_style.dart';
import 'package:hawiah_driver/core/utils/navigator_methods.dart';
import 'package:hawiah_driver/features/authentication/presentation/dialog/unauthenticated_dialog.dart';
import 'package:hawiah_driver/features/chat/cubit/chat_cubit.dart';
import 'package:hawiah_driver/features/chat/model/chat_model.dart';
import 'package:hawiah_driver/features/chat/presentation/widget/conversation_list_tile.dart';
import 'package:hawiah_driver/features/profile/presentation/cubit/cubit_profile.dart';
import 'package:hawiah_driver/injection_container.dart';

class AllChatsScreen extends StatefulWidget {
  const AllChatsScreen({super.key});
  static const String routeName = '/AllChatsScreen';
  @override
  State<AllChatsScreen> createState() => _AllChatsScreenState();
}

class _AllChatsScreenState extends State<AllChatsScreen> {
  late ChatCubit chatCubit;
  late String userId;
  final TextEditingController _searchController = TextEditingController();
  List<RecentChatModel> _allChats = [];
  List<RecentChatModel> _filteredChats = [];
  bool isVesetor = false;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (HiveMethods.isVisitor() || HiveMethods.getToken() == null) {
      log(HiveMethods.isVisitor().toString());
      log(HiveMethods.getToken().toString());
      isVesetor = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        NavigatorMethods.showAppDialog(context, UnauthenticatedDialog());
      });
    } else {
      userId = sl<ProfileCubit>().user!.id.toString();
      chatCubit = ChatCubit();
      chatCubit.fetchRecentChats(
        currentId: userId,
        currentType: 'driver',
      );
    }
  }

  @override
  void dispose() {
    if (!isVesetor) {
      chatCubit.close();
    }
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredChats = List.from(_allChats);
      } else {
        _filteredChats = _allChats.where((chat) {
          final name = chat.receiverName.toLowerCase();
          final id = chat.orderId.toLowerCase();
          return name.contains(query) || id.contains(query);
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isVesetor) {
      return EmptyChatWidget();
    }
    return BlocProvider.value(
      value: chatCubit,
      child: Scaffold(
        extendBody: true,
        appBar: CustomAppBar(
          context,
          titleText: AppLocaleKey.chat.tr(),
          centerTitle: true,
        ),
        body: Padding(
          padding: EdgeInsets.symmetric(horizontal: 18),
          child: Column(
            children: [
              BlocBuilder<ChatCubit, ChatState>(
                builder: (context, state) {
                  if (state is RecentChatsLoaded) {
                    return _buildSearchField();
                  }
                  return const SizedBox();
                },
              ),
              Gap(10.h),
              Divider(color: Colors.grey.shade300),
              Expanded(
                child: BlocListener<ChatCubit, ChatState>(
                  listener: (context, state) {
                    if (state is RecentChatsLoaded) {
                      _allChats = state.chats;
                      _filteredChats = List.from(_allChats);
                    }
                  },
                  child: BlocBuilder<ChatCubit, ChatState>(
                    builder: (context, state) {
                      if (state is ChatLoading) {
                        return const Center(child: CustomLoading());
                      } else if (state is RecentChatsLoaded) {
                        final chats = _filteredChats;
                        return ListView.separated(
                          separatorBuilder: (context, index) =>
                              Divider(color: Colors.grey.shade300),
                          itemCount: chats.length,
                          itemBuilder: (context, index) {
                            final chat = chats[index];
                            return ConversationListTile(
                                chat: chat, userId: userId, chatCubit: chatCubit);
                          },
                        );
                      } else if (state is ChatEmpty) {
                        return EmptyChatWidget();
                      } else if (state is ChatError) {
                        return Center(child: Text(state.message));
                      } else {
                        return const SizedBox.shrink();
                      }
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchField() {
    return Material(
      elevation: 4,
      shadowColor: Colors.black26,
      borderRadius: BorderRadius.circular(12),
      child: CustomTextField(
        controller: _searchController,
        hintText: AppLocaleKey.findAConversation.tr(),
        hintStyle: TextStyle(color: const Color(0xff979797), fontSize: 15.sp),
        fillColor: AppColor.whiteColor,
        prefixIcon: Icon(Icons.search, color: AppColor.mainAppColor, size: 25),
      ),
    );
  }
}

class EmptyChatWidget extends StatelessWidget {
  const EmptyChatWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(AppImages.noChatIcon),
          Text(
            AppLocaleKey.noChatyet.tr(),
            style: AppTextStyle.text20_500,
          ),
        ],
      ),
    );
  }
}
