import 'dart:developer';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:hawiah_driver/core/locale/app_locale_key.dart';
import 'package:hawiah_driver/core/networking/api_helper.dart';
import 'package:hawiah_driver/core/networking/urls.dart';
import 'package:hawiah_driver/core/utils/common_methods.dart';
import 'package:hawiah_driver/core/utils/navigator_methods.dart';
import 'package:hawiah_driver/features/authentication/presentation/screens/login-screen.dart';
import 'package:hawiah_driver/features/order/presentation/model/orders_model.dart';
import 'package:hawiah_driver/features/order/presentation/model/single_order_model.dart'
    hide SingleOrderData;
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../../../core/routes/app_routers_import.dart';
import 'order-state.dart';

class OrderCubit extends Cubit<OrderState> {
  static OrderCubit get(BuildContext context) => BlocProvider.of(context);

  OrderCubit() : super(OrderInitial());

  changeRebuild() {
    emit(OrderChange());
  }

  bool isOrderCurrent = true;

  void changeOrderCurrent() {
    isOrderCurrent = !isOrderCurrent;
    emit(OrderChange());
  }

  CalendarFormat calendarFormat = CalendarFormat.month;
  RangeSelectionMode rangeSelectionMode = RangeSelectionMode.toggledOn;
  DateTime focusedDay = DateTime.now();
  DateTime? selectedDay;
  DateTime? rangeStart;
  DateTime? rangeEnd;

// =================== Orders ====================

// current orders
  List<SingleOrderData> currentOrders = [];
  int currentPageCurrent = 1;
  int lastPageCurrent = 1;
  bool isLoadingCurrent = false;
  bool isLoadingMoreCurrent = false;

// old orders
  List<SingleOrderData> oldOrders = [];
  int currentPageOld = 1;
  int lastPageOld = 1;
  bool isLoadingOld = false;
  bool isLoadingMoreOld = false;

// Helpers
  bool get canLoadMoreCurrent => currentPageCurrent < lastPageCurrent;
  bool get canLoadMoreOld => currentPageOld < lastPageOld;

// =================== Main API Function ====================// =================== Main API Function ====================
  Future<void> getOrders({
    required int orderStatus,
    int page = 1,
    bool isLoadMore = false,
    bool isRefresh = false,
  }) async {
    log("**************************** getOrders($orderStatus) *************************");

    final bool isCurrent = orderStatus == 0;

    // إذا كان تحديث، تأكد أن الصفحة هي الأولى دائماً
    if (isRefresh) {
      page = 1;
    }

    // =================== Prevent Re-fetching =====================
    // Removed to force reload every time

    // =================== Load =====================
    if (isLoadMore) {
      if (isCurrent) {
        if (!canLoadMoreCurrent || isLoadingMoreCurrent) return;
        isLoadingMoreCurrent = true;
      } else {
        if (!canLoadMoreOld || isLoadingMoreOld) return;
        isLoadingMoreOld = true;
      }
      emit(OrderPaginationLoading());
    } else {
      if (isCurrent) {
        isLoadingCurrent = true;
        currentOrders = [];
      } else {
        isLoadingOld = true;
        oldOrders = [];
      }
      // إذا كنت تريد أن يظهر Loading أثناء الرفرش اترك هذا السطر،
      // أما إذا كنت تستخدم RefreshIndicator في الواجهة وتريد اختفاء اللودينج القديم، يمكنك وضع شرط هنا.
      emit(OrderLoading());
    }

    // =================== API =====================
    final response = await ApiHelper.instance.get(
      Urls.orders(orderStatus),
      queryParameters: {
        "page": page,
      },
    );

    if (response.state == ResponseState.complete) {
      try {
        final result = OrdersModel.fromJson(response.data);
        final newOrders = result.data?.data ?? [];
        final pagination = result.data?.pagination;

        if (isCurrent) {
          currentPageCurrent = pagination?.currentPage ?? 1;
          lastPageCurrent = pagination?.lastPage ?? 1;
        } else {
          currentPageOld = pagination?.currentPage ?? 1;
          lastPageOld = pagination?.lastPage ?? 1;
        }

        // داخل دالة getOrders في حالة النجاح
        if (isLoadMore) {
          if (isCurrent) {
            currentOrders.addAll(newOrders);
            isLoadingMoreCurrent = false;
          } else {
            oldOrders.addAll(newOrders);
            isLoadingMoreOld = false;
          }
        } else {
          if (isCurrent) {
            currentOrders = newOrders; // استبدال القائمة بالكامل
            isLoadingCurrent = false;
          } else {
            oldOrders = newOrders; // استبدال القائمة بالكامل
            isLoadingOld = false;
          }
        }

        // هام: إرسال الحالة بعد تحديث المتغيرات
        emit(OrderSuccess(ordersModel: result));
      } catch (e) {
        log("Error parsing orders: $e");
        if (isCurrent) {
          isLoadingCurrent = false;
          isLoadingMoreCurrent = false;
        } else {
          isLoadingOld = false;
          isLoadingMoreOld = false;
        }

        // Use response.getMessage() or fallback to the exception message
        final errorMsg = response.getMessage().isNotEmpty ? response.getMessage() : e.toString();
        emit(OrderError(errorMsg));
      }
    } else if (response.state == ResponseState.unauthorized) {
      if (isCurrent) {
        isLoadingCurrent = false;
        isLoadingMoreCurrent = false;
      } else {
        isLoadingOld = false;
        isLoadingMoreOld = false;
      }
      emit(Unauthenticated());
    } else {
      if (isCurrent) {
        isLoadingCurrent = false;
        isLoadingMoreCurrent = false;
      } else {
        isLoadingOld = false;
        isLoadingMoreOld = false;
      }

      final errorMsg =
          response.getMessage().isNotEmpty ? response.getMessage() : "Failed to load orders";

      emit(OrderError(errorMsg));
    }
  }

  Future<File> compressImage(File file) async {
    int sizeInBytes = file.lengthSync();
    double sizeInKb = sizeInBytes / 1024;

    if (sizeInKb < 500) {
      return file;
    }

    final dir = await getTemporaryDirectory();
    final targetPath =
        path.join(dir.absolute.path, 'compressed_${DateTime.now().millisecondsSinceEpoch}.jpg');

    var result = await FlutterImageCompress.compressAndGetFile(
      file.absolute.path,
      targetPath,
      quality: 70,
      minWidth: 1024,
      minHeight: 1024,
    );

    int quality = 70;
    while (result != null && await result.length() > 500 * 1024 && quality > 10) {
      quality -= 10;
      final newTargetPath = path.join(
          dir.absolute.path, 'compressed_${DateTime.now().millisecondsSinceEpoch}_$quality.jpg');
      result = await FlutterImageCompress.compressAndGetFile(
        file.absolute.path,
        newTargetPath,
        quality: quality,
        minWidth: 1024,
        minHeight: 1024,
      );
    }

    return result != null ? File(result.path) : file;
  }

  //================== confirm order ====================
  ApiResponse _ordersResponse = ApiResponse(state: ResponseState.sleep, data: null);
  Future<void> confirmOrders({
    required int orderId,
    required otp,
    required lat,
    required long,
    required File img,
  }) async {
    File imageFile = await compressImage(img);
    final data = <String, dynamic>{
      'otp': otp,
      'latitude': lat,
      'longitude': long,
    };
    data['hawiah_image'] = await MultipartFile.fromFile(imageFile.path,
        filename: "hawiah.jpg", contentType: DioMediaType('image', 'jpg'));

    final formData = FormData.fromMap(data);

    emit(OrderLoading());
    _ordersResponse = ApiResponse(state: ResponseState.loading, data: null);
    var _success = null;
    emit(OrderLoading());
    _ordersResponse = await ApiHelper.instance.post(
      Urls.confirmOrders(orderId),
      body: formData,
      hasToken: true,
      isMultipart: true,
    );
    emit(OrderChange());

    if (_ordersResponse.data['success'] == true) {
      emit(OrderConfirmed(success: _success));
    } else {
      emit(OrderError(_ordersResponse.getMessage().isNotEmpty
          ? _ordersResponse.getMessage()
          : tr(AppLocaleKey.unknownError)));
    }
  }

  //========================== empty order ==========================
  ApiResponse _emptyOrdersResponse = ApiResponse(state: ResponseState.sleep, data: null);
  Future<void> confirmEmptyOrder({
    required int orderId,
    required lat,
    required long,
    required File img,
    required VoidCallback onSuccess,
  }) async {
    File imageFile = await compressImage(img);
    final data = <String, dynamic>{
      'empty_latitude': lat,
      'empty_longitude': long,
    };
    data['empty_image'] = await MultipartFile.fromFile(imageFile.path,
        filename: "hawiah.jpg", contentType: DioMediaType('image', 'jpg'));

    final formData = FormData.fromMap(data);

    emit(OrderLoading());
    _emptyOrdersResponse = ApiResponse(state: ResponseState.loading, data: null);
    var _success = null;
    emit(OrderLoading());
    _emptyOrdersResponse = await ApiHelper.instance.post(
      Urls.confirmEmptyOrders(orderId),
      body: formData,
      hasToken: true,
      isMultipart: true,
    );
    emit(OrderChange());

    if (_emptyOrdersResponse.data['success'] == true) {
      emit(OrderConfirmed(success: _success));
      onSuccess.call();
    } else {
      emit(OrderError(_emptyOrdersResponse.getMessage().isNotEmpty
          ? _emptyOrdersResponse.getMessage()
          : tr(AppLocaleKey.unknownError)));
    }
  }

  //================== get nearby provider ====================

  Future<void> getNearbyProviders({
    required int catigoryId,
    required int addressId,
    required VoidCallback onSuccess,
  }) async {
    NavigatorMethods.loading();
    FormData body = FormData.fromMap({
      'product_id': catigoryId,
      'address_id': addressId,
    });
    final response = await ApiHelper.instance.post(
      Urls.getNearbyProviders,
      body: body,
    );
    NavigatorMethods.loadingOff();
    if (response.state == ResponseState.complete) {
      onSuccess.call();
    } else if (response.state == ResponseState.unauthorized) {
      NavigatorMethods.pushNamedAndRemoveUntil(
          AppRouters.navigatorKey.currentContext!, LoginScreen.routeName);
    } else {
      CommonMethods.showError(
        message: response.getMessage().isNotEmpty
            ? response.getMessage()
            : tr(AppLocaleKey.anErrorOccurred),
        apiResponse: response,
      );
    }
  }

  //?================== singleOrder ====================
  Future<void> singleOrder({required int orderId}) async {
    emit(OrderLoading());

    final response = await ApiHelper.instance.get(Urls.showOrder(orderId));

    if (response.state == ResponseState.complete) {
      if (response.data?['success'] == true && response.data?['data'] != null) {
        final order = SingleOrderModel.fromJson(response.data);
        emit(CurrentOrderLoaded(order));
      } else {
        emit(CurrentOrderError(response.getMessage().isNotEmpty
            ? response.getMessage()
            : tr(AppLocaleKey.anErrorOccurred)));
      }
    } else if (response.state == ResponseState.unauthorized) {
      NavigatorMethods.pushNamedAndRemoveUntil(
          AppRouters.navigatorKey.currentContext!, LoginScreen.routeName);
    } else {
      emit(CurrentOrderError(response.getMessage().isNotEmpty
          ? response.getMessage()
          : tr(AppLocaleKey.anErrorOccurred)));
    }
  }
}
