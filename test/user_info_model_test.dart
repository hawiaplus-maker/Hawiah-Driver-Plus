import 'package:flutter_test/flutter_test.dart';
import 'package:hawiah_driver/features/profile/presentation/screens/model/user_info_model.dart';

void main() {
  Map<String, dynamic> response({
    Object? success = true,
    Object? active = 1,
    Object? orderWork = false,
    Object? projectWork = false,
    Object? cleaningContractWork = false,
    bool withData = true,
    String message = 'User information retrieved successfully.',
  }) {
    return {
      'success': success,
      'message': message,
      if (withData)
        'data': {
          'id': 536,
          'type': 'employee',
          'name': 'Driver',
          'email': null,
          'mobile': '0560498210',
          'image': '',
          'api_token': 'token',
          'fcm_token': 'fcm',
          'active': active,
          'order_work': orderWork,
          'project_work': projectWork,
          'cleaning_contract_work': cleaningContractWork,
        },
    };
  }

  group('UserInfoModel.canUseApp', () {
    test('allows an active account with a successful response', () {
      final model = UserInfoModel.fromJson(response());

      expect(model.success, isTrue);
      expect(model.data?.active, isTrue);
      expect(model.canUseApp, isTrue);
    });

    test('denies an inactive account even when the request succeeds', () {
      final model = UserInfoModel.fromJson(response(active: 0));

      expect(model.success, isTrue);
      expect(model.canUseApp, isFalse);
    });

    test('denies an inactive account sent as a string', () {
      expect(
        UserInfoModel.fromJson(response(active: '0')).canUseApp,
        isFalse,
      );
      expect(
        UserInfoModel.fromJson(response(active: '1')).canUseApp,
        isTrue,
      );
    });

    test('denies an unsuccessful response even when data is present', () {
      final model = UserInfoModel.fromJson(
        response(success: false, message: 'Account is not active.'),
      );

      expect(model.success, isFalse);
      expect(model.message, 'Account is not active.');
      expect(model.canUseApp, isFalse);
    });

    test('denies a response without data', () {
      final model = UserInfoModel.fromJson(response(withData: false));

      expect(model.data, isNull);
      expect(model.canUseApp, isFalse);
    });
  });

  group('work type flags', () {
    test('normalizes bool, int and string values', () {
      final model = UserInfoModel.fromJson(
        response(
          orderWork: 1,
          projectWork: 'true',
          cleaningContractWork: '0',
        ),
      );

      expect(model.data?.orderWork, isTrue);
      expect(model.data?.projectWork, isTrue);
      expect(model.data?.cleaningContractWork, isFalse);
    });
  });
}
