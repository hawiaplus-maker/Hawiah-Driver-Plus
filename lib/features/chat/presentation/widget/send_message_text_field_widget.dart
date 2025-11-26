import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:hawiah_driver/core/custom_widgets/custom-text-field-widget.dart';
import 'package:hawiah_driver/core/images/app_images.dart';
import 'package:hawiah_driver/core/locale/app_locale_key.dart';
import 'package:hawiah_driver/core/theme/app_colors.dart';
import 'package:hawiah_driver/features/chat/cubit/chat_cubit.dart';
import 'package:hawiah_driver/features/chat/presentation/screens/single-chat-screen.dart';

class SendMessageTextField extends StatelessWidget {
  const SendMessageTextField({
    super.key,
    required TextEditingController messageEC,
    required ChatCubit chatCubit,
    required this.widget,
  })  : _messageEC = messageEC,
        _chatCubit = chatCubit;

  final TextEditingController _messageEC;
  final ChatCubit _chatCubit;
  final SingleChatScreen widget;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: true,
      child: Column(
        children: [
          Divider(
            color: AppColor.lightGreyColor.withAlpha(100),
            thickness: 0.5,
            height: 0.5,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 5),
            child: Row(
              children: [
                Expanded(
                  child: CustomTextField(
                    unFocusColor: AppColor.grayBlueColor.withAlpha(100),
                    fillColor: AppColor.grayBlueColor,
                    controller: _messageEC,
                    hintText: AppLocaleKey.messageHint.tr(),
                  ),
                ),
                IconButton(
                  onPressed: () {
                    final txt = _messageEC.text;
                    if (txt.isNotEmpty) {
                      _chatCubit.sendMessage(
                        message: txt,
                        senderId: widget.args.senderId,
                        senderType: widget.args.senderType,
                        receiverId: widget.args.receiverId,
                        receiverType: widget.args.receiverType,
                        receiverName: widget.args.receiverName,
                        receiverImage: widget.args.receiverImage,
                      );
                    }
                    _messageEC.clear();
                  },
                  icon: Container(
                      height: 40,
                      width: 40,
                      decoration: BoxDecoration(
                        color: AppColor.mainAppColor,
                        shape: BoxShape.circle,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            AppImages.sends,
                            height: 20,
                            width: 20,
                            color: AppColor.whiteColor,
                          ),
                        ],
                      )),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
