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
import 'package:hawiah_driver/injection_container.dart';

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
    final cubit = sl<OrderCubit>();
    // تحميل الصفحة التالية عند الاقتراب من النهاية
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 150 &&
        cubit.canLoadMoreCurrent &&
        cubit.state is! OrderPaginationLoading) {
      cubit.getOrders(
        orderStatus: widget.isCurrent ? 0 : 1,
        page: widget.isCurrent ? cubit.currentPageCurrent + 1 : cubit.currentPageOld + 1,
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
    return BlocBuilder<OrderCubit, OrderState>(
      bloc: context.read<OrderCubit>(),
      builder: (context, state) {
        final cubit = context.watch<OrderCubit>();
        final orders = widget.isCurrent ? cubit.currentOrders : cubit.oldOrders;

        final isPaginating = widget.isCurrent ? cubit.isLoadingMoreCurrent : cubit.isLoadingMoreOld;

        // لو لسه أول تحميل
        if (orders.isEmpty && state is OrderLoading) {
          return Center(
              child: SingleChildScrollView(
            child: Column(
              children: [
                ...List.generate(
                    6,
                    (index) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 3.5, horizontal: 16),
                          child: CustomShimmer(
                            height: 120,
                            width: double.infinity,
                            radius: 15,
                          ),
                        ))
              ],
            ),
          ));
        } else if (orders.isEmpty && state is OrderSuccess) {
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
                text: "request_hawaia".tr(),
              )
            ],
          ));
        }

        return ListView.separated(
          separatorBuilder: (context, index) => SizedBox(height: 7),
          controller: _scrollController,
          itemCount: orders.length + (isPaginating ? 1 : 0),
          padding: EdgeInsets.symmetric(horizontal: 16),
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
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Center(
                    child: CustomShimmer(
                  height: 120,
                  width: double.infinity,
                  radius: 15,
                )),
              );
            }
          },
        );
      },
    );
  }
}
