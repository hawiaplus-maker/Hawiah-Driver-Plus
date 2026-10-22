import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:hawiah_driver/core/custom_widgets/custom_loading/custom_shimmer.dart';
import 'package:hawiah_driver/core/images/app_images.dart';
import 'package:hawiah_driver/core/locale/app_locale_key.dart';
import 'package:hawiah_driver/core/theme/app_colors.dart';
import 'package:hawiah_driver/core/theme/app_text_style.dart';
import 'package:hawiah_driver/features/order/presentation/model/cleaning_contract_delivery_model.dart';
import 'package:hawiah_driver/features/order/presentation/model/orders_model.dart';
import 'package:hawiah_driver/features/order/presentation/model/project_discharge_model.dart';
import 'package:hawiah_driver/features/order/presentation/screens/order_details_screen.dart';
import 'package:hawiah_driver/features/order/presentation/widget/cleaning_contract_order_card_widget.dart';
import 'package:hawiah_driver/features/order/presentation/widget/order_card_widget.dart';
import 'package:hawiah_driver/features/order/presentation/widget/project_discharge_order_card_widget.dart';

import '../order-cubit/order-cubit.dart';
import '../order-cubit/order-state.dart';

class OrderTapList extends StatefulWidget {
  const OrderTapList(
      {super.key, required this.isCurrent, this.isDischarges = false});

  final bool isCurrent;

  /// When true this list shows cleaning-contract discharge records
  /// (the third tab, only visible in cleaning-contract mode).
  final bool isDischarges;

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

    if (widget.isDischarges) {
      if (_scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent - 150 &&
          cubit.state is! OrderPaginationLoading &&
          cubit.canLoadMoreDischarges) {
        cubit.getCleaningContractDischarges(
          page: cubit.dischargeCurrentPage + 1,
          isLoadMore: true,
        );
      }
      return;
    }

    final canLoadMore = cubit.isProjectWorkMode
        ? cubit.canLoadMoreProject
        : cubit.isCleaningContractMode
            ? cubit.canLoadMoreCleaningContract
            : (widget.isCurrent
                ? cubit.canLoadMoreCurrent
                : cubit.canLoadMoreOld);

    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 150 &&
        cubit.state is! OrderPaginationLoading &&
        canLoadMore) {
      if (cubit.isProjectWorkMode) {
        cubit.getProjectDischarges(
          orderStatus: widget.isCurrent ? 0 : 1,
          page: cubit.projectCurrentPage + 1,
          isLoadMore: true,
        );
      } else if (cubit.isCleaningContractMode) {
        cubit.getCleaningContractDeliveries(
          orderStatus: widget.isCurrent ? 0 : 1,
          page: cubit.cleaningCurrentPage + 1,
          isLoadMore: true,
        );
      } else {
        cubit.getOrders(
          orderStatus: widget.isCurrent ? 0 : 1,
          page: widget.isCurrent
              ? cubit.currentPageCurrent + 1
              : cubit.currentPageOld + 1,
          isLoadMore: true,
        );
      }
    }
  }

  Future<void> _onRefresh() async {
    final cubit = context.read<OrderCubit>();
    if (widget.isDischarges) {
      await cubit.getCleaningContractDischarges(isRefresh: true);
      return;
    }
    if (cubit.isProjectWorkMode) {
      await cubit.getProjectDischarges(
        orderStatus: widget.isCurrent ? 0 : 1,
        isRefresh: true,
      );
    } else if (cubit.isCleaningContractMode) {
      await cubit.getCleaningContractDeliveries(
        orderStatus: widget.isCurrent ? 0 : 1,
        isRefresh: true,
      );
    } else {
      await cubit.getOrders(
        orderStatus: widget.isCurrent ? 0 : 1,
        isRefresh: true,
      );
    }
  }

  String get _emptyStateMessage {
    if (widget.isDischarges) return AppLocaleKey.noDischarges.tr();
    return widget.isCurrent
        ? AppLocaleKey.noCurrentOrders.tr()
        : AppLocaleKey.noOldOrders.tr();
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
        final isCleaning = cubit.isCleaningContractMode;
        final List<dynamic> orders;
        if (widget.isDischarges) {
          orders = cubit.cleaningDischarges;
        } else if (cubit.isProjectWorkMode && !widget.isDischarges) {
          orders = widget.isCurrent
              ? cubit.projectCurrentOrders
              : cubit.projectOldOrders;
        } else if (isCleaning) {
          orders = widget.isCurrent
              ? cubit.cleaningCurrentOrders
              : cubit.cleaningOldOrders;
        } else {
          orders =
              widget.isCurrent ? cubit.currentOrders : cubit.oldOrders;
        }
        final isPaginating = cubit.isProjectWorkMode && !widget.isDischarges
            ? cubit.isLoadingMoreProject
            : widget.isDischarges
                ? cubit.isLoadingMoreDischarges
                : isCleaning
                    ? cubit.isLoadingMoreCleaningContract
                    : (widget.isCurrent
                        ? cubit.isLoadingMoreCurrent
                        : cubit.isLoadingMoreOld);
        final bool showCleaningCards =
            widget.isDischarges || isCleaning;
        // لو لسه أول تحميل
        if (state is OrderLoading) {
          return Center(
              child: SingleChildScrollView(
            child: Column(
              children: List.generate(
                  6,
                  (index) => Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 3.5, horizontal: 16),
                        child: CustomShimmer(
                          height: 120,
                          width: double.infinity,
                          radius: 15,
                        ),
                      )),
            ),
          ));
        } else if (state is OrderSuccess) {
          if (orders.isEmpty) {
            return RefreshIndicator(
              onRefresh: _onRefresh,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(minHeight: constraints.maxHeight),
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SvgPicture.asset(
                              AppImages.containerIcon,
                              height: 120,
                              colorFilter: ColorFilter.mode(
                                  AppColor.mainAppColor, BlendMode.srcIn),
                            ),
                            Text(
                              _emptyStateMessage,
                              style: AppTextStyle.text16_700,
                            ),
                            const SizedBox(height: 10),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            );
          }
        }

        return RefreshIndicator(
          onRefresh: _onRefresh,
          child: ListView.separated(
            physics: const AlwaysScrollableScrollPhysics(),
            separatorBuilder: (context, index) => const SizedBox(height: 7),
            controller: _scrollController,
            itemCount: orders.length + (isPaginating ? 1 : 0),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemBuilder: (context, index) {
              if (index < orders.length) {
                final item = orders[index];
                if (showCleaningCards) {
                  return CleaningContractOrderCardWidget(
                    order: item as CleaningContractDeliveryItem,
                  );
                }
                if (cubit.isProjectWorkMode) {
                  return ProjectDischargeOrderCardWidget(
                    pickup: item as ProjectDischargeItem,
                  );
                }
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => OrderDetailsScreen(
                          orderId: (item as SingleOrderData).id ?? 0,
                          isCurrent: widget.isCurrent,
                        ),
                      ),
                    );
                  },
                  child: OrderCardWidget(order: item as SingleOrderData),
                );
              } else {
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
          ),
        );
      },
    );
  }
}
