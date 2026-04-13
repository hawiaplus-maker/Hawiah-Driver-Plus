import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hawiah_driver/core/locale/app_locale_key.dart';
import 'package:hawiah_driver/core/networking/api_helper.dart';
import 'package:hawiah_driver/core/networking/urls.dart';
import 'package:hawiah_driver/core/utils/common_methods.dart';
import 'package:hawiah_driver/core/utils/navigator_methods.dart';
import 'package:hawiah_driver/features/location/presentation/cubit/address_state.dart';

class AddressCubit extends Cubit<AddressState> {
  static AddressCubit get(BuildContext context) => BlocProvider.of(context);

  AddressCubit() : super(AddressInitial());

  changeRebuild() {
    emit(AddressUpdate());
  }

//====================== neighborhoods

  void initialNeighborhoods() {
    _neighborhoodsResponse = ApiResponse(
      state: ResponseState.sleep,
      data: null,
    );
    emit(AddressUpdate());
  }

  ApiResponse _neighborhoodsResponse = ApiResponse(
    state: ResponseState.sleep,
    data: null,
  );
  ApiResponse get neighborhoodsResponse => _neighborhoodsResponse;

  Future<void> getneighborhoods(int id) async {
    _neighborhoodsResponse = ApiResponse(
      state: ResponseState.loading,
      data: null,
    );
    emit(AddressUpdate());
    _neighborhoodsResponse = await ApiHelper.instance.get(
      Urls.neighborhoodsByCity(id),
    );
    if (_neighborhoodsResponse.state == ResponseState.complete && _neighborhoodsResponse.data != null) {
      final dynamic messageData = _neighborhoodsResponse.data['message'];
      if (messageData is Iterable) {
        // Data is correctly an iterable, we can proceed
        // (If there was a local list to populate, we'd do it here)
      } else {
        // API returned something else (likely a string error despite 'complete' state)
        CommonMethods.showError(
          message: _neighborhoodsResponse.getMessage().isNotEmpty 
              ? _neighborhoodsResponse.getMessage() 
              : tr(AppLocaleKey.anErrorOccurred),
          apiResponse: _neighborhoodsResponse,
        );
      }
      emit(AddressUpdate());
    }
  }
  //====================== Store Address ===================================

  Future<void> storeAddress(
      {required String title,
      required double latitude,
      required double longitude,
      required int neighborhoodId,
      required VoidCallback onSuccess}) async {
    NavigatorMethods.loading();
    FormData body = FormData.fromMap({
      'title': title,
      'latitude': latitude,
      'longitude': longitude,
      'neighborhood_id': neighborhoodId
    });
    final response = await ApiHelper.instance.post(
      Urls.storeAddress,
      body: body,
    );
    NavigatorMethods.loadingOff();
    if (response.state == ResponseState.complete) {
      CommonMethods.showToast(message: tr(AppLocaleKey.saveChangesSuccess));
      onSuccess.call();
    } else if (response.state == ResponseState.unauthorized) {
      CommonMethods.showAlertDialog(
        message: tr(AppLocaleKey.youMustLogInFirst),
      );
    } else {
      CommonMethods.showError(
        message: response.getMessage().isNotEmpty ? response.getMessage() : tr(AppLocaleKey.anErrorOccurred),
        apiResponse: response,
      );
    }
  }

  //*===================================== update address ====================
  Future<void> updateAddress(
      {required String title,
      required double latitude,
      required double longitude,
      required int neighborhoodId,
      required int addressId,
      required VoidCallback onSuccess}) async {
    NavigatorMethods.loading();
    FormData body = FormData.fromMap({
      'title': title,
      'latitude': latitude,
      'longitude': longitude,
      'neighborhood_id': neighborhoodId
    });
    final response = await ApiHelper.instance.put(
      Urls.updateAddress(addressId),
      body: body,
    );
    NavigatorMethods.loadingOff();
    if (response.state == ResponseState.complete) {
      CommonMethods.showToast(message: tr(AppLocaleKey.saveChangesSuccess));
      onSuccess.call();
    } else if (response.state == ResponseState.unauthorized) {
      CommonMethods.showAlertDialog(
        message: tr(AppLocaleKey.youMustLogInFirst),
      );
    } else {
      CommonMethods.showError(
        message: response.getMessage().isNotEmpty ? response.getMessage() : tr(AppLocaleKey.anErrorOccurred),
        apiResponse: response,
      );
    }
  }

  //*===================================== Get All Address ===================
  void initialaddresses() {
    _addressesResponse = ApiResponse(
      state: ResponseState.sleep,
      data: null,
    );
    emit(AddressUpdate());
  }

  ApiResponse _addressesResponse = ApiResponse(
    state: ResponseState.sleep,
    data: null,
  );
  ApiResponse get addressesResponse => _addressesResponse;

  Future<void> getaddresses() async {
    _addressesResponse = ApiResponse(
      state: ResponseState.loading,
      data: null,
    );

    emit(AddressUpdate());
    _addressesResponse = await ApiHelper.instance.get(
      Urls.addresses,
    );
    if (_addressesResponse.state == ResponseState.complete && _addressesResponse.data != null) {
      final dynamic messageData = _addressesResponse.data['message'];
      if (messageData is Iterable) {
         // Proceed with population if needed
      } else {
        CommonMethods.showError(
          message: _addressesResponse.getMessage().isNotEmpty 
              ? _addressesResponse.getMessage() 
              : tr(AppLocaleKey.anErrorOccurred),
          apiResponse: _addressesResponse,
        );
      }
      emit(AddressUpdate());
    }
  }
}
