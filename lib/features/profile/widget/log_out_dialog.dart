import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hawiah_driver/core/hive/hive_methods.dart';
import 'package:hawiah_driver/core/images/app_images.dart';
import 'package:hawiah_driver/core/locale/app_locale_key.dart';
import 'package:hawiah_driver/core/utils/navigator_methods.dart';
import 'package:hawiah_driver/features/authentication/presentation/controllers/auth-cubit/auth-cubit.dart';
import 'package:hawiah_driver/features/authentication/presentation/screens/validate_mobile_screen.dart';
import 'package:hawiah_driver/features/profile/presentation/cubit/cubit_profile.dart';
import 'package:hawiah_driver/injection_container.dart';

class LogOutDialog extends StatelessWidget {
  const LogOutDialog({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      child: Padding(
        padding: EdgeInsets.all(20.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            IconButton(
                onPressed: () => Navigator.pop(context),
                icon: SvgPicture.asset(AppImages.closeCircleIcon)),
            Center(
              child: Image.asset(
                AppImages.logoutGif,
                height: 80,
                cacheHeight: 80,
              ),
            ),
            Center(
              child: Text(
                AppLocaleKey.didYouWantToLogout.tr(),
                style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w500),
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(height: 20.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: () {
                    AuthCubit.get(context).logout(
                      onSuccess: () {
                        HiveMethods.deleteToken();
                        sl<ProfileCubit>().user;

                        NavigatorMethods.pushNamedAndRemoveUntil(
                            context, ValidateMobileScreen.routeName);
                      },
                    );
                  },
                  child: SizedBox(
                    width: 80,
                    height: 50,
                    child: Card(
                      color: const Color(0xFF2AD352),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Text(
                          AppLocaleKey.yes.tr(),
                          style: TextStyle(fontSize: 14, color: Colors.white, height: 2),
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 16),
                GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: SizedBox(
                    width: 80,
                    height: 50,
                    child: Card(
                      color: const Color.fromARGB(255, 0, 4, 35),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Text(
                          AppLocaleKey.no.tr(),
                          style: TextStyle(fontSize: 14.sp, color: Colors.white, height: 2),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
