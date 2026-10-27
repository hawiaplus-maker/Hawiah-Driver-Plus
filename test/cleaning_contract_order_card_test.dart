import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hawiah_driver/core/theme/cubit/app_theme_cubit.dart';
import 'package:hawiah_driver/features/order/presentation/model/cleaning_contract_delivery_model.dart';
import 'package:hawiah_driver/features/order/presentation/order-cubit/order-cubit.dart';
import 'package:hawiah_driver/features/order/presentation/widget/cleaning_contract_order_card_widget.dart';
import 'package:hawiah_driver/main.dart' show genContext;
import 'package:hive/hive.dart';

/// Serves the few translations the card needs, so the test doesn't depend on
/// the asset bundle.
class _TestAssetLoader extends AssetLoader {
  @override
  Future<Map<String, dynamic>> load(String path, Locale locale) async {
    return {
      'company': 'Company',
      'showDetails': 'Show details',
      'startAtDate': 'Start at',
    };
  }
}

CleaningContractDeliveryItem _delivery({
  String? status = 'assigned',
  String? statusLabel = 'Assigned',
  String? companyName = 'Company',
}) {
  return CleaningContractDeliveryItem.fromJson({
    'id': 1,
    'contract_number': 'CC-1',
    'company_name': companyName,
    'container_name': 'Container 6-Yard',
    'delivery_status': status,
    'delivery_status_label': statusLabel,
    'start_date': '2026-11-19',
  });
}

/// Renders the card inside a ListView — the same place the orders screen puts
/// it.
Future<void> pumpCard(
  WidgetTester tester,
  CleaningContractDeliveryItem order, {
  double width = 381,
}) async {
  final cubit = OrderCubit();
  addTearDown(cubit.close);

  await tester.pumpWidget(
    ScreenUtilInit(
      designSize: const Size(381, 828),
      builder: (context, child) {
        return EasyLocalization(
          supportedLocales: const [Locale('en'), Locale('ar')],
          path: 'assets/translations',
          startLocale: const Locale('en'),
          fallbackLocale: const Locale('en'),
          saveLocale: false,
          useOnlyLangCode: true,
          assetLoader: _TestAssetLoader(),
          child: BlocProvider<AppThemeCubit>(
            create: (_) => AppThemeCubit()..initial(),
            child: BlocProvider<OrderCubit>.value(
              value: cubit,
              child: Builder(
                builder: (context) => MaterialApp(
                  localizationsDelegates: context.localizationDelegates,
                  supportedLocales: context.supportedLocales,
                  locale: context.locale,
                  builder: (context, child) {
                    genContext = context;
                    return child!;
                  },
                  home: Scaffold(
                    body: SizedBox(
                      width: width,
                      child: ListView(
                        children: [
                          CleaningContractOrderCardWidget(order: order),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  setUpAll(() async {
    final dir = await Directory.systemTemp.createTemp('hawiah_hive_test');
    Hive.init(dir.path);
    await Hive.openBox('app');
  });

  testWidgets('an assigned cleaning record has no action on the card',
      (tester) async {
    await pumpCard(tester, _delivery());

    expect(tester.takeException(), isNull);
    expect(find.text('#CC-1'), findsOneWidget);
    expect(find.text('Start Discharging'), findsNothing);
    expect(find.text('Complete Discharging'), findsNothing);
  });

  testWidgets('an in-transit cleaning record has no action on the card',
      (tester) async {
    await pumpCard(
        tester, _delivery(status: 'in_transit', statusLabel: 'In Transit'));

    expect(tester.takeException(), isNull);
    expect(find.text('Start Discharging'), findsNothing);
    expect(find.text('Complete Discharging'), findsNothing);
  });

  testWidgets('a completed cleaning record has no action on the card',
      (tester) async {
    await pumpCard(
        tester, _delivery(status: 'delivered', statusLabel: 'Delivered'));

    expect(tester.takeException(), isNull);
    expect(find.text('Start Discharging'), findsNothing);
    expect(find.text('Complete Discharging'), findsNothing);
  });

  testWidgets('a discharged cleaning record has no action on the card',
      (tester) async {
    await pumpCard(
        tester, _delivery(status: 'discharged', statusLabel: 'Discharged'));

    expect(tester.takeException(), isNull);
    expect(find.text('Start Discharging'), findsNothing);
    expect(find.text('Complete Discharging'), findsNothing);
  });

  testWidgets('the card renders a long company name without overflowing',
      (tester) async {
    await pumpCard(
      tester,
      _delivery(
        companyName:
            'A very very long company name that should be ellipsized instead of overflowing the row',
      ),
    );

    expect(tester.takeException(), isNull);
  });

  testWidgets('the card renders on a narrow screen without overflowing',
      (tester) async {
    await pumpCard(tester, _delivery(), width: 320);

    expect(tester.takeException(), isNull);
  });
}
