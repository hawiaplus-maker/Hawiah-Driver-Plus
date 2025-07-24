import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hawiah_driver/core/networking/api_helper.dart';
import 'package:hawiah_driver/core/networking/urls.dart';
import 'package:hawiah_driver/features/notifications/model/notifications_model.dart';
import 'package:hawiah_driver/features/notifications/presentation/cubit/notifications_state.dart';

class NotificationsCubit extends Cubit<NotificationsState> {
  static NotificationsCubit get(BuildContext context) =>
      BlocProvider.of(context);

  NotificationsCubit() : super(NotificationsInitial());

  void initialSetting() {
    _notificationsResponse = ApiResponse(
      state: ResponseState.sleep,
      data: null,
    );
    _notifications = null;
    emit(NotificationsUpdate());
  }

  ApiResponse _notificationsResponse = ApiResponse(
    state: ResponseState.sleep,
    data: null,
  );
  ApiResponse get notificationsResponse => _notificationsResponse;

  NotificationsModel? _notifications;
  NotificationsModel? get setting => _notifications;

  Future<void> getnotifications() async {
    emit(NotificationsLoading());
    _notificationsResponse = ApiResponse(
      state: ResponseState.loading,
      data: null,
    );
    _notifications = null;
    emit(NotificationsLoading());

    _notificationsResponse = await ApiHelper.instance.get(
      "${Urls.notifications}",
    );

    emit(NotificationsLoading());

    if (_notificationsResponse.state == ResponseState.complete) {
      _notifications = NotificationsModel.fromJson(_notificationsResponse.data);
      emit(NotificationsUpdate());
    } else if (_notificationsResponse.state == ResponseState.unauthorized) {
      emit(NotificationsUpdate());
    }
  }
}
