import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hawiah_driver/core/networking/api_helper.dart';
import 'package:hawiah_driver/core/networking/urls.dart';
import 'package:hawiah_driver/features/setting/cubit/setting_state.dart';
import 'package:hawiah_driver/features/setting/model/setting_model.dart';

class SettingCubit extends Cubit<SettingState> {
  static SettingCubit get(BuildContext context) => BlocProvider.of(context);

  SettingCubit() : super(SettingInitial());

  void initialSetting() {
    _settingResponse = ApiResponse(state: ResponseState.sleep, data: null);
    _setting = null;
    emit(SettingUpdate());
  }

  ApiResponse _settingResponse = ApiResponse(state: ResponseState.sleep, data: null);
  ApiResponse get settingResponse => _settingResponse;

  SettingModel? _setting;
  SettingModel? get setting => _setting;

  Future<void> getsetting() async {
    _settingResponse = ApiResponse(state: ResponseState.loading, data: null);
    _setting = null;
    emit(SettingUpdate());
    _settingResponse = await ApiHelper.instance.get("${Urls.settings}");
    emit(SettingLoading());
    if (_settingResponse.state == ResponseState.complete) {
      _setting = SettingModel.fromJson(_settingResponse.data['data']);
      emit(SettingUpdate());
    } else if (_settingResponse.state == ResponseState.unauthorized) {
      emit(SettingUpdate());
    }
  }
}
