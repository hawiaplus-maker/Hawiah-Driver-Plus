import 'dart:developer'; // للإضافة logging

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:hawiah_driver/core/custom_widgets/custom_button.dart';
import 'package:hawiah_driver/core/custom_widgets/custom_loading/custom_shimmer.dart';
import 'package:hawiah_driver/core/images/app_images.dart';
import 'package:hawiah_driver/core/locale/app_locale_key.dart';
import 'package:hawiah_driver/core/theme/app_colors.dart';
import 'package:hawiah_driver/core/theme/app_text_style.dart';
import 'package:hawiah_driver/features/order/presentation/screens/current-order-screen.dart';
import 'package:hawiah_driver/features/order/presentation/screens/old-order-screen.dart';
import 'package:hawiah_driver/features/order/presentation/widget/order_card_widget.dart';

import '../order-cubit/order-cubit.dart';
import '../order-cubit/order-state.dart';

class OrderTapList extends StatefulWidget {
  const OrderTapList({super.key, required this.isCurrent});

  final bool isCurrent;

  @override
  State<OrderTapList> createState() => _OrderTapListState();
}

class _OrderTapListState extends State<OrderTapList> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    final cubit = context.read<OrderCubit>();
    final bool isLoadingMore =
        widget.isCurrent ? cubit.isLoadingMoreCurrent : cubit.isLoadingMoreOld;
    final bool canLoadMore = widget.isCurrent ? cubit.canLoadMoreCurrent : cubit.canLoadMoreOld;
    final int currentPage = widget.isCurrent ? cubit.currentPageCurrent : cubit.currentPageOld;

    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 150 &&
        canLoadMore &&
        !isLoadingMore) {
      cubit.getOrders(
        orderStatus: widget.isCurrent ? 0 : 1,
        page: currentPage + 1,
        isLoadMore: true,
      );
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // نستخدم BlocBuilder ليعيد بناء الواجهة عند كل تغيير في الحالة
    return BlocBuilder<OrderCubit, OrderState>(
      builder: (context, state) {
        final cubit = context.read<OrderCubit>();

        // جلب القائمة الصحيحة بناءً على التاب
        final orders = widget.isCurrent ? cubit.currentOrders : cubit.oldOrders;

        // التحقق مما إذا كان هناك تحميل جاري *لهذا التاب تحديداً*
        // هذا أهم جزء لتجنب عرض "لا توجد بيانات" أثناء التحميل
        final bool isThisListLoading =
            widget.isCurrent ? cubit.isLoadingCurrent : cubit.isLoadingOld;
        final bool isPaginating =
            widget.isCurrent ? cubit.isLoadingMoreCurrent : cubit.isLoadingMoreOld;

        // للتشخيص (يمكنك حذفه لاحقاً)
        log("Tab Current: ${widget.isCurrent}, Loading: $isThisListLoading, Orders Count: ${orders.length}");

        // 1. حالة التحميل الأولي (القائمة فارغة + جاري التحميل)
        if (isThisListLoading && orders.isEmpty) {
          return Center(
            child: SingleChildScrollView(
              child: Column(
                children: List.generate(
                  6,
                  (index) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 3.5, horizontal: 16),
                    child: const CustomShimmer(
                      height: 120,
                      width: double.infinity,
                      radius: 15,
                    ),
                  ),
                ),
              ),
            ),
          );
        }

        // 2. حالة عدم وجود بيانات (التحميل انتهى + القائمة فارغة)
        if (!isThisListLoading && orders.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SvgPicture.asset(
                  AppImages.containerIcon,
                  height: 120,
                  colorFilter: ColorFilter.mode(AppColor.mainAppColor, BlendMode.srcIn),
                ),
                Text(
                  widget.isCurrent
                      ? AppLocaleKey.noCurrentOrders.tr()
                      : AppLocaleKey.noOldOrders.tr(),
                  style: AppTextStyle.text16_700,
                ),
                const SizedBox(height: 10),
                CustomButton(
                  width: MediaQuery.of(context).size.width / 2.5,
                  radius: 5,
                  text: "request_hawaia".tr(), // تأكد من وجود مفتاح الترجمة هذا
                  onPressed: () {
                    // Action
                  },
                )
              ],
            ),
          );
        }

        // 3. عرض البيانات (القائمة تحتوي على عناصر)
        return ListView.separated(
          separatorBuilder: (context, index) => const SizedBox(height: 7),
          controller: _scrollController,
          // إضافة عنصر واحد في الأسفل للودينج اذا كان هناك تحميل للمزيد
          itemCount: orders.length + (isPaginating ? 1 : 0),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          itemBuilder: (context, index) {
            if (index < orders.length) {
              final order = orders[index];
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => widget.isCurrent
                          ? CurrentOrderScreen(
                              ordersDate: order,
                              ordersData: order,
                            )
                          : OldOrderScreen(
                              ordersDate: order,
                            ),
                    ),
                  );
                },
                child: OrderCardWidget(order: order),
              );
            } else {
              // شكل التحميل في أسفل القائمة عند الـ Pagination
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Center(
                  child: CustomShimmer(
                    height: 120,
                    width: double.infinity,
                    radius: 15,
                  ),
                ),
              );
            }
          },
        );
      },
    );
  }
}
