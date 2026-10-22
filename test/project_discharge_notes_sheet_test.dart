import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hawiah_driver/core/theme/cubit/app_theme_cubit.dart';
import 'package:hawiah_driver/features/order/presentation/widget/discharge_action_widget.dart';
import 'package:hawiah_driver/main.dart' show genContext;
import 'package:hive/hive.dart';

/// Serves the few translations the notes sheet needs, so the test doesn't
/// depend on the asset bundle.
class _TestAssetLoader extends AssetLoader {
  @override
  Future<Map<String, dynamic>> load(String path, Locale locale) async {
    return {
      'driverNotes': 'Driver notes',
      'driverNotesHint': 'Add notes (optional)',
      'captureAndComplete': 'Capture photo & finish',
      'cancel': 'Cancel',
    };
  }
}

/// Opens the notes sheet as a real modal bottom sheet, the same way the
/// discharge action does.
Future<void> openNotesSheet(WidgetTester tester) async {
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
            // A Builder gives a context below EasyLocalization, so the
            // MaterialApp can pick up its localization delegates.
            child: Builder(
              builder: (context) => MaterialApp(
                localizationsDelegates: context.localizationDelegates,
                supportedLocales: context.supportedLocales,
                locale: context.locale,
                // The app resolves its theme colors through a global context,
                // which has to live below the AppThemeCubit provider.
                builder: (context, child) {
                  genContext = context;
                  return child!;
                },
                home: Scaffold(
                  body: Builder(
                    builder: (sheetContext) => ElevatedButton(
                      onPressed: () => DriverNotesSheet.show(sheetContext),
                      child: const Text('open'),
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

  await tester.tap(find.text('open'));
  await tester.pumpAndSettle();
}

void main() {
  setUpAll(() async {
    final dir = await Directory.systemTemp.createTemp('hawiah_hive_test');
    Hive.init(dir.path);
    await Hive.openBox('app');
  });

  testWidgets('the notes sheet survives being closed', (tester) async {
    await openNotesSheet(tester);

    // Type into the notes field.
    await tester.enterText(find.byType(TextFormField), 'filled the container');
    await tester.pump();

    // Close the sheet through the action button — the sheet keeps building
    // during its exit animation, so the controller must still be alive.
    await tester.tap(find.text('Capture photo & finish'), warnIfMissed: false);
    await tester.pump();

    expect(tester.takeException(), isNull);

    // Finish the exit animation.
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
  });

  testWidgets('the notes sheet survives being dismissed', (tester) async {
    await openNotesSheet(tester);

    await tester.enterText(find.byType(TextFormField), 'some note');
    await tester.pump();

    await tester.tap(find.text('Cancel'), warnIfMissed: false);
    await tester.pump();

    expect(tester.takeException(), isNull);

    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
  });
}
