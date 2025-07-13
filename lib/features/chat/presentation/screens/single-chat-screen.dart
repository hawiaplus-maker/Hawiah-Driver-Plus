import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:hawiah_driver/core/custom_widgets/custom-text-field-widget.dart';
import 'package:hawiah_driver/core/custom_widgets/custom_app_bar/custom_app_bar.dart';
import 'package:hawiah_driver/core/custom_widgets/custom_image/custom_network_image.dart';
import 'package:hawiah_driver/core/custom_widgets/custom_loading/custom_loading.dart';
import 'package:hawiah_driver/core/images/app_images.dart';
import 'package:hawiah_driver/core/locale/app_locale_key.dart';
import 'package:hawiah_driver/core/theme/app_colors.dart';
import 'package:hawiah_driver/core/utils/date_methods.dart';
import 'package:hawiah_driver/features/chat/cubit/chat_cubit.dart';
import 'package:hawiah_driver/features/chat/model/chat_model.dart';
import 'package:hawiah_driver/features/chat/presentation/widget/message_widget.dart';
import 'package:grouped_list/grouped_list.dart';

class SingleChatScreenArgs {
  final String senderId;
  final String reciverImage;
  final String reciverName;
  final String senderType;
  final String orderId;

  SingleChatScreenArgs({
    required this.senderId,
    required this.senderType,
    required this.orderId,
    required this.reciverImage,
    required this.reciverName,
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
    _chatCubit = ChatCubit();
    _chatCubit.initialize(widget.args.orderId);
    super.initState();
  }

  @override
  void dispose() {
    _chatCubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => _chatCubit,
      child: Scaffold(
        appBar: CustomAppBar(
          context,
          titleText: widget.args.reciverName,
          centerTitle: false,
          leadingWidth: 70,
          actions: [
            IconButton(
                onPressed: () => Navigator.pop(context),
                icon: RotatedBox(
                    quarterTurns: 90,
                    child: Icon(
                      Icons.arrow_back_ios_new,
                    ))),
          ],
          leading: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: CustomNetworkImage(
              imageUrl: widget.args.reciverImage,
              height: 40,
              width: 40,
              radius: 30,
              fit: BoxFit.cover,
            ),
          ),
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
                    return GroupedListView<ChatMessageModel, DateTime>(
                      elements: state.messages,
                      groupBy: (element) => DateTime(
                        element.timeStamp!.year,
                        element.timeStamp!.month,
                        element.timeStamp!.day,
                      ),
                      padding: const EdgeInsets.symmetric(
                        vertical: 10,
                        horizontal: 20,
                      ),
                      itemComparator: (item1, item2) =>
                          item1.timeStamp!.compareTo(item2.timeStamp!),
                      groupItemBuilder: (
                        context,
                        element,
                        groupStart,
                        groupEnd,
                      ) {
                        return MessageWidget(message: element);
                      },
                      groupSeparatorBuilder: (date) => Center(
                        child: Text(
                          date.day == DateTime.now().day
                              ? AppLocaleKey.today.tr()
                              : DateMethods.formatToDate(date),
                        ),
                      ),
                      separator: const SizedBox(height: 15),
                      reverse: true,
                      order: GroupedListOrder.DESC,
                    );
                  } else {
                    return const SizedBox();
                  }
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Expanded(
                      child: CustomTextField(
                          unFocusColor: AppColor.grayBlueColor.withAlpha(100),
                          fillColor: AppColor.grayBlueColor,
                          controller: _messageEC)),
                  IconButton(
                    onPressed: () {
                      final txt = _messageEC.text;
                      if (txt.isNotEmpty) {
                        _chatCubit.sendMessage(
                          message: txt,
                          senderId: widget.args.senderId,
                          senderType: widget.args.senderType,
                        );
                      }
                      _messageEC.clear();
                    },
                    icon: SvgPicture.asset(AppImages.sendIcon),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
