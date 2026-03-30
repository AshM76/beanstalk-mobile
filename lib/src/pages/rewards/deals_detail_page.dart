import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:beanstalk_mobile/src/models/deals/deal_model.dart';
import 'package:beanstalk_mobile/src/ui/app_skin.dart';
import 'package:beanstalk_mobile/src/utils/loading.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../preferences/user_preference.dart';
import '../../services/deals/deals_service.dart';
import '../../services/demo/demo_service.dart';
import '../../services/setup_service.dart';
import '../../utils/utils.dart';
import '../../widgets/deals/deals_list_widget.dart';
import '../../widgets/deals/deals_typeOfDeal_widget.dart';

class DealsDetailPage extends StatefulWidget {
  @override
  _DealsDetailPageState createState() => _DealsDetailPageState();
}

class _DealsDetailPageState extends State<DealsDetailPage> {
  final _prefs = new UserPreference();
  var dealID;
  Deal _currentDeal = Deal(
    dealId: '',
    dealTitle: '',
    dealDescription: '',
    dealImageUrl: '',
    dealTypeOfDeal: '',
    dealAmount: '',
    dealOffer: '',
    dealTypeOfProduct: '',
    dealBrandOfProduct: '',
    dealRangeDeal: '',
    dealStartDate: null,
    dealEndDate: null,
    dealUrl: '',
    dealDispensaryId: '',
    dealDispensaryName: '',
    dealStoresAvailables: [],
  );

  List<Deal> _dealsList = [];

  final dealsServices = DealsServices();

  @override
  void initState() {
    super.initState();
    () async {
      await Future.delayed(Duration.zero);
      loadDealById(context);
    }();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(size.height * 0.066),
        child: AppBar(
          elevation: 0.0,
          automaticallyImplyLeading: false,
          backgroundColor: AppColor.primaryColor,
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
          actions: [
            _backButton(context),
          ],
        ),
      ),
      body: Container(
        color: AppColor.background,
        child: Stack(
          children: [
            Positioned(
              right: -40.0,
              bottom: 50.0,
              child: Image.network(
                AppLogos.iconImg,
                height: 250.0,
                fit: BoxFit.contain,
                opacity: const AlwaysStoppedAnimation(0.2),
                // color: AppColor.primaryColor.withOpacity(0.05),
              ),
            ),
            _contentDeals(context),
            Positioned(
              bottom: size.height * 0.025,
              child: _iniDealsOptionsBar(context),
            ),
          ],
        ),
      ),
    );
  }

  _contentDeals(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final String _urlResources = SetupServices.resourcesURL;
    return Positioned(
      top: size.height * 0.0,
      child: AnimatedContainer(
        duration: Duration(milliseconds: 150),
        width: size.width,
        height: size.height,
        child: SingleChildScrollView(
          child: Stack(
            children: [
              Container(
                padding: EdgeInsets.only(left: 20.0, right: 20.0, top: 15.0, bottom: 15.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Material(
                        borderRadius: BorderRadius.circular(30),
                        elevation: 3.5,
                        child: Container(
                          clipBehavior: Clip.antiAlias,
                          width: size.width * 0.77,
                          height: size.height * 0.17,
                          decoration: BoxDecoration(color: AppColor.primaryColor, borderRadius: BorderRadius.circular(30)),
                          child: _currentDeal.dealImageUrl == ''
                              ? Container(
                                  decoration: BoxDecoration(
                                      image: DecorationImage(
                                        image: AssetImage('assets/img/deal-default.png'),
                                        fit: BoxFit.cover,
                                      ),
                                      borderRadius: BorderRadius.circular(15.0)),
                                )
                              : Image.network(
                                  _urlResources + _currentDeal.dealImageUrl!,
                                  fit: BoxFit.cover,
                                ),
                        ),
                      ),
                    ),
                    SizedBox(height: size.height * 0.015),
                    Container(
                      child: Text(
                        _currentDeal.dealTitle!,
                        textAlign: TextAlign.left,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 3,
                        style: TextStyle(
                          fontSize: AppFontSizes.titleSize,
                          color: AppColor.primaryColor,
                          fontFamily: "Matterdi",
                        ),
                      ),
                    ),
                    SizedBox(height: size.height * 0.01),
                    Container(
                      height: 1.0,
                      width: double.maxFinite,
                      color: AppColor.secondaryColor,
                    ),
                    SizedBox(height: size.height * 0.02),
                    Container(
                      width: double.maxFinite,
                      margin: EdgeInsets.only(right: size.width * 0.38),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Dispensary",
                            style: TextStyle(fontSize: AppFontSizes.contentSmallSize, color: AppColor.content, fontWeight: FontWeight.w700),
                          ),
                          SizedBox(height: size.height * 0.005),
                          Row(
                            children: [
                              Image(
                                color: AppColor.fifthColor,
                                width: AppFontSizes.contentSmallSize,
                                image: AssetImage('assets/img/icon_arrow.png'),
                                fit: BoxFit.contain,
                              ),
                              SizedBox(width: size.width * 0.02),
                              Text(
                                _currentDeal.dealDispensaryName!,
                                textAlign: TextAlign.left,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: AppFontSizes.contentSize,
                                  color: AppColor.content,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: size.height * 0.025),
                    Container(
                      width: double.maxFinite,
                      margin: EdgeInsets.only(right: size.width * 0.38),
                      padding: EdgeInsets.symmetric(horizontal: 10.0),
                      child: Text(
                        _currentDeal.dealDescription!,
                        textAlign: TextAlign.left,
                        maxLines: 5,
                        style: TextStyle(
                          fontSize: AppFontSizes.contentSize,
                          color: AppColor.content,
                        ),
                      ),
                    ),
                    _currentDeal.dealTypeOfProduct == ''
                        ? Container()
                        : Container(
                            width: double.maxFinite,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(height: size.height * 0.025),
                                Text(
                                  'Type of Product',
                                  style: TextStyle(fontSize: AppFontSizes.contentSmallSize, color: AppColor.content, fontWeight: FontWeight.w700),
                                ),
                                SizedBox(height: size.height * 0.005),
                                Row(
                                  children: [
                                    Image(
                                      color: AppColor.fifthColor,
                                      width: AppFontSizes.contentSmallSize,
                                      image: AssetImage('assets/img/icon_arrow.png'),
                                      fit: BoxFit.contain,
                                    ),
                                    SizedBox(width: size.width * 0.02),
                                    Text(
                                      _currentDeal.dealTypeOfProduct!,
                                      textAlign: TextAlign.left,
                                      style: TextStyle(
                                        fontSize: AppFontSizes.contentSize,
                                        color: AppColor.content,
                                      ),
                                      maxLines: 1,
                                      softWrap: true,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                    _currentDeal.dealBrandOfProduct == ''
                        ? Container()
                        : Container(
                            width: double.maxFinite,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(height: size.height * 0.025),
                                Text(
                                  "Brand of Product",
                                  style: TextStyle(fontSize: AppFontSizes.contentSmallSize, color: AppColor.content, fontWeight: FontWeight.w700),
                                ),
                                SizedBox(height: size.height * 0.005),
                                Row(
                                  children: [
                                    Image(
                                      color: AppColor.fifthColor,
                                      width: AppFontSizes.contentSmallSize,
                                      image: AssetImage('assets/img/icon_arrow.png'),
                                      fit: BoxFit.contain,
                                    ),
                                    SizedBox(width: size.width * 0.02),
                                    Text(
                                      _currentDeal.dealBrandOfProduct!,
                                      textAlign: TextAlign.left,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: AppFontSizes.contentSize,
                                        color: AppColor.content,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                    SizedBox(height: size.height * 0.025),
                    Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Container(
                        child: Text(
                          "Date the offer is valid",
                          style: TextStyle(fontSize: AppFontSizes.contentSmallSize, color: AppColor.content, fontWeight: FontWeight.w700),
                        ),
                      ),
                      SizedBox(height: size.height * 0.005),
                      Container(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Flexible(
                              flex: 2,
                              child: Container(
                                height: 50,
                                child: Stack(
                                  children: [
                                    Container(
                                      alignment: Alignment.centerLeft,
                                      // width: size.width * 0.35,
                                      margin: EdgeInsets.symmetric(vertical: 5.0, horizontal: 5.0),
                                      padding: EdgeInsets.symmetric(vertical: 5.0, horizontal: 15.0),
                                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10.0)),
                                      child: Text(
                                        _currentDeal.dealStartDate == null ? '' : DateFormat.yMMMMd().format(_currentDeal.dealStartDate!),
                                        textAlign: TextAlign.left,
                                        style: TextStyle(
                                          fontSize: AppFontSizes.contentSmallSize,
                                          color: AppColor.primaryColor,
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      top: 5.0,
                                      child: Image(
                                        color: AppColor.fifthColor,
                                        width: AppFontSizes.contentSmallSize,
                                        image: AssetImage('assets/img/icon_arrow.png'),
                                        fit: BoxFit.contain,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            _currentDeal.dealRangeDeal == 'oneday'
                                ? Container()
                                : Flexible(
                                    flex: 1,
                                    child: Container(
                                      margin: EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0),
                                      child: Text(
                                        "To",
                                        style:
                                            TextStyle(fontSize: AppFontSizes.contentSmallSize, color: AppColor.content, fontWeight: FontWeight.w600),
                                      ),
                                    ),
                                  ),
                            _currentDeal.dealRangeDeal == 'oneday'
                                ? Container()
                                : Flexible(
                                    flex: 2,
                                    child: Container(
                                      height: 50,
                                      child: Center(
                                        child: Stack(
                                          children: [
                                            Container(
                                              alignment: Alignment.centerLeft,
                                              // width: size.width * 0.35,
                                              margin: EdgeInsets.symmetric(vertical: 5.0, horizontal: 5.0),
                                              padding: EdgeInsets.symmetric(vertical: 5.0, horizontal: 15.0),
                                              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10.0)),
                                              child: Text(
                                                _currentDeal.dealEndDate == null ? '' : DateFormat.yMMMMd().format(_currentDeal.dealEndDate!),
                                                textAlign: TextAlign.left,
                                                style: TextStyle(
                                                  fontSize: AppFontSizes.contentSmallSize,
                                                  color: AppColor.primaryColor,
                                                ),
                                              ),
                                            ),
                                            Positioned(
                                              top: 5.0,
                                              child: Image(
                                                color: AppColor.fifthColor,
                                                width: AppFontSizes.contentSmallSize,
                                                image: AssetImage('assets/img/icon_arrow.png'),
                                                fit: BoxFit.contain,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                          ],
                        ),
                      ),
                    ]),
                    SizedBox(height: size.height * 0.025),
                    _dealsList.length > 0
                        ? Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                child: Text(
                                  "Other Deals of Dispensary",
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
                              SizedBox(height: size.height * 0.25),
                            ],
                          )
                        : SizedBox(height: size.height * 0.1),
                  ],
                ),
              ),
              Positioned(
                top: _currentDeal.dealTitle!.length > 25 ? size.height * 0.32 : size.height * 0.275,
                right: -5.0,
                child: Container(
                    height: 85.0,
                    width: size.width * 0.40,
                    margin: EdgeInsets.symmetric(vertical: 3.0, horizontal: 3.0),
                    decoration: BoxDecoration(
                      color: AppColor.primaryColor,
                      borderRadius: BorderRadius.only(topLeft: Radius.circular(size.width * 0.05), bottomLeft: Radius.circular(size.width * 0.05)),
                    ),
                    child: Container(
                      width: double.maxFinite,
                      margin: EdgeInsets.only(
                        top: size.height * 0.010,
                        left: size.width * 0.015,
                        right: size.width * 0.010,
                      ),
                      padding: EdgeInsets.symmetric(horizontal: size.width * 0.005),
                      child: typeOfDealDetail(_currentDeal),
                    )),
              ),
            ],
          ),
        ),
      ),
    );
  }

  loadDealById(BuildContext context) async {
    final demoService = DemoServices();
    ProgressDialog progressDialog = ProgressDialog(context);
    progressDialog.show();
    final String _dealId = ModalRoute.of(context)?.settings.arguments?.toString() ?? '';
    try {
      Map infoResponse;
      _prefs.demoVersion ? infoResponse = await demoService.loadDeal(_prefs.id) : infoResponse = await dealsServices.loadDealbyId(_dealId);

      if (infoResponse['ok']) {
        setState(() {
          //LOAD DEAL RESPONSE
          final dealResult = infoResponse['deal'];
          _currentDeal = Deal.fromJson(dealResult);
          //LOAD DEALS
          _dealsList = [];
          final dealsResult = infoResponse['deal']['deal_deals'] ?? [];
          dealsResult.forEach((deal) {
            Deal tempDeal = Deal.fromJsonWidgetList(deal);
            _dealsList.add(tempDeal);
          });

          progressDialog.dismiss();
        });
      } else {
        progressDialog.dismiss();
        showAlertMessage(context, "error load deal", () {
          Navigator.pop(context);
        });
      }
    } catch (e) {
      showAlertMessage(context, "A network error occurred", () {
        Navigator.pop(context);
      });
      throw e;
    }
  }

  //Session Options Bar
  Widget _iniDealsOptionsBar(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Container(
      height: 70.0,
      width: size.width,
      child: Container(
          margin: EdgeInsets.symmetric(horizontal: 15.0),
          decoration: BoxDecoration(
            color: AppColor.background,
            borderRadius: BorderRadius.circular(size.width * 0.05),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.5),
                offset: Offset(0.0, 1.0), //(x,y)
                blurRadius: 5.0,
              ),
            ],
          ),
          child: Row(
            children: [
              // InkWell(
              //   child: Container(
              //     width: 50.0,
              //     margin: EdgeInsets.symmetric(horizontal: 5.0, vertical: 5.0),
              //     child: Image(
              //       height: 25.0,
              //       width: 25.0,
              //       image: AssetImage('assets/img/icon_save.png'),
              //       color: AppColor.secondaryColor,
              //       fit: BoxFit.contain,
              //     ),
              //   ),
              //   onTap: () {
              //     print("Save Deal");
              //   },
              // ),
              // InkWell(
              //   child: Container(
              //     width: 50.0,
              //     margin: EdgeInsets.symmetric(horizontal: 5.0, vertical: 5.0),
              //     child: Icon(
              //       Icons.favorite_border_rounded,
              //       color: AppColor.secondaryColor,
              //       size: 33,
              //     ),
              //   ),
              //   onTap: () {
              //     print("Save Favorites");
              //   },
              // ),
              _currentDeal.dealUrl == ''
                  ? Container()
                  : Material(
                      borderRadius: BorderRadius.all(
                        Radius.circular(20),
                      ),
                      child: InkWell(
                        child: Container(
                          height: double.maxFinite,
                          width: size.width * 0.4,
                          margin: EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.all(
                              Radius.circular(15),
                            ),
                            color: AppColor.primaryColor,
                          ),
                          child: Center(
                            child: Text(
                              "Go to Deal",
                              style: TextStyle(
                                fontSize: AppFontSizes.buttonSize + 2.5,
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                        onTap: () {
                          print("Go to Deal URL");
                          _launchURL(_currentDeal.dealUrl);
                        },
                      ),
                    ),
              Expanded(child: Container()),
              Material(
                borderRadius: BorderRadius.all(
                  Radius.circular(20),
                ),
                child: InkWell(
                  child: Container(
                    height: double.maxFinite,
                    width: size.width * 0.4,
                    margin: EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(
                        Radius.circular(15),
                      ),
                      color: AppColor.secondaryColor,
                    ),
                    child: Center(
                      child: Text(
                        "Go to Dispensary",
                        style: TextStyle(
                          fontSize: AppFontSizes.buttonSize + 2.5,
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  onTap: () {
                    _showStoresSheet();
                  },
                ),
              ),
            ],
          )),
    );
  }

  _launchURL(url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  Widget _backButton(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return SafeArea(
      child: Align(
        alignment: Alignment.topRight,
        child: Padding(
          padding: EdgeInsets.only(right: 15.0),
          child: InkWell(
            child: Container(
              width: size.width * 0.1,
              height: size.width * 0.1,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(
                  Radius.circular(20),
                ),
                color: Colors.black.withOpacity(0.15),
              ),
              child: Icon(
                Icons.close_rounded,
                size: 30.0,
                color: Colors.white,
              ),
            ),
            onTap: () => Navigator.of(context).pop(),
          ),
        ),
      ),
    );
  }

  _showStoresSheet() {
    final size = MediaQuery.of(context).size;

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
                    height: size.height * 0.48,
                    child: Stack(
                      children: <Widget>[
                        Container(
                          width: double.infinity,
                          height: 60.0,
                          alignment: Alignment.topCenter,
                          padding: EdgeInsets.symmetric(horizontal: 30.0),
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
                                        fontSize: AppFontSizes.buttonSize + 5.0,
                                        fontWeight: FontWeight.w500,
                                      ),
                                      textScaler: TextScaler.linear(AppFontScales.adaptiveScale),
                                    ),
                                    onPressed: () {
                                      Navigator.pop(context);
                                    }),
                              ],
                            ),
                          ),
                        ),
                        Align(
                          alignment: Alignment.bottomCenter,
                          child: Container(
                            height: size.height * 0.4,
                            padding: EdgeInsets.symmetric(horizontal: size.width * 0.1),
                            child: Column(
                              children: [
                                Container(
                                  margin: EdgeInsets.only(bottom: 5.0, top: 10.0),
                                  alignment: Alignment.centerLeft,
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.only(bottom: 5.0),
                                        child: Text(
                                          "Dispensaries availables:",
                                          style: TextStyle(
                                            color: AppColor.primaryColor,
                                            fontSize: AppFontSizes.subTitleSize,
                                            fontWeight: FontWeight.w700,
                                          ),
                                          textScaler: TextScaler.linear(AppFontScales.adaptiveScale),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                _initStoreList(context)
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

  Widget _initStoreList(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Container(
      height: size.height * 0.3,
      child: ListView.builder(
          itemCount: _currentDeal.dealStoresAvailables!.length, //_productList.length,
          itemBuilder: (BuildContext context, int index) => _initStoreOption(context, index)),
    );
  }

  Widget _initStoreOption(BuildContext context, int index) {
    final size = MediaQuery.of(context).size;
    return Material(
      child: InkWell(
          child: Container(
            height: size.height * 0.07,
            margin: EdgeInsets.only(top: size.height * 0.01),
            padding: EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0),
            decoration: BoxDecoration(color: AppColor.content.withOpacity(0.1), borderRadius: BorderRadius.circular(10.0)),
            child: Row(
              children: [
                Center(
                  child: Icon(
                    Icons.location_on,
                    size: 35,
                    color: AppColor.secondaryColor,
                  ),
                ),
                SizedBox(width: size.width * 0.01),
                Container(
                  width: size.width * 0.6,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _currentDeal.dealStoresAvailables![index].title!,
                        textAlign: TextAlign.left,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        softWrap: true,
                        style: TextStyle(
                          fontSize: AppFontSizes.contentSize,
                          color: AppColor.primaryColor,
                          fontFamily: "Matterdi",
                        ),
                      ),
                      Text(
                        _currentDeal.dealStoresAvailables![index].addressline1!,
                        textAlign: TextAlign.left,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        softWrap: true,
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
          ),
          onTap: () {
            print("Go to Dispensary");
            Navigator.pushNamed(context, 'dispensary_detail', arguments: _currentDeal.dealStoresAvailables![index].id);
          }),
    );
  }
}
