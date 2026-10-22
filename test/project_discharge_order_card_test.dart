import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hawiah_driver/core/theme/cubit/app_theme_cubit.dart';
import 'package:hawiah_driver/features/order/presentation/model/project_discharge_model.dart';
import 'package:hawiah_driver/features/order/presentation/widget/project_discharge_order_card_widget.dart';
import 'package:hawiah_driver/main.dart' show genContext;
import 'package:hive/hive.dart';

/// Serves the few translations the card needs, so the test doesn't depend on
/// the asset bundle.
class _TestAssetLoader extends AssetLoader {
  @override
  Future<Map<String, dynamic>> load(String path, Locale locale) async {
    return {
      'container': 'Container',
      'clientName': 'Client',
      'scheduledDate': 'Scheduled date',
      'showDetails': 'Show details',
    };
  }
}

ProjectDischargeItem _pickup({
  String? status = 'assigned',
  String? statusLabel = 'dont delete or edite this account - حاوية 6 يارده',
  String? projectName = 'Container 6-Yard Container (6 ياردة)',
}) {
  return ProjectDischargeItem(
    id: 1,
    referenceNumber: '9161154',
    projectName: projectName,
    containerName: 'Container 6-Yard Container',
    containerSize: 6,
    clientName: 'Client',
    scheduledDate: '2026-11-19',
    scheduledTime: '09:00:00',
    status: status,
    statusLabel: statusLabel,
  );
}

/// Renders the card inside a ListView — the same place the orders screen puts
/// it. The ListView gives the card an unbounded height, which is what used to
/// break the `Flexible` inside the card's Column.
Future<void> pumpCard(
  WidgetTester tester,
  ProjectDischargeItem pickup, {
  double width = 381,
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
                        ProjectDischargeOrderCardWidget(pickup: pickup),
                      ],
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

  testWidgets('the card renders inside a ListView without layout errors',
      (tester) async {
    await pumpCard(tester, _pickup());

    expect(tester.takeException(), isNull);
    expect(find.text('#9161154'), findsOneWidget);
    expect(find.text('Show details'), findsOneWidget);
  });

  testWidgets('the card renders a long project name without overflowing',
      (tester) async {
    await pumpCard(
      tester,
      _pickup(
        projectName:
            'A very very long project name that should be ellipsized instead of overflowing the row',
      ),
    );

    expect(tester.takeException(), isNull);
  });

  testWidgets('the card renders the completed state without layout errors',
      (tester) async {
    await pumpCard(tester, _pickup(status: 'completed'));

    expect(tester.takeException(), isNull);
  });

  testWidgets('the card renders on a narrow screen without overflowing',
      (tester) async {
    await pumpCard(tester, _pickup(), width: 320);

    expect(tester.takeException(), isNull);
  });
}
