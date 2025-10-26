import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hawiah_driver/core/custom_widgets/custom_image/custom_network_image.dart';
import 'package:hawiah_driver/core/locale/app_locale_key.dart';
import 'package:hawiah_driver/core/theme/app_colors.dart';
import 'package:hawiah_driver/core/theme/app_text_style.dart';
import 'package:hawiah_driver/core/utils/date_methods.dart';
import 'package:hawiah_driver/features/notifications/presentation/screen/notifications_screen.dart';
import 'package:hawiah_driver/features/order/presentation/screens/current-order-screen.dart';
import 'package:hawiah_driver/features/order/presentation/screens/old-order-screen.dart';

import '../order-cubit/order-cubit.dart';
import '../order-cubit/order-state.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late OrderCubit orderCubit;

  @override
  void initState() {
    super.initState();
    orderCubit = OrderCubit.get(context);
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(_handleTabChange);

    // مبدئيًا نعتبر أنه في تبويب "حالية"
    orderCubit.changeOrderCurrent();
    orderCubit.getOrders(0);
  }

  void _handleTabChange() {
    if (_tabController.indexIsChanging) return;

    final isCurrent = _tabController.index == 0;
    final status = isCurrent ? 0 : 1;

    orderCubit.changeOrderCurrent();
    orderCubit.getOrders(status); // يجلب فقط إذا كانت غير موجودة
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      appBar: AppBar(
        title: Text(AppLocaleKey.orders.tr(), style: AppTextStyle.text20_700),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const NotificationsScreen()),
              );
            },
            icon: Image.asset("assets/icons/notfication_icon.png"),
            constraints: BoxConstraints(maxWidth: 40.w, maxHeight: 40.h),
          ),
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              height: 50,
              decoration: BoxDecoration(
                color: AppColor.selectedLightBlueColor,
                borderRadius: BorderRadius.circular(14),
              ),
              child: TabBar(
                controller: _tabController,
                labelColor: AppColor.whiteColor,
                unselectedLabelColor: AppColor.greyColor,
                labelStyle: AppTextStyle.text20_700,
                indicator: BoxDecoration(
                  color: AppColor.mainAppColor,
                  borderRadius: BorderRadius.circular(14),
                ),
                dividerHeight: 0,
                indicatorSize: TabBarIndicatorSize.tab,
                tabs: [
                  Tab(text: AppLocaleKey.current.tr()),
                  Tab(text: AppLocaleKey.end.tr()),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: BlocBuilder<OrderCubit, OrderState>(
              builder: (context, state) {
                if (state is OrderLoading && orderCubit.orders == null) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state is OrderError) {
                  return Center(child: Text(AppLocaleKey.loadingRequests.tr()));
                }

                final orders = orderCubit.orders?.data ?? [];

                return TabBarView(
                  controller: _tabController,
                  children: [
                    _buildOrderList(
                      orderCubit.orders?.data ?? [],
                      isCurrent: true,
                    ),
                    _buildOrderList(
                      orderCubit.orders?.data ?? [],
                      isCurrent: false,
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderList(List<dynamic> orders, {required bool isCurrent}) {
    if (orders.isEmpty) {
      return const Center(child: Text("لا توجد طلبات في هذا القسم"));
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 80),
      child: ListView.builder(
        itemCount: orders.length,
        padding: const EdgeInsets.all(16),
        itemBuilder: (context, index) {
          final order = orders[index];
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (_) =>
                          isCurrent
                              ? CurrentOrderScreen(ordersDate: order)
                              : OldOrderScreen(ordersDate: order),
                ),
              );
            },
            child: Card(
              margin: EdgeInsets.symmetric(vertical: 10),
              elevation: 5,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: Container(
                padding: EdgeInsets.all(10),
                margin: EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        CustomNetworkImage(
                          imageUrl: order.image ?? "",
                          height: 70.h,
                          width: 70.h,
                        ),
                        const SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              order.product ?? '---',
                              style: const TextStyle(
                                color: Colors.black,
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              DateMethods.formatToFullData(
                                DateTime.tryParse(order.createdAt ?? "") ??
                                    DateTime.now(),
                              ),
                              style: const TextStyle(
                                color: Colors.black54,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 5),
                            RichText(
                              text: TextSpan(
                                children: [
                                  TextSpan(
                                    text: AppLocaleKey.states.tr() + ': ',
                                    style: AppTextStyle.text16_600,
                                  ),
                                  TextSpan(
                                    text:
                                        context.locale.languageCode == 'en'
                                            ? order.status['en'] ?? ''
                                            : order.status['ar'] ?? '',
                                    style: AppTextStyle.text16_500.copyWith(
                                      color: AppColor.mainAppColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Text(
                          AppLocaleKey.orderDetails.tr(),
                          style: AppTextStyle.text16_600.copyWith(
                            color: AppColor.mainAppColor,
                          ),
                        ),
                        const SizedBox(width: 5),
                        Icon(
                          Icons.arrow_forward_ios,
                          color: AppColor.mainAppColor,
                          size: 20,
                        ),
                      ],
                    ),
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
