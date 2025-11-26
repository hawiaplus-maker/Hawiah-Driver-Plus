import 'package:flutter/material.dart';

class OnBoardingModel {
  bool? success;
  List<Data>? data;

  OnBoardingModel({this.success, this.data});

  OnBoardingModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    if (json['data'] != null) {
      data = <Data>[];
      json['data'].forEach((v) {
        data!.add(Data.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> dataMap = <String, dynamic>{};
    dataMap['success'] = success;
    if (data != null) {
      dataMap['data'] = data!.map((v) => v.toJson()).toList();
    }
    return dataMap;
  }
}

class Data {
  int? id;
  MultiLangText? title;
  MultiLangText? about;
  String? image;

  Data({this.id, this.title, this.about, this.image});

  Data.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    title = json['title'] != null ? MultiLangText.fromJson(json['title']) : null;
    about = json['about'] != null ? MultiLangText.fromJson(json['about']) : null;
    image = json['image'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> dataMap = <String, dynamic>{};
    dataMap['id'] = id;
    if (title != null) dataMap['title'] = title!.toJson();
    if (about != null) dataMap['about'] = about!.toJson();
    dataMap['image'] = image;
    return dataMap;
  }
}

class MultiLangText {
  String? en;
  String? ar;

  MultiLangText({this.en, this.ar});

  MultiLangText.fromJson(Map<String, dynamic> json) {
    en = json['en'];
    ar = json['ar'];
  }

  Map<String, dynamic> toJson() {
    return {
      'en': en,
      'ar': ar,
    };
  }

  // دالة لإرجاع النص حسب لغة التطبيق
  String text(BuildContext context) {
    final langCode = Localizations.localeOf(context).languageCode;
    if (langCode == 'ar') return ar ?? '';
    return en ?? '';
  }
}
