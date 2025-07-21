import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hawiah_driver/core/custom_widgets/custom_app_bar/custom_app_bar.dart';
import 'package:hawiah_driver/core/locale/app_locale_key.dart';
import 'package:hawiah_driver/core/theme/app_colors.dart';

class AllChatsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        context,
        title: Text(
          AppLocaleKey.chat.tr(),
          style: TextStyle(color: Colors.black),
        ),
        centerTitle: true,
      ),
      body: Container(
        padding: EdgeInsets.symmetric(horizontal: 20.w),
        child: Column(
          children: [
            TextFormField(
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                hintText: AppLocaleKey.findAConversation.tr(),
                hintStyle: TextStyle(
                  color: Color(0xff979797),
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w400,
                ),
                filled: true, // Set background color
                fillColor: Color(0xFFF9F9F9), // Set background color to #F9F9F9
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(
                    40.0,
                  ), // Apply border radius
                  borderSide:
                      BorderSide.none, // Remove border side for regular border
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(
                    40.0,
                  ), // Apply border radius
                  borderSide:
                      BorderSide.none, // Remove border side for enabled state
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(
                    40.0,
                  ), // Apply border radius
                  borderSide:
                      BorderSide.none, // Remove border side for focused state
                ),
                suffixIcon: Icon(
                  Icons.search,
                  color: AppColor.mainAppColor, // Change icon color to #2D01FE
                  size: 25,
                ),
              ),
            ),
            Expanded(
              child: ListView(
                children: [
                  ChatItem(
                    context,
                    name: 'عبد الله علي',
                    message: 'يمكنك دفع التمديد من خلال التطبيق',
                    time: '5 دقائق',
                    imageUrl: 'assets/images/person_chat_image.png',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AllChatsScreen(),
                        ),
                      );
                    }, // Replace with real image URL
                  ),
                  ChatItem(
                    context,
                    name: 'محمد حلمي',
                    message: 'أنت: سعيد جدًا بالتعامل معك',
                    time: 'الأمس',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AllChatsScreen(),
                        ),
                      );
                    },
                    imageUrl:
                        'assets/images/person_chat_image.png', // Replace with real image URL
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget ChatItem(
    BuildContext context, {
    required String name,
    required String message,
    required String time,
    required String imageUrl,
    required VoidCallback onTap,
  }) {
    return Column(
      children: [
        ListTile(
          leading: CircleAvatar(
            backgroundImage: AssetImage(imageUrl),
            radius: 25,
          ),
          title: Text(name, style: TextStyle(fontWeight: FontWeight.bold)),
          subtitle: Text(
            message,
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
            style: TextStyle(color: Color(0xffADB5BD), fontSize: 12.sp),
          ),
          trailing: Text(
            time,
            style: TextStyle(color: Color(0xff000912), fontSize: 12.sp),
          ),
          onTap: onTap,
        ),
        Divider(color: Colors.grey, thickness: 0.5),
      ],
    );
  }
}
