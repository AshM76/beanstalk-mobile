import 'package:beanstalk_mobile/src/models/dispensaries/dispensary_hours_model.dart';

/// Store class.
class Store {
  Store({
    this.id,
    this.title,
    this.description,
    this.photos,
    this.addressline1,
    this.addressline2,
    this.city,
    this.state,
    this.zip,
    this.phone,
    this.email,
    this.website,
    this.facebook,
    this.instagram,
    this.twitter,
    this.youtube,
    this.hours,
    this.favorite,
    this.rating,
    this.dispensaryId,
    this.dispensaryTitle,
  });

  String? id;
  String? title;
  String? description;
  List<String?>? photos;
  String? addressline1;
  String? addressline2;
  String? city;
  String? state;
  String? zip;
  String? phone;
  String? email;
  String? website;
  String? facebook;
  String? instagram;
  String? twitter;
  String? youtube;
  List<Hours>? hours;
  bool? favorite;
  double? rating;
  String? dispensaryId;
  String? dispensaryTitle;

  factory Store.fromJsonList(Map<String, dynamic> parsedJson) {
    return new Store(
      id: parsedJson['store_id'] ?? "",
      title: parsedJson['store_name'] ?? "",
      addressline1: parsedJson['store_address']['addressLine1'] ?? "",
    );
  }

  factory Store.fromJson(Map<String, dynamic> parsedJson) {
    List<String?> photosListTemp = [];
    final photosResult = parsedJson['store_photos'] ?? [];
    photosResult.forEach((photo) {
      String? tempPhoto = photo['photo_url'];
      photosListTemp.add(tempPhoto);
    });

    String _facebook = '';
    String _instagram = '';
    String _twitter = '';
    String _youtube = '';
    if (parsedJson['clinician_social'] != null) {
      _facebook = parsedJson['clinician_social']['facebook'] ?? "";
      _instagram = parsedJson['clinician_social']['instagram'] ?? "";
      _facebook = parsedJson['clinician_social']['twitter'] ?? "";
      _instagram = parsedJson['clinician_social']['youtube'] ?? "";
    }

    List<Hours> hoursListTemp = [];
    final hoursResult = parsedJson['store_hours'] ?? [];
    hoursResult.forEach((hours) {
      Hours temphour = Hours.fromJson(hours);
      hoursListTemp.add(temphour);
    });

    double? rating = 0.0;
    if (parsedJson['store_rating'] is double) {
      rating = parsedJson['store_rating'];
    } else if (parsedJson['store_rating'] is int) {
      int valueTemp = parsedJson['store_rating'];
      rating = valueTemp.toDouble();
    } else {
      rating = double.parse(parsedJson['store_rating']);
    }

    return new Store(
      id: parsedJson['store_id'] ?? "",
      title: parsedJson['store_name'] ?? "",
      description: parsedJson['store_description'] ?? "",
      photos: photosListTemp,
      //store_address
      addressline1: parsedJson['store_address']['addressLine1'] ?? "",
      addressline2: parsedJson['store_address']['adressLine2'] ?? "",
      city: parsedJson['store_address']['city'] ?? "",
      state: parsedJson['store_address']['state'] ?? "",
      zip: parsedJson['store_address']['zip'] ?? "",
      // country: parsedJson['store_address']['country'] ?? "",
      //store_contact
      email: parsedJson['store_contact']['email'] ?? "",
      phone: parsedJson['store_contact']['phone'] ?? "",
      // fax: parsedJson['store_contact']['fax'] ?? "",
      website: parsedJson['store_contact']['website'] ?? "",
      //clinician_social
      facebook: _facebook,
      instagram: _instagram,
      twitter: _twitter,
      youtube: _youtube,
      //hours
      hours: hoursListTemp,
      favorite: parsedJson['store_favorite'] ?? false,
      rating: rating,
      dispensaryId: parsedJson['store_dispensary_id'] ?? '',
      dispensaryTitle: parsedJson['store_dispensary_title'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": this.id,
      "title": this.title,
      "photos": this.photos,
      "description": this.description,
      "addressline1": this.addressline1,
      "addressline2": this.addressline2,
      "city": this.city,
      "state": this.state,
      "zip": this.zip,
      "phone": this.phone,
      "email": this.email,
      "website": this.website,
      "facebook": this.facebook,
      "instagram": this.instagram,
      "twitter": this.twitter,
      "youtube": this.youtube,
      "hours": this.hours,
      "favorite": this.favorite,
      "rating": this.rating,
      "dispensary_id": this.dispensaryId,
      "dispensary_title": this.dispensaryTitle,
    };
  }
}
