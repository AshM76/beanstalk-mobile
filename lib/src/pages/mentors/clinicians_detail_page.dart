import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:beanstalk_mobile/src/models/chatings/chat_clinician_model.dart';
import 'package:beanstalk_mobile/src/models/clinicians/clinician_hours_model.dart';
import 'package:beanstalk_mobile/src/models/clinicians/clinician_model.dart';
import 'package:beanstalk_mobile/src/services/clinician/clinician_service.dart';
import 'package:beanstalk_mobile/src/ui/app_skin.dart';
import 'package:beanstalk_mobile/src/utils/loading.dart';

import '../../preferences/user_preference.dart';
import '../../services/demo/demo_service.dart';
import '../../services/setup_service.dart';

class ClinicianDetailPage extends StatefulWidget {
  @override
  _ClinicianDetailPageState createState() => _ClinicianDetailPageState();
}

class _ClinicianDetailPageState extends State<ClinicianDetailPage> {
  final _prefs = new UserPreference();
  final clinicianListServices = ClinicianServices();
  Clinician _clinician = Clinician(
    title: '',
    firstName: '',
    lastName: '',
    photo: '',
    about: '',
    specialties: '',
    certifications: false,
    addressline1: '',
    addressline2: '',
    city: '',
    state: '',
    zip: '',
    country: '',
    phone: '',
    fax: '',
    email: '',
    website: '',
    facebook: '',
    instagram: '',
    hours: [],
  );

  @override
  void initState() {
    super.initState();
    () async {
      await Future.delayed(Duration.zero);
      _loadClinicians(context);
    }();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        elevation: 0.0,
        backgroundColor: AppColor.primaryColor,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            color: Colors.transparent,
          ),
          child: SafeArea(
            child: Center(
              child: Image.network(
                AppLogos.iconImg,
                width: size.width * 0.1,
                height: size.width * 0.1,
                fit: BoxFit.contain,
              ),
            ),
          ),
        ),
      ),
      body: Container(
        color: AppColor.primaryColor,
        child: Stack(
          children: [
            _headerDispensary(context),
            _conntentDispensary(context),
          ],
        ),
      ),
    );
  }

  _headerDispensary(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final String _urlResources = SetupServices.resourcesURL;
    return Stack(
      children: [
        Positioned.fill(
            child: Container(
          color: AppColor.primaryColor,
        )),
        Positioned(
          right: -50.0,
          top: 10.0,
          child: Image.network(
            AppLogos.iconImg,
            height: size.height * 0.3,
            fit: BoxFit.cover,
            opacity: const AlwaysStoppedAnimation(0.2),
            // color: Colors.white.withOpacity(0.1),
          ),
        ),
        Positioned(
          right: 15.0,
          top: 0.0,
          child: InkWell(
            child: Container(
              width: size.width * 0.14,
              height: size.height * 0.07,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(
                  Radius.circular(10),
                ),
                color: Colors.white.withOpacity(0.1),
              ),
              child: Icon(
                Icons.chat,
                size: size.height * 0.055,
                color: AppColor.fifthColor,
              ),
            ),
            onTap: () {
              ChatClinician _chatHistory = ChatClinician(
                  id: '',
                  companyId: _prefs.appId,
                  companyName: _prefs.projectId,
                  clinicianId: _clinician.id,
                  clinicianName: _clinician.title! + '' + _clinician.firstName! + '' + _clinician.lastName!,
                  lastMessage: '',
                  messages: []);
              _prefs.clinicianPhoto = _clinician.photo!;
              Navigator.pushNamed(context, 'chat_clinician_private', arguments: _chatHistory);
            },
          ),
        ),
        Center(
          child: Column(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(size.height * 0.175),
                child: _clinician.photo!.length > 0
                    ? Image.network(
                        _urlResources + _clinician.photo!,
                        height: size.height * 0.175,
                        fit: BoxFit.cover,
                      )
                    : Image(
                        image: AssetImage('assets/img/clinician.png'),
                        width: size.width * 0.35,
                        height: size.width * 0.35,
                        fit: BoxFit.cover,
                      ),
              ),
              SizedBox(height: size.height * 0.005),
              Container(
                child: Text(
                  _clinician.title! + " " + _clinician.firstName! + " " + _clinician.lastName!,
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 3,
                  style: TextStyle(
                    fontSize: AppFontSizes.titleSize - 2.5,
                    color: AppColor.background,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              SizedBox(height: size.height * 0.0025),
              Container(
                child: Text(
                  _clinician.specialties!,
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                  style: TextStyle(
                    fontSize: AppFontSizes.contentSize,
                    color: AppColor.fifthColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        )
      ],
    );
  }

  _conntentDispensary(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Positioned(
      bottom: 0.0,
      child: AnimatedContainer(
        duration: Duration(milliseconds: 150),
        width: size.width,
        height: size.height * 0.6,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.only(
            topRight: Radius.circular(30),
            topLeft: Radius.circular(30),
          ),
          color: Colors.grey[200],
        ),
        child: SingleChildScrollView(
          child: Container(
              padding: EdgeInsets.only(left: 20.0, right: 20.0, top: 20.0, bottom: 10.0),
              child: Stack(
                children: [_showInformation(context)],
              )),
        ),
      ),
    );
  }

  _showInformation(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: size.height * 0.01),
        _clinician.certifications!
            ? Row(
                children: [
                  Icon(
                    Icons.badge_rounded, //assistant_outlined, // assignment_turned_in,
                    size: 30,
                    color: AppColor.secondaryColor,
                  ),
                  SizedBox(width: size.width * 0.01),
                  Text(
                    "Medical Cannabis Certifications Offered",
                    textAlign: TextAlign.left,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                    style: TextStyle(
                      fontSize: AppFontSizes.contentSize - 1.0,
                      color: AppColor.secondaryColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              )
            : Container(),
        SizedBox(height: size.height * 0.01),
        Text(
          _clinician.about!,
          textAlign: TextAlign.left,
          overflow: TextOverflow.ellipsis,
          maxLines: 7,
          style: TextStyle(
            fontSize: AppFontSizes.contentSize,
            color: AppColor.content,
            fontWeight: FontWeight.w700,
          ),
        ),
        SizedBox(height: size.height * 0.02),
        Container(
          child: Text(
            "Location",
            style: TextStyle(fontSize: AppFontSizes.contentSmallSize, color: AppColor.content, fontWeight: FontWeight.w600),
          ),
        ),
        SizedBox(height: size.height * 0.01),
        Row(
          children: [
            Container(
              height: 50.0,
              width: size.width * 0.12,
              decoration: BoxDecoration(color: AppColor.background, borderRadius: BorderRadius.circular(10.0)),
              child: Center(
                child: Icon(
                  Icons.location_on,
                  size: 30,
                  color: AppColor.secondaryColor,
                ),
              ),
            ),
            SizedBox(width: size.width * 0.015),
            Container(
              height: 50.0,
              width: size.width * 0.72,
              padding: EdgeInsets.symmetric(vertical: 2.5, horizontal: 10.0),
              decoration: BoxDecoration(color: AppColor.background, borderRadius: BorderRadius.circular(10.0)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _clinician.addressline1!,
                    textAlign: TextAlign.left,
                    style: TextStyle(
                      fontSize: AppFontSizes.contentSize,
                      color: AppColor.content,
                    ),
                  ),
                  Text(
                    _clinician.addressline2!,
                    textAlign: TextAlign.left,
                    style: TextStyle(
                      fontSize: AppFontSizes.contentSize - 1.0,
                      color: AppColor.content,
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
        SizedBox(height: size.height * 0.01),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Flexible(
                  flex: 2,
                  child: Container(
                      child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Container(
                          child: Text(
                            "City",
                            style: TextStyle(fontSize: AppFontSizes.contentSmallSize, color: AppColor.content, fontWeight: FontWeight.w600),
                          ),
                        ),
                        Container(
                          height: 50,
                          child: Stack(
                            children: [
                              Container(
                                alignment: Alignment.center,
                                width: size.width * 0.70,
                                margin: EdgeInsets.symmetric(vertical: 5.0, horizontal: 5.0),
                                padding: EdgeInsets.symmetric(vertical: 5.0, horizontal: 5.0),
                                decoration: BoxDecoration(color: AppColor.background, borderRadius: BorderRadius.circular(10.0)),
                                child: Text(
                                  _clinician.city!,
                                  textAlign: TextAlign.left,
                                  style: TextStyle(
                                    fontSize: AppFontSizes.contentSize,
                                    color: AppColor.content,
                                  ),
                                ),
                              ),
                              Positioned(
                                top: 5.0,
                                child: Image(
                                  color: AppColor.fifthColor,
                                  width: AppFontSizes.contentSize,
                                  image: AssetImage('assets/img/icon_arrow.png'),
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ]),
                      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Container(
                          child: Text(
                            "State",
                            style: TextStyle(fontSize: AppFontSizes.contentSmallSize, color: AppColor.content, fontWeight: FontWeight.w600),
                          ),
                        ),
                        Container(
                          height: 50,
                          child: Stack(
                            children: [
                              Container(
                                alignment: Alignment.center,
                                width: size.width * 0.70,
                                margin: EdgeInsets.symmetric(vertical: 5.0, horizontal: 5.0),
                                padding: EdgeInsets.symmetric(vertical: 5.0, horizontal: 5.0),
                                decoration: BoxDecoration(color: AppColor.background, borderRadius: BorderRadius.circular(10.0)),
                                child: Text(
                                  _clinician.state!,
                                  textAlign: TextAlign.left,
                                  style: TextStyle(
                                    fontSize: AppFontSizes.contentSize,
                                    color: AppColor.content,
                                  ),
                                ),
                              ),
                              Positioned(
                                top: 5.0,
                                child: Image(
                                  color: AppColor.fifthColor,
                                  width: AppFontSizes.contentSize,
                                  image: AssetImage('assets/img/icon_arrow.png'),
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ]),
                      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Container(
                          child: Text(
                            "Zip",
                            style: TextStyle(fontSize: AppFontSizes.contentSmallSize, color: AppColor.content, fontWeight: FontWeight.w600),
                          ),
                        ),
                        Container(
                          height: 50,
                          child: Stack(
                            children: [
                              Container(
                                alignment: Alignment.center,
                                width: size.width * 0.70,
                                margin: EdgeInsets.symmetric(vertical: 5.0, horizontal: 5.0),
                                padding: EdgeInsets.symmetric(vertical: 5.0, horizontal: 5.0),
                                decoration: BoxDecoration(color: AppColor.background, borderRadius: BorderRadius.circular(10.0)),
                                child: Text(
                                  _clinician.zip!,
                                  textAlign: TextAlign.left,
                                  style: TextStyle(
                                    fontSize: AppFontSizes.contentSize,
                                    color: AppColor.content,
                                  ),
                                ),
                              ),
                              Positioned(
                                top: 5.0,
                                child: Image(
                                  color: AppColor.fifthColor,
                                  width: AppFontSizes.contentSize,
                                  image: AssetImage('assets/img/icon_arrow.png'),
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ]),
                    ],
                  )),
                ),
                Flexible(
                  flex: 2,
                  child: Container(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _clinician.country!.length > 0
                            ? Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                Container(
                                  child: Text(
                                    "Country",
                                    style: TextStyle(fontSize: AppFontSizes.contentSmallSize, color: AppColor.content, fontWeight: FontWeight.w600),
                                  ),
                                ),
                                Container(
                                  height: 50,
                                  child: Stack(
                                    children: [
                                      Container(
                                        alignment: Alignment.center,
                                        width: size.width * 0.70,
                                        margin: EdgeInsets.symmetric(vertical: 5.0, horizontal: 5.0),
                                        padding: EdgeInsets.symmetric(vertical: 5.0, horizontal: 5.0),
                                        decoration: BoxDecoration(color: AppColor.background, borderRadius: BorderRadius.circular(10.0)),
                                        child: Text(
                                          _clinician.country!,
                                          textAlign: TextAlign.left,
                                          style: TextStyle(
                                            fontSize: AppFontSizes.contentSize,
                                            color: AppColor.content,
                                          ),
                                        ),
                                      ),
                                      Positioned(
                                        top: 5.0,
                                        child: Image(
                                          color: AppColor.fifthColor,
                                          width: AppFontSizes.contentSize,
                                          image: AssetImage('assets/img/icon_arrow.png'),
                                          fit: BoxFit.contain,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ])
                            : Container(),
                        _clinician.hours!.length > 0
                            ? Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                Container(
                                  child: Text(
                                    "Hours",
                                    style: TextStyle(fontSize: AppFontSizes.contentSmallSize, color: AppColor.content, fontWeight: FontWeight.w600),
                                  ),
                                ),
                                Container(
                                  height: 177,
                                  child: Stack(
                                    children: [
                                      Container(
                                        margin: EdgeInsets.symmetric(vertical: 5.0, horizontal: 5.0),
                                        padding: EdgeInsets.symmetric(vertical: 5.0, horizontal: 5.0),
                                        decoration: BoxDecoration(color: AppColor.background, borderRadius: BorderRadius.circular(10.0)),
                                        child: ListView.builder(
                                            padding: EdgeInsets.symmetric(vertical: 2.5, horizontal: 5.0),
                                            physics: NeverScrollableScrollPhysics(),
                                            itemCount: _clinician.hours!.length,
                                            itemBuilder: (BuildContext context, int index) => _initHours(context, index)),
                                        // Text(
                                        //   _store.hours.length > 0
                                        //       ? _store.hours
                                        //       : "09:00 AM - 20:00 PM",
                                        //   textAlign: TextAlign.left,
                                        //   style: TextStyle(
                                        //     fontSize:
                                        //         AppFontSizes.contentSize -
                                        //             1.0,
                                        //     color: AppColor.content,
                                        //   ),
                                        // ),
                                      ),
                                      Positioned(
                                        top: 5.0,
                                        child: Image(
                                          color: AppColor.fifthColor,
                                          width: AppFontSizes.contentSize,
                                          image: AssetImage('assets/img/icon_arrow.png'),
                                          fit: BoxFit.contain,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ])
                            : Container(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        SizedBox(height: size.height * 0.02),
        _clinician.phone!.length > 0 || _clinician.email!.length > 0 || _clinician.phone!.length > 0 || _clinician.website!.length > 0
            ? Container(
                child: Text(
                  "Contacts",
                  style: TextStyle(fontSize: AppFontSizes.contentSmallSize, color: AppColor.content, fontWeight: FontWeight.w600),
                ),
              )
            : Container(),
        SizedBox(height: size.height * 0.01),
        _clinician.email!.length > 0
            ? Row(
                children: [
                  Container(
                    height: 50.0,
                    width: size.width * 0.12,
                    decoration: BoxDecoration(color: AppColor.background, borderRadius: BorderRadius.circular(10.0)),
                    child: Center(
                      child: Icon(
                        Icons.mail,
                        size: 30,
                        color: AppColor.secondaryColor,
                      ),
                    ),
                  ),
                  SizedBox(width: size.width * 0.015),
                  Container(
                    height: 50.0,
                    width: size.width * 0.72,
                    padding: EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0),
                    decoration: BoxDecoration(color: AppColor.background, borderRadius: BorderRadius.circular(10.0)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Email",
                          textAlign: TextAlign.left,
                          style: TextStyle(fontSize: AppFontSizes.contentSmallSize, color: AppColor.content, fontWeight: FontWeight.w700),
                        ),
                        SizedBox(height: size.height * 0.001),
                        Text(
                          _clinician.email!,
                          textAlign: TextAlign.left,
                          style: TextStyle(
                            fontSize: AppFontSizes.contentSize - 1.0,
                            color: AppColor.content,
                          ),
                        )
                      ],
                    ),
                  ),
                ],
              )
            : Container(),
        SizedBox(height: size.height * 0.01),
        _clinician.phone!.length > 0
            ? Row(
                children: [
                  Container(
                    height: 50.0,
                    width: size.width * 0.12,
                    decoration: BoxDecoration(color: AppColor.background, borderRadius: BorderRadius.circular(10.0)),
                    child: Center(
                      child: Icon(
                        Icons.phone,
                        size: 30,
                        color: AppColor.secondaryColor,
                      ),
                    ),
                  ),
                  SizedBox(width: size.width * 0.015),
                  Container(
                    height: 50.0,
                    width: size.width * 0.72,
                    padding: EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0),
                    decoration: BoxDecoration(color: AppColor.background, borderRadius: BorderRadius.circular(10.0)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Phone",
                          textAlign: TextAlign.left,
                          style: TextStyle(fontSize: AppFontSizes.contentSmallSize, color: AppColor.content, fontWeight: FontWeight.w700),
                        ),
                        SizedBox(height: size.height * 0.001),
                        Text(
                          _clinician.phone!,
                          textAlign: TextAlign.left,
                          style: TextStyle(
                            fontSize: AppFontSizes.contentSize - 1.0,
                            color: AppColor.content,
                          ),
                        )
                      ],
                    ),
                  ),
                ],
              )
            : Container(),
        SizedBox(height: size.height * 0.01),
        _clinician.website!.length > 0
            ? Row(
                children: [
                  Container(
                    height: 50.0,
                    width: size.width * 0.12,
                    decoration: BoxDecoration(color: AppColor.background, borderRadius: BorderRadius.circular(10.0)),
                    child: Center(
                      child: Icon(
                        Icons.laptop_windows_rounded,
                        size: 30,
                        color: AppColor.secondaryColor,
                      ),
                    ),
                  ),
                  SizedBox(width: size.width * 0.015),
                  Container(
                    height: 50.0,
                    width: size.width * 0.72,
                    padding: EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0),
                    decoration: BoxDecoration(color: AppColor.background, borderRadius: BorderRadius.circular(10.0)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Web Site",
                          textAlign: TextAlign.left,
                          style: TextStyle(fontSize: AppFontSizes.contentSmallSize, color: AppColor.content, fontWeight: FontWeight.w700),
                        ),
                        SizedBox(height: size.height * 0.001),
                        Text(
                          _clinician.website!,
                          textAlign: TextAlign.left,
                          style: TextStyle(
                            fontSize: AppFontSizes.contentSize - 1.0,
                            color: AppColor.content,
                          ),
                        )
                      ],
                    ),
                  ),
                ],
              )
            : Container(),
        SizedBox(height: size.height * 0.02),
        _clinician.facebook!.length > 0 || _clinician.instagram!.length > 0
            ? Container(
                child: Text(
                  "Social Media",
                  style: TextStyle(fontSize: AppFontSizes.contentSmallSize, color: AppColor.content, fontWeight: FontWeight.w600),
                ),
              )
            : Container(),
        SizedBox(height: size.height * 0.01),
        _clinician.facebook!.length > 0
            ? InkWell(
                child: Row(
                  children: [
                    Container(
                      height: 50.0,
                      width: size.width * 0.12,
                      decoration: BoxDecoration(color: AppColor.background, borderRadius: BorderRadius.circular(10.0)),
                      child: Center(
                        child: Center(
                          child: Image(
                            color: AppColor.secondaryColor,
                            width: 35.0,
                            image: AssetImage('assets/img/socialmedia/icon_fb.png'),
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: size.width * 0.015),
                    Container(
                      height: 50.0,
                      width: size.width * 0.72,
                      padding: EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0),
                      decoration: BoxDecoration(color: AppColor.background, borderRadius: BorderRadius.circular(10.0)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Facebook",
                            textAlign: TextAlign.left,
                            style: TextStyle(fontSize: AppFontSizes.contentSmallSize, color: AppColor.content, fontWeight: FontWeight.w700),
                          ),
                          SizedBox(height: size.height * 0.001),
                          Text(
                            _clinician.facebook!,
                            textAlign: TextAlign.left,
                            style: TextStyle(
                              fontSize: AppFontSizes.contentSize - 1.0,
                              color: AppColor.content,
                            ),
                          )
                        ],
                      ),
                    ),
                  ],
                ),
                onTap: () {
                  print("Facebook");
                },
              )
            : Container(),
        SizedBox(height: size.height * 0.01),
        _clinician.instagram!.length > 0
            ? InkWell(
                child: Row(
                  children: [
                    Container(
                      height: 50.0,
                      width: size.width * 0.12,
                      decoration: BoxDecoration(color: AppColor.background, borderRadius: BorderRadius.circular(10.0)),
                      child: Center(
                        child: Center(
                          child: Image(
                            color: AppColor.secondaryColor,
                            width: 35.0,
                            image: AssetImage('assets/img/socialmedia/icon_instagram.png'),
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: size.width * 0.015),
                    Container(
                      height: 50.0,
                      width: size.width * 0.72,
                      padding: EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0),
                      decoration: BoxDecoration(color: AppColor.background, borderRadius: BorderRadius.circular(10.0)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Instagram",
                            textAlign: TextAlign.left,
                            style: TextStyle(fontSize: AppFontSizes.contentSmallSize, color: AppColor.content, fontWeight: FontWeight.w700),
                          ),
                          SizedBox(height: size.height * 0.001),
                          Text(
                            _clinician.instagram!,
                            textAlign: TextAlign.left,
                            style: TextStyle(
                              fontSize: AppFontSizes.contentSize - 1.0,
                              color: AppColor.content,
                            ),
                          )
                        ],
                      ),
                    ),
                  ],
                ),
                onTap: () {
                  print("Instagram");
                },
              )
            : Container(),
        SizedBox(height: size.height * 0.05),
      ],
    );
  }

  _loadClinicians(BuildContext context) async {
    final demoService = DemoServices();
    ProgressDialog progressDialog = ProgressDialog(context);
    progressDialog.show();
    final String? _clinicianId = ModalRoute.of(context)?.settings.arguments?.toString() ?? _clinician.id;

    Map infoResponse =
        _prefs.demoVersion ? await demoService.loadClinicianDetail(_prefs.id) : await clinicianListServices.clinicianDetail(_clinicianId);

    if (infoResponse['ok']) {
      setState(() {
        //LOAD CLINICIAN
        _clinician = Clinician.fromJson(infoResponse['clinician']);
        progressDialog.dismiss();
      });
    } else {
      progressDialog.dismiss();
      print("error load clinician info");
    }
  }

  Widget _initHours(BuildContext context, int index) {
    final size = MediaQuery.of(context).size;
    // Hours hour = _store.hours[index];
    Hours hour = _clinician.hours![index];
    return Container(
      margin: EdgeInsets.only(bottom: size.height * 0.005),
      child: Column(
        children: [
          Text(
            hour.day!,
            textAlign: TextAlign.left,
            style: TextStyle(
              fontSize: AppFontSizes.contentSmallSize - 1.0,
              color: AppColor.content,
            ),
          ),
          Text(
            DateFormat.jm().format(hour.opensAt!) + ' - ' + DateFormat.jm().format(hour.closesAt!),
            textAlign: TextAlign.left,
            style: TextStyle(
              fontSize: AppFontSizes.contentSmallSize - 1.5,
              color: AppColor.content,
            ),
          ),
        ],
      ),
    );
  }
}
