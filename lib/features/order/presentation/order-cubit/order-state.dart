import 'package:hawiah_driver/features/order/presentation/model/orders_model.dart';

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

class OrderError extends OrderState {}

class OrderEmpty extends OrderState {}

class Unauthenticated extends OrderState {}
