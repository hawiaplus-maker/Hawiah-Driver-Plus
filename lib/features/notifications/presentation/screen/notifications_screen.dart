import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:hawiah_driver/core/custom_widgets/custom-text-field-widget.dart';
import 'package:hawiah_driver/core/custom_widgets/custom_app_bar/custom_app_bar.dart';
import 'package:hawiah_driver/core/custom_widgets/custom_loading/custom_loading.dart';
import 'package:hawiah_driver/core/images/app_images.dart';
import 'package:hawiah_driver/core/locale/app_locale_key.dart';
import 'package:hawiah_driver/core/theme/app_colors.dart';
import 'package:hawiah_driver/core/theme/app_text_style.dart';
import 'package:hawiah_driver/features/notifications/presentation/cubit/notifications_cubit.dart';
import 'package:hawiah_driver/features/notifications/presentation/cubit/notifications_state.dart';
import 'package:hawiah_driver/features/notifications/presentation/widget/notification_widget.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final TextEditingController _searchController = TextEditingController();
  String? _searchQuery;
  int? _seen;

  @override
  void initState() {
    super.initState();

    context.read<NotificationsCubit>().getnotifications();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        context,
        appBarColor: AppColor.whiteColor,
        titleText: AppLocaleKey.notifications.tr(),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          children: [
            Material(
              elevation: 4,
              shadowColor: Colors.black26,
              borderRadius: BorderRadius.circular(12),
              child: CustomTextField(
                controller: _searchController,
                fillColor: AppColor.whiteColor,
                hintText: AppLocaleKey.search.tr(),
                prefixIcon: Padding(
                  padding: const EdgeInsets.all(10),
                  child: SvgPicture.asset(
                    AppImages.search,
                    color: AppColor.mainAppColor,
                    height: 16,
                    width: 16,
                  ),
                ),
                onChanged: (value) {
                  setState(() => _searchQuery = value.trim());
                  context.read<NotificationsCubit>().getnotifications(
                        search: value.trim(),
                        seen: _seen,
                      );
                },
                suffixIcon: PopupMenuButton<int?>(
                  color: AppColor.whiteColor,
                  elevation: 4,
                  icon: Padding(
                    padding: const EdgeInsets.all(10),
                    child: SvgPicture.asset(
                      AppImages.filter,
                      color: AppColor.mainAppColor,
                      height: 16,
                      width: 16,
                    ),
                  ),
                  onSelected: (value) {
                    setState(() => _seen = value);
                    context.read<NotificationsCubit>().getnotifications(
                          search: _searchQuery,
                          seen: _seen,
                        );
                  },
                  itemBuilder: (context) => [
                    PopupMenuItem<int?>(
                      value: 0,
                      child: Builder(builder: (context) {
                        return Row(
                          children: [
                            SvgPicture.asset(AppImages.megaphoneoff),
                            const SizedBox(width: 10),
                            Text(
                              AppLocaleKey.unread.tr(),
                              style: AppTextStyle.text18_500.copyWith(color: AppColor.mainAppColor),
                            ),
                          ],
                        );
                      }),
                    ),
                    PopupMenuItem<int?>(
                      value: 1,
                      child: Builder(builder: (context) {
                        return Row(
                          children: [
                            SvgPicture.asset(AppImages.megaphone),
                            const SizedBox(width: 10),
                            Text(
                              AppLocaleKey.read.tr(),
                              style: AppTextStyle.text18_500,
                            ),
                          ],
                        );
                      }),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: BlocBuilder<NotificationsCubit, NotificationsState>(
                builder: (context, state) {
                  final cubit = context.read<NotificationsCubit>();
                  final notifications = cubit.setting?.notifications ?? [];
                  final locale = context.locale.languageCode;

                  final filteredNotifications = notifications.where((item) {
                    final title =
                        (locale == 'ar' ? item.title?.ar : item.title?.en)?.toLowerCase() ?? "";
                    final message =
                        (locale == 'ar' ? item.message?.ar : item.message?.en)?.toLowerCase() ?? "";
                    final query = _searchQuery?.toLowerCase();
                    return title.contains(query ?? "") || message.contains(query ?? "");
                  }).toList();

                  if (state is NotificationsLoading) {
                    return const Center(child: CustomLoading());
                  }

                  if (state is NotificationsUpdate) {
                    if (notifications.isEmpty) return _buildEmptyState();

                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8.0),
                      child: Column(
                        children: [
                          const SizedBox(height: 10),
                          Divider(thickness: 1, color: Colors.grey.shade300),
                          Expanded(
                            child: filteredNotifications.isEmpty
                                ? _buildEmptyState()
                                : RefreshIndicator(
                                    onRefresh: () async {
                                      await cubit.getnotifications(
                                        search: _searchQuery,
                                      );
                                    },
                                    child: ListView.separated(
                                      itemCount: filteredNotifications.length,
                                      itemBuilder: (context, index) {
                                        final item = filteredNotifications[index];
                                        return NotificationWidget(item: item);
                                      },
                                      separatorBuilder: (context, index) => Divider(
                                        height: 1,
                                        color: AppColor.greyColor.withOpacity(0.2),
                                      ),
                                    ),
                                  ),
                          ),
                        ],
                      ),
                    );
                  }

                  return const SizedBox();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(AppImages.notification, height: 80, width: 80),
            const SizedBox(height: 16),
            Text(AppLocaleKey.noNotifications.tr(), style: AppTextStyle.text20_500),
          ],
        ),
      );
}
