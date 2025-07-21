import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:hawiah_driver/core/images/app_images.dart';
import 'package:hawiah_driver/core/locale/app_locale_key.dart';
import 'package:hawiah_driver/features/profile/presentation/cubit/cubit_profile.dart';
import 'package:hawiah_driver/features/profile/presentation/cubit/state_profile.dart';
import 'package:image_picker/image_picker.dart';

class UserProfile extends StatefulWidget {
  @override
  State<UserProfile> createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile> {
  final Map<String, TextEditingController> controllers = {
    "name": TextEditingController(),
    "username": TextEditingController(),
    "mobile": TextEditingController(),
    "email": TextEditingController(),
  };

  File? _pickedImage;

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<ProfileCubit>().fetchProfile();
    });
  }

  Future<void> _pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
    );

    if (pickedFile != null) {
      setState(() {
        _pickedImage = File(pickedFile.path);
      });

      Fluttertoast.showToast(msg: AppLocaleKey.imageSelected.tr());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: BlocConsumer<ProfileCubit, ProfileState>(
        listener: (context, state) {
          if (state is ProfileLoaded) {
            final user = state.user;
            controllers['name']!.text = user.name;
            controllers['username']!.text = user.username;
            controllers['mobile']!.text = user.mobile;
            controllers['email']!.text = user.email;
          }

          if (state is ProfileUpdateSuccess) {
            Fluttertoast.showToast(
              msg: state.message,
              backgroundColor: Colors.green,
              textColor: Colors.white,
            );
          } else if (state is ProfileError) {
            Fluttertoast.showToast(
              msg: state.message,
              backgroundColor: Colors.red,
              textColor: Colors.white,
            );
          }
        },
        builder: (context, state) {
          String imageUrl = '';
          if (state is ProfileLoaded) {
            imageUrl = state.user.image;
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 20,
                ),
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: _pickImage,
                      child: CircleAvatar(
                        radius: 50,
                        backgroundImage:
                            _pickedImage != null
                                ? FileImage(_pickedImage!)
                                : (imageUrl.isNotEmpty
                                    ? NetworkImage(imageUrl) as ImageProvider
                                    : AssetImage(AppImages.profileEmptyImage)),
                        child: Align(
                          alignment: Alignment.bottomRight,
                          child: CircleAvatar(
                            backgroundColor: Colors.white,
                            radius: 15,
                            child: Container(
                              height: 50,
                              width: 70,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Color(0xff2204AE),
                                border: Border.all(
                                  color: Colors.black,
                                  width: .5,
                                ),
                              ),
                              child: Icon(
                                Icons.camera_alt_outlined,
                                size: 18,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 40),
                    ...controllers.entries.map((entry) {
                      final key = entry.key;
                      final controller = entry.value;
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: TextFormField(
                          controller: controller,
                          decoration: InputDecoration(
                            labelText: key.capitalize(),
                            border: OutlineInputBorder(),
                          ),
                        ),
                      );
                    }).toList(),
                    Spacer(),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color.fromARGB(255, 56, 109, 222),
                        fixedSize: Size.fromWidth(300),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: () async {
                        final cubit = context.read<ProfileCubit>();

                        await cubit.updateProfile(
                          name: controllers['name']!.text,
                          username: controllers['username']!.text,
                          mobile: controllers['mobile']!.text,
                          email: controllers['email']!.text,
                          imageFile: _pickedImage,
                        );
                      },
                      child: Text(
                        AppLocaleKey.tracking.tr(),
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ),
                    SizedBox(height: 20),
                  ],
                ),
              ),
            );
          } else if (state is ProfileLoading) {
            return Center(child: CircularProgressIndicator());
          } else
            return Container(color: Colors.red);
        },
      ),
    );
  }
}

extension StringX on String {
  String capitalize() =>
      isNotEmpty ? "${this[0].toUpperCase()}${substring(1)}" : this;
}
