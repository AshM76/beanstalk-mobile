import 'dart:convert';

UserProfileModel userModelFromJson(String str) => UserProfileModel.fromJson(json.decode(str));

String userProfileModelToJson(UserProfileModel data) => json.encode(data.toJson());

class UserProfileModel {
  UserProfileModel({
    this.userId,
    this.email,
    //
    this.gender,
    this.age,
    this.firstName,
    this.lastName,
    this.userName,
    this.phoneNumber,
    //
    this.conditions,
    this.medications,
    this.symptoms,
    //
    this.marketingEmail,
    this.marketingText,
    //
    this.agreement,
    this.validateEmail,
    //
    this.timeNotifications = 15,
  });

  String? userId;
  String? email;
  //
  String? gender;
  DateTime? age;
  String? firstName;
  String? lastName;
  String? userName;
  String? phoneNumber;
  //
  String? conditions;
  String? medications;
  String? symptoms;
  //
  // String height;
  // String height_metric;
  // String weight;
  // String weight_metric;
  //
  bool? marketingEmail;
  bool? marketingText;
  //
  bool? agreement;
  bool? validateEmail;
  //
  int? timeNotifications;

  factory UserProfileModel.fromJson(Map<String, dynamic> json) => UserProfileModel(
        userId: json["user_id"],
        email: json["user_email"],
        //
        gender: json["user_gender"],
        age: json.containsKey('user_age')
            ? (json['user_age'] is Map ? DateTime.parse(json['user_age']['value']) : DateTime.parse(json['user_age']))
            : DateTime(0),
        firstName: json["user_firstName"],
        lastName: json["user_lastName"],
        userName: json["user_userName"],
        phoneNumber: json["user_phoneNumber"],
        //
        conditions: json["user_conditions"],
        medications: json["user_medications"],
        symptoms: json['user_symptoms'],
        //
        marketingEmail: json["user_marketingEmail"],
        marketingText: json["user_marketingText"],
        //
        agreement: json["user_agreement"],
        validateEmail: json["user_validateEmail"],
        //
        timeNotifications: json["user_timeNotifications"],
      );

  Map<String, dynamic> toJson() => {
        "user_id": userId,
        "user_email": email,
        //
        "user_gender": gender,
        "user_age": age,
        "user_firstName": firstName,
        "user_lastName": lastName,
        "user_userName": userName,
        "user_phoneNumber": phoneNumber,
        //
        "user_conditions": conditions,
        "user_medications": medications,
        "user_symptoms": symptoms,
        //
        "user_marketingEmail": marketingEmail,
        "user_marketingText": marketingText,
        //
        "user_agreement": agreement,
        "user_validateEmail": validateEmail,
        //
        "user_timeNotifications": timeNotifications,
      };
}
