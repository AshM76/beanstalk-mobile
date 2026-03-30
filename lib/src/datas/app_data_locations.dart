import '../models/locations/location_state_model.dart';

class AppDataLocation {
  //State Location List
  static List<StateLocation> dataStatesOfUnitedStates = [
    StateLocation(title: "Alabama", abbreviation: "AL"),
    StateLocation(title: "Alaska", abbreviation: "AK"),
    StateLocation(title: "American Samoa", abbreviation: "AS"), //
    StateLocation(title: "Arizona", abbreviation: "AZ"),
    StateLocation(title: "Arkansas", abbreviation: "AR"),
    StateLocation(title: "California", abbreviation: "CA"),
    StateLocation(title: "Colorado", abbreviation: "CO"),
    StateLocation(title: "Connecticut", abbreviation: "CT"),
    StateLocation(title: "Delaware", abbreviation: "DE"),
    StateLocation(title: "District Of Columbia", abbreviation: "DC"),
    StateLocation(title: "Federated States Of Micronesia", abbreviation: "FM"), //
    StateLocation(title: "Florida", abbreviation: "FL"),
    StateLocation(title: "Georgia", abbreviation: "GA"),
    StateLocation(title: "Guam", abbreviation: "GU"), //
    StateLocation(title: "Hawaii", abbreviation: "HI"),
    StateLocation(title: "Idaho", abbreviation: "ID"),
    StateLocation(title: "Illinois", abbreviation: "IL"),
    StateLocation(title: "Indiana", abbreviation: "IN"),
    StateLocation(title: "Iowa", abbreviation: "IA"),
    StateLocation(title: "Kansas", abbreviation: "KS"),
    StateLocation(title: "Kentucky", abbreviation: "KY"),
    StateLocation(title: "Louisiana", abbreviation: "LA"),
    StateLocation(title: "Maine", abbreviation: "ME"),
    StateLocation(title: "Marshall Islands", abbreviation: "MH"),
    StateLocation(title: "Maryland", abbreviation: "MD"),
    StateLocation(title: "Massachusetts", abbreviation: "MA"),
    StateLocation(title: "Michigan", abbreviation: "MI"),
    StateLocation(title: "Minnesota", abbreviation: "MN"),
    StateLocation(title: "Mississippi", abbreviation: "MS"),
    StateLocation(title: "Missouri", abbreviation: "MO"),
    StateLocation(title: "Montana", abbreviation: "MT"),
    StateLocation(title: "Nebraska", abbreviation: "NE"),
    StateLocation(title: "Nevada", abbreviation: "NV"),
    StateLocation(title: "New Hampshire", abbreviation: "NH"),
    StateLocation(title: "New Jersey", abbreviation: "NJ"),
    StateLocation(title: "New Mexico", abbreviation: "NM"),
    StateLocation(title: "New York", abbreviation: "NY"),
    StateLocation(title: "North Carolina", abbreviation: "NC"),
    StateLocation(title: "North Dakota", abbreviation: "ND"),
    StateLocation(title: "Northern Mariana Islands", abbreviation: "CM"), //
    StateLocation(title: "Ohio", abbreviation: "OH"),
    StateLocation(title: "Oklahoma", abbreviation: "OK"),
    StateLocation(title: "Oregon", abbreviation: "OR"),
    StateLocation(title: "Palau", abbreviation: "PW"), //
    StateLocation(title: "Pennsylvania", abbreviation: "PA"),
    StateLocation(title: "Puerto Rico", abbreviation: "PR"),
    StateLocation(title: "Rhode Island", abbreviation: "RI"),
    StateLocation(title: "South Carolina", abbreviation: "SC"),
    StateLocation(title: "South Dakota", abbreviation: "SD"),
    StateLocation(title: "Tennessee", abbreviation: "TN"),
    StateLocation(title: "Texas", abbreviation: "TX"),
    StateLocation(title: "Utah", abbreviation: "UT"),
    StateLocation(title: "Vermont", abbreviation: "VT"),
    StateLocation(title: "Virgin Islands", abbreviation: "VI"), //
    StateLocation(title: "Virginia", abbreviation: "VA"),
    StateLocation(title: "Washington", abbreviation: "WA"),
    StateLocation(title: "West Virginia", abbreviation: "WV"),
    StateLocation(title: "Wisconsin", abbreviation: "WI"),
    StateLocation(title: "Wyoming", abbreviation: "WY"),
  ];

  static List<StateLocation> dataStatesOfAustralian = [
    StateLocation(title: "Australian Capital Territory", abbreviation: "AU-ACT"),
    StateLocation(title: "New South Wales", abbreviation: "AU-NSW"),
    StateLocation(title: "Northern Territory", abbreviation: "AU-NT"),
    StateLocation(title: "Queensland", abbreviation: "AU-QLD"),
    StateLocation(title: "South Australia", abbreviation: "AU-SA"),
    StateLocation(title: "Tasmania", abbreviation: "AU-TAS"),
    StateLocation(title: "Victoria", abbreviation: "AU-VIC"),
    StateLocation(title: "Western Australia", abbreviation: "AU-WA"),
  ];

  //Country Title
  String countryTitle(String code) {
    switch (code.toLowerCase()) {
      case "us":
        return "United States";
      case "au":
        return "Australia";
      default:
        return "";
    }
  }

  //Country Title
  String countryIcon(String code) {
    switch (code.toLowerCase()) {
      case "us":
        return "flag_us.png";
      case "au":
        return "flag_au.png";
      default:
        return "";
    }
  }

  //State US Title
  String? statesUSTitle(String abbreviation) {
    StateLocation state = dataStatesOfUnitedStates.singleWhere((state) => state.abbreviation == abbreviation);
    return state.title;
  }

  //State AU Title
  String? statesAUTitle(String abbreviation) {
    StateLocation state = dataStatesOfAustralian.singleWhere((state) => state.abbreviation == abbreviation);
    return state.title;
  }
}
