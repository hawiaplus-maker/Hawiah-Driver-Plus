import 'dart:developer';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hawiah_driver/core/images/image_compressor.dart';
import 'package:hawiah_driver/core/locale/app_locale_key.dart';
import 'package:hawiah_driver/core/hive/hive_methods.dart';
import 'package:hawiah_driver/core/networking/api_helper.dart';
import 'package:hawiah_driver/core/networking/urls.dart';
import 'package:hawiah_driver/core/utils/common_methods.dart';
import 'package:hawiah_driver/core/utils/navigator_methods.dart';
import 'package:hawiah_driver/features/authentication/presentation/screens/login-screen.dart';
import 'package:hawiah_driver/features/order/presentation/model/cleaning_contract_delivery_model.dart';
import 'package:hawiah_driver/features/order/presentation/model/orders_model.dart';
import 'package:hawiah_driver/features/order/presentation/model/project_discharge_model.dart';
import 'package:hawiah_driver/features/order/presentation/model/single_order_model.dart'
    hide SingleOrderData;
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

// cleaning contracts deliveries
  List<CleaningContractDeliveryItem> cleaningContractDeliveries = [];
  List<CleaningContractDeliveryItem> cleaningCurrentOrders = [];
  List<CleaningContractDeliveryItem> cleaningOldOrders = [];
  int cleaningCurrentPage = 1;
  int cleaningLastPage = 1;
  bool isLoadingCleaningContract = false;
  bool isLoadingMoreCleaningContract = false;

// cleaning contracts discharges (cleaning contract mode: the two tabs)
  List<CleaningContractDeliveryItem> cleaningDischarges = [];
  List<CleaningContractDeliveryItem> cleaningCurrentDischarges = [];
  List<CleaningContractDeliveryItem> cleaningOldDischarges = [];
  int dischargeCurrentPage = 1;
  int dischargeLastPage = 1;
  bool isLoadingDischarges = false;
  bool isLoadingMoreDischarges = false;
  bool dischargeLoadedOnce = false;

// Helpers
  bool get canLoadMoreCurrent => currentPageCurrent < lastPageCurrent;
  bool get canLoadMoreOld => currentPageOld < lastPageOld;

  /// When the driver has cleaning_contract_work enabled, serve cleaning
  /// contract deliveries instead of regular orders.
  ///
  /// The flags are read from Hive (saved at login) because AuthCubit is
  /// registered as a factory — every sl<AuthCubit>() creates a fresh instance
  /// with null flags, which caused the cleaning flow to never trigger.
  /// NOTE: the profile API (work_types.orders/enabled work types) reflects
  /// *allowed* capabilities, not the active session flags, so it must NOT
  /// override the login values.
  ///
  /// `cleaning_contract_work` describes the driver's active work type, so it
  /// wins over `order_work` (the account may keep its regular-orders
  /// capability flag while the cleaning contract flow is the active one).
  bool get isCleaningContractMode =>
      HiveMethods.getCleaningContractWork() == true;

// project work (project pickups / discharges)
  List<ProjectDischargeItem> projectDischarges = [];
  List<ProjectDischargeItem> projectCurrentOrders = [];
  List<ProjectDischargeItem> projectOldOrders = [];
  int projectCurrentPage = 1;
  int projectLastPage = 1;
  bool isLoadingProject = false;
  bool isLoadingMoreProject = false;

  /// Project-discharges mode: project_work is on and none of the higher
  /// priority work types are active (order_work > cleaning > projects).
  bool get isProjectWorkMode =>
      HiveMethods.getProjectWork() == true &&
      HiveMethods.getOrderWork() != true &&
      HiveMethods.getCleaningContractWork() != true;

  bool get canLoadMoreProject => projectCurrentPage < projectLastPage;

  /// Fetches project pickups (project discharges) and splits them into
  /// current (not completed) and old (completed) lists.
  Future<void> getProjectDischarges({
    required int
        orderStatus, // 0 = current, 1 = old (drives nothing server-side;
    // the endpoint is fetched once and split client-side, like deliveries)
    int page = 1,
    bool isLoadMore = false,
    bool isRefresh = false,
  }) async {
    log("**************************** getProjectDischarges($orderStatus, page: $page) *************************");

    if (isRefresh) {
      page = 1;
    }

    if (isLoadMore) {
      if (!canLoadMoreProject || isLoadingMoreProject) return;
      isLoadingMoreProject = true;
      emit(OrderPaginationLoading());
    } else {
      isLoadingProject = true;
      // A refresh keeps the current list visible until the new data lands,
      // so the cards don't flash a loading shimmer while acting on a pickup.
      if (!isRefresh) {
        emit(OrderLoading());
      }
    }

    final response = await ApiHelper.instance.get(
      Urls.projectDischarges,
      queryParameters: {"page": page},
    );

    if (response.state == ResponseState.complete) {
      try {
        final result = ProjectDischargeModel.fromJson(response.data);
        final newItems = result.data?.data ?? [];
        final pagination = result.data?.pagination;

        projectCurrentPage = pagination?.currentPage ?? 1;
        projectLastPage = pagination?.lastPage ?? 1;

        final List<ProjectDischargeItem> allItems;
        if (isLoadMore) {
          projectDischarges.addAll(newItems);
          allItems = projectDischarges;
        } else {
          projectDischarges = newItems;
          allItems = newItems;
        }

        projectCurrentOrders = allItems.where((e) => !e.isCompleted).toList();
        projectOldOrders = allItems.where((e) => e.isCompleted).toList();

        if (isLoadMore) {
          isLoadingMoreProject = false;
        } else {
          isLoadingProject = false;
        }

        emit(OrderSuccess(ordersModel: null));
      } catch (e) {
        log("Error parsing project discharges: $e");
        isLoadingProject = false;
        isLoadingMoreProject = false;
        final errorMsg = response.getMessage().isNotEmpty
            ? response.getMessage()
            : e.toString();
        emit(OrderError(errorMsg));
      }
    } else if (response.state == ResponseState.unauthorized) {
      isLoadingProject = false;
      isLoadingMoreProject = false;
      emit(Unauthenticated());
    } else {
      isLoadingProject = false;
      isLoadingMoreProject = false;
      final errorMsg = response.getMessage().isNotEmpty
          ? response.getMessage()
          : "Failed to load project discharges";
      emit(OrderError(errorMsg));
    }
  }

  bool get canLoadMoreCleaningContract =>
      cleaningCurrentPage < cleaningLastPage;

  bool get canLoadMoreDischarges => dischargeCurrentPage < dischargeLastPage;

  // =================== Project pickup actions ====================

  /// Starts the trip of an assigned project pickup.
  ///
  /// POST `{{baseUrl}}drivers/project-discharges/{pickupId}/start-trip`
  /// body: `image_before` (multipart).
  ///
  /// On success the pickup status becomes `in_trans` and the orders list is
  /// refreshed so the action button turns into "Complete Discharging".
  Future<void> startProjectTrip({
    required int pickupId,
    required File image,
  }) async {
    log("**************************** startProjectTrip($pickupId) *************************");
    if (isClosed) return;
    emit(DischargeActionLoading(pickupId));

    try {
      final imageFile = await compressImage(image);
      final formData = FormData.fromMap({
        'image_before': await MultipartFile.fromFile(
          imageFile.path,
          filename: "image_before.jpg",
          contentType: DioMediaType('image', 'jpg'),
        ),
      });

      final response = await ApiHelper.instance.post(
        Urls.startProjectTrip(pickupId),
        body: formData,
        hasToken: true,
        isMultipart: true,
      );

      if (isClosed) return;

      if (response.state == ResponseState.unauthorized) {
        emit(Unauthenticated());
        return;
      }

      if (response.state == ResponseState.complete &&
          _isSuccessResponse(response)) {
        emit(DischargeActionSuccess(
            pickupId, tr(AppLocaleKey.startTripSuccess)));
        await _refreshProjectDischarges();
        return;
      }

      emit(DischargeActionError(
        pickupId,
        response.getMessage().isNotEmpty
            ? response.getMessage()
            : tr(AppLocaleKey.anErrorOccurred),
      ));
    } catch (e) {
      log("Error starting project trip: $e");
      if (isClosed) return;
      emit(DischargeActionError(pickupId, tr(AppLocaleKey.anErrorOccurred)));
    }
  }

  /// Completes a project pickup discharge.
  ///
  /// POST `{{baseUrl}}drivers/project-discharges/{pickupId}/complete`
  /// body: `image_after` (multipart), `latitude`, `longitude`, `driver_notes`.
  ///
  /// On success the pickup is marked as completed and the orders list is
  /// refreshed so the pickup moves to the "End" tab.
  Future<void> completeProjectDischarge({
    required int pickupId,
    required File image,
    required double latitude,
    required double longitude,
    String? driverNotes,
  }) async {
    log("**************************** completeProjectDischarge($pickupId) *************************");
    if (isClosed) return;
    emit(DischargeActionLoading(pickupId));

    try {
      final imageFile = await compressImage(image);
      final formData = FormData.fromMap({
        'image_after': await MultipartFile.fromFile(
          imageFile.path,
          filename: "image_after.jpg",
          contentType: DioMediaType('image', 'jpg'),
        ),
        'latitude': latitude,
        'longitude': longitude,
        'driver_notes': (driverNotes ?? '').trim(),
      });

      final response = await ApiHelper.instance.post(
        Urls.completeProjectDischarge(pickupId),
        body: formData,
        hasToken: true,
        isMultipart: true,
      );

      if (isClosed) return;

      if (response.state == ResponseState.unauthorized) {
        emit(Unauthenticated());
        return;
      }

      if (response.state == ResponseState.complete &&
          _isSuccessResponse(response)) {
        emit(DischargeActionSuccess(
            pickupId, tr(AppLocaleKey.completeDischargeSuccess)));
        await _refreshProjectDischarges();
        return;
      }

      emit(DischargeActionError(
        pickupId,
        response.getMessage().isNotEmpty
            ? response.getMessage()
            : tr(AppLocaleKey.anErrorOccurred),
      ));
    } catch (e) {
      log("Error completing project discharge: $e");
      if (isClosed) return;
      emit(DischargeActionError(pickupId, tr(AppLocaleKey.anErrorOccurred)));
    }
  }

  /// Completes a cleaning contract discharge.
  ///
  /// POST `{{baseUrl}}v2/drivers/cleaning-contracts-discharges/{id}/complete`
  /// body: `image_after` (multipart), `latitude`, `longitude`, `driver_notes`.
  ///
  /// On success the record is marked as discharged and the list is refreshed
  /// so the button disappears.
  Future<void> completeCleaningContractDischarge({
    required int dischargeId,
    required File image,
    required double latitude,
    required double longitude,
    String? driverNotes,
  }) async {
    log("**************************** completeCleaningContractDischarge($dischargeId) *************************");
    if (isClosed) return;
    emit(DischargeActionLoading(dischargeId));

    try {
      final imageFile = await compressImage(image);
      final formData = FormData.fromMap({
        'image_after': await MultipartFile.fromFile(
          imageFile.path,
          filename: "image_after.jpg",
          contentType: DioMediaType('image', 'jpg'),
        ),
        'latitude': latitude,
        'longitude': longitude,
        'driver_notes': (driverNotes ?? '').trim(),
      });

      final response = await ApiHelper.instance.post(
        Urls.completeCleaningContractDischarge(dischargeId),
        body: formData,
        hasToken: true,
        isMultipart: true,
      );

      if (isClosed) return;

      if (response.state == ResponseState.unauthorized) {
        emit(Unauthenticated());
        return;
      }

      if (response.state == ResponseState.complete &&
          _isSuccessResponse(response)) {
        emit(DischargeActionSuccess(
            dischargeId, tr(AppLocaleKey.completeDischargeSuccess)));
        await _refreshCleaningContractDischarges();
        return;
      }

      emit(DischargeActionError(
        dischargeId,
        response.getMessage().isNotEmpty
            ? response.getMessage()
            : tr(AppLocaleKey.anErrorOccurred),
      ));
    } catch (e) {
      log("Error completing the cleaning contract discharge: $e");
      if (isClosed) return;
      emit(DischargeActionError(dischargeId, tr(AppLocaleKey.anErrorOccurred)));
    }
  }

  /// Reloads the project pickups after an action so the cards show the new
  /// status (assigned -> in_trans -> completed).
  Future<void> _refreshProjectDischarges() async {
    if (isClosed) return;
    await getProjectDischarges(orderStatus: 0, isRefresh: true);
  }

  /// Reloads the cleaning contract discharges after an action so the cards
  /// move from the current tab to the completed one.
  Future<void> _refreshCleaningContractDischarges() async {
    if (isClosed) return;
    await getCleaningContractDischarges(isRefresh: true);
  }

  /// The API wraps every payload in `{success, message, data}` — a response
  /// without an explicit `success: false` is treated as a success.
  bool _isSuccessResponse(ApiResponse response) {
    final data = response.data;
    if (data is Map) {
      return data['success'] != false;
    }
    return true;
  }

  /// Fetches container discharge (emptying) records for the third tab.
  Future<void> getCleaningContractDischarges({
    int page = 1,
    bool isLoadMore = false,
    bool isRefresh = false,
  }) async {
    log("**************************** getCleaningContractDischarges($page) *************************");

    if (isRefresh) {
      page = 1;
      dischargeLoadedOnce = false;
    }

    if (isLoadMore) {
      if (!canLoadMoreDischarges || isLoadingMoreDischarges) return;
      isLoadingMoreDischarges = true;
      emit(OrderPaginationLoading());
    } else {
      isLoadingDischarges = true;
      if (!isRefresh) {
        // Pull-to-refresh keeps existing data visible until the new page lands.
        cleaningDischarges = [];
        emit(OrderLoading());
      }
    }

    final response = await ApiHelper.instance.get(
      Urls.cleaningContractsDischarges,
      queryParameters: {"page": page},
    );

    if (response.state == ResponseState.complete) {
      try {
        final result = CleaningContractDeliveryModel.fromJson(response.data);
        final newItems = result.data?.data ?? [];
        final pagination = result.data?.pagination;

        dischargeCurrentPage = pagination?.currentPage ?? 1;
        dischargeLastPage = pagination?.lastPage ?? 1;

        if (isLoadMore) {
          cleaningDischarges.addAll(newItems);
          isLoadingMoreDischarges = false;
        } else {
          cleaningDischarges = newItems;
          isLoadingDischarges = false;
        }

        // The cleaning screen has two tabs fed by this single endpoint:
        // current (not discharged yet) and end (completed).
        cleaningCurrentDischarges =
            cleaningDischarges.where((e) => !e.isCompleted).toList();
        cleaningOldDischarges =
            cleaningDischarges.where((e) => e.isCompleted).toList();

        dischargeLoadedOnce = true;
        emit(OrderSuccess(ordersModel: null));
      } catch (e) {
        log("Error parsing cleaning contract discharges: $e");
        isLoadingDischarges = false;
        isLoadingMoreDischarges = false;
        emit(OrderError(response.getMessage().isNotEmpty
            ? response.getMessage()
            : e.toString()));
      }
    } else if (response.state == ResponseState.unauthorized) {
      isLoadingDischarges = false;
      isLoadingMoreDischarges = false;
      emit(Unauthenticated());
    } else {
      isLoadingDischarges = false;
      isLoadingMoreDischarges = false;
      emit(OrderError(response.getMessage().isNotEmpty
          ? response.getMessage()
          : "Failed to load cleaning contract discharges"));
    }
  }

// =================== Main API Function ====================// =================== Main API Function ====================
  Future<void> getOrders({
    required int orderStatus,
    int page = 1,
    bool isLoadMore = false,
    bool isRefresh = false,
  }) async {
    log("**************************** getOrders($orderStatus) *************************");

    // When cleaning contract work is enabled, the discharges are the work
    // list. Both tabs split it client-side by completion state.
    if (isCleaningContractMode) {
      await getCleaningContractDischarges(
        page: page,
        isLoadMore: isLoadMore,
        isRefresh: isRefresh,
      );
      return;
    }

    // When project work is enabled, serve project pickups (discharges).
    if (isProjectWorkMode) {
      await getProjectDischarges(
        orderStatus: orderStatus,
        page: page,
        isLoadMore: isLoadMore,
        isRefresh: isRefresh,
      );
      return;
    }

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
        final errorMsg = response.getMessage().isNotEmpty
            ? response.getMessage()
            : e.toString();
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

      final errorMsg = response.getMessage().isNotEmpty
          ? response.getMessage()
          : "Failed to load orders";

      emit(OrderError(errorMsg));
    }
  }

  // =================== Cleaning Contract Deliveries ====================
  /// Fetches the cleaning contract deliveries and splits them into current
  /// (not completed) and old (completed) lists — exactly like
  /// [getProjectDischarges] does for project pickups.
  ///
  /// GET `{{baseUrl}}v2/drivers/cleaning-contracts-deliveries?page=1`
  ///
  /// The endpoint returns every delivery of the driver; [orderStatus] does not
  /// filter anything server-side, it only tells the caller which tab asked
  /// (kept so both flows share the same signature).
  Future<void> getCleaningContractDeliveries({
    required int orderStatus, // 0 = current, 1 = old (no server-side filter)
    int page = 1,
    bool isLoadMore = false,
    bool isRefresh = false,
  }) async {
    log("**************************** getCleaningContractDeliveries($orderStatus, page: $page) *************************");

    if (isRefresh) {
      page = 1;
    }

    if (isLoadMore) {
      if (!canLoadMoreCleaningContract || isLoadingMoreCleaningContract) return;
      isLoadingMoreCleaningContract = true;
      emit(OrderPaginationLoading());
    } else {
      isLoadingCleaningContract = true;
      // A refresh keeps the current list visible until the new data lands,
      // so the cards don't flash a loading shimmer while acting on a delivery.
      if (!isRefresh) {
        emit(OrderLoading());
      }
    }

    final response = await ApiHelper.instance.get(
      Urls.cleaningContractsDeliveries,
      queryParameters: {"page": page},
    );

    if (response.state == ResponseState.complete) {
      try {
        final result = CleaningContractDeliveryModel.fromJson(response.data);
        final newItems = result.data?.data ?? [];
        final pagination = result.data?.pagination;

        cleaningCurrentPage = pagination?.currentPage ?? 1;
        cleaningLastPage = pagination?.lastPage ?? 1;

        final List<CleaningContractDeliveryItem> allItems;
        if (isLoadMore) {
          cleaningContractDeliveries.addAll(newItems);
          allItems = cleaningContractDeliveries;
        } else {
          cleaningContractDeliveries = newItems;
          allItems = newItems;
        }

        cleaningCurrentOrders = allItems.where((e) => !e.isCompleted).toList();
        cleaningOldOrders = allItems.where((e) => e.isCompleted).toList();

        if (isLoadMore) {
          isLoadingMoreCleaningContract = false;
        } else {
          isLoadingCleaningContract = false;
        }

        emit(OrderSuccess(ordersModel: null));
      } catch (e) {
        log("Error parsing cleaning contracts: $e");
        isLoadingCleaningContract = false;
        isLoadingMoreCleaningContract = false;
        final errorMsg = response.getMessage().isNotEmpty
            ? response.getMessage()
            : e.toString();
        emit(OrderError(errorMsg));
      }
    } else if (response.state == ResponseState.unauthorized) {
      isLoadingCleaningContract = false;
      isLoadingMoreCleaningContract = false;
      emit(Unauthenticated());
    } else {
      isLoadingCleaningContract = false;
      isLoadingMoreCleaningContract = false;
      final errorMsg = response.getMessage().isNotEmpty
          ? response.getMessage()
          : "Failed to load cleaning contract deliveries";
      emit(OrderError(errorMsg));
    }
  }

  /// Compresses the photo before it is uploaded.
  ///
  /// A camera photo weighs 3-8 MB — the proof only has to show the container,
  /// so the image is scaled down and re-encoded before it is sent. See
  /// [ImageCompressor] for the details.
  Future<File> compressImage(File file) async =>
      ImageCompressor.compress(file, prefix: 'upload');

  //================== confirm order ====================
  ApiResponse _ordersResponse =
      ApiResponse(state: ResponseState.sleep, data: null);
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
  ApiResponse _emptyOrdersResponse =
      ApiResponse(state: ResponseState.sleep, data: null);
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
    _emptyOrdersResponse =
        ApiResponse(state: ResponseState.loading, data: null);
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
