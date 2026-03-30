import 'clinician_hours_model.dart';

/// Clinician class.
class Clinician {
  Clinician({
    this.id,
    this.title,
    this.firstName,
    this.lastName,
    this.photo,
    this.about,
    this.specialties,
    this.certifications,
    this.addressline1,
    this.addressline2,
    this.city,
    this.state,
    this.zip,
    this.country,
    this.phone,
    this.fax,
    this.email,
    this.website,
    this.facebook,
    this.instagram,
    this.hours,
  });

  String? id;
  String? title;
  String? firstName;
  String? lastName;
  String? photo;
  String? about;
  String? specialties;
  bool? certifications;
  String? addressline1;
  String? addressline2;
  String? city;
  String? state;
  String? zip;
  String? country;
  String? phone;
  String? fax;
  String? email;
  String? website;
  String? facebook;
  String? instagram;
  List<Hours>? hours;

  factory Clinician.fromJson(Map<String, dynamic> parsedJson) {
    String? _title = parsedJson['clinician_title'].toString().toLowerCase() == "none" ? "" : parsedJson['clinician_title'];
    String _facebook = '';
    String _instagram = '';
    if (parsedJson['clinician_social'] != null) {
      _facebook = parsedJson['clinician_social']['facebook'] ?? "";
      _instagram = parsedJson['clinician_social']['instagram'] ?? "";
    }

    List<Hours> hoursListTemp = [];
    final hoursResult = parsedJson['clinician_hours'] ?? [];
    if (hoursResult.toString().isNotEmpty) {
      hoursResult.forEach((hours) {
        Hours temphour = Hours.fromJson(hours);
        hoursListTemp.add(temphour);
      });
    }

    return new Clinician(
      id: parsedJson['clinician_id'] ?? "",
      title: _title ?? "",
      firstName: parsedJson['clinician_firstName'],
      lastName: parsedJson['clinician_lastName'],
      photo: parsedJson['clinician_photoURL'] ?? "",
      about: parsedJson['clinician_about'] ?? "",
      specialties: parsedJson['clinician_specialties'] ?? "",
      certifications: parsedJson['clinician_certifications'] ?? false,
      //clinician_address
      addressline1: parsedJson['clinician_address']['addressLine1'] ?? "",
      addressline2: parsedJson['clinician_address']['adressLine2'] ?? "",
      city: parsedJson['clinician_address']['city'] ?? "",
      state: parsedJson['clinician_address']['state'] ?? "",
      zip: parsedJson['clinician_address']['zip'] ?? "",
      country: parsedJson['clinician_address']['country'] ?? "",
      //clinician_contact
      email: parsedJson['clinician_contact']['email'] ?? "",
      phone: parsedJson['clinician_contact']['phone'] ?? "",
      fax: parsedJson['clinician_contact']['fax'] ?? "",
      website: parsedJson['clinician_contact']['website'] ?? "",
      //clinician_social
      facebook: _facebook,
      instagram: _instagram,
      //hours
      hours: hoursListTemp,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "clinician_id": this.id,
      "clinician_title": this.title,
      "clinician_firstName": this.firstName,
      "clinician_lastName": this.lastName,
      "clinician_addressline1": this.addressline1,
      "clinician_addressline2": this.addressline2,
      "clinician_photoURL": this.photo,
      "clinician_about": this.about,
      "clinician_specialties": this.specialties,
      "clinician_certifications": this.certifications,
      "clinician_city": this.city,
      "clinician_state": this.state,
      "clinician_zip": this.zip,
      "clinician_country": this.country,
      "clinician_phone": this.phone,
      "clinician_fax": this.fax,
      "clinician_email": this.email,
      "clinician_website": this.website,
      "clinician_facebook": this.facebook,
      "clinician_instagram": this.instagram,
      "clinician_hours": this.hours,
    };
  }
}
