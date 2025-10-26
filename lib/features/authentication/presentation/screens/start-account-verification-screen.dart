// import 'package:easy_localization/easy_localization.dart' as es;
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:hawiah_driver_plus/core/custom_widgets/global-elevated-button-widget.dart';
// import 'package:hawiah_driver_plus/features/authentication/presentation/screens/verification-otp-screen.dart';

// import '../controllers/auth-cubit/auth-cubit.dart';
// import '../controllers/auth-cubit/auth-state.dart';

// class StartAccountVerificationScreen extends StatelessWidget {
//   const StartAccountVerificationScreen({super.key, this.phoneNumber, this.otp});
//   final String? phoneNumber;
//   final int? otp;
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: Colors.white,
//         elevation: 0,
//         leading: IconButton(
//           icon: Icon(Icons.arrow_back, color: Colors.black),
//           onPressed: () {
//             Navigator.pop(context);
//           },
//         ),
//       ),
//       body: BlocConsumer<AuthCubit, AuthState>(
//         builder: (BuildContext context, AuthState state) {
//           final authChange = AuthCubit.get(context);
//           final selectedSmsOrWhatsApp = authChange.selectedSmsOrWhatsApp;
//           final receiveNotifications = authChange.receiveNotifications;
//           final isResetPassword = authChange.isResetPassword;
//           return Container(
//             margin: EdgeInsets.symmetric(horizontal: 20.w),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 isResetPassword
//                     ? Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text(
//                             "setPassword".tr(),
//                             style:
//                                 TextStyle(fontSize: 25.sp, color: Colors.black),
//                           ),
//                           Text(
//                             "chooseVerificationMethod".tr(),
//                             style: TextStyle(
//                                 fontSize: 15.sp, color: Color(0xff979797)),
//                           ),
//                         ],
//                       )
//                     : Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text(
//                             "start_account_verification".tr(),
//                             style:
//                                 TextStyle(fontSize: 25.sp, color: Colors.black),
//                           ),
//                           Text(
//                             "choose_verification_method".tr(),
//                             style: TextStyle(
//                                 fontSize: 15.sp, color: Color(0xff979797)),
//                           ),
//                         ],
//                       ),
//                 SizedBox(height: 0.1.sh),
//                 Directionality(
//                   textDirection: context.locale.languageCode == 'ar'
//                       ? TextDirection.rtl
//                       : TextDirection.ltr,
//                   child: Column(
//                     children: [
//                       GestureDetector(
//                         onTap: () {
//                           authChange.updateSelectedSmsOrWhatsApp(1);
//                         },
//                         child: Row(
//                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                           children: [
//                             Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 Text("send_code_via_sms".tr()),
//                                 SizedBox(height: 5.h),
//                                 Text('${phoneNumber!.replaceAll('05', '5')}' ??
//                                     '+966 5 123 45678'),
//                               ],
//                             ),
//                             Radio(
//                               value: 1,
//                               groupValue: selectedSmsOrWhatsApp,
//                               onChanged: (value) {
//                                 authChange.updateSelectedSmsOrWhatsApp(value!);
//                               },
//                             ),
//                           ],
//                         ),
//                       ),
//                       Divider(
//                         height: 30,
//                       ),
//                     ],
//                   ),
//                 ),
//                 Spacer(),
//                 GestureDetector(
//                   onTap: () {
//                     authChange
//                         .updateReceiveNotifications(!receiveNotifications);
//                   },
//                   child: Row(
//                     children: [
//                       Checkbox(
//                         checkColor: Colors.white,
//                         activeColor: Colors.green,
//                         value: receiveNotifications,
//                         shape: CircleBorder(),
//                         onChanged: (bool? value) {
//                           authChange.updateReceiveNotifications(value!);
//                         },
//                       ),
//                       Text(
//                         "receive_notifications_whatsapp".tr(),
//                         style: TextStyle(
//                             color: Color(0xff979797), fontSize: 15.sp),
//                       ),
//                     ],
//                   ),
//                 ),
//                 SizedBox(height: 20.h),
//                 Container(
//                     alignment: Alignment.center,
//                     child: GlobalElevatedButton(
//                       label: "continue".tr(),
//                       onPressed: () {
//                         Navigator.push(
//                             context,
//                             MaterialPageRoute(
//                                 builder: (context) => VerificationOtpScreen(
//                                       phoneNumber: phoneNumber,
//                                       otp:otp

//                                     )));
//                       },
//                       backgroundColor: Color(0xffEDEEFF),
//                       textColor: AppColor.mainAppColor,
//                       padding:
//                           EdgeInsets.symmetric(horizontal: 20, vertical: 12),
//                       borderRadius: BorderRadius.circular(20),
//                       fixedWidth: 0.80, // 80% width of the screen
//                     )),
//                 SizedBox(height: 40.h),
//               ],
//             ),
//           );
//         },
//         listener: (BuildContext context, AuthState state) {},
//       ),
//     );
//   }
// }
