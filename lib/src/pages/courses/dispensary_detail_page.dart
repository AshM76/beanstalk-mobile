import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:intl/intl.dart';
import 'package:beanstalk_mobile/src/models/chatings/chat_dispensary_model.dart';
import 'package:beanstalk_mobile/src/models/dispensaries/dispensary_hours_model.dart';
import 'package:beanstalk_mobile/src/models/stores/store_model.dart';
import 'package:beanstalk_mobile/src/services/dispensary/dispensary_service.dart';
import 'package:beanstalk_mobile/src/ui/app_skin.dart';
import 'package:beanstalk_mobile/src/utils/loading.dart';

import '../../models/deals/deal_model.dart';
import '../../preferences/user_preference.dart';
import '../../services/demo/demo_service.dart';
import '../../services/setup_service.dart';
import '../../utils/utils.dart';
import '../../widgets/deals/deals_list_widget.dart';

class DispensarieDetailPage extends StatefulWidget {
  @override
  _DispensarieDetailPageState createState() => _DispensarieDetailPageState();
}

class _DispensarieDetailPageState extends State<DispensarieDetailPage> {
  final _prefs = new UserPreference();
  final dispensaryListServices = DispensaryServices();
  Store _store = Store(
      title: '',
      description: '',
      photos: [],
      addressline1: '',
      addressline2: '',
      city: '',
      state: '',
      zip: '',
      hours: [],
      phone: '',
      email: '',
      website: '',
      facebook: '',
      instagram: '',
      twitter: '',
      youtube: '',
      favorite: false,
      rating: 0.0,
      dispensaryId: '',
      dispensaryTitle: '');

  List<Deal> _dealsList = [];

  double? _rating = 0.0;
  bool? _setFavorite = false;

  @override
  void initState() {
    super.initState();
    () async {
      await Future.delayed(Duration.zero);
      _loadDispensary(context);
    }();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: AppColor.primaryColor,
        child: Stack(
          children: [
            _headerDispensary(context),
            _backButton(context),
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
        _store.photos!.length > 0
            ? Container(
                width: size.width,
                height: size.height * 0.35,
                child: Image.network(
                  _urlResources + _store.photos!.first!,
                  fit: BoxFit.cover,
                ),
              )
            : Container(
                width: size.width,
                height: size.height * 0.35,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/img/dispensary.jpg'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
        _store.photos!.length > 0
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
          bottom: size.height * 0.075,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: size.width * 0.85,
                margin: EdgeInsets.symmetric(horizontal: 20.0),
                child: Text(
                  _store.title!,
                  textAlign: TextAlign.left,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 3,
                  style: TextStyle(
                    fontSize: AppFontSizes.titleSize,
                    color: AppColor.fourthColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              SizedBox(height: size.height * 0.0025),
              _store.dispensaryTitle!.length > 0
                  ? Container(
                      width: size.width * 0.85,
                      margin: EdgeInsets.symmetric(horizontal: 20.0),
                      child: Text(
                        _store.dispensaryTitle!,
                        textAlign: TextAlign.start,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                        style: TextStyle(
                          fontSize: AppFontSizes.contentSize,
                          color: AppColor.secondaryColor,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    )
                  : Container(),
              SizedBox(height: size.height * 0.015),
              Row(
                children: [
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: 20.0),
                    child: Row(
                      children: [
                        Container(
                          width: size.width * 0.1,
                          height: size.width * 0.1,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.all(
                              Radius.circular(30),
                            ),
                            color: Colors.black.withOpacity(0.3),
                          ),
                          child: Center(
                            child: Text(
                              _store.rating.toString(),
                              style: TextStyle(
                                fontSize: AppFontSizes.subTitleSize + 2.0,
                                color: AppColor.secondaryColor,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: size.width * 0.01),
                        RatingBar.builder(
                          ignoreGestures: true,
                          initialRating: _store.rating!,
                          minRating: 0,
                          direction: Axis.horizontal,
                          allowHalfRating: true,
                          itemCount: 5,
                          itemSize: 25,
                          itemPadding: EdgeInsets.symmetric(horizontal: 2.5),
                          itemBuilder: (context, _) => Icon(
                            Icons.star,
                            color: AppColor.secondaryColor,
                          ),
                          onRatingUpdate: (rating) {
                            print(rating);
                            setState(() {
                              // _rate = rating;
                            });
                          },
                        ),
                        SizedBox(width: size.width * 0.01),
                        Container(
                          child: InkWell(
                            child: Container(
                                width: size.width * 0.14,
                                height: size.width * 0.08,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(12),
                                  ),
                                  color: Colors.white.withOpacity(0.1),
                                ),
                                child: Center(
                                    child: Text(
                                  "Rate",
                                  style: TextStyle(
                                    fontSize: AppFontSizes.contentSmallSize + 1.5,
                                    color: AppColor.secondaryColor,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ))),
                            onTap: () {
                              setState(() {
                                /////
                                ///////
                                _showRatingSheet(_store);
                                ///////
                                /////
                              });
                            },
                          ),
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        Positioned(
          right: 15.0,
          bottom: size.height * 0.08,
          child: InkWell(
            child: Container(
              width: size.width * 0.12,
              height: size.width * 0.12,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(
                  Radius.circular(30),
                ),
                color: Colors.white.withOpacity(0.1),
              ),
              child: Icon(
                _store.favorite! ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                size: 35,
                color: AppColor.secondaryColor,
              ),
            ),
            onTap: () {
              if (_prefs.demoVersion) {
                showAlertMessage(context, 'Not available in demo version', () {
                  Navigator.pop(context);
                });
              } else {
                setState(() {
                  _setFavorite! ? _setFavorite = false : _setFavorite = true;
                  _setFavoriteDispensary(context);
                });
              }
            },
          ),
        ),
        Positioned(
          right: 12.0,
          top: size.height * 0.05,
          child: InkWell(
            child: Container(
              width: size.width * 0.14,
              height: size.width * 0.14,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(
                  Radius.circular(10),
                ),
                color: Colors.white.withOpacity(0.1),
              ),
              child: Icon(
                Icons.chat,
                size: 40,
                color: AppColor.secondaryColor,
              ),
            ),
            onTap: () {
              ChatDispensary _chatHistory = ChatDispensary(
                  id: '',
                  dispensaryId: _store.dispensaryId,
                  dispensaryName: _store.dispensaryTitle,
                  storeId: _store.id,
                  storeName: _store.title,
                  lastMessage: '',
                  messages: []);
              Navigator.pushNamed(context, 'chat_private', arguments: _chatHistory);
            },
          ),
        ),
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
        height: size.height * 0.7,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.only(
            topRight: Radius.circular(30),
            topLeft: Radius.circular(30),
          ),
          color: Colors.grey[200],
        ),
        child: SingleChildScrollView(
          child: Container(
              padding: EdgeInsets.only(left: 25.0, right: 27.0, top: 20.0, bottom: 10.0),
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
        SizedBox(height: size.height * 0.015),
        Container(
          width: double.maxFinite,
          padding: EdgeInsets.symmetric(vertical: 15.0, horizontal: 10.0),
          decoration: BoxDecoration(color: AppColor.background, borderRadius: BorderRadius.circular(10.0)),
          child: Text(
            _store.description!,
            textAlign: TextAlign.left,
            overflow: TextOverflow.ellipsis,
            maxLines: 5,
            style: TextStyle(
              fontSize: AppFontSizes.contentSize,
              color: AppColor.content,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        SizedBox(height: size.height * 0.025),
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
                    _store.addressline1!,
                    textAlign: TextAlign.left,
                    style: TextStyle(
                      fontSize: AppFontSizes.contentSize,
                      color: AppColor.content,
                    ),
                  ),
                  Text(
                    _store.addressline2!,
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
        SizedBox(height: size.height * 0.015),
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
                                alignment: Alignment.centerLeft,
                                margin: EdgeInsets.symmetric(vertical: 5.0, horizontal: 5.0),
                                padding: EdgeInsets.symmetric(vertical: 5.0, horizontal: 15.0),
                                decoration: BoxDecoration(color: AppColor.background, borderRadius: BorderRadius.circular(10.0)),
                                child: Text(
                                  _store.city!,
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
                                alignment: Alignment.centerLeft,
                                margin: EdgeInsets.symmetric(vertical: 5.0, horizontal: 5.0),
                                padding: EdgeInsets.symmetric(vertical: 5.0, horizontal: 15.0),
                                decoration: BoxDecoration(color: AppColor.background, borderRadius: BorderRadius.circular(10.0)),
                                child: Text(
                                  _store.state!,
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
                                alignment: Alignment.centerLeft,
                                margin: EdgeInsets.symmetric(vertical: 5.0, horizontal: 5.0),
                                padding: EdgeInsets.symmetric(vertical: 5.0, horizontal: 15.0),
                                decoration: BoxDecoration(color: AppColor.background, borderRadius: BorderRadius.circular(10.0)),
                                child: Text(
                                  _store.zip!,
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
                  flex: _store.hours!.length > 0 ? 2 : 0,
                  child: Container(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // _store.email.length > 0
                        //     ? Column(
                        //         crossAxisAlignment: CrossAxisAlignment.start,
                        //         children: [
                        //             Container(
                        //               child: Text(
                        //                 "License",
                        //                 style: TextStyle(
                        //                     fontSize:
                        //                         AppFontSizes.contentSmallSize,
                        //                     color: AppColor.content,
                        //                     fontWeight: FontWeight.w600),
                        //               ),
                        //             ),
                        //             Container(
                        //               height: 50,
                        //               child: Stack(
                        //                 children: [
                        //                   Container(
                        //                     alignment: Alignment.center,
                        //                     width: size.width * 0.70,
                        //                     margin: EdgeInsets.symmetric(
                        //                         vertical: 5.0, horizontal: 5.0),
                        //                     padding: EdgeInsets.symmetric(
                        //                         vertical: 5.0, horizontal: 5.0),
                        //                     decoration: BoxDecoration(
                        //                         color: AppColor.background,
                        //                         borderRadius:
                        //                             BorderRadius.circular(
                        //                                 10.0)),
                        //                     child: Text(
                        //                       _store.email,
                        //                       textAlign: TextAlign.left,
                        //                       style: TextStyle(
                        //                         fontSize:
                        //                             AppFontSizes.contentSize,
                        //                         color: AppColor.content,
                        //                       ),
                        //                     ),
                        //                   ),
                        //                   Positioned(
                        //                     top: 5.0,
                        //                     child: Image(
                        //                       color: AppColor.fifthColor,
                        //                       width: AppFontSizes.contentSize,
                        //                       image: AssetImage(
                        //                           'assets/img/icon_arrow.png'),
                        //                       fit: BoxFit.contain,
                        //                     ),
                        //                   ),
                        //                 ],
                        //               ),
                        //             ),
                        //           ])
                        //     : Container(),
                        _store.hours!.length > 0
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
                                            itemCount: _store.hours!.length,
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
        SizedBox(height: size.height * 0.025),
        _store.phone!.length > 0 || _store.email!.length > 0 || _store.website!.length > 0
            ? Container(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Contacts",
                      style: TextStyle(fontSize: AppFontSizes.contentSmallSize, color: AppColor.content, fontWeight: FontWeight.w600),
                    ),
                    SizedBox(height: size.height * 0.005),
                    Container(
                      height: 0.5,
                      width: double.maxFinite,
                      color: AppColor.fifthColor,
                    ),
                    SizedBox(height: size.height * 0.01),
                  ],
                ),
              )
            : Container(),
        _store.phone!.length > 0
            ? Padding(
                padding: EdgeInsets.only(bottom: size.height * 0.01),
                child: Row(
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
                            _store.phone!,
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
              )
            : Container(),
        _store.email!.length > 0
            ? Padding(
                padding: EdgeInsets.only(bottom: size.height * 0.01),
                child: Row(
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
                            _store.email!,
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
              )
            : Container(),
        _store.website!.length > 0
            ? Padding(
                padding: EdgeInsets.only(bottom: size.height * 0.01),
                child: Row(
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
                            _store.website!,
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
              )
            : Container(),
        SizedBox(height: size.height * 0.025),
        _store.facebook!.length > 0 || _store.instagram!.length > 0 || _store.twitter!.length > 0 || _store.youtube!.length > 0
            ? Container(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Social Media",
                      style: TextStyle(fontSize: AppFontSizes.contentSmallSize, color: AppColor.content, fontWeight: FontWeight.w600),
                    ),
                    SizedBox(height: size.height * 0.005),
                    Container(
                      height: 0.5,
                      width: double.maxFinite,
                      color: AppColor.fifthColor,
                    ),
                    SizedBox(height: size.height * 0.01),
                  ],
                ),
              )
            : Container(),
        _store.facebook!.length > 0
            ? Padding(
                padding: EdgeInsets.only(bottom: size.height * 0.01),
                child: InkWell(
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
                              _store.facebook!,
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
                ),
              )
            : Container(),
        _store.instagram!.length > 0
            ? Padding(
                padding: EdgeInsets.only(bottom: size.height * 0.01),
                child: InkWell(
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
                              _store.instagram!,
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
                ),
              )
            : Container(),
        _store.twitter!.length > 0
            ? Padding(
                padding: EdgeInsets.only(bottom: size.height * 0.01),
                child: InkWell(
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
                              image: AssetImage('assets/img/socialmedia/icon_twitter.png'),
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
                              "Twitter",
                              textAlign: TextAlign.left,
                              style: TextStyle(fontSize: AppFontSizes.contentSmallSize, color: AppColor.content, fontWeight: FontWeight.w700),
                            ),
                            SizedBox(height: size.height * 0.001),
                            Text(
                              _store.twitter!,
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
                    print("Twitter");
                  },
                ),
              )
            : Container(),
        _store.youtube!.length > 0
            ? Padding(
                padding: EdgeInsets.only(bottom: size.height * 0.01),
                child: InkWell(
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
                              image: AssetImage('assets/img/socialmedia/icon_youtube.png'),
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
                              "Youtube",
                              textAlign: TextAlign.left,
                              style: TextStyle(fontSize: AppFontSizes.contentSmallSize, color: AppColor.content, fontWeight: FontWeight.w700),
                            ),
                            SizedBox(height: size.height * 0.001),
                            Text(
                              _store.youtube!,
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
                    print("Youtube");
                  },
                ),
              )
            : Container(),
        SizedBox(height: size.height * 0.025),
        _dealsList.length > 0
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    child: Text(
                      "Deals of Dispensary",
                      style: TextStyle(fontSize: AppFontSizes.contentSmallSize, color: AppColor.content, fontWeight: FontWeight.w600),
                    ),
                  ),
                  SizedBox(height: size.height * 0.005),
                  Container(
                    height: 0.5,
                    width: double.maxFinite,
                    color: AppColor.fifthColor,
                  ),
                  SizedBox(height: size.height * 0.015),
                  _dealsList.length <= 0
                      ? Container()
                      : Container(
                          width: double.maxFinite,
                          height: 130,
                          child: loadDealsList(context, _dealsList),
                        ),
                  SizedBox(height: size.height * 0.15),
                ],
              )
            : SizedBox(height: size.height * 0.1),
      ],
    );
  }

  _loadDispensary(BuildContext context) async {
    final demoService = DemoServices();
    ProgressDialog progressDialog = ProgressDialog(context);
    progressDialog.show();
    final String? _storeId = ModalRoute.of(context)?.settings.arguments?.toString() ?? _store.id;

    Map infoResponse = _prefs.demoVersion ? await demoService.loadStoreDetail(_prefs.id) : await dispensaryListServices.dispensaryDetail(_storeId);

    if (infoResponse['ok']) {
      setState(() {
        //LOAD DISPENSARY
        _store = Store.fromJson(infoResponse['store']);
        _setFavorite = _store.favorite;
        //LOAD DEALS
        _dealsList = [];
        final dealsResult = infoResponse['store']['store_deals'] ?? [];
        dealsResult.forEach((deal) {
          Deal tempDeal = Deal.fromJsonWidgetList(deal);
          _dealsList.add(tempDeal);
        });

        progressDialog.dismiss();
      });
    } else {
      progressDialog.dismiss();
      print("error load dispensary info");
    }
  }

  Widget _backButton(BuildContext context) {
    return SafeArea(
      child: Align(
        alignment: Alignment.topLeft,
        child: Padding(
          padding: EdgeInsets.only(left: 15.0),
          child: InkWell(
              child: Icon(
                Icons.arrow_back_ios_rounded,
                size: 30.0,
                color: Colors.white,
              ),
              onTap: () => {
                    setState(() {
                      Navigator.pushReplacementNamed(context, 'navigation', arguments: "dispensaries");
                      // Navigator.pop(context);
                      // Navigator.pushNamed(context, 'profile')
                      //           .then((_) => setState(() {}));
                    })
                  }),
        ),
      ),
    );
  }

  _showRatingSheet(Store dispensary) {
    final size = MediaQuery.of(context).size;
    _rating = dispensary.rating;
    showModalBottomSheet(
        isScrollControlled: true,
        context: context,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(30.0)),
        ),
        builder: (context) {
          return BottomSheet(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30.0),
            ),
            builder: (BuildContext context) {
              return StatefulBuilder(
                builder: (BuildContext context, setState) {
                  return Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(30),
                        topRight: Radius.circular(30),
                      ),
                    ),
                    height: 300.0,
                    child: Stack(
                      children: <Widget>[
                        Container(
                          width: double.infinity,
                          height: 60.0,
                          alignment: Alignment.topCenter,
                          padding: EdgeInsets.symmetric(horizontal: 15.0),
                          decoration: BoxDecoration(
                            gradient: AppColor.secondaryGradient,
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(30),
                              topRight: Radius.circular(30),
                            ),
                          ),
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: Row(
                              children: [
                                TextButton(
                                    child: Text(
                                      "Cancel",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: AppFontSizes.buttonSize + 3.0,
                                        fontWeight: FontWeight.w500,
                                      ),
                                      textScaler: TextScaler.linear(AppFontScales.adaptiveScale),
                                    ),
                                    onPressed: () {
                                      Navigator.pop(context);
                                    }),
                                Expanded(child: SizedBox()),
                                TextButton(
                                    child: Text(
                                      "Save",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: AppFontSizes.buttonSize + 3.0,
                                        fontWeight: FontWeight.w800,
                                      ),
                                      textScaler: TextScaler.linear(AppFontScales.adaptiveScale),
                                    ),
                                    onPressed: () {
                                      if (_store.rating != _rating) {
                                        if (_prefs.demoVersion) {
                                          showAlertMessage(context, 'Not available in demo version', () {
                                            Navigator.pop(context);
                                          });
                                        } else {
                                          _ratingDispensary(context);
                                        }
                                      } else {
                                        Navigator.pop(context);
                                      }
                                    }),
                              ],
                            ),
                          ),
                        ),
                        Align(
                          alignment: Alignment.bottomCenter,
                          child: Container(
                            height: 250.0,
                            padding: EdgeInsets.symmetric(horizontal: size.width * 0.1, vertical: size.height * 0.025),
                            child: Column(
                              children: [
                                Container(
                                  margin: EdgeInsets.only(bottom: 5.0, top: 20.0),
                                  alignment: Alignment.center,
                                  child: Text(
                                    "Let us how know you like us",
                                    style: TextStyle(
                                      color: AppColor.primaryColor,
                                      fontSize: AppFontSizes.subTitleSize + 3.0,
                                      fontWeight: FontWeight.w700,
                                    ),
                                    textScaler: TextScaler.linear(AppFontScales.adaptiveScale),
                                  ),
                                ),
                                SizedBox(height: 10.0),
                                RatingBar.builder(
                                  initialRating: dispensary.rating!,
                                  minRating: 0,
                                  direction: Axis.horizontal,
                                  allowHalfRating: true,
                                  itemCount: 5,
                                  itemSize: 35,
                                  itemPadding: EdgeInsets.symmetric(horizontal: 2.5),
                                  itemBuilder: (context, _) => Icon(
                                    Icons.star,
                                    color: AppColor.secondaryColor,
                                  ),
                                  onRatingUpdate: (rating) {
                                    print(rating);
                                    setState(() {
                                      _rating = rating;
                                    });
                                  },
                                ),
                                SizedBox(height: 10.0),
                                Text(
                                  "Rate the dispensary",
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: AppFontSizes.contentSize - 1.0,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                SizedBox(height: 15.0),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
            onClosing: () {},
          );
        });
  }

  _ratingDispensary(BuildContext context) async {
    ProgressDialog progressDialog = ProgressDialog(context);
    progressDialog.show();
    Map infoResponse = await dispensaryListServices.dispensaryRating(_store.id!, _rating);
    if (infoResponse['ok']) {
      setState(() {
        _store.rating = infoResponse['rating'];
        Navigator.pop(context);
        // _loadDispensary(context);
        progressDialog.dismiss();
      });
    } else {
      progressDialog.dismiss();
      print("error set Rating");
    }
  }

  _setFavoriteDispensary(BuildContext context) async {
    ProgressDialog progressDialog = ProgressDialog(context);
    progressDialog.show();
    Map infoResponse = await dispensaryListServices.dispensarySetFavorite(_store.id!, _setFavorite);
    if (infoResponse['ok']) {
      setState(() {
        _store.favorite = infoResponse['favorite'];
        progressDialog.dismiss();
      });
    } else {
      progressDialog.dismiss();
      print("error set Favorite");
    }
  }

  Widget _initHours(BuildContext context, int index) {
    final size = MediaQuery.of(context).size;
    Hours hour = _store.hours![index];
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
