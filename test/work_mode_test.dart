import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hawiah_driver/core/hive/hive_methods.dart';
import 'package:hawiah_driver/features/order/presentation/model/cleaning_contract_delivery_model.dart';
import 'package:hawiah_driver/features/order/presentation/order-cubit/order-cubit.dart';
import 'package:hive/hive.dart';

void main() {
  late OrderCubit cubit;

  setUpAll(() async {
    final dir = await Directory.systemTemp.createTemp('hawiah_work_mode_test');
    Hive.init(dir.path);
    await Hive.openBox('app');
  });

  setUp(() {
    HiveMethods.deleteWorkTypes();
    cubit = OrderCubit();
  });

  tearDown(() async {
    await cubit.close();
  });

  CleaningContractDeliveryItem delivery(String status) =>
      CleaningContractDeliveryItem.fromJson({
        'id': 1,
        'contract_number': 'CC-1',
        'delivery_status': status,
      });

  group('work type flags', () {
    test('bool, int and string values are normalized', () {
      HiveMethods.updateCleaningContractWork('true');
      expect(HiveMethods.getCleaningContractWork(), isTrue);

      HiveMethods.updateCleaningContractWork(1);
      expect(HiveMethods.getCleaningContractWork(), isTrue);

      HiveMethods.updateCleaningContractWork('0');
      expect(HiveMethods.getCleaningContractWork(), isFalse);

      HiveMethods.updateOrderWork(0);
      expect(HiveMethods.getOrderWork(), isFalse);
    });

    test('cleaning_contract_work alone selects the cleaning flow', () {
      HiveMethods.updateCleaningContractWork(true);

      expect(cubit.isCleaningContractMode, isTrue);
      expect(cubit.isProjectWorkMode, isFalse);
    });

    test('cleaning wins when order_work is also enabled', () {
      HiveMethods.updateCleaningContractWork(true);
      HiveMethods.updateOrderWork(true);

      expect(cubit.isCleaningContractMode, isTrue);
      expect(cubit.isProjectWorkMode, isFalse);
    });

    test('project flow needs project_work without cleaning', () {
      HiveMethods.updateProjectWork(true);
      expect(cubit.isProjectWorkMode, isTrue);

      HiveMethods.updateCleaningContractWork(true);
      expect(cubit.isProjectWorkMode, isFalse);
    });

    test('no work flag keeps the regular orders flow', () {
      expect(cubit.isCleaningContractMode, isFalse);
      expect(cubit.isProjectWorkMode, isFalse);
    });
  });

  group('session', () {
    test('clearSession removes the token, user and work flags', () {
      HiveMethods.updateToken('token');
      HiveMethods.updateUserId(12);
      HiveMethods.updateOrderWork(true);
      HiveMethods.updateProjectWork(true);
      HiveMethods.updateCleaningContractWork(true);
      HiveMethods.updateIsVisitor(false);

      HiveMethods.clearSession();

      expect(HiveMethods.getToken(), isNull);
      expect(HiveMethods.getUserId(), isNull);
      expect(HiveMethods.getOrderWork(), isNull);
      expect(HiveMethods.getProjectWork(), isNull);
      expect(HiveMethods.getCleaningContractWork(), isNull);
      expect(HiveMethods.isVisitor(), isTrue);
    });
  });

  group('cleaning delivery status', () {
    test('unfinished deliveries stay current, completed ones go to the end',
        () {
      final items = [
        delivery('assigned'),
        delivery('in_trans'),
        delivery('delivered'),
        delivery('discharged'),
      ];

      final current = items.where((e) => !e.isCompleted).toList();
      final old = items.where((e) => e.isCompleted).toList();

      expect(current.map((e) => e.deliveryStatus), ['assigned', 'in_trans']);
      expect(old.map((e) => e.deliveryStatus), ['delivered', 'discharged']);
    });

    test('a plain status key is accepted (some deployments use it)', () {
      final item = CleaningContractDeliveryItem.fromJson({
        'id': 1,
        'status': 'assigned',
      });

      expect(item.isAssigned, isTrue);
      expect(item.isCompleted, isFalse);
    });
  });
}
