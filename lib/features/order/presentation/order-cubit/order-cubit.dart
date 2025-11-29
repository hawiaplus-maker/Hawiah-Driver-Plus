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
import 'package:hawiah_driver/features/order/presentation/model/orders_model.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:table_calendar/table_calendar.dart';

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
    // التعديل هنا: لن يتم التوقف إذا كان isRefresh = true
    if (!isLoadMore && !isRefresh) {
      if (isCurrent && currentOrders.isNotEmpty) {
        log("✔ Skipping fetch: current orders already loaded");
        emit(OrderSuccess(
          ordersModel: OrdersModel(
            data: OrdersData(
              data: currentOrders,
              pagination: Pagination(
                currentPage: currentPageCurrent,
                lastPage: lastPageCurrent,
              ),
            ),
          ),
        ));
        return;
      }

      if (!isCurrent && oldOrders.isNotEmpty) {
        log("✔ Skipping fetch: old orders already loaded");
        emit(OrderSuccess(
          ordersModel: OrdersModel(
            data: OrdersData(
              data: oldOrders,
              pagination: Pagination(
                currentPage: currentPageOld,
                lastPage: lastPageOld,
              ),
            ),
          ),
        ));
        return;
      }
    }

    // =================== Load =====================
    if (isLoadMore) {
      if (isCurrent ? isLoadingMoreCurrent : isLoadingMoreOld) return;
      if (isCurrent) {
        isLoadingMoreCurrent = true;
      } else {
        isLoadingMoreOld = true;
      }
      emit(OrderPaginationLoading());
    } else {
      if (isCurrent) {
        isLoadingCurrent = true;
      } else {
        isLoadingOld = true;
      }
      // إذا كنت تريد أن يظهر Loading أثناء الرفرش اترك هذا السطر،
      // أما إذا كنت تستخدم RefreshIndicator في الواجهة وتريد اختفاء اللودينج القديم، يمكنك وضع شرط هنا.
      emit(OrderLoading());
    }

    // =================== API =====================
    final response = await ApiHelper.instance.get(
      Urls.orders(orderStatus),
      queryParameters: {
        "order_status": orderStatus,
        "page": page,
      },
    );

    if (response.state == ResponseState.complete) {
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
    } else {
      if (isCurrent) {
        isLoadingCurrent = false;
        isLoadingMoreCurrent = false;
      } else {
        isLoadingOld = false;
        isLoadingMoreOld = false;
      }
      emit(OrderError());
    }
  }

  compressImage(File file) async {
    final dir = await getTemporaryDirectory();
    final targetPath = path.join(dir.absolute.path, 'compressed_${path.basename(file.path)}');

    final result = await FlutterImageCompress.compressAndGetFile(
      file.absolute.path,
      targetPath,
      quality: 50, // Adjust quality (0-100)
      format: CompressFormat.jpeg,
    );

    return result ?? file; // fallback to original if compression fails
  }

  ApiResponse _ordersResponse = ApiResponse(state: ResponseState.sleep, data: null);
  Future<void> confirmOrders({
    required int orderId,
    required otp,
    required lat,
    required long,
    required File img,
  }) async {
    XFile imageFile = await compressImage(File(img.path));
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
      emit(OrderError());
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
      CommonMethods.showAlertDialog(
        message: tr(AppLocaleKey.youMustLogInFirst),
      );
    } else {
      CommonMethods.showError(
        message: response.data['message'] ?? 'حدث خطاء',
        apiResponse: response,
      );
    }
  }
  //?================== create order ====================
}
