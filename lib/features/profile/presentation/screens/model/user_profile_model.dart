class UserProfileModel {
  final int id;
  final String name;
  final String username;
  final String mobile;
  final String email;
  final String city;
  final String nationalId;
  final String walletLimit;
  final String image;
  final WorkTypes? workTypes;
  final List<String>? allowedWorkTypes;

  UserProfileModel({
    required this.id,
    required this.name,
    required this.username,
    required this.mobile,
    required this.email,
    required this.city,
    required this.nationalId,
    required this.walletLimit,
    required this.image,
    this.workTypes,
    this.allowedWorkTypes,
  });

  factory UserProfileModel.fromJson(Map<String, dynamic> json) {
    final data = json['message'] ?? {};
    final workTypesJson = data['work_types'];
    final allowed = data['allowed_work_types'];
    return UserProfileModel(
      id: data['id'] is int ? data['id'] : int.tryParse(data['id'].toString()) ?? 0,
      name: data['name']?.toString() ?? '',
      username: data['username']?.toString() ?? '',
      mobile: data['mobile']?.toString() ?? '',
      email: data['email']?.toString() ?? '',
      city: data['city']?.toString() ?? '',
      nationalId: data['national_id']?.toString() ?? '',
      walletLimit: data['wallet_limit']?.toString() ?? '',
      image: data['image']?.toString() ?? '',
      workTypes: workTypesJson != null ? WorkTypes.fromJson(workTypesJson) : null,
      allowedWorkTypes: allowed is List
          ? allowed.map((e) => e.toString()).toList()
          : null,
    );
  }

  UserProfileModel copyWithField(String field, String value) {
    switch (field) {
      case 'name':
        return UserProfileModel(
          id: id,
          name: value,
          username: username,
          mobile: mobile,
          email: email,
          city: city,
          nationalId: nationalId,
          walletLimit: walletLimit,
          image: image,
          workTypes: workTypes,
          allowedWorkTypes: allowedWorkTypes,
        );
      case 'username':
        return UserProfileModel(
          id: id,
          name: name,
          username: value,
          mobile: mobile,
          email: email,
          city: city,
          nationalId: nationalId,
          walletLimit: walletLimit,
          image: image,
          workTypes: workTypes,
          allowedWorkTypes: allowedWorkTypes,
        );
      case 'mobile':
        return UserProfileModel(
          id: id,
          name: name,
          username: username,
          mobile: value,
          email: email,
          city: city,
          nationalId: nationalId,
          walletLimit: walletLimit,
          image: image,
          workTypes: workTypes,
          allowedWorkTypes: allowedWorkTypes,
        );
      case 'email':
        return UserProfileModel(
          id: id,
          name: name,
          username: username,
          mobile: mobile,
          email: value,
          city: city,
          nationalId: nationalId,
          walletLimit: walletLimit,
          image: image,
          workTypes: workTypes,
          allowedWorkTypes: allowedWorkTypes,
        );
      default:
        return this;
    }
  }
}

class WorkTypes {
  final bool? orders;
  final bool? projects;
  final bool? cleaningContracts;

  WorkTypes({this.orders, this.projects, this.cleaningContracts});

  factory WorkTypes.fromJson(Map<String, dynamic> json) {
    return WorkTypes(
      orders: json['orders'],
      projects: json['projects'],
      cleaningContracts: json['cleaning_contracts'] ?? json['cleaning_contract'],
    );
  }
}
