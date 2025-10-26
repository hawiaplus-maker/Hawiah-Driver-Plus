import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hawiah_driver/core/locale/app_locale_key.dart';
import 'package:hawiah_driver/core/theme/app_colors.dart';
import 'package:hawiah_driver/core/theme/app_text_style.dart';
import 'package:hawiah_driver/core/utils/date_methods.dart';
import 'package:hawiah_driver/features/notifications/presentation/cubit/notifications_cubit.dart';
import 'package:hawiah_driver/features/notifications/presentation/cubit/notifications_state.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  @override
  initState() {
    context.read<NotificationsCubit>().getnotifications();
    super.initState();
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
        ),
        title: Text(
          AppLocaleKey.notifications.tr(),
          style: AppTextStyle.text20_700,
        ),
        centerTitle: true,
      ),
      body: BlocBuilder<NotificationsCubit, NotificationsState>(
        builder: (context, state) {
          final cubit = context.read<NotificationsCubit>();
          final notifications = cubit.setting?.notifications.data;

          if (state is NotificationsLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is NotificationsUpdate) {
            if (notifications == null || notifications.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/images/empty_notifications.png',
                      height: 80,
                      width: 80,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      AppLocaleKey.noNotifications.tr(),
                      style: AppTextStyle.text16_600,
                    ),
                  ],
                ),
              );
            }

            return ListView.builder(
              itemCount: notifications.length,
              itemBuilder: (context, index) {
                final item = notifications[index];
                final locale = context.locale.languageCode;

                final title = locale == 'ar' ? item.title.ar : item.title.en;
                final message =
                    locale == 'ar' ? item.message.ar : item.message.en;

                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Card(
                    elevation: 5,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    child: ListTile(
                      leading: Image.asset(
                        'assets/images/notification.png',
                        height: 25.h,
                        width: 25.w,
                        color: AppColor.mainAppColor,
                      ),
                      title: Text(title, style: AppTextStyle.text16_700),
                      subtitle: Text(message, style: AppTextStyle.text14_400),
                      trailing: Text(
                        DateMethods.formatToDate(item.createdAt),
                        style: AppTextStyle.text12_400,
                      ),
                    ),
                  ),
                );
              },
            );
          }

          return const SizedBox();
        },
      ),
    );
  }
}
