import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gap/gap.dart';
import 'package:hawiah_driver/core/custom_widgets/custom_app_bar/custom_app_bar.dart';
import 'package:hawiah_driver/core/custom_widgets/custom_image/custom_network_image.dart';
import 'package:hawiah_driver/core/extension/context_extension.dart';
import 'package:hawiah_driver/core/images/app_images.dart';
import 'package:hawiah_driver/core/locale/app_locale_key.dart';
import 'package:hawiah_driver/core/theme/app_colors.dart';
import 'package:hawiah_driver/core/theme/app_text_style.dart';
import 'package:hawiah_driver/core/utils/date_methods.dart';
import 'package:hawiah_driver/features/chat/presentation/screens/single-chat-screen.dart';

class SingleChatAppBar extends StatelessWidget {
  const SingleChatAppBar({
    super.key,
    required this.widget,
  });

  final SingleChatScreen widget;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance.collection('orders').doc(widget.args.orderId).snapshots(),
      builder: (context, snapshot) {
        String statusText = '';

        if (snapshot.hasData && snapshot.data!.exists) {
          final data = snapshot.data!.data() as Map<String, dynamic>;

          final receiverType = widget.args.receiverType;

          final bool isOnline = data['${receiverType}_isOnline'] ?? false;
          final lastSeen = (data['${receiverType}_lastSeen'] as Timestamp?)?.toDate();

          if (isOnline) {
            statusText = AppLocaleKey.connected.tr();
          } else if (lastSeen != null) {
            statusText = '${AppLocaleKey.lastseen.tr()} ${DateMethods.formatToTime(lastSeen)}';
          } else {
            statusText = AppLocaleKey.notconnected.tr();
          }
        }

        return CustomAppBar(
          appBarColor: AppColor.whiteColor,
          context,
          title: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Stack(
                children: [
                  CustomNetworkImage(
                    imageUrl: widget.args.receiverImage,
                    height: 40,
                    width: 40,
                    radius: 30,
                    fit: BoxFit.cover,
                  ),
                  if (snapshot.hasData &&
                      snapshot.data!.data() != null &&
                      (snapshot.data!.data()
                              as Map<String, dynamic>)['${widget.args.receiverType}_isOnline'] ==
                          true)
                    Positioned(
                      bottom: 8,
                      right: 12,
                      child: Container(
                        height: 12,
                        width: 12,
                        decoration: BoxDecoration(
                          color: Colors.green,
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColor.whiteColor, width: 2),
                        ),
                      ),
                    ),
                ],
              ),
              Gap(5),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.args.receiverName,
                    style: AppTextStyle.text14_400.copyWith(fontFamily: context.fontFamily()),
                  ),
                  if (statusText.isNotEmpty)
                    Text(
                      statusText,
                      style: AppTextStyle.text12_400
                          .copyWith(color: Colors.grey, fontFamily: context.fontFamily()),
                    ),
                ],
              ),
            ],
          ),
          centerTitle: false,
          leadingWidth: 70,
          actions: [
            IconButton(
              onPressed: () {},
              icon: SvgPicture.asset(AppImages.phoneCallIcon),
            ),
            IconButton(
              onPressed: () {},
              icon: SvgPicture.asset(AppImages.videoCallIcon),
            ),
            IconButton(
              onPressed: () {},
              icon: Icon(Icons.more_vert, color: AppColor.lightGreyColor),
            ),
          ],
        );
      },
    );
  }
}
