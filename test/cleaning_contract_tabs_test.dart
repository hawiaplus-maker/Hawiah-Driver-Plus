import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hawiah_driver/core/hive/hive_methods.dart';
import 'package:hawiah_driver/core/theme/cubit/app_theme_cubit.dart';
import 'package:hawiah_driver/features/order/presentation/model/cleaning_contract_delivery_model.dart';
import 'package:hawiah_driver/features/order/presentation/order-cubit/order-cubit.dart';
import 'package:hawiah_driver/features/order/presentation/widget/order_tap_list.dart';
import 'package:hawiah_driver/main.dart' show genContext;
import 'package:hive/hive.dart';

/// Serves the few translations the list needs, so the test doesn't depend on
/// the asset bundle.
class _TestAssetLoader extends AssetLoader {
  @override
  Future<Map<String, dynamic>> load(String path, Locale locale) async {
    return {
      'company': 'Company',
      'showDetails': 'Show details',
      'startAtDate': 'Start at',
      'noDischarges': 'No discharges',
      'noOldOrders': 'No old orders',
    };
  }
}

CleaningContractDeliveryItem _discharge({
  required int id,
  required String contractNumber,
  required String companyName,
  required String status,
}) {
  return CleaningContractDeliveryItem.fromJson({
    'id': id,
    'contract_number': contractNumber,
    'company_name': companyName,
    'container_name': 'Container 6-Yard',
    'discharge_status': status,
    'start_date': '2026-11-19',
  });
}

Future<void> pumpTab(
  WidgetTester tester,
  OrderCubit cubit, {
  required bool isCurrent,
}) async {
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
                    body: OrderTapList(
                      isCurrent: isCurrent,
                      isDischarges: true,
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
  late OrderCubit cubit;

  setUpAll(() async {
    final dir = await Directory.systemTemp.createTemp('hawiah_tabs_test');
    Hive.init(dir.path);
    await Hive.openBox('app');
    HiveMethods.updateCleaningContractWork(true);
  });

  tearDownAll(() {
    HiveMethods.deleteWorkTypes();
  });

  setUp(() {
    cubit = OrderCubit();
    // Both cleaning tabs are fed by the single discharges list, split in the
    // cubit by completion state.
    cubit.cleaningCurrentDischarges = [
      _discharge(
        id: 1,
        contractNumber: 'CC-1',
        companyName: 'Current Co',
        status: 'assigned',
      ),
    ];
    cubit.cleaningOldDischarges = [
      _discharge(
        id: 2,
        contractNumber: 'CC-2',
        companyName: 'Old Co',
        status: 'discharged',
      ),
    ];
  });

  tearDown(() async {
    await cubit.close();
  });

  testWidgets('the current tab lists only unfinished discharges',
      (tester) async {
    await pumpTab(tester, cubit, isCurrent: true);

    expect(tester.takeException(), isNull);
    expect(find.text('#CC-1'), findsOneWidget);
    expect(find.text('#CC-2'), findsNothing);
    // Actions live on the details screen only — never on the orders list.
    expect(find.text('Complete Discharging'), findsNothing);
  });

  testWidgets('the completed tab lists only finished discharges',
      (tester) async {
    await pumpTab(tester, cubit, isCurrent: false);

    expect(tester.takeException(), isNull);
    expect(find.text('#CC-2'), findsOneWidget);
    expect(find.text('#CC-1'), findsNothing);
    expect(find.text('Complete Discharging'), findsNothing);
  });
}
