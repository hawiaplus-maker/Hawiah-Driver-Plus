class SettingModel {
  int? id;
  Title? title;
  String? image;
  String? email;
  Title? about;
  Title? address;
  String? phone;
  String? hotline;
  String? whatsApp;
  String? facebook;
  String? twitter;
  String? youTube;
  String? linkedIn;
  String? instagram;
  String? logo;
  Title? footer;
  String? aboutImage;
  String? apiVersion;
  String? googlePlay;
  String? appStore;
  Title? termsCondition;
  Title? privacy;
  List<MobileOnboard>? mobileOnboard;
  List<MobileSlider>? mobileSlider;
  String? createdAt;
  String? updatedAt;
  Title? subscribeTitle;
  Title? subscribeDescription;
  Title? sliderImage;
  String? headerLogo;
  String? footerLogo;
  Title? appLinkImage;
  Title? howWorkImage;
  Title? getTouchImage;
  Title? faqImage;
  Title? subscribeImage;
  Title? sliderTitle;
  Title? sliderSubTitle;
  Title? sliderTag;
  Title? sliderDescription;
  Title? galleryTitle;
  Title? appLinkTitle;
  Title? appLinkDescription;
  Title? howWorkTitle;
  String? howWorkDescription;
  Title? featureTitle;
  FeatureDescription? featureDescription;
  Title? getTouchTitle;
  Title? getTouchDescription;
  String? webMobiles;
  String? webEmails;
  FeatureDescription? footerDescription;
  String? copyright;
  Title? faqTitle;
  FeatureDescription? faqDescription;
  int? numberPoint;
  String? excelUserUploadExample;
  String? support;

  SettingModel(
      {this.id,
      this.title,
      this.image,
      this.email,
      this.about,
      this.address,
      this.phone,
      this.hotline,
      this.whatsApp,
      this.facebook,
      this.twitter,
      this.youTube,
      this.linkedIn,
      this.instagram,
      this.logo,
      this.footer,
      this.aboutImage,
      this.apiVersion,
      this.googlePlay,
      this.appStore,
      this.termsCondition,
      this.privacy,
      this.mobileOnboard,
      this.mobileSlider,
      this.createdAt,
      this.updatedAt,
      this.subscribeTitle,
      this.subscribeDescription,
      this.sliderImage,
      this.headerLogo,
      this.footerLogo,
      this.appLinkImage,
      this.howWorkImage,
      this.getTouchImage,
      this.faqImage,
      this.subscribeImage,
      this.sliderTitle,
      this.sliderSubTitle,
      this.sliderTag,
      this.sliderDescription,
      this.galleryTitle,
      this.appLinkTitle,
      this.appLinkDescription,
      this.howWorkTitle,
      this.howWorkDescription,
      this.featureTitle,
      this.featureDescription,
      this.getTouchTitle,
      this.getTouchDescription,
      this.webMobiles,
      this.webEmails,
      this.footerDescription,
      this.copyright,
      this.faqTitle,
      this.faqDescription,
      this.numberPoint,
      this.excelUserUploadExample,
      this.support});

  SettingModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    title = json['title'] != null ? new Title.fromJson(json['title']) : null;
    image = json['image'];
    email = json['email'];
    about = json['about'] != null ? new Title.fromJson(json['about']) : null;
    address = json['address'] != null ? new Title.fromJson(json['address']) : null;
    phone = json['phone'];
    hotline = json['hotline'];
    whatsApp = json['whatsApp'];
    facebook = json['facebook'];
    twitter = json['twitter'];
    youTube = json['youTube'];
    linkedIn = json['linkedIn'];
    instagram = json['instagram'];
    logo = json['logo'];
    footer = json['footer'] != null ? new Title.fromJson(json['footer']) : null;
    aboutImage = json['about_image'];
    apiVersion = json['api_version'];
    googlePlay = json['googlePlay'];
    appStore = json['appStore'];
    termsCondition =
        json['terms_condition'] != null ? new Title.fromJson(json['terms_condition']) : null;
    privacy = json['privacy'] != null ? new Title.fromJson(json['privacy']) : null;
    if (json['mobile_onboard'] != null) {
      mobileOnboard = <MobileOnboard>[];
      json['mobile_onboard'].forEach((v) {
        mobileOnboard!.add(new MobileOnboard.fromJson(v));
      });
    }
    if (json['mobile_slider'] != null) {
      mobileSlider = <MobileSlider>[];
      json['mobile_slider'].forEach((v) {
        mobileSlider!.add(new MobileSlider.fromJson(v));
      });
    }
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    subscribeTitle =
        json['subscribe_title'] != null ? new Title.fromJson(json['subscribe_title']) : null;
    subscribeDescription = json['subscribe_description'] != null
        ? new Title.fromJson(json['subscribe_description'])
        : null;
    sliderImage = json['slider_image'] != null ? new Title.fromJson(json['slider_image']) : null;
    headerLogo = json['header_logo'];
    footerLogo = json['footer_logo'];
    appLinkImage =
        json['app_link_image'] != null ? new Title.fromJson(json['app_link_image']) : null;
    howWorkImage =
        json['how_work_image'] != null ? new Title.fromJson(json['how_work_image']) : null;
    getTouchImage =
        json['get_touch_image'] != null ? new Title.fromJson(json['get_touch_image']) : null;
    faqImage = json['faq_image'] != null ? new Title.fromJson(json['faq_image']) : null;
    subscribeImage =
        json['subscribe_image'] != null ? new Title.fromJson(json['subscribe_image']) : null;
    sliderTitle = json['slider_title'] != null ? new Title.fromJson(json['slider_title']) : null;
    sliderSubTitle =
        json['slider_sub_title'] != null ? new Title.fromJson(json['slider_sub_title']) : null;
    sliderTag = json['slider_tag'] != null ? new Title.fromJson(json['slider_tag']) : null;
    sliderDescription =
        json['slider_description'] != null ? new Title.fromJson(json['slider_description']) : null;
    galleryTitle = json['gallery_title'] != null ? new Title.fromJson(json['gallery_title']) : null;
    appLinkTitle =
        json['app_link_title'] != null ? new Title.fromJson(json['app_link_title']) : null;
    appLinkDescription = json['app_link_description'] != null
        ? new Title.fromJson(json['app_link_description'])
        : null;
    howWorkTitle =
        json['how_work_title'] != null ? new Title.fromJson(json['how_work_title']) : null;
    howWorkDescription = json['how_work_description'];
    featureTitle = json['feature_title'] != null ? new Title.fromJson(json['feature_title']) : null;
    featureDescription = json['feature_description'] != null
        ? new FeatureDescription.fromJson(json['feature_description'])
        : null;
    getTouchTitle =
        json['get_touch_title'] != null ? new Title.fromJson(json['get_touch_title']) : null;
    getTouchDescription = json['get_touch_description'] != null
        ? new Title.fromJson(json['get_touch_description'])
        : null;
    webMobiles = json['web_mobiles'];
    webEmails = json['web_emails'];
    footerDescription = json['footer_description'] != null
        ? new FeatureDescription.fromJson(json['footer_description'])
        : null;
    copyright = json['copyright'];
    faqTitle = json['faq_title'] != null ? new Title.fromJson(json['faq_title']) : null;
    faqDescription = json['faq_description'] != null
        ? new FeatureDescription.fromJson(json['faq_description'])
        : null;
    numberPoint = json['number_point'];
    excelUserUploadExample = json['excel_user_upload_example'];
    support = json['support'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    if (this.title != null) {
      data['title'] = this.title!.toJson();
    }
    data['image'] = this.image;
    data['email'] = this.email;
    if (this.about != null) {
      data['about'] = this.about!.toJson();
    }
    if (this.address != null) {
      data['address'] = this.address!.toJson();
    }
    data['phone'] = this.phone;
    data['hotline'] = this.hotline;
    data['whatsApp'] = this.whatsApp;
    data['facebook'] = this.facebook;
    data['twitter'] = this.twitter;
    data['youTube'] = this.youTube;
    data['linkedIn'] = this.linkedIn;
    data['instagram'] = this.instagram;
    data['logo'] = this.logo;
    if (this.footer != null) {
      data['footer'] = this.footer!.toJson();
    }
    data['about_image'] = this.aboutImage;
    data['api_version'] = this.apiVersion;
    data['googlePlay'] = this.googlePlay;
    data['appStore'] = this.appStore;
    if (this.termsCondition != null) {
      data['terms_condition'] = this.termsCondition!.toJson();
    }
    if (this.privacy != null) {
      data['privacy'] = this.privacy!.toJson();
    }
    if (this.mobileOnboard != null) {
      data['mobile_onboard'] = this.mobileOnboard!.map((v) => v.toJson()).toList();
    }
    if (this.mobileSlider != null) {
      data['mobile_slider'] = this.mobileSlider!.map((v) => v.toJson()).toList();
    }
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    if (this.subscribeTitle != null) {
      data['subscribe_title'] = this.subscribeTitle!.toJson();
    }
    if (this.subscribeDescription != null) {
      data['subscribe_description'] = this.subscribeDescription!.toJson();
    }
    if (this.sliderImage != null) {
      data['slider_image'] = this.sliderImage!.toJson();
    }
    data['header_logo'] = this.headerLogo;
    data['footer_logo'] = this.footerLogo;
    if (this.appLinkImage != null) {
      data['app_link_image'] = this.appLinkImage!.toJson();
    }
    if (this.howWorkImage != null) {
      data['how_work_image'] = this.howWorkImage!.toJson();
    }
    if (this.getTouchImage != null) {
      data['get_touch_image'] = this.getTouchImage!.toJson();
    }
    if (this.faqImage != null) {
      data['faq_image'] = this.faqImage!.toJson();
    }
    if (this.subscribeImage != null) {
      data['subscribe_image'] = this.subscribeImage!.toJson();
    }
    if (this.sliderTitle != null) {
      data['slider_title'] = this.sliderTitle!.toJson();
    }
    if (this.sliderSubTitle != null) {
      data['slider_sub_title'] = this.sliderSubTitle!.toJson();
    }
    if (this.sliderTag != null) {
      data['slider_tag'] = this.sliderTag!.toJson();
    }
    if (this.sliderDescription != null) {
      data['slider_description'] = this.sliderDescription!.toJson();
    }
    if (this.galleryTitle != null) {
      data['gallery_title'] = this.galleryTitle!.toJson();
    }
    if (this.appLinkTitle != null) {
      data['app_link_title'] = this.appLinkTitle!.toJson();
    }
    if (this.appLinkDescription != null) {
      data['app_link_description'] = this.appLinkDescription!.toJson();
    }
    if (this.howWorkTitle != null) {
      data['how_work_title'] = this.howWorkTitle!.toJson();
    }
    data['how_work_description'] = this.howWorkDescription;
    if (this.featureTitle != null) {
      data['feature_title'] = this.featureTitle!.toJson();
    }
    if (this.featureDescription != null) {
      data['feature_description'] = this.featureDescription!.toJson();
    }
    if (this.getTouchTitle != null) {
      data['get_touch_title'] = this.getTouchTitle!.toJson();
    }
    if (this.getTouchDescription != null) {
      data['get_touch_description'] = this.getTouchDescription!.toJson();
    }
    data['web_mobiles'] = this.webMobiles;
    data['web_emails'] = this.webEmails;
    if (this.footerDescription != null) {
      data['footer_description'] = this.footerDescription!.toJson();
    }
    data['copyright'] = this.copyright;
    if (this.faqTitle != null) {
      data['faq_title'] = this.faqTitle!.toJson();
    }
    if (this.faqDescription != null) {
      data['faq_description'] = this.faqDescription!.toJson();
    }
    data['number_point'] = this.numberPoint;
    data['excel_user_upload_example'] = this.excelUserUploadExample;
    data['support'] = this.support;
    return data;
  }
}

class Title {
  String? en;
  String? ar;

  Title({this.en, this.ar});

  Title.fromJson(Map<String, dynamic> json) {
    en = json['en'];
    ar = json['ar'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['en'] = this.en;
    data['ar'] = this.ar;
    return data;
  }
}

class MobileOnboard {
  String? text;
  String? img;

  MobileOnboard({this.text, this.img});

  MobileOnboard.fromJson(Map<String, dynamic> json) {
    text = json['text'];
    img = json['img'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['text'] = this.text;
    data['img'] = this.img;
    return data;
  }
}

class FeatureDescription {
  String? ar;

  FeatureDescription({this.ar});

  FeatureDescription.fromJson(Map<String, dynamic> json) {
    ar = json['ar'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['ar'] = this.ar;
    return data;
  }
}

class MobileSlider {
  String? text;
  String? img;

  MobileSlider({this.text, this.img});

  MobileSlider.fromJson(Map<String, dynamic> json) {
    text = json['text'];
    img = json['img'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['text'] = this.text;
    data['img'] = this.img;
    return data;
  }
}
