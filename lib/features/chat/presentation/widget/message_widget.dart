import 'package:flutter/material.dart';
import 'package:hawiah_driver/core/theme/app_colors.dart';
import 'package:hawiah_driver/core/theme/app_text_style.dart';
import 'package:hawiah_driver/core/utils/date_methods.dart';
import 'package:hawiah_driver/features/chat/model/chat_model.dart';
import 'package:hawiah_driver/features/profile/presentation/cubit/cubit_profile.dart';

import 'package:provider/provider.dart';

class MessageWidget extends StatelessWidget {
  const MessageWidget({super.key, required this.message});
  final ChatMessageModel message;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: int.tryParse(message.senderId.toString()) ==
              context.read<ProfileCubit>().user.id
          ? TextDirection.rtl
          : TextDirection.ltr,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  // int.tryParse(message.senderId.toString()) ==
                  //         context.read<ProfileCubit>().user.id
                  //     ? Positioned(
                  //       bottom: 0,
                  //       right: -14,
                  //       child: CustomPaint(
                  //         size: const Size(14, 15),
                  //         painter: MeTrianglePainter(
                  //           color: AppColor.greyColor.withOpacity(.100),
                  //         ),
                  //       ),
                  //     )
                  //     : Positioned(
                  //       bottom: 0,
                  //       left: -14,
                  //       child: CustomPaint(
                  //         size: const Size(14, 15),
                  //         painter: TrianglePainter(
                  //           color: AppColor.mainAppColor.withOpacity(.100),
                  //         ),
                  //       ),
                  //     ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 12,
                      horizontal: 15,
                    ),
                    decoration: BoxDecoration(
                        color: int.tryParse(message.senderId.toString()) ==
                                context.read<ProfileCubit>().user.id
                            ? AppColor.blueColor
                            : AppColor.whiteColor,
                        borderRadius: BorderRadius.only(
                          topLeft: const Radius.circular(20),
                          topRight: const Radius.circular(20),
                          bottomLeft: Radius.circular(
                            int.tryParse(message.senderId.toString()) ==
                                    context.read<ProfileCubit>().user.id
                                ? 20
                                : 0,
                          ),
                          bottomRight: Radius.circular(
                            int.tryParse(message.senderId.toString()) ==
                                    context.read<ProfileCubit>().user.id
                                ? 0
                                : 20,
                          ),
                        ),
                        boxShadow: [
                          int.tryParse(message.senderId.toString()) ==
                                  context.read<ProfileCubit>().user.id
                              ? BoxShadow()
                              : BoxShadow(
                                  color: AppColor.lightGreyColor,
                                  spreadRadius: 5,
                                  blurRadius: 7,
                                  offset: const Offset(0, 3),
                                ),
                        ]),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          message.message ?? "",
                          maxLines: 5,
                          style: int.tryParse(message.senderId.toString()) ==
                                  context.read<ProfileCubit>().user.id
                              ? AppTextStyle.text14_500
                                  .copyWith(color: AppColor.whiteColor)
                              : AppTextStyle.text14_500,
                        ),
                        Text(
                          DateMethods.formatToTime(message.timeStamp),
                          style: int.tryParse(message.senderId.toString()) ==
                                  context.read<ProfileCubit>().user.id
                              ? AppTextStyle.text10_400
                                  .copyWith(color: AppColor.whiteColor)
                              : AppTextStyle.text10_400.copyWith(
                                  color: AppColor.textSecondaryColor,
                                ),
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    left: int.tryParse(message.senderId.toString()) ==
                            context.read<ProfileCubit>().user.id
                        ? 0
                        : -20,
                    right: int.tryParse(message.senderId.toString()) ==
                            context.read<ProfileCubit>().user.id
                        ? -20
                        : 0,
                    bottom: -30,
                    child: const Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class TrianglePainter extends CustomPainter {
  TrianglePainter({this.color});
  final Color? color;
  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color ?? Colors.white // Change color as needed
      ..style = PaintingStyle.fill;

    final path = Path();
    path.moveTo(0, size.height);
    path.lineTo(size.width, size.height);
    path.lineTo(size.width, 0);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(TrianglePainter oldDelegate) {
    return false;
  }
}

class MeTrianglePainter extends CustomPainter {
  MeTrianglePainter({this.color});
  final Color? color;
  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color ?? Colors.white // Change color as needed
      ..style = PaintingStyle.fill;

    final path = Path();
    path.moveTo(0, 0);
    path.lineTo(0, size.height);
    path.lineTo(size.width, size.height);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(MeTrianglePainter oldDelegate) {
    return false;
  }
}
