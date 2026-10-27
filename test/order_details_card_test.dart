import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hawiah_driver/core/theme/cubit/app_theme_cubit.dart';
import 'package:hawiah_driver/features/order/presentation/model/single_order_model.dart';
import 'package:hawiah_driver/features/order/presentation/widget/hawiah_details.dart';
import 'package:hawiah_driver/main.dart' show genContext;
import 'package:hive/hive.dart';

/// Serves the few translations the card needs, so the test doesn't depend on
/// the asset bundle.
class _TestAssetLoader extends AssetLoader {
  @override
  Future<Map<String, dynamic>> load(String path, Locale locale) async {
    return {
      'orderdata': 'Order data',
      'orderCode': 'Order code:',
      'address': 'Address',
      'startdate': 'Start date',
      'enddate': 'End date',
      'createdAt': 'Created at',
    };
  }
}

SingleOrderModel _order({
  String? product = '20 Yard Container',
  String? provider = 'Service provider',
  String? address = 'Riyadh - Olaya',
}) {
  return SingleOrderModel(
    success: true,
    data: SingleOrderData(
      id: 1,
      referenceNumber: 'ORD-123',
      product: product,
      serviceProvider: provider,
      status: LocalizedTitle(en: 'Processing', ar: 'قيد المعالجة'),
      address: address,
      fromDate: '2026-10-22',
      toDate: '2026-10-25',
      createdAt: '2026-10-22 10:00',
      latitude: '24.7136',
      longitude: '46.6753',
      user: 'Ahmed',
      userMobile: '555555555',
    ),
  );
}

/// Renders the card inside a scroll view — the same place the details page
/// puts it.
Future<void> pumpDetails(
  WidgetTester tester,
  SingleOrderModel order, {
  double width = 381,
  Locale locale = const Locale('en'),
}) async {
  // Use a real phone surface: ScreenUtil scales .w/.h from the screen size, so
  // rendering a narrow card inside the default 800px test surface would
  // exaggerate every width.
  tester.view.physicalSize = Size(width, 828);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  await tester.pumpWidget(
    ScreenUtilInit(
      designSize: const Size(381, 828),
      builder: (context, child) {
        return EasyLocalization(
          supportedLocales: const [Locale('en'), Locale('ar')],
          path: 'assets/translations',
          startLocale: locale,
          fallbackLocale: const Locale('en'),
          saveLocale: false,
          useOnlyLangCode: true,
          assetLoader: _TestAssetLoader(),
          child: BlocProvider<AppThemeCubit>(
            create: (_) => AppThemeCubit()..initial(),
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
                  body: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: HawiahDetails(ordersDate: order),
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
    final dir =
        await Directory.systemTemp.createTemp('hawiah_order_details_test');
    Hive.init(dir.path);
    await Hive.openBox('app');
  });

  testWidgets('the order card shows the same data sections as a project card',
      (tester) async {
    await pumpDetails(tester, _order());

    expect(tester.takeException(), isNull);
    expect(find.text('Order data'), findsOneWidget);
    expect(find.text('Processing'), findsOneWidget);
    expect(find.text('20 Yard Container'), findsOneWidget);
    expect(find.textContaining('ORD-123'), findsOneWidget);
    expect(find.text('Service provider'), findsOneWidget);
    expect(find.text('Address'), findsOneWidget);
    expect(find.text('Riyadh - Olaya'), findsOneWidget);
    expect(find.text('Start date'), findsOneWidget);
    expect(find.text('2026-10-22'), findsOneWidget);
    expect(find.text('End date'), findsOneWidget);
    expect(find.text('2026-10-25'), findsOneWidget);
    expect(find.text('Created at'), findsOneWidget);
  });

  testWidgets('missing optional data leaves the card clean', (tester) async {
    await pumpDetails(
      tester,
      _order(product: 'Container', provider: '', address: ''),
    );

    expect(tester.takeException(), isNull);
    expect(find.text('Address'), findsNothing);
    expect(find.text('Created at'), findsOneWidget);
  });

  testWidgets('long names and addresses do not overflow on a narrow screen',
      (tester) async {
    await pumpDetails(
      tester,
      _order(
        product:
            'A very very long container product name that should be ellipsized',
        provider:
            'A very very long service provider name that should be ellipsized',
        address:
            'A very very long delivery address that should wrap instead of overflowing the row',
      ),
      width: 320,
    );

    expect(tester.takeException(), isNull);
  });

  testWidgets('the card renders correctly in Arabic', (tester) async {
    await pumpDetails(tester, _order(), locale: const Locale('ar'));

    expect(tester.takeException(), isNull);
    expect(find.text('قيد المعالجة'), findsOneWidget);
  });
}
