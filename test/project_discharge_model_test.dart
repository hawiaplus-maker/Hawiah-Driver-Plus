import 'package:flutter_test/flutter_test.dart';
import 'package:hawiah_driver/features/order/presentation/model/project_discharge_model.dart';

ProjectDischargeItem itemWithStatus(String status) =>
    ProjectDischargeItem.fromJson({'id': 1, 'status': status});

void main() {
  group('ProjectDischargeItem status', () {
    test('assigned shows the start action', () {
      final item = itemWithStatus('assigned');
      expect(item.isAssigned, isTrue);
      expect(item.isInTransit, isFalse);
      expect(item.isCompleted, isFalse);
    });

    test('in_transit shows the finish action', () {
      final item = itemWithStatus('in_transit');
      expect(item.isInTransit, isTrue);
      expect(item.isAssigned, isFalse);
      expect(item.isCompleted, isFalse);
    });

    test('in_trans shows the finish action', () {
      expect(itemWithStatus('in_trans').isInTransit, isTrue);
    });

    test('"in transit" (with a space) shows the finish action', () {
      expect(itemWithStatus('in transit').isInTransit, isTrue);
    });

    test('"In-Transit" (mixed case + dash) shows the finish action', () {
      expect(itemWithStatus('In-Transit').isInTransit, isTrue);
    });

    test('any other "trans" flavour shows the finish action', () {
      expect(itemWithStatus('on_transit').isInTransit, isTrue);
      expect(itemWithStatus('trip_in_transit').isInTransit, isTrue);
    });

    test('a status without "trans" never shows the finish action', () {
      expect(itemWithStatus('assigned').isInTransit, isFalse);
      expect(itemWithStatus('completed').isInTransit, isFalse);
      expect(itemWithStatus('pending').isInTransit, isFalse);
    });

    test('completed is neither assigned nor in transit', () {
      final item = itemWithStatus('completed');
      expect(item.isCompleted, isTrue);
      expect(item.isAssigned, isFalse);
      expect(item.isInTransit, isFalse);
    });

    test('a null status is neither assigned nor in transit', () {
      final item = itemWithStatus('assigned').isAssigned;
      expect(item, isTrue);
      expect(ProjectDischargeItem.fromJson({'id': 1}).isAssigned, isFalse);
      expect(ProjectDischargeItem.fromJson({'id': 1}).isInTransit, isFalse);
    });
  });
}
