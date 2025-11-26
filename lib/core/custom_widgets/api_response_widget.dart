import 'package:flutter/material.dart';
import 'package:hawiah_driver/core/custom_widgets/custom_loading/custom_loading.dart';
import 'package:hawiah_driver/core/custom_widgets/exception_widget.dart';
import 'package:hawiah_driver/core/custom_widgets/no_data_widget.dart';
import 'package:hawiah_driver/core/custom_widgets/offline_widget.dart';
import 'package:hawiah_driver/core/networking/api_helper.dart';

class ApiResponseWidget extends StatelessWidget {
  final ApiResponse apiResponse;
  final Widget child;
  final double loadingSize;
  final Widget? loadingWidget;
  final Widget? errorWidget;
  final Widget? emptyWidget;
  final Widget? unauthorizedWidget;
  final Widget? offlineWidget;
  final bool isEmpty;
  final bool initialChild;
  final void Function()? onReload;
  final Axis axis;
  final String? noDataMessage;
  final String? exceptionMessage;
  final Color? loadingColor;
  const ApiResponseWidget({
    super.key,
    required this.apiResponse,
    required this.child,
    required this.onReload,
    required this.isEmpty,
    this.loadingSize = 35,
    this.loadingWidget,
    this.axis = Axis.vertical,
    this.noDataMessage,
    this.exceptionMessage,
    this.errorWidget,
    this.emptyWidget,
    this.offlineWidget,
    this.loadingColor,
    this.unauthorizedWidget,
    this.initialChild = false,
  });

  @override
  Widget build(BuildContext context) {
    switch (apiResponse.state) {
      case ResponseState.sleep:
        if (initialChild) {
          return child;
        } else {
          return const SizedBox();
        }
      case ResponseState.loading:
        return loadingWidget ??
            Center(
              child: CustomLoading(
                size: loadingSize,
                color: loadingColor,
              ),
            );
      case ResponseState.complete:
      case ResponseState.pagination:
        if (isEmpty) {
          return emptyWidget ??
              Center(
                child: NoDataWidget(
                  message: noDataMessage,
                  axis: axis,
                ),
              );
        } else {
          return child;
        }
      case ResponseState.error:
        return errorWidget ??
            Center(
              child: ExceptionWidget(
                message: exceptionMessage,
                axis: axis,
                onReload: onReload,
              ),
            );
      case ResponseState.unauthorized:
        return unauthorizedWidget ??
            Center(
              child: ExceptionWidget(
                message: exceptionMessage,
                axis: axis,
                onReload: onReload,
              ),
            );
      case ResponseState.offline:
        return offlineWidget ??
            Center(
              child: OfflineWidget(
                axis: axis,
                onReload: onReload,
              ),
            );
      case ResponseState.badRequest:
        throw UnimplementedError();
    }
  }
}
