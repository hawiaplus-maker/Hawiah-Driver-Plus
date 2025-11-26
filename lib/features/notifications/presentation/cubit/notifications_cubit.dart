import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hawiah_driver/core/custom_widgets/custom_toast.dart';
import 'package:hawiah_driver/core/locale/app_locale_key.dart';
import 'package:hawiah_driver/core/networking/api_helper.dart';
import 'package:hawiah_driver/core/networking/urls.dart';
import 'package:hawiah_driver/core/utils/common_methods.dart';
import 'package:hawiah_driver/core/utils/navigator_methods.dart';
import 'package:hawiah_driver/features/notifications/model/notifications_model.dart';
import 'package:hawiah_driver/features/notifications/presentation/cubit/notifications_state.dart';

class NotificationsCubit extends Cubit<NotificationsState> {
  static NotificationsCubit get(BuildContext context) => BlocProvider.of(context);

  NotificationsCubit() : super(NotificationsInitial());

  ApiResponse _notificationsResponse = ApiResponse(state: ResponseState.sleep, data: null);
  ApiResponse get notificationsResponse => _notificationsResponse;

  NotificationsModel? _notifications;
  NotificationsModel? get setting => _notifications;

  bool _firstLoad = true;

  Future<void> getnotifications({String? search, int? seen}) async {
    emit(NotificationsLoading());

    _notificationsResponse = await ApiHelper.instance.get(Urls.getNotifications,
        queryParameters: {if (search != null) "search": search, if (seen != null) "seen": seen});

    if (_notificationsResponse.state == ResponseState.complete) {
      _notifications = NotificationsModel.fromJson(_notificationsResponse.data);
      emit(NotificationsUpdate());
    } else {
      emit(NotificationsUpdate());
    }
  }

  Future<void> deleteNotification(int id) async {
    NavigatorMethods.loading();
    if (_notifications == null) return;

    final oldNotifications = List<Datum>.from(_notifications!.notifications);

    _notifications!.notifications.removeWhere((n) => n.id == id);
    emit(NotificationsUpdate());

    _notificationsResponse = await ApiHelper.instance.delete(
      "${Urls.deleteNotification(id)}",
    );

    NavigatorMethods.loadingOff();

    if (_notificationsResponse.state == ResponseState.complete) {
      CommonMethods.showToast(
        message: AppLocaleKey.notificationDeleted.tr(),
        type: ToastType.success,
      );
    } else {
      _notifications!.notifications = oldNotifications;
      emit(NotificationsUpdate());
      CommonMethods.showToast(
        message: AppLocaleKey.notificationDeleteFailed.tr(),
        type: ToastType.error,
      );
    }
  }

  void initialSetting() {
    _notificationsResponse = ApiResponse(state: ResponseState.sleep, data: null);
    _notifications = null;
    _firstLoad = true;
    emit(NotificationsUpdate());
  }
}
