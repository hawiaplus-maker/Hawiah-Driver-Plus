import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:grouped_list/grouped_list.dart';
import 'package:hawiah_driver/core/locale/app_locale_key.dart';
import 'package:hawiah_driver/core/theme/app_colors.dart';
import 'package:hawiah_driver/core/theme/app_text_style.dart';
import 'package:hawiah_driver/core/utils/date_methods.dart';
import 'package:hawiah_driver/features/chat/model/chat_model.dart';
import 'package:hawiah_driver/features/chat/presentation/widget/message_widget.dart';

class SingleChatGroupedListView extends StatelessWidget {
  const SingleChatGroupedListView({
    super.key,
    required this.state,
  });
  final List<ChatMessageModel> state;
  @override
  Widget build(BuildContext context) {
    return GroupedListView<ChatMessageModel, DateTime>(
      elements: state,
      groupBy: (element) => DateTime(
        element.timeStamp!.year,
        element.timeStamp!.month,
        element.timeStamp!.day,
      ),
      padding: const EdgeInsets.symmetric(
        vertical: 10,
        horizontal: 20,
      ),
      itemComparator: (item1, item2) => item1.timeStamp!.compareTo(item2.timeStamp!),
      groupItemBuilder: (
        context,
        element,
        groupStart,
        groupEnd,
      ) {
        return MessageWidget(message: element);
      },
      groupSeparatorBuilder: (date) => Center(
        child: Card(
          elevation: 5,
          color: AppColor.whiteColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
            child: Text(
              date.day == DateTime.now().day
                  ? AppLocaleKey.today.tr()
                  : DateMethods.formatToFullData(date),
              style: AppTextStyle.text12_500,
            ),
          ),
        ),
      ),
      separator: const SizedBox(height: 15),
      reverse: true,
      order: GroupedListOrder.DESC,
    );
  }
}
