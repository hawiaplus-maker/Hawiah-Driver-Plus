import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:hawiah_driver/core/custom_widgets/app_bottom_sheet.dart';
import 'package:hawiah_driver/core/custom_widgets/custom_button.dart';
import 'package:hawiah_driver/core/custom_widgets/custom-text-field-widget.dart';
import 'package:hawiah_driver/core/custom_widgets/custom_toast.dart';
import 'package:hawiah_driver/core/images/image_methods.dart';
import 'package:hawiah_driver/core/locale/app_locale_key.dart';
import 'package:hawiah_driver/core/theme/app_colors.dart';
import 'package:hawiah_driver/core/theme/app_text_style.dart';
import 'package:hawiah_driver/core/utils/common_methods.dart';
import 'package:hawiah_driver/core/utils/navigator_methods.dart';
import 'package:hawiah_driver/features/location/service/location_service.dart';
import 'package:hawiah_driver/features/order/presentation/order-cubit/order-cubit.dart';
import 'package:hawiah_driver/features/order/presentation/order-cubit/order-state.dart';
import 'package:hawiah_driver/injection_container.dart';
import 'package:image_picker/image_picker.dart';

/// Sends the discharge to the API.
typedef DischargeCompleter = Future<void> Function({
  required File image,
  required double latitude,
  required double longitude,
  required String driverNotes,
});

/// The action button of a discharge.
///
/// The button drives the whole cycle of a discharge:
///
/// 1. the driver writes an optional note,
/// 2. the "after" photo is taken with the camera,
/// 3. the current position is attached,
/// 4. [onComplete] sends everything to the API.
///
/// The same button is used by the project pickups and by the cleaning
/// contracts — only the API call differs.
class DischargeActionWidget extends StatefulWidget {
  const DischargeActionWidget({
    super.key,
    required this.dischargeId,
    required this.isVisible,
    required this.onComplete,
    this.label,
    this.isFullWidth = false,
  });

  /// The id of the discharge the button belongs to.
  final int dischargeId;

  /// When false the button is not shown (the discharge is done).
  final bool isVisible;

  /// The API call — the widget prepares the photo, the position and the notes.
  final DischargeCompleter onComplete;

  /// The text of the button.
  final String? label;

  /// When true the button stretches over the whole available width
  /// (details screen), otherwise it keeps a compact height (list card).
  final bool isFullWidth;

  @override
  State<DischargeActionWidget> createState() => _DischargeActionWidgetState();
}

class _DischargeActionWidgetState extends State<DischargeActionWidget> {
  /// Id of the discharge whose action is currently running (null = idle).
  int? _runningDischargeId;

  /// True while the driver is going through the action (notes, camera,
  /// location, upload) — the button shows the loader and can't be tapped
  /// twice.
  bool _isWorking = false;

  bool get _isRunning => _runningDischargeId == widget.dischargeId;

  /// The loader is up while the action is running.
  bool get _isBusy => _isWorking || _isRunning;

  @override
  Widget build(BuildContext context) {
    if (!widget.isVisible) return const SizedBox.shrink();

    return BlocListener<OrderCubit, OrderState>(
      listenWhen: (previous, current) =>
          current is DischargeActionLoading ||
          current is DischargeActionSuccess ||
          current is DischargeActionError,
      listener: (context, state) {
        if (state is DischargeActionLoading) {
          if (state.dischargeId == widget.dischargeId) {
            setState(() => _runningDischargeId = state.dischargeId);
          }
          return;
        }

        if (state is DischargeActionSuccess) {
          if (state.dischargeId != widget.dischargeId) return;
          setState(() => _runningDischargeId = null);
          CommonMethods.showToast(message: state.message);
          return;
        }

        if (state is DischargeActionError) {
          if (state.dischargeId != widget.dischargeId) return;
          setState(() => _runningDischargeId = null);
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
      text: widget.label ?? AppLocaleKey.completeDischarging.tr(),
      isLoading: _isBusy,
      style: AppTextStyle.text14_600.copyWith(color: Colors.white),
      color: AppColor.mainAppColor,
      onPressed: _isBusy ? null : _complete,
    );
  }

  /// Captures the "after" image, grabs the current location and completes the
  /// discharge.
  Future<void> _complete() async {
    // 1. Optional driver notes.
    final notes = await _showNotesSheet();
    if (notes == null) return; // the driver closed the sheet.

    // 2. Location service + permission.
    //    The shared service holds the position detected when the app opened.
    final locationService = sl<LocationService>();
    final isServiceEnabled =
        await locationService.checkAndRequestLocationService();
    if (!isServiceEnabled) {
      _showError(AppLocaleKey.pleaseEnableLocation.tr());
      return;
    }

    if (!await locationService.checkAndRequestLocationPermission()) {
      _showError(AppLocaleKey.pleaseEnableLocation.tr());
      return;
    }

    // 3. Resolve the location while the driver is taking the photo.
    //    The position detected when the app opened is reused when it is
    //    still fresh, so nothing has to be awaited here — and the wait is
    //    capped, so a GPS without a fix never blocks the discharge.
    final locationFuture = locationService.getLocationForAction();

    _setWorking(true);
    var loadingShown = false;
    try {
      // 4. Camera only — the proof must be shot on site.
      final image = await _pickPhoto();
      // The driver cancelled the camera — nothing to upload.
      if (image == null) return;
      if (!mounted) return;

      // 5. The loader stays up while the position is resolved and the photo
      //    is sent, so the driver always sees that something is happening.
      loadingShown = true;
      NavigatorMethods.loading();

      final location = await locationFuture;
      if (!mounted) return;

      if (location == null) {
        _showError(AppLocaleKey.locationUnavailable.tr());
        return;
      }

      await widget.onComplete(
        image: image,
        latitude: location.latitude,
        longitude: location.longitude,
        driverNotes: notes,
      );
    } catch (e) {
      _showError(AppLocaleKey.anErrorOccurred.tr());
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

  /// Bottom sheet with an optional driver notes field.
  /// Returns the notes, or null when the sheet was dismissed.
  Future<String?> _showNotesSheet() {
    return DriverNotesSheet.show(context);
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

/// The driver notes bottom sheet.
///
/// It owns the [TextEditingController] on purpose: the controller can only be
/// disposed once the sheet is really unmounted. Disposing it as soon as the
/// route is popped breaks the still-mounted [TextFormField], which keeps
/// building during the sheet's exit animation.
class DriverNotesSheet extends StatefulWidget {
  const DriverNotesSheet({super.key});

  /// Opens the driver notes sheet and returns the entered notes.
  /// Returns null when the sheet was dismissed without confirming.
  static Future<String?> show(BuildContext context) {
    return showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      // The sheet can't be dismissed by accident: the driver has to confirm
      // (the camera opens) or cancel on purpose. A dismissed sheet would
      // silently stop the discharge.
      isDismissible: false,
      enableDrag: false,
      backgroundColor: Colors.transparent,
      builder: (_) => const DriverNotesSheet(),
    );
  }

  @override
  State<DriverNotesSheet> createState() => _DriverNotesSheetState();
}

class _DriverNotesSheetState extends State<DriverNotesSheet> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: AppBottomSheet(
        title: AppLocaleKey.driverNotes.tr(),
        children: [
          CustomTextField(
            controller: _controller,
            hintText: AppLocaleKey.driverNotesHint.tr(),
            maxLines: 3,
          ),
          Gap(20.h),
          CustomButton(
            text: AppLocaleKey.captureAndComplete.tr(),
            onPressed: () =>
                Navigator.of(context).pop(_controller.text.trim()),
          ),
          Gap(10.h),
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              width: double.infinity,
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Text(
                AppLocaleKey.cancel.tr(),
                style: AppTextStyle.text16_500.copyWith(
                  color: AppColor.textGrayColor,
                ),
              ),
            ),
          ),
          Gap(20.h),
        ],
      ),
    );
  }
}
