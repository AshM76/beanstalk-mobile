import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:geocoding/geocoding.dart' as Geocoding;
import 'package:beanstalk_mobile/src/models/clinicians/clinician_model.dart';
import 'package:beanstalk_mobile/src/services/clinician/clinician_service.dart';
import 'package:beanstalk_mobile/src/ui/app_skin.dart';
import 'package:beanstalk_mobile/src/utils/loading.dart';

import '../../preferences/user_preference.dart';
import '../../services/demo/demo_service.dart';
import '../../services/setup_service.dart';
import '../../utils/utils.dart';

class CliniciansListPage extends StatefulWidget {
  @override
  _CliniciansListPageState createState() => _CliniciansListPageState();
}

class _CliniciansListPageState extends State<CliniciansListPage> {
  final _prefs = new UserPreference();
  final clinicianListServices = ClinicianServices();
  List<Clinician> _clinicianList = [];

  Location location = Location();
  late LocationData _currentPosition;
  String? _addressLocation;

  double value = 0.12;

  @override
  void initState() {
    super.initState();
    () async {
      await Future.delayed(Duration.zero);
      // getLocation(); //
      loadClinicians(context, '');
    }();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    String _searchTitle = "";
    if (_addressLocation == null) {
      _addressLocation = "Current location";
    }
    return Scaffold(
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(size.height * 0.066),
          child: AppBar(
            elevation: 0.0,
            automaticallyImplyLeading: false,
            backgroundColor: AppColor.background,
            flexibleSpace: SafeArea(
              child: FlexibleSpaceBar(
                title: Container(
                  child: Center(
                    child: Image.network(
                      AppLogos.iconImg,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        body: SingleChildScrollView(
          child: Container(
            color: AppColor.background,
            padding: EdgeInsets.symmetric(horizontal: 10.0),
            child: Column(
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10.0),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Clinicians",
                      style: TextStyle(
                        fontSize: AppFontSizes.titleSize + (size.width * 0.01),
                        fontFamily: AppFont.primaryFont,
                        color: AppColor.primaryColor,
                      ),
                    ),
                  ),
                ),
                Container(
                  height: 45.0,
                  padding: EdgeInsets.symmetric(horizontal: 15.0, vertical: 5.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          child: TextField(
                            onChanged: (value) => _searchTitle = value,
                            autofocus: false,
                            keyboardType: TextInputType.emailAddress,
                            style: TextStyle(fontSize: 15.0, color: Colors.black87),
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: Colors.white,
                              hintText: "Find your clinicians...",
                              hintStyle: TextStyle(fontSize: 14.0, color: Colors.grey[400]),
                              contentPadding: EdgeInsets.only(left: 25.0, right: 25.0, top: 10.0, bottom: 10.0),
                              border: OutlineInputBorder(borderSide: BorderSide.none, borderRadius: BorderRadius.circular(20.0)),
                              focusedBorder: OutlineInputBorder(borderSide: BorderSide.none, borderRadius: BorderRadius.circular(20.0)),
                            ),
                          ),
                        ),
                      ),
                      FloatingActionButton(
                        elevation: 0.0,
                        backgroundColor: Colors.transparent,
                        foregroundColor: AppColor.background,
                        heroTag: "search",
                        child: Container(
                          width: 45,
                          height: 45,
                          child: Icon(
                            Icons.search_rounded,
                            size: 27,
                          ),
                          decoration: BoxDecoration(shape: BoxShape.circle, gradient: AppColor.secondaryGradient),
                        ),
                        onPressed: () {
                          if (_searchTitle.isNotEmpty) {
                            print("Search");
                            loadClinicians(context, _searchTitle);
                          } else {
                            if (_prefs.demoVersion) {
                              showAlertMessage(context, 'Not available in demo version', () {
                                Navigator.pop(context);
                              });
                            } else {
                              loadClinicians(context, '');
                            }
                          }
                        },
                      ),
                    ],
                  ),
                ),
                Container(
                  height: 45.0,
                  padding: EdgeInsets.symmetric(horizontal: 15.0, vertical: 5.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          child: TextField(
                            enabled: false,
                            style: TextStyle(fontSize: 15.0, color: Colors.black87),
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: AppColor.thirdColor.withOpacity(0.1),
                              hintText: _addressLocation,
                              hintStyle: TextStyle(fontSize: 14.0, color: AppColor.primaryColor),
                              contentPadding: EdgeInsets.only(left: 25.0, right: 25.0, top: 10.0, bottom: 10.0),
                              border: OutlineInputBorder(borderSide: BorderSide.none, borderRadius: BorderRadius.circular(20.0)),
                              focusedBorder: OutlineInputBorder(borderSide: BorderSide.none, borderRadius: BorderRadius.circular(20.0)),
                            ),
                          ),
                        ),
                      ),
                      FloatingActionButton(
                          elevation: 0.0,
                          backgroundColor: Colors.transparent,
                          foregroundColor: AppColor.background,
                          heroTag: "location",
                          child: Container(
                            width: 45,
                            height: 45,
                            child: Icon(
                              Icons.location_on,
                              size: 25,
                            ),
                            decoration: BoxDecoration(shape: BoxShape.circle, gradient: AppColor.secondaryGradient),
                          ),
                          onPressed: () {
                            if (_prefs.demoVersion) {
                              showAlertMessage(context, 'Not available in demo version', () {
                                Navigator.pop(context);
                              });
                            } else {
                              setState(() {
                                print("Location");
                                getLocation();
                                value = 0.5;
                              });
                            }
                          }),
                    ],
                  ),
                ),
                SizedBox(height: size.height * 0.01),
                Container(
                  height: size.height * 0.593,
                  child: ListView.builder(
                      itemCount: _clinicianList.length, itemBuilder: (BuildContext context, int index) => buildDispensaryCard(context, index)),
                ),
                SizedBox(height: size.height * 0.01),
              ],
            ),
          ),
        ));
  }

  getLocation() async {
    ProgressDialog progressDialog = ProgressDialog(context);
    progressDialog.show();

    bool _serviceEnabled;
    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        return;
      }
    }

    PermissionStatus _permissionGranted;
    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return;
      }
    }

    _currentPosition = await location.getLocation();
    print("${_currentPosition.latitude} : ${_currentPosition.longitude}");
    _getAddress(_currentPosition.latitude!, _currentPosition.longitude!).then((value) {
      setState(() {
        _addressLocation = "${value.first.name}";
        print(_addressLocation);
        ////
        loadCliniciansNearby(context, _currentPosition.latitude.toString(), _currentPosition.longitude.toString());
        ////
        progressDialog.dismiss();
      });
    });
  }

  Future<List<Geocoding.Placemark>> _getAddress(double lat, double lang) async {
    // final coordinates = new Coordinates(lat, lang);
    // List<Address> address = await Geocoder.local.findAddressesFromCoordinates(coordinates);
    List<Geocoding.Placemark> placemarks = await Geocoding.placemarkFromCoordinates(lat, lang);
    return placemarks;
  }

  Widget buildDispensaryCard(BuildContext context, int index) {
    final size = MediaQuery.of(context).size;
    final String _urlResources = SetupServices.resourcesURL;
    Clinician clinician = _clinicianList[index];
    return Container(
      height: 150.0,
      child: InkWell(
        child: Card(
          shadowColor: Colors.transparent,
          color: Colors.transparent,
          semanticContainer: true,
          elevation: 2.5,
          margin: EdgeInsets.symmetric(horizontal: 7.5, vertical: 7.5),
          clipBehavior: Clip.antiAliasWithSaveLayer,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25.0),
          ),
          child: Stack(
            children: [
              Positioned(
                bottom: 0,
                child: Container(
                  height: 50.0,
                  width: size.width * 0.91,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(
                      topRight: Radius.circular(25),
                      topLeft: Radius.circular(25),
                    ),
                    gradient: AppColor.secondaryGradient,
                  ),
                ),
              ),
              Container(
                height: 80.0,
                padding: EdgeInsets.only(top: size.width * 0.03, left: size.width * 0.04, right: size.width * 0.01, bottom: size.width * 0.01),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(size.width * 0.17),
                      child: _clinicianList[index].photo!.length > 0
                          ? Image.network(
                              _urlResources + _clinicianList[index].photo!,
                              width: size.width * 0.17,
                              height: size.width * 0.17,
                              fit: BoxFit.cover,
                            )
                          : Image(
                              image: AssetImage('assets/img/clinician.png'),
                              width: size.width * 0.17,
                              height: size.width * 0.17,
                              fit: BoxFit.cover,
                            ),
                    ),
                    SizedBox(width: size.width * 0.025),
                    Container(
                      width: size.width * 0.6,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            clinician.title! + " " + clinician.firstName! + " " + clinician.lastName!,
                            textAlign: TextAlign.start,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 2,
                            style: TextStyle(
                              fontSize: AppFontSizes.subTitleSize,
                              color: AppColor.content,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          SizedBox(height: size.height * 0.005),
                          Text(
                            clinician.specialties!,
                            textAlign: TextAlign.start,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 2,
                            style: TextStyle(
                              fontSize: AppFontSizes.contentSize - 1.5,
                              color: AppColor.secondaryColor,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                bottom: size.height * 0.01,
                child: Container(
                  padding: EdgeInsets.only(top: size.width * 0.02, left: size.width * 0.1, right: size.width * 0.01),
                  child: Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        size: AppFontSizes.contentSize + 7.0,
                        color: AppColor.background,
                      ),
                      SizedBox(width: size.width * 0.02),
                      Container(
                        alignment: Alignment.centerLeft,
                        height: 35.0,
                        width: size.width * 0.65,
                        child: Text(
                          clinician.addressline1! +
                              " " +
                              clinician.addressline2! +
                              ", " +
                              clinician.city! +
                              "\n" +
                              clinician.state! +
                              " " +
                              clinician.zip!,
                          textAlign: TextAlign.left,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
                          style: TextStyle(
                            fontSize: AppFontSizes.contentSize - 1.5,
                            color: AppColor.background,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        onTap: () {
          print(_clinicianList[index]);
          Navigator.pushNamed(context, 'clinician_detail', arguments: _clinicianList[index].id);
        },
      ),
    );
  }

  loadClinicians(BuildContext context, String search) async {
    final demoService = DemoServices();
    ProgressDialog progressDialog = ProgressDialog(context);
    progressDialog.show();
    Map infoResponse = _prefs.demoVersion ? await demoService.loadClinicians(_prefs.id) : await clinicianListServices.clinicianList(search);
    if (infoResponse['ok']) {
      setState(() {
        _clinicianList = [];
        final cliniciansResult = infoResponse['clinicians'] ?? [];
        cliniciansResult.forEach((clinician) {
          Clinician tempClinician = Clinician.fromJson(clinician);
          _clinicianList.add(tempClinician);
        });
        progressDialog.dismiss();
      });
    } else {
      setState(() {
        _clinicianList = [];
        print("error load stores");
        progressDialog.dismiss();
      });
    }
  }

  loadCliniciansNearby(BuildContext context, String latitude, String longitude) async {
    final demoService = DemoServices();
    ProgressDialog progressDialog = ProgressDialog(context);
    progressDialog.show();
    Map infoResponse =
        _prefs.demoVersion ? await demoService.loadStores(_prefs.id) : await clinicianListServices.clinicianLocation(latitude, longitude);
    if (infoResponse['ok']) {
      setState(() {
        _clinicianList = [];
        final cliniciansResult = infoResponse['clinicians'] ?? [];
        cliniciansResult.forEach((clinician) {
          Clinician tempClinician = Clinician.fromJson(clinician);
          _clinicianList.add(tempClinician);
        });
        progressDialog.dismiss();
      });
    } else {
      setState(() {
        _clinicianList = [];
        progressDialog.dismiss();
        print("error load clinicians");
      });
    }
  }
}
