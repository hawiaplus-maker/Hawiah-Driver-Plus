import 'dart:io';

import 'package:bot_toast/bot_toast.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hawiah_driver/core/locale/app_locale_key.dart';
import 'package:hawiah_driver/core/networking/urls.dart';
import 'package:hawiah_driver/core/theme/cubit/app_theme_cubit.dart';
import 'package:hawiah_driver/features/location/service/location_service.dart';
import 'package:hawiah_driver/features/order/presentation/model/cleaning_contract_delivery_model.dart';
import 'package:hawiah_driver/features/order/presentation/order-cubit/order-cubit.dart';
import 'package:hawiah_driver/features/order/presentation/widget/discharge_action_widget.dart';
import 'package:hawiah_driver/injection_container.dart';
import 'package:hawiah_driver/main.dart' show genContext;
import 'package:hive/hive.dart';
import 'package:image_picker_platform_interface/image_picker_platform_interface.dart';
import 'package:location/location.dart';

/// Serves the few translations the action needs.
class _TestAssetLoader extends AssetLoader {
  @override
  Future<Map<String, dynamic>> load(String path, Locale locale) async {
    return {
      'driverNotes': 'Driver notes',
      'driverNotesHint': 'Add notes (optional)',
      'captureAndComplete': 'Capture photo & finish',
      'cancel': 'Cancel',
      'completeDischarging': 'Complete Discharging',
      'completeDischargeSuccess': 'Discharge completed',
      'cameraNotAvailable': 'Camera not available',
      'pleaseEnableLocation': 'Please enable location',
      'anErrorOccurred': 'An error occurred',
    };
  }
}

/// Returns the prepared photo instead of opening the camera.
class _FakeImagePicker extends ImagePickerPlatform {
  _FakeImagePicker(this.file);

  final File file;

  @override
  Future<XFile?> getImageFromSource({
    required ImageSource source,
    ImagePickerOptions options = const ImagePickerOptions(),
  }) async =>
      XFile(file.path);

  @override
  Future<XFile?> getImage({
    required ImageSource source,
    double? maxWidth,
    double? maxHeight,
    int? imageQuality,
    CameraDevice preferredCameraDevice = CameraDevice.rear,
  }) async =>
      XFile(file.path);
}

/// A location service that always answers instantly.
class _FakeLocationService extends LocationService {
  @override
  Future<bool> checkAndRequestLocationService() async => true;

  @override
  Future<bool> checkAndRequestLocationPermission() async => true;

  @override
  Future<LocationData?> getLocationForAction({
    Duration timeout = const Duration(seconds: 12),
  }) async =>
      LocationData.fromMap({'latitude': 24.7136, 'longitude': 46.6753});
}

/// The payload the widget prepared.
class _SentPayload {
  File? image;
  double? latitude;
  double? longitude;
  String? driverNotes;
}

void main() {
  late Directory tempDir;
  late File photo;
  late OrderCubit cubit;

  setUpAll(() async {
    tempDir = await Directory.systemTemp.createTemp('hawiah_cleaning_test');
    final hiveDir = await Directory.systemTemp.createTemp('hawiah_hive_test');
    Hive.init(hiveDir.path);
    await Hive.openBox('app');

    photo = File('${tempDir.path}/photo.jpg');
    await photo.writeAsBytes(List<int>.filled(600 * 1024, 7));
  });

  setUp(() async {
    cubit = OrderCubit();
    if (sl.isRegistered<LocationService>()) {
      await sl.unregister<LocationService>();
    }
    sl.registerSingleton<LocationService>(_FakeLocationService());
    ImagePickerPlatform.instance = _FakeImagePicker(photo);
  });

  tearDown(() async {
    await cubit.close();
  });

  CleaningContractDeliveryItem record(String status) =>
      CleaningContractDeliveryItem.fromJson({
        'id': 1,
        'contract_number': 'CC-1',
        'company_name': 'Company',
        'container_name': 'Container',
        'discharge_status': status,
        'discharge_status_label': status,
      });

  Future<void> pumpButton(
    WidgetTester tester,
    CleaningContractDeliveryItem order,
    _SentPayload payload,
  ) async {
    tester.view.physicalSize = const Size(1170, 2532);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

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
                    navigatorObservers: [BotToastNavigatorObserver()],
                    builder: (context, child) {
                      genContext = context;
                      return BotToastInit()(context, child);
                    },
                    home: Scaffold(
                      body: DischargeActionWidget(
                        dischargeId: order.id!,
                        isVisible: order.isAssigned,
                        label: AppLocaleKey.completeDischarging.tr(),
                        isFullWidth: true,
                        onComplete: ({
                          required image,
                          required latitude,
                          required longitude,
                          required driverNotes,
                        }) async {
                          payload
                            ..image = image
                            ..latitude = latitude
                            ..longitude = longitude
                            ..driverNotes = driverNotes;
                        },
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

  test('the complete endpoint matches the API', () {
    expect(
      Urls.completeCleaningContractDischarge(1),
      'https://hawiaplus.com/api/v2/drivers/cleaning-contracts-discharges/1/complete',
    );
  });

  test('a record is assigned until the discharge is done', () {
    expect(record('assigned').isAssigned, isTrue);
    expect(record('assigned').isCompleted, isFalse);
    expect(record('discharged').isAssigned, isFalse);
    expect(record('discharged').isCompleted, isTrue);
    expect(record('delivered').isCompleted, isTrue);
  });

  testWidgets('the button shows up for an assigned discharge',
      (tester) async {
    final payload = _SentPayload();
    await pumpButton(tester, record('assigned'), payload);

    expect(find.text('Complete Discharging'), findsOneWidget);
  });

  testWidgets('the button is hidden once the discharge is done',
      (tester) async {
    final payload = _SentPayload();
    await pumpButton(tester, record('discharged'), payload);

    expect(find.text('Complete Discharging'), findsNothing);
  });

  testWidgets('the discharge is sent with the photo, the position and the notes',
      (tester) async {
    final payload = _SentPayload();
    await pumpButton(tester, record('assigned'), payload);

    await tester.tap(find.text('Complete Discharging'));
    await tester.pumpAndSettle();

    // The notes sheet opens.
    expect(find.text('Driver notes'), findsOneWidget);
    await tester.enterText(find.byType(TextFormField), 'container is empty');
    await tester.pump();

    // The photo is taken and the discharge is sent.
    await tester.tap(find.text('Capture photo & finish'));
    await tester.pumpAndSettle();

    expect(payload.image, isNotNull);
    expect(payload.latitude, 24.7136);
    expect(payload.longitude, 46.6753);
    expect(payload.driverNotes, 'container is empty');
    expect(tester.takeException(), isNull);
  });
}
