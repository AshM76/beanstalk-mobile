import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:location/location.dart';
import 'package:geocoding/geocoding.dart' as Geocoding;
import 'package:beanstalk_mobile/src/models/stores/store_model.dart';
import 'package:beanstalk_mobile/src/services/dispensary/dispensary_service.dart';
import 'package:beanstalk_mobile/src/ui/app_skin.dart';
import 'package:beanstalk_mobile/src/utils/loading.dart';

import '../../preferences/user_preference.dart';
import '../../services/demo/demo_service.dart';
import '../../services/setup_service.dart';
import '../../utils/utils.dart';

class DispensaryListPage extends StatefulWidget {
  @override
  _DispensaryListPageState createState() => _DispensaryListPageState();
}

class _DispensaryListPageState extends State<DispensaryListPage> {
  final _prefs = new UserPreference();
  final dispensaryListServices = DispensaryServices();
  List<Store> _storeList = [];

  Location location = Location();
  late LocationData _currentPosition;
  String? _address;

  double value = 0.12;

  bool _favoriteScreen = false;

  @override
  void initState() {
    super.initState();
    () async {
      await Future.delayed(Duration.zero);
      loadDispensaries(context);
    }();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    String _searchTitle = "";
    if (_address == null) {
      _address = "Current location";
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
            leading: _favoriteScreen
                ? IconButton(
                    icon: Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: AppColor.content,
                    ),
                    onPressed: () {
                      _favoriteScreen = false;
                      loadDispensaries(context);
                    },
                  )
                : Container(),
            actions: [
              _favoriteScreen
                  ? Container()
                  : Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15.0),
                      child: IconButton(
                        icon: Icon(
                          Icons.favorite,
                          color: AppColor.secondaryColor,
                          size: 35,
                        ),
                        onPressed: () {
                          if (_prefs.demoVersion) {
                            showAlertMessage(context, 'Not available in demo version', () {
                              Navigator.pop(context);
                            });
                          } else {
                            _favoriteScreen = true;
                            loadDispensariesFavorites(context);
                          }
                        },
                      ),
                    )
            ],
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
                      _favoriteScreen ? "Favorites" : "Dispensaries",
                      style: TextStyle(
                        fontSize: AppFontSizes.titleSize + (size.width * 0.01),
                        fontFamily: AppFont.primaryFont,
                        color: AppColor.primaryColor,
                      ),
                    ),
                  ),
                ),
                _favoriteScreen
                    ? Container()
                    : Container(
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
                                    hintText: "Find your dispensaries...",
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
                                  loadDispensariesBySearch(context, _searchTitle);
                                } else {
                                  if (_prefs.demoVersion) {
                                    showAlertMessage(context, 'Not available in demo version', () {
                                      Navigator.pop(context);
                                    });
                                  } else {
                                    loadDispensaries(context);
                                  }
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                _favoriteScreen
                    ? Container()
                    : Container(
                        height: 45.0,
                        padding: EdgeInsets.symmetric(horizontal: 15.0, vertical: 5.0),
                        child: Row(
                          children: [
                            Expanded(
                              child: Container(
                                child: TextField(
                                  enabled: false,
                                  keyboardType: TextInputType.emailAddress,
                                  style: TextStyle(fontSize: 15.0, color: Colors.black87),
                                  decoration: InputDecoration(
                                    filled: true,
                                    fillColor: AppColor.thirdColor.withOpacity(0.1),
                                    hintText: _address,
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
                  height: _favoriteScreen ? size.height * 0.693 : size.height * 0.593,
                  child: ListView.builder(
                      itemCount: _storeList.length, itemBuilder: (BuildContext context, int index) => buildDispensaryCard(context, index)),
                ),
                SizedBox(height: size.height * 0.01),
              ],
            ),
          ),
        ));
  }

  getLocation() async {
    bool _serviceEnabled;
    PermissionStatus _permissionGranted;

    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        return;
      }
    }

    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return;
      }
    }

    _currentPosition = await location.getLocation();
    print("${_currentPosition.longitude} : ${_currentPosition.longitude}");
    setState(() {
      _getAddress(_currentPosition.latitude!, _currentPosition.longitude!).then((value) {
        setState(() {
          _address = "${value.first.name}";
          print(_address);
          ////
          loadDispensariesByLocation(context);
          ////
        });
      });
    });

    // location.onLocationChanged.listen((LocationData currentLocation) {
    //   print("${currentLocation.longitude} : ${currentLocation.longitude}");
    //   setState(() {
    //     _currentPosition = currentLocation;
    //     _getAddress(_currentPosition.latitude, _currentPosition.longitude)
    //         .then((value) {
    //       setState(() {
    //         _address = "${value.first.addressLine}";
    //       });
    //     });
    //   });
    // });
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
    return Container(
      height: 180.0,
      child: InkWell(
        child: Card(
          semanticContainer: true,
          elevation: 5,
          margin: EdgeInsets.symmetric(horizontal: 7.5, vertical: 7.5),
          clipBehavior: Clip.antiAliasWithSaveLayer,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25.0),
          ),
          child: Stack(
            children: [
              _storeList[index].photos!.length > 0
                  ? Image.network(
                      _urlResources + _storeList[index].photos!.first!,
                      width: size.width * 0.91,
                      fit: BoxFit.cover,
                    )
                  : Image(
                      image: AssetImage('assets/img/dispensary.jpg'),
                      width: size.width * 0.91,
                      fit: BoxFit.cover,
                    ),
              _storeList[index].photos!.length > 0
                  ? Positioned.fill(
                      child: BackdropFilter(
                        filter: ImageFilter.blur(
                          sigmaX: 2.0,
                          sigmaY: 2.0,
                        ),
                        child: (Container(
                          color: AppColor.primaryColor.withOpacity(0.5),
                        )),
                      ),
                    )
                  : Positioned.fill(
                      child: BackdropFilter(
                        filter: ImageFilter.blur(
                          sigmaX: 3.0,
                          sigmaY: 3.0,
                        ),
                        child: (Container(
                          color: AppColor.primaryColor.withOpacity(0.3),
                        )),
                      ),
                    ),
              Positioned(
                bottom: 0,
                child: Container(
                  height: 67.5,
                  width: size.width * 0.91,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(
                      topRight: Radius.circular(25),
                      topLeft: Radius.circular(25),
                    ),
                    gradient: AppColor.secondaryGradient,
                    color: Colors.transparent.withOpacity(0.9),
                  ),
                ),
              ),
              Positioned(
                // bottom: size.height * 0.095,
                bottom: 70.0,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 15.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "${_storeList[index].title![0].toUpperCase()}${_storeList[index].title!.substring(1).toLowerCase()}",
                        textAlign: TextAlign.start,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                        style: TextStyle(
                          fontSize: AppFontSizes.titleSize - 3.5,
                          color: AppColor.fourthColor,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(height: size.height * 0.0025),
                      _storeList[index].dispensaryTitle!.length > 0
                          ? Text(
                              _storeList[index].dispensaryTitle!,
                              textAlign: TextAlign.start,
                              overflow: TextOverflow.ellipsis,
                              maxLines: 2,
                              style: TextStyle(
                                fontSize: AppFontSizes.contentSize - 2.0,
                                color: AppColor.secondaryColor,
                                fontWeight: FontWeight.w700,
                              ),
                            )
                          : Container(),
                    ],
                  ),
                ),
              ),
              Positioned(
                bottom: size.height * 0.01,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 15.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        margin: EdgeInsets.only(left: 0.5),
                        child: Row(
                          children: [
                            Icon(
                              Icons.location_on,
                              size: 22.5,
                              color: AppColor.fifthColor,
                            ),
                            SizedBox(width: size.width * 0.007),
                            Container(
                              alignment: Alignment.centerLeft,
                              height: 35.0,
                              width: size.width * 0.65,
                              child: Text(
                                _storeList[index].addressline1! + " " + _storeList[index].addressline2!,
                                textAlign: TextAlign.left,
                                overflow: TextOverflow.ellipsis,
                                maxLines: 2,
                                style: TextStyle(
                                  fontSize: AppFontSizes.contentSize + 1.5,
                                  color: AppColor.fifthColor,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: size.height * 0.001),
                      Row(
                        children: [
                          Container(
                            width: size.width * 0.06,
                            height: size.width * 0.06,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.all(
                                Radius.circular(30),
                              ),
                              color: Colors.black.withOpacity(0.3),
                            ),
                            child: Center(
                              child: Text(
                                _storeList[index].rating.toString(),
                                style: TextStyle(
                                  fontSize: AppFontSizes.contentSmallSize + 1.0,
                                  color: AppColor.fifthColor,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 2.0),
                          RatingBar.builder(
                            ignoreGestures: true,
                            initialRating: _storeList[index].rating!,
                            minRating: 0,
                            direction: Axis.horizontal,
                            allowHalfRating: true,
                            itemCount: 5,
                            itemSize: 20,
                            itemPadding: EdgeInsets.symmetric(horizontal: 2),
                            itemBuilder: (context, _) => Icon(
                              Icons.star,
                              color: AppColor.fifthColor,
                            ),
                            onRatingUpdate: (double value) {},
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                top: 10.0,
                right: 10.0,
                child: Container(
                  width: size.width * 0.10,
                  height: size.width * 0.10,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(
                      Radius.circular(30),
                    ),
                    color: AppColor.background.withOpacity(0.1),
                  ),
                  child: Icon(
                    _storeList[index].favorite! ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                    size: 27,
                    color: _storeList[index].favorite! ? AppColor.secondaryColor : AppColor.fifthColor.withOpacity(0.75),
                  ),
                ),
              ),
            ],
          ),
        ),
        onTap: () {
          print(_storeList[index]);
          Navigator.pushNamed(context, 'dispensary_detail', arguments: _storeList[index].id);
        },
      ),
    );
  }

  loadDispensaries(BuildContext context) async {
    final demoService = DemoServices();
    ProgressDialog progressDialog = ProgressDialog(context);
    progressDialog.show();
    Map infoResponse = _prefs.demoVersion ? await demoService.loadStores(_prefs.id) : await dispensaryListServices.dispensaryList();
    if (infoResponse['ok']) {
      setState(() {
        _storeList = [];
        final dispensariesResult = infoResponse['stores'] ?? [];
        dispensariesResult.forEach((store) {
          Store tempStore = Store.fromJson(store);
          _storeList.add(tempStore);
        });
        progressDialog.dismiss();
      });
    } else {
      _storeList = [];
      progressDialog.dismiss();
      print("error load stores");
    }
  }

  loadDispensariesBySearch(BuildContext context, String search) async {
    ProgressDialog progressDialog = ProgressDialog(context);
    progressDialog.show();
    Map infoResponse = {};
    if (double.tryParse(search) != null) {
      infoResponse = await dispensaryListServices.dispensaryListByZip(search);
    } else {
      infoResponse = await dispensaryListServices.dispensaryListBySearch(search);
    }
    if (infoResponse['ok']) {
      setState(() {
        _storeList = [];
        final dispensariesResult = infoResponse['stores'] ?? [];
        dispensariesResult.forEach((store) {
          Store tempStore = Store.fromJson(store);
          _storeList.add(tempStore);
        });
        progressDialog.dismiss();
      });
    } else {
      _storeList = [];
      progressDialog.dismiss();
      print("error load stores");
    }
  }

  loadDispensariesByLocation(BuildContext context) async {
    ProgressDialog progressDialog = ProgressDialog(context);
    progressDialog.show();
    Map infoResponse = await dispensaryListServices.dispensaryListByLocation(_currentPosition.longitude, _currentPosition.latitude);
    if (infoResponse['ok']) {
      setState(() {
        _storeList = [];
        final dispensariesResult = infoResponse['stores'] ?? [];
        dispensariesResult.forEach((store) {
          Store tempStore = Store.fromJson(store);
          _storeList.add(tempStore);
        });
        progressDialog.dismiss();
      });
    } else {
      print("error load stores");
      setState(() {
        _storeList = [];
        progressDialog.dismiss();
      });
    }
  }

  loadDispensariesFavorites(BuildContext context) async {
    ProgressDialog progressDialog = ProgressDialog(context);
    progressDialog.show();
    Map infoResponse = await dispensaryListServices.dispensaryFavoritesList();
    if (infoResponse['ok']) {
      setState(() {
        _storeList = [];
        final dispensariesResult = infoResponse['stores'] ?? [];
        dispensariesResult.forEach((store) {
          Store tempStore = Store.fromJson(store);
          _storeList.add(tempStore);
        });
        progressDialog.dismiss();
      });
    } else {
      progressDialog.dismiss();
      showAlertLongMessage(context, "You don't have Favorites Dispensaries", () {
        Navigator.pop(context);
      });
      print("Favorites does not exists");
    }
  }
}
