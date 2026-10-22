import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hawiah_driver/core/custom_widgets/custom_button.dart';
import 'package:hawiah_driver/core/custom_widgets/custom_toast.dart';
import 'package:hawiah_driver/core/images/image_methods.dart';
import 'package:hawiah_driver/core/locale/app_locale_key.dart';
import 'package:hawiah_driver/core/theme/app_colors.dart';
import 'package:hawiah_driver/core/theme/app_text_style.dart';
import 'package:hawiah_driver/core/utils/common_methods.dart';
import 'package:hawiah_driver/core/utils/navigator_methods.dart';
import 'package:hawiah_driver/features/order/presentation/model/project_discharge_model.dart';
import 'package:hawiah_driver/features/order/presentation/order-cubit/order-cubit.dart';
import 'package:hawiah_driver/features/order/presentation/order-cubit/order-state.dart';
import 'package:image_picker/image_picker.dart';

/// The "Handle pickup" button of an assigned project pickup.
///
/// The button captures the "before" image from the camera and calls
/// `POST {{baseUrl}}drivers/project-discharges/{id}/start-trip`. On success
/// the status becomes `in_trans` and the orders are refreshed — the button
/// then turns into the "Complete Discharging" one
/// ([DischargeActionWidget]).
class ProjectStartTripActionWidget extends StatefulWidget {
  const ProjectStartTripActionWidget({
    super.key,
    required this.pickup,
    this.isFullWidth = false,
  });

  final ProjectDischargeItem pickup;

  /// When true the button stretches over the whole available width
  /// (details screen), otherwise it keeps a compact height (list card).
  final bool isFullWidth;

  @override
  State<ProjectStartTripActionWidget> createState() =>
      _ProjectStartTripActionWidgetState();
}

class _ProjectStartTripActionWidgetState
    extends State<ProjectStartTripActionWidget> {
  /// Id of the pickup whose action is currently running (null = idle).
  int? _runningPickupId;

  /// True while the camera is open and the photo is sent — the button shows
  /// the loader and can't be tapped twice.
  bool _isWorking = false;

  ProjectDischargeItem get _pickup => widget.pickup;

  bool get _isRunning =>
      _pickup.id != null && _runningPickupId == _pickup.id;

  bool get _isBusy => _isWorking || _isRunning;

  @override
  Widget build(BuildContext context) {
    // Nothing to do for a pickup that isn't assigned.
    if (!_pickup.isAssigned) return const SizedBox.shrink();

    return BlocListener<OrderCubit, OrderState>(
      listenWhen: (previous, current) =>
          current is DischargeActionLoading ||
          current is DischargeActionSuccess ||
          current is DischargeActionError,
      listener: (context, state) {
        if (state is DischargeActionLoading) {
          if (state.dischargeId == _pickup.id) {
            setState(() => _runningPickupId = state.dischargeId);
          }
          return;
        }

        if (state is DischargeActionSuccess) {
          if (state.dischargeId != _pickup.id) return;
          setState(() => _runningPickupId = null);
          CommonMethods.showToast(message: state.message);
          return;
        }

        if (state is DischargeActionError) {
          if (state.dischargeId != _pickup.id) return;
          setState(() => _runningPickupId = null);
          CommonMethods.showToast(
            message: state.message,
            type: ToastType.error,
          );
        }
      },
      child: _buildButton(),
    );
  }

  Widget _buildButton() {
    return CustomButton(
      height: widget.isFullWidth ? 50 : 40,
      radius: 10,
      text: AppLocaleKey.handlePickup.tr(),
      isLoading: _isBusy,
      style: AppTextStyle.text14_600.copyWith(color: Colors.white),
      color: AppColor.secondAppColor,
      onPressed: _isBusy ? null : _startTrip,
    );
  }

  /// Captures the "before" image from the camera and starts the trip.
  Future<void> _startTrip() async {
    final pickupId = _pickup.id;
    if (pickupId == null) return;

    _setWorking(true);
    var loadingShown = false;
    try {
      final image = await _pickPhoto();
      // The driver cancelled the camera — nothing to do.
      if (image == null) return;
      if (!mounted) return;

      loadingShown = true;
      NavigatorMethods.loading();
      await context.read<OrderCubit>().startProjectTrip(
            pickupId: pickupId,
            image: image,
          );
    } catch (e) {
      _showError(AppLocaleKey.cameraNotAvailable.tr());
    } finally {
      if (loadingShown) NavigatorMethods.loadingOff();
      _setWorking(false);
    }
  }

  /// Opens the camera and returns the photo — null when the driver cancelled.
  Future<File?> _pickPhoto() async {
    try {
      return await ImageMethods.pickImageAndReturn(
        source: ImageSource.camera,
      );
    } catch (e) {
      _showError(AppLocaleKey.cameraNotAvailable.tr());
      return null;
    }
  }

  void _setWorking(bool value) {
    if (!mounted) return;
    setState(() => _isWorking = value);
  }

  void _showError(String message) {
    if (!mounted) return;
    CommonMethods.showToast(message: message, type: ToastType.error);
  }
}
