import 'package:hawiah_driver/features/order/presentation/model/orders_model.dart';
import 'package:hawiah_driver/features/order/presentation/model/single_order_model.dart';

abstract class OrderState {}

class OrderInitial extends OrderState {}

class OrderSuccess extends OrderState {
  final OrdersModel? ordersModel;
  OrderSuccess({this.ordersModel});
}

class OrderConfirmed extends OrderState {
  final bool? success;
  OrderConfirmed({this.success});
}

class OrderPaginationLoading extends OrderState {}

class OrderLoading extends OrderState {}

class OrderChange extends OrderState {}

class OrderRebuild extends OrderState {}

class OrderError extends OrderState {
  final String message;
  OrderError(this.message);
}

class OrderEmpty extends OrderState {}

class Unauthenticated extends OrderState {}

class CurrentOrderLoaded extends OrderState {
  final SingleOrderModel order;
  CurrentOrderLoaded(this.order);
}

class CurrentOrderError extends OrderState {
  final String message;
  CurrentOrderError(this.message);
}

class CurrentOrderLoading extends OrderState {}

/// A discharge action (project pickup / cleaning contract) is in flight.
class DischargeActionLoading extends OrderState {
  final int dischargeId;
  DischargeActionLoading(this.dischargeId);
}

/// A discharge action finished successfully — the list is refreshed.
class DischargeActionSuccess extends OrderState {
  final int dischargeId;
  final String message;
  DischargeActionSuccess(this.dischargeId, this.message);
}

/// A discharge action failed.
class DischargeActionError extends OrderState {
  final int dischargeId;
  final String message;
  DischargeActionError(this.dischargeId, this.message);
}
