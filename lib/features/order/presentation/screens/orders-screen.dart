import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hawiah_driver/core/custom_widgets/custom_app_bar/custom_app_bar.dart';
import 'package:hawiah_driver/core/custom_widgets/custom_button.dart';
import 'package:hawiah_driver/core/custom_widgets/no_data_widget.dart';
import 'package:hawiah_driver/core/hive/hive_methods.dart';
import 'package:hawiah_driver/core/locale/app_locale_key.dart';
import 'package:hawiah_driver/core/theme/app_colors.dart';
import 'package:hawiah_driver/core/theme/app_text_style.dart';
import 'package:hawiah_driver/core/utils/navigator_methods.dart';
import 'package:hawiah_driver/features/authentication/presentation/dialog/unauthenticated_dialog.dart';
import 'package:hawiah_driver/features/order/presentation/widget/order_tap_list.dart';
import 'package:hawiah_driver/injection_container.dart';

import '../order-cubit/order-cubit.dart';
import '../order-cubit/order-state.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isDialogOpen = false;

  @override
  void initState() {
    super.initState();
    super.initState();
    if (HiveMethods.isVisitor() || HiveMethods.getToken() == null) {
      isVesetor = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        NavigatorMethods.showAppDialog(context, UnauthenticatedDialog());
      });
    }
    final cubit = sl<OrderCubit>();

    cubit.getOrders(orderStatus: 0);
    cubit.getOrders(orderStatus: 1);
    _tabController = TabController(length: 2, vsync: this);
  }

  bool isVesetor = false;

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: sl<OrderCubit>(),
      child: Scaffold(
        appBar: CustomAppBar(
          context,
          titleText: AppLocaleKey.orders.tr(),
        ),
        body: Column(
          children: [
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: TabBar(
                controller: _tabController,
                labelColor: AppColor.whiteColor,
                labelStyle: AppTextStyle.text20_700.copyWith(fontFamily: "DINNextLTArabic"),
                indicatorColor: Colors.transparent,
                dividerHeight: 0,
                labelPadding: const EdgeInsets.symmetric(horizontal: 3),
                onTap: (value) {
                  _tabController.index = value;
                  setState(() {});
                },
                tabs: [
                  Tab(
                    iconMargin: EdgeInsets.all(0),
                    child: CustomButton(
                      radius: 5,
                      color: _tabController.index == 0
                          ? AppColor.mainAppColor
                          : AppColor.secondAppColor,
                      text: AppLocaleKey.current.tr(),
                      style: AppTextStyle.buttonStyle
                          .copyWith(fontSize: 18, fontWeight: FontWeight.w400),
                    ),
                  ),
                  Tab(
                    iconMargin: EdgeInsets.all(0),
                    child: CustomButton(
                      radius: 5,
                      color: _tabController.index == 1
                          ? AppColor.mainAppColor
                          : AppColor.secondAppColor,
                      text: AppLocaleKey.end.tr(),
                      style: AppTextStyle.buttonStyle
                          .copyWith(fontSize: 18, fontWeight: FontWeight.w400),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: BlocConsumer<OrderCubit, OrderState>(
                listener: (context, state) async {
                  if (state is Unauthenticated && !_isDialogOpen) {
                    _isDialogOpen = true;
                    await NavigatorMethods.showAppDialog(context, UnauthenticatedDialog());
                    _isDialogOpen = false;
                  }
                },
                builder: (context, state) {
                  if (state is Unauthenticated) {
                    return Center(
                        child: NoDataWidget(
                      message: AppLocaleKey.noCurrentOrders.tr(),
                    ));
                  }
                  return TabBarView(
                    controller: _tabController,
                    physics: BouncingScrollPhysics(),
                    children: [
                      OrderTapList(
                        isCurrent: true,
                      ),
                      OrderTapList(
                        isCurrent: false,
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
