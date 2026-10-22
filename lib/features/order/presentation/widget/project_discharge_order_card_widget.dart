import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:hawiah_driver/core/locale/app_locale_key.dart';
import 'package:hawiah_driver/core/theme/app_colors.dart';
import 'package:hawiah_driver/core/theme/app_text_style.dart';
import 'package:hawiah_driver/features/order/presentation/model/project_discharge_model.dart';
import 'package:hawiah_driver/features/order/presentation/screens/current-order-screen.dart';
import 'package:hawiah_driver/features/order/presentation/screens/old-order-screen.dart';

/// List card for project pickups (project discharges) — same layout as the
/// cleaning contract card: left info column + status badge column on the right.
class ProjectDischargeOrderCardWidget extends StatelessWidget {
  const ProjectDischargeOrderCardWidget({super.key, required this.pickup});

  final ProjectDischargeItem pickup;

  bool get _isCompleted => pickup.isCompleted;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _onTap(context),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColor.whiteColor,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: AppColor.mainAppColor.withAlpha(40),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // NOTE: no flex child here — this Column lives in an
                  // unbounded-height context (card is inside a ListView), so a
                  // Flexible/Expanded child would throw
                  // "RenderFlex children have non-zero flex but incoming height
                  // constraints are unbounded". The width is already bounded by
                  // the outer Expanded, so the ellipsis is enough.
                  Text("#${pickup.referenceNumber ?? '---'}",
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyle.text16_500),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Flexible so the name shrinks/ellipsizes instead of
                      // overflowing the row when the badge is present.
                      Expanded(
                        child: Text(
                          pickup.projectName ?? '---',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyle.text14_400,
                        ),
                      ),
                      const SizedBox(width: 8),
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 140),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                color: _statusColor(_isCompleted).withAlpha(50),
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: Center(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 8,
                                  ),
                                  child: Text(
                                    pickup.statusDisplay,
                                    textAlign: TextAlign.center,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: AppTextStyle.text14_400.copyWith(
                                      color: _statusColor(_isCompleted),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Text(
                    '${AppLocaleKey.container.tr()} ${pickup.containerName ?? ''}'
                    '${pickup.containerSize != null ? ' (${pickup.containerSize} ياردة)' : ''}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyle.text14_400.copyWith(
                      color: AppColor.textGrayColor,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    '${AppLocaleKey.clientName.tr()} ${pickup.clientName ?? ''}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyle.text14_400.copyWith(
                      color: AppColor.textGrayColor,
                    ),
                  ),
                  const SizedBox(height: 5),
                  if (!_isCompleted) ...[
                    Text(
                      '${AppLocaleKey.scheduledDate.tr()} ${pickup.scheduledDate ?? '---'}'
                      '${pickup.scheduledTime != null ? ' - ${_formatTime(pickup.scheduledTime!)}' : ''}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyle.text14_400.copyWith(
                        color: AppColor.redColor,
                      ),
                    ),
                    const SizedBox(height: 5),
                  ],
                  // Text(
                  //   '${AppLocaleKey.completedPickupsLabel.tr()} '
                  //   '${pickup.completedPickups ?? 0}/${pickup.totalPickups ?? 0}',
                  //   maxLines: 1,
                  //   overflow: TextOverflow.ellipsis,
                  //   style: AppTextStyle.text14_400.copyWith(
                  //     color: AppColor.mainAppColor,
                  //   ),
                  // ),
                  // const SizedBox(height: 5),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Icon(Icons.remove_red_eye_outlined, color: AppColor.lightGreyColor, size: 15),
                      const SizedBox(width: 5),
                      Text(
                        AppLocaleKey.showDetails.tr(),
                        style: AppTextStyle.text16_600.copyWith(
                          color: AppColor.mainAppColor,
                          decoration: TextDecoration.underline,
                          decorationColor: AppColor.mainAppColor,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
          ],
        ),
      ),
    );
  }

  String _formatTime(String time) {
    final parts = time.split(':');
    if (parts.length >= 2) {
      final hour = int.tryParse(parts[0]) ?? 0;
      final minute = parts[1];
      final period = hour >= 12 ? 'PM' : 'AM';
      final hour12 = hour % 12 == 0 ? 12 : hour % 12;
      return '$hour12:$minute $period';
    }
    return time;
  }

  Color _statusColor(bool isCompleted) {
    if (isCompleted) return AppColor.mainAppColor;
    // The trip is running — the driver still has to finish the discharge.
    if (pickup.isInTransit) return AppColor.orangeColor;
    return AppColor.textGrayColor;
  }

  void _onTap(BuildContext context) {
    if (_isCompleted) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => OldOrderScreen(ordersDate: pickup),
        ),
      );
    } else {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => CurrentOrderScreen(
            ordersDate: pickup,
            orderId: pickup.id ?? 0,
          ),
        ),
      );
    }
  }
}
