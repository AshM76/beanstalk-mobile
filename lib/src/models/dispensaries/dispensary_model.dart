import 'dispensary_hours_model.dart';

/// Dispensary class.
class Dispensary {
  Dispensary({
    this.id,
    this.title,
    this.photo,
    this.description,
    this.addressline1,
    this.addressline2,
    this.city,
    this.state,
    this.zip,
    this.phone,
    this.website,
    this.hours,
    this.license,
    this.facebook,
    this.instagram,
    this.twitter,
    this.youtube,
    this.favorite,
    this.rating,
  });

  String? id;
  String? title;
  String? photo;
  String? description;
  String? addressline1;
  String? addressline2;
  String? city;
  String? state;
  String? zip;
  String? phone;
  String? website;
  List<Hours>? hours;
  String? license;
  String? facebook;
  String? instagram;
  String? twitter;
  String? youtube;

  bool? favorite;
  double? rating;

  factory Dispensary.fromJson(Map<String, dynamic> parsedJson) {
    double? rating = 0.0;

    if (parsedJson['rating'] is double) {
      rating = parsedJson['rating'];
    } else if (parsedJson['rating'] is int) {
      int valueTemp = parsedJson['rating'];
      rating = valueTemp.toDouble();
    } else {
      rating = double.parse(parsedJson['rating']);
    }

    return new Dispensary(
      id: parsedJson['dispensary_id'] ?? "",
      title: parsedJson['dispensary_name'] ?? "",
      photo: parsedJson['dispensary_photo'] ?? "",
      description: parsedJson['dispensary_description'] ?? "",
      addressline1: parsedJson['dispensary_addressLine1'] ?? "",
      addressline2: parsedJson['dispensary_addressLine2'] ?? "",
      city: parsedJson['dispensary_city'] ?? "",
      state: parsedJson['dispensary_state'] ?? "",
      zip: parsedJson['dispensary_zip'] ?? "",
      phone: parsedJson['dispensary_phone'] ?? "",
      website: parsedJson['dispensary_website'] ?? "",
      hours: parsedJson['dispensary_hours'] ?? "" as List<Hours>?,
      license: parsedJson['dispensary_license'] ?? "",
      facebook: parsedJson['dispensary_facebook'] ?? "",
      instagram: parsedJson['dispensary_instagram'] ?? "",
      twitter: parsedJson['dispensary_twitter'] ?? "",
      youtube: parsedJson['dispensary_youtube'] ?? "",
      favorite: parsedJson['favorite'] ?? false,
      rating: rating,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": this.id,
      "title": this.title,
      "photo": this.photo,
      "description": this.description,
      "addressline1": this.addressline1,
      "addressline2": this.addressline2,
      "city": this.city,
      "state": this.state,
      "zip": this.zip,
      "phone": this.phone,
      "website": this.website,
      "hours": this.hours,
      "license": this.license,
      "facebook": this.facebook,
      "instagram": this.instagram,
      "twitter": this.twitter,
      "youtube": this.youtube,
      "favorite": this.favorite,
      "rating": this.rating,
    };
  }
}
