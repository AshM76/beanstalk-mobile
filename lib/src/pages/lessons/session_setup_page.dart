import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:beanstalk_mobile/src/models/canna_condition_model.dart';
import 'package:beanstalk_mobile/src/models/canna_deliveryMethod_model.dart';

import 'package:beanstalk_mobile/src/services/notifications/notification_service.dart';

import 'package:beanstalk_mobile/src/datas/app_data.dart';
import 'package:beanstalk_mobile/src/ui/app_skin.dart';
import 'package:beanstalk_mobile/src/utils/utils.dart';

import 'package:beanstalk_mobile/src/models/canna_dose_model.dart';
import 'package:beanstalk_mobile/src/models/canna_measurement_model.dart';
import 'package:beanstalk_mobile/src/models/session_model.dart';
import 'package:beanstalk_mobile/src/models/canna_strainType_model.dart';
import 'package:beanstalk_mobile/src/widgets/sessions/title_step_session_widget.dart';

import '../../models/canna_cannabinoid_model.dart';
import '../../models/canna_productType_model.dart';
import '../../models/canna_terpene_model.dart';
import '../../models/inventory/products_model.dart';
import '../../models/lumir_study/lumir_products_model.dart';
import '../../preferences/user_preference.dart';
import '../../services/inventory/inventory_service.dart';
import '../../utils/loading.dart';
import '../../widgets/onboarding/actionCardAddCondition_widget.dart';
import '../../widgets/profile/lumir_study/lummir_selectCondition_widget.dart';
import '../../widgets/profile/lumir_study/lummir_selectSecondaryCondition_widget.dart';
import '../../widgets/sessions/card/card_activeIngredients_widget.dart';
import '../../widgets/sessions/card/card_conditions_widget.dart';
import '../../widgets/sessions/card/card_method_widget.dart';
import '../../widgets/sessions/card/card_species_widget.dart';
import '../../widgets/sessions/card/card_terpenes_widget.dart';
import '../../widgets/sessions/card/card_value_heightCard_widget.dart';

class SessionSetupPage extends StatefulWidget {
  @override
  _SessionSetupPageState createState() => _SessionSetupPageState();
}

class _SessionSetupPageState extends State<SessionSetupPage> {
  final _prefs = new UserPreference();
  final inventoryServices = InventoryServices();

  Session _currentSession = Session(
    primaryCondition: [],
    secondaryCondition: [],
    productType: ProductType(title: ""),
    deliveryMethodType: DeliveryMethod(title: ""),
    strainType: StrainType(title: ""),
    cannabinoids: [],
    terpenes: [],
    activeIngredientsMeasurement: Measurement(title: ""),
    dose: Dose(value: 0),
    doseMeasurement: Measurement(title: "", minScale: 0, maxScale: 10),
    temperatureMeasurement: Measurement(title: ""),
    sessionAdditionalNotes: [],
  );

  int currentStep = 0;

  //Treatments
  List<Condition> _sessionPrimaryConditions = [];
  List<Condition> _sessionSecondaryConditions = [];
  //Brand
  bool _brandLumir = false;
  bool _brandOther = true; //By Default
  //Products Lumir
  List<LumirProduct> _lumir_productList = [];
  //Products
  bool _foundProductList = false;
  TextEditingController _foundProductController = TextEditingController();
  List<Product> _productList = [];
  //Product
  final List<ProductType> _dataProductTypes = AppData.dataProductTypes;
  String? _productTypeSelected = '';
  //Delivery Method
  List<DeliveryMethod> _dataDeliveryMethods = [];
  //StrainType
  final List<StrainType> _dataStrainTypes = AppData.dataStrainTypes;
  //ProductFields
  final _productBrandController = TextEditingController();
  final _productNameController = TextEditingController();
  //Temperature
  bool _tempF = false;
  bool _tempC = false;
  TextEditingController _temperatureController = TextEditingController();
  //ActiveIngredients
  final List<Measurement> _dataMeasurements = AppData.dataMeasurements;
  final List<Cannabinoid> _dataCannabinoids = AppData.dataCannabinoids;
  final List<Terpene> _dataTerpenes = AppData.dataTerpenes;
  List<Cannabinoid> _selectedCannabinoids = [];
  List<Terpene> _selectedTerpenes = [];
  TextEditingController _thcController = TextEditingController();
  TextEditingController _cbdController = TextEditingController();
  List<TextEditingController> _cannabinoidsController = [];
  bool _addCannabinoid = false;
  bool _addTerpenes = false;
  @override
  void initState() {
    super.initState();
    _clearSetupSession();
    _loadUserPreferences();
    NotificationService.init();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(size.height * 0.055),
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
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back_ios_new_rounded,
              color: AppColor.content,
            ),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
      ),
      body: Theme(
        data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
          primary: AppColor.secondaryColor,
        )),
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 25.0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Setup Session",
                  style: TextStyle(
                    fontSize: AppFontSizes.titleSize + (size.width * 0.01),
                    fontFamily: AppFont.primaryFont,
                    color: AppColor.primaryColor,
                  ),
                ),
              ),
            ),
            SingleChildScrollView(
              child: Container(
                color: AppColor.background,
                height: size.height - (size.height * 0.2),
                child: Stepper(
                  margin: EdgeInsets.only(left: 50.0, right: 20.0),
                  steps: getSteps(),
                  currentStep: currentStep,
                  onStepContinue: () {
                    final isLastStep = currentStep == getSteps().length - 1;
                    if (!isLastStep) {
                      if (currentStep == 0) {
                        _currentSession.primaryCondition = _sessionPrimaryConditions;
                        _currentSession.secondaryCondition = _sessionSecondaryConditions;
                        if (validateSteps(0)) {
                          setState(() => currentStep++);
                        }
                      }
                      // else if (currentStep == 1) {
                      //   if (validateSteps(1)) {
                      //     setState(() => currentStep++);
                      //   }
                      // }
                      else if (currentStep == 1) {
                        if (_brandOther) {
                          _currentSession.productBrand = _productBrandController.text;
                          _currentSession.productName = _productNameController.text;
                          _currentSession.temperature = _temperatureController.text;
                          _currentSession.cannabinoids = [];
                          if (_thcController.text != '') {
                            _currentSession.cannabinoids!.add(Cannabinoid(title: "THC", value: _thcController.text));
                          }
                          if (_cbdController.text != '') {
                            _currentSession.cannabinoids!.add(Cannabinoid(title: "CBD", value: _cbdController.text));
                          }
                          for (var i = 0; i < _cannabinoidsController.length; i++) {
                            if (_cannabinoidsController[i].text != "") {
                              _currentSession.cannabinoids!
                                  .add(Cannabinoid(title: _dataCannabinoids[i].title, value: _cannabinoidsController[i].text));
                            }
                          }
                          _currentSession.terpenes = [];
                          _selectedTerpenes.forEach((terpene) {
                            _currentSession.terpenes!.add(terpene);
                          });
                        }
                        if (validateSteps(2)) {
                          setState(() => currentStep++);
                        }
                      }
                    } else {
                      print('complete');
                    }
                  },
                  onStepCancel: () {
                    currentStep == 0 ? null : setState(() => currentStep--);
                  },
                  onStepTapped: (index) {
                    if (index <= currentStep) {
                      setState(() => currentStep = index);
                    }
                  },
                  controlsBuilder: (context, ControlsDetails details) {
                    final isLastStep = currentStep == getSteps().length - 1;
                    if (isLastStep) {
                      return _initContinueButton(context);
                    } else {
                      return Container(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            InkWell(
                              child: Container(
                                height: 40.0,
                                width: size.width * 0.35,
                                margin: EdgeInsets.only(top: size.height * 0.02, bottom: size.height * 0.01),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(12),
                                  ),
                                  color: AppColor.background,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.withOpacity(0.5),
                                      offset: Offset(0.0, 1.5),
                                      blurRadius: 1.5,
                                    ),
                                  ],
                                ),
                                child: Center(
                                  child: Text(
                                    "Continue",
                                    style: TextStyle(
                                      fontSize: AppFontSizes.buttonSize + 2.5,
                                      color: AppColor.secondaryColor,
                                      fontWeight: FontWeight.w800,
                                    ),
                                    textScaler: TextScaler.linear(AppFontScales.adaptiveScale),
                                  ),
                                ),
                              ),
                              onTap: details.onStepContinue,
                            ),
                          ],
                        ),
                      );
                    }
                  },
                ),
              ),
            ),
            // _initContinueButton(context),
          ],
        ),
      ),
    );
  }

  List<Step> getSteps() => [
        Step(
          state: currentStep > 0 ? StepState.complete : StepState.indexed,
          isActive: currentStep >= 0,
          title: TitleSectionSession(context, "Treatments"),
          content: Container(
            child: Column(
              children: [
                _initPrimaryConditions(context),
                SizedBox(height: 10.0),
                _initSecondaryConditions(context),
              ],
            ),
          ),
        ),
        // Step(
        //     state: currentStep > 1 ? StepState.complete : StepState.indexed,
        //     isActive: currentStep >= 1,
        //     title: TitleSectionSession(context, "Brand"),
        //     content: _initBrandOption(context)),
        Step(
          state: currentStep > 2 ? StepState.complete : StepState.indexed,
          isActive: currentStep >= 2,
          title: TitleSectionSession(context, "Product"),
          content: _brandLumir ? _initLumirProducts(context) : _initProducts(context),
        ),
        Step(
          state: currentStep > 3 ? StepState.complete : StepState.indexed,
          isActive: currentStep >= 3,
          title: TitleSectionSession(context, "Complete"),
          content: buildSessionCard(context, _currentSession),
        ),
      ];

  bool validateSteps(int step) {
    switch (step) {
      case 0:
        if (_sessionPrimaryConditions.length <= 0) {
          showAlertMessage(context, "Please select your conditions", () {
            Navigator.pop(context);
          });
          return false;
        } else if (_sessionSecondaryConditions.length <= 0) {
          showAlertMessage(context, "Please select your secondary conditions", () {
            Navigator.pop(context);
          });
          return false;
        }
        return true;
      case 1:
        if (!_brandLumir && !_brandOther) {
          showAlertMessage(context, "Please select brand", () {
            Navigator.pop(context);
          });
          return false;
        }
        return true;
      case 2:
        if (_brandLumir && _currentSession.productBrand!.isEmpty) {
          showAlertMessage(context, "Please select your lumir product", () {
            Navigator.pop(context);
          });
          return false;
        }
        if (_brandOther && _currentSession.productType!.title == "") {
          showAlertMessage(context, "Please select product type", () {
            Navigator.pop(context);
          });
          return false;
        }
        if (_brandOther && _currentSession.deliveryMethodType!.title == "") {
          showAlertMessage(context, "Please select delivery method", () {
            Navigator.pop(context);
          });
          return false;
        }
        if (_brandOther && _currentSession.strainType!.title == "") {
          showAlertMessage(context, "Please select the strain type", () {
            Navigator.pop(context);
          });
          return false;
        }
        if (_brandOther && _currentSession.productBrand == "") {
          showAlertLongMessage(context, "Please enter the product brand", () {
            Navigator.pop(context);
          });
          return false;
        }
        if (_brandOther && _currentSession.productName == "") {
          showAlertLongMessage(context, "Please enter the product name", () {
            Navigator.pop(context);
          });
          return false;
        }
        if (_brandOther && _currentSession.temperature != "") {
          if (_currentSession.temperatureMeasurement!.title == "") {
            showAlertLongMessage(context, "Please select your temperature measurement (°F, °C)", () {
              Navigator.pop(context);
            });
            return false;
          }
        }
        if (_thcController.text != "" || _cbdController.text != "") {
          if (_currentSession.activeIngredientsMeasurement!.title == "") {
            showAlertLongMessage(context, "Please select your active ingredient measurement (%, mg, ml)", () {
              Navigator.pop(context);
            });
            return false;
          }
        }

        for (var i = 0; i < _cannabinoidsController.length; i++) {
          if (_cannabinoidsController[i].text != "") {
            if (_currentSession.activeIngredientsMeasurement!.title == "") {
              showAlertLongMessage(context, "Please select your active ingredient measurement (%, mg, ml)", () {
                Navigator.pop(context);
              });
              return false;
            }
          }
        }
        for (var i = 0; i < _selectedTerpenes.length; i++) {
          if (_selectedTerpenes[i].value != "") {
            if (_currentSession.activeIngredientsMeasurement!.title == "") {
              showAlertLongMessage(context, "Please select your active ingredient measurement (%, mg, ml)", () {
                Navigator.pop(context);
              });
              return false;
            }
          }
        }
        return true;
      default:
        return false;
    }
  }

  Widget _initPrimaryConditions(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Column(
      children: [
        TitleInternalSectionSession(context, "Condition(s) you're treating", true),
        SizedBox(height: size.height * 0.01),
        Container(
          height: size.height * 0.08,
          width: double.maxFinite,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            shrinkWrap: true,
            itemCount: _sessionPrimaryConditions.length,
            itemBuilder: (BuildContext context, int index) {
              final condition = _sessionPrimaryConditions[index];
              return InkWell(
                child: Container(
                  width: size.width * 0.75,
                  decoration: BoxDecoration(
                    gradient: AppColor.primaryGradient,
                    borderRadius: BorderRadius.circular(size.width * 0.04),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        offset: Offset(1.0, 1.0), //(x,y)
                        blurRadius: 1.0,
                      ),
                    ],
                  ),
                  child: Stack(
                    children: [
                      Positioned(
                        top: -10.0,
                        right: -10.0,
                        child: Image.network(
                          AppLogos.iconWhiteImg,
                          color: Colors.white.withOpacity(0.15),
                          width: size.width * 0.2,
                          fit: BoxFit.contain,
                        ),
                      ),
                      Row(
                        children: [
                          Container(
                            width: size.width * 0.2,
                            margin: EdgeInsets.all(5.0),
                            padding: EdgeInsets.all(5.0),
                            child: Image(
                              color: AppColor.background,
                              image: AssetImage('assets/img/condition/${AppData().iconCondition(condition.title!)}'),
                              fit: BoxFit.contain,
                            ),
                          ),
                          Expanded(
                            child: Container(
                              margin: EdgeInsets.all(5.0),
                              child: Text(
                                condition.title!,
                                style: TextStyle(color: AppColor.background, fontSize: AppFontSizes.subTitleSize, fontWeight: FontWeight.w600),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                onTap: () {
                  showSelectConditionDialog(context, _sessionPrimaryConditions, setState, ((primaryConditions) {
                    _sessionPrimaryConditions = primaryConditions;
                    _sessionSecondaryConditions = [];
                    _prefs.secondaryConditions.forEach((condition) {
                      Map<String, dynamic> temp = jsonDecode(condition);
                      Condition tempCondition = Condition.fromJson(temp);
                      _sessionSecondaryConditions.add(tempCondition);
                    });
                    _sessionSecondaryConditions.removeWhere((tempCondition) => tempCondition.title == _sessionPrimaryConditions[0].title);
                    Navigator.of(context).pop();
                    setState(() {});
                  }));
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _initSecondaryConditions(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Column(
      children: [
        TitleInternalSectionSession(context, "Secondary Conditions", true),
        SizedBox(height: size.height * 0.01),
        _sessionSecondaryConditions.length > 0
            ? Container(
                height: size.height * 0.14,
                width: double.maxFinite,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  shrinkWrap: true,
                  itemCount: _sessionSecondaryConditions.length,
                  itemBuilder: (BuildContext context, int index) {
                    final condition = _sessionSecondaryConditions[index];
                    return InkWell(
                      child: Container(
                        width: size.width * 0.245,
                        margin: EdgeInsets.only(right: 5.0),
                        decoration: BoxDecoration(
                          gradient: AppColor.primaryGradient,
                          borderRadius: BorderRadius.circular(size.width * 0.04),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.5),
                              offset: Offset(1.0, 1.0), //(x,y)
                              blurRadius: 1.0,
                            ),
                          ],
                        ),
                        child: Stack(
                          children: [
                            Positioned(
                              top: -5.0,
                              right: -5.0,
                              child: Image.network(
                                AppLogos.iconWhiteImg,
                                color: Colors.white.withOpacity(0.75),
                                opacity: const AlwaysStoppedAnimation(0.2),
                                width: size.width * 0.15,
                                fit: BoxFit.contain,
                              ),
                            ),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(height: size.height * 0.01),
                                Image(
                                  color: AppColor.background,
                                  height: size.height * 0.065,
                                  image: AssetImage('assets/img/condition/${AppData().iconCondition(condition.title!)}'),
                                  fit: BoxFit.contain,
                                ),
                                SizedBox(height: size.height * 0.0075),
                                Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 2.0),
                                  child: Container(
                                    height: size.height * 0.044,
                                    child: Center(
                                      child: Text(
                                        condition.title!,
                                        style: TextStyle(
                                            color: AppColor.background,
                                            fontSize:
                                                condition.title!.length < 25 ? AppFontSizes.contentSize - 1.0 : AppFontSizes.contentSmallSize - 2.0,
                                            fontWeight: FontWeight.w600),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      onTap: () {
                        showSelectSecondaryConditionDialog(context, _sessionPrimaryConditions, _sessionSecondaryConditions, setState,
                            ((secondaryConditions) {
                          _sessionSecondaryConditions = secondaryConditions;
                          Navigator.of(context).pop();
                          setState(() {});
                        }));
                      },
                    );
                  },
                ),
              )
            : Align(
                alignment: Alignment.centerLeft,
                child: ActionCardAddCondition("add", size, () {
                  showSelectSecondaryConditionDialog(context, _sessionPrimaryConditions, _sessionSecondaryConditions, setState,
                      ((secondaryConditions) {
                    _sessionSecondaryConditions = [];
                    _sessionSecondaryConditions = secondaryConditions;
                    Navigator.of(context).pop();
                    setState(() {});
                  }));
                }),
              ),
      ],
    );
  }

  Widget _initBrandOption(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Column(
      children: [
        TitleInternalSectionSession(context, "Brand", true),
        SizedBox(height: size.height * 0.01),
        Container(
          height: size.height * 0.07,
          child: Row(
            children: [
              Expanded(
                child: InkWell(
                  child: Container(
                    width: size.width * 0.4,
                    decoration: BoxDecoration(
                      gradient: _brandLumir ? AppColor.secondaryGradient : AppColor.primaryGradient,
                      borderRadius: BorderRadius.all(
                        Radius.circular(size.width * 0.04),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.7),
                          offset: Offset(0.0, 1.0), //(x,y)
                          blurRadius: 5.0,
                        ),
                      ],
                    ),
                    child: Stack(
                      children: [
                        Positioned(
                          top: -5.0,
                          right: -5.0,
                          child: Image.network(
                            AppLogos.iconImg,
                            // color: Colors.white.withOpacity(0.2),
                            opacity: const AlwaysStoppedAnimation(0.2),
                            width: size.width * 0.15,
                            fit: BoxFit.contain,
                          ),
                        ),
                        Center(
                          child: Text(
                            'Lumir',
                            style: TextStyle(color: AppColor.background, fontSize: AppFontSizes.subTitleSize, fontWeight: FontWeight.w600),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ),
                  onTap: () {
                    print("LUMIR");
                    if (_brandLumir) {
                      _brandLumir = false;
                    } else {
                      _brandLumir = true;
                      _brandOther = false;
                      _foundProductList = false;
                      _loadLumirProducts(context);
                    }
                    setState(() {});
                  },
                ),
              ),
              SizedBox(width: size.height * 0.005),
              Expanded(
                child: InkWell(
                  child: Container(
                    width: size.width * 0.4,
                    decoration: BoxDecoration(
                      gradient: _brandOther ? AppColor.secondaryGradient : AppColor.primaryGradient,
                      borderRadius: BorderRadius.all(
                        Radius.circular(size.width * 0.04),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.7),
                          offset: Offset(0.0, 1.0), //(x,y)
                          blurRadius: 5.0,
                        ),
                      ],
                    ),
                    child: Stack(
                      children: [
                        Positioned(
                          top: -5.0,
                          right: -5.0,
                          child: Image.network(
                            AppLogos.iconImg,
                            opacity: const AlwaysStoppedAnimation(0.2),
                            // color: Colors.white.withOpacity(0.2),
                            width: size.width * 0.15,
                            fit: BoxFit.contain,
                          ),
                        ),
                        Center(
                          child: Text(
                            'Other',
                            style: TextStyle(color: AppColor.background, fontSize: AppFontSizes.subTitleSize, fontWeight: FontWeight.w600),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ),
                  onTap: () {
                    print("OTHER");
                    if (_brandOther) {
                      _brandOther = false;
                    } else {
                      _brandOther = true;
                      _brandLumir = false;
                      _clearSetupSession();
                    }
                    setState(() {});
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _initProducts(BuildContext context) {
    return Column(
      children: [
        _initProductType(context),
        _initDeliveryMethod(context),
        _initStrainType(context),
        _initFoundProductField(context),
        _foundProductList ? _initFoundProductList(context) : Container(),
        _initProductBrand(context),
        _initProductName(context),
        _productTypeSelected == 'Vape Cartridges' || _productTypeSelected == 'Oil/Extract' || _productTypeSelected == 'Resin'
            ? _initTemperature(context)
            : Container(),
        _initActiveIngredients(context),
        _initTerpenes(context),
        // _initContinueButton(context),
      ],
    );
  }

  Widget _initProductType(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Column(
      children: [
        SizedBox(height: size.height * 0.01),
        TitleInternalSectionSession(context, "Product Type", true),
        SizedBox(height: size.height * 0.01),
        Stack(
          children: [
            Container(
              height: size.height * 0.175,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                shrinkWrap: true,
                itemCount: _dataProductTypes.length,
                itemBuilder: (BuildContext context, int index) {
                  final productType = _dataProductTypes[index];
                  return Stack(
                    children: [
                      InkWell(
                        child: Container(
                          width: size.width * 0.3,
                          margin: EdgeInsets.only(right: size.width * 0.01),
                          decoration: BoxDecoration(
                            gradient: productType.isSelected ? AppColor.primaryGradient : AppColor.secondaryGradient,
                            borderRadius: BorderRadius.circular(size.width * 0.04),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.5),
                                offset: Offset(1.0, 1.0), //(x,y)
                                blurRadius: 1.0,
                              ),
                            ],
                          ),
                          child: Stack(
                            children: [
                              Positioned(
                                top: -5.0,
                                right: -7.5,
                                child: Image.network(
                                  AppLogos.iconWhiteImg,
                                  color: Colors.white.withOpacity(0.15),
                                  width: size.width * 0.2,
                                  fit: BoxFit.contain,
                                ),
                              ),
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SizedBox(height: size.height * 0.01),
                                  Image(
                                    color: Colors.white,
                                    height: size.height * 0.06,
                                    image: AssetImage('assets/img/medication/${productType.icon}'),
                                    fit: BoxFit.contain,
                                  ),
                                  SizedBox(height: size.height * 0.015),
                                  Text(
                                    productType.title!,
                                    style: TextStyle(color: Colors.white, fontSize: AppFontSizes.contentSize, fontWeight: FontWeight.w600),
                                    textAlign: TextAlign.center,
                                  ),
                                  SizedBox(height: size.height * 0.005),
                                  Container(
                                    height: size.height * 0.05,
                                    child: Center(
                                      child: Text(
                                        productType.description!,
                                        style: TextStyle(
                                            color: AppColor.background, fontSize: AppFontSizes.contentSmallSize - 1.0, fontWeight: FontWeight.w500),
                                        textAlign: TextAlign.center,
                                        maxLines: 3,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        onTap: () {
                          setState(() {
                            if (productType.isSelected) {
                              productType.isSelected = false;
                              _currentSession.productType = ProductType(title: "");
                              _productTypeSelected = "";
                            } else {
                              _dataProductTypes.forEach((m) {
                                m.isSelected = false;
                              });
                              productType.isSelected = true;
                              _currentSession.productType = productType;
                              _productTypeSelected = productType.title;
                              _dataDeliveryMethods = AppData().deliveryMethods(_productTypeSelected);
                              _dataDeliveryMethods.forEach((deliveryMethod) {
                                deliveryMethod.isSelected = false;
                              });
                              if (_productTypeSelected == "Vape Cartridges") {
                                _currentSession.deliveryMethodType = DeliveryMethod(title: "N/A");
                              } else {
                                _currentSession.deliveryMethodType = DeliveryMethod(title: "");
                              }
                            }
                          });
                        },
                      ),
                    ],
                  );
                },
              ),
            ),
            // Positioned(
            //   right: 0.0,
            //   child: Container(
            //     decoration: BoxDecoration(
            //       color: AppColor.primaryColor.withOpacity(0.3),
            //       borderRadius: BorderRadius.only(
            //         topLeft: Radius.circular(25.0),
            //         bottomLeft: Radius.circular(25.0),
            //       ),
            //     ),
            //     height: size.height * 0.175,
            //     width: size.width * 0.07,
            //     child: Center(
            //       child: Image(
            //         color: AppColor.background.withOpacity(0.8),
            //         width: 15.0,
            //         image: AssetImage('assets/img/icon_arrowButton.png'),
            //         fit: BoxFit.contain,
            //       ),
            //     ),
            //   ),
            // ),
          ],
        ),
      ],
    );
  }

  Widget _initDeliveryMethod(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return _productTypeSelected == 'Vape Cartridges' || _productTypeSelected == ''
        ? Container()
        : Column(
            children: [
              SizedBox(height: size.height * 0.01),
              TitleInternalSectionSession(context, "Delivery Method", true),
              SizedBox(height: size.height * 0.01),
              Stack(
                children: [
                  Container(
                    height: size.height * 0.07,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      shrinkWrap: true,
                      itemCount: _dataDeliveryMethods.length,
                      itemBuilder: (BuildContext context, int index) {
                        final deliveryMethod = _dataDeliveryMethods[index];
                        return Stack(
                          children: [
                            InkWell(
                              child: Container(
                                width: size.width * 0.3,
                                margin: EdgeInsets.only(right: size.width * 0.01),
                                decoration: BoxDecoration(
                                  gradient: deliveryMethod.isSelected ? AppColor.primaryGradient : AppColor.secondaryGradient,
                                  borderRadius: BorderRadius.circular(size.width * 0.04),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.withOpacity(0.5),
                                      offset: Offset(1.0, 1.0), //(x,y)
                                      blurRadius: 1.0,
                                    ),
                                  ],
                                ),
                                child: Stack(
                                  children: [
                                    Positioned(
                                      top: -5.0,
                                      right: -5.0,
                                      child: Image.network(
                                        AppLogos.iconWhiteImg,
                                        color: Colors.white.withOpacity(0.15),
                                        width: size.width * 0.15,
                                        fit: BoxFit.contain,
                                      ),
                                    ),
                                    Center(
                                      child: Text(
                                        deliveryMethod.title!,
                                        style: TextStyle(color: Colors.white, fontSize: AppFontSizes.contentSize, fontWeight: FontWeight.w600),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              onTap: () {
                                setState(() {
                                  if (deliveryMethod.isSelected) {
                                    deliveryMethod.isSelected = false;
                                    _currentSession.deliveryMethodType = DeliveryMethod(title: "");
                                  } else {
                                    _dataDeliveryMethods.forEach((d) {
                                      d.isSelected = false;
                                    });
                                    deliveryMethod.isSelected = true;
                                    _currentSession.deliveryMethodType = deliveryMethod;
                                  }
                                });
                              },
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ],
              ),
            ],
          );
  }

  Widget _initStrainType(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Column(
      children: [
        SizedBox(height: size.height * 0.01),
        TitleInternalSectionSession(context, "Strain Type", true),
        Container(
          alignment: Alignment.center,
          height: 100.0,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            shrinkWrap: true,
            itemCount: _dataStrainTypes.length,
            itemBuilder: (BuildContext context, int index) {
              final strain = _dataStrainTypes[index];
              return Stack(
                children: [
                  InkWell(
                    child: Container(
                      width: size.width * 0.2,
                      margin: EdgeInsets.symmetric(vertical: 5.0, horizontal: 4.5),
                      decoration: strain.isSelected
                          ? BoxDecoration(
                              gradient: AppColor.primaryGradient,
                              borderRadius: BorderRadius.circular(size.width * 0.05),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.5),
                                  offset: Offset(1.0, 1.0), //(x,y)
                                  blurRadius: 1.0,
                                ),
                              ],
                            )
                          : BoxDecoration(
                              gradient: AppColor.secondaryGradient,
                              borderRadius: BorderRadius.circular(size.width * 0.05),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.5),
                                  offset: Offset(1.0, 1.0), //(x,y)
                                  blurRadius: 1.0,
                                ),
                              ],
                            ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20.0),
                        child: Stack(
                          children: [
                            Positioned(
                              top: -2.5,
                              right: -5.0,
                              child: Image.network(
                                AppLogos.iconWhiteImg,
                                color: Colors.white.withOpacity(0.15),
                                width: 55.0,
                                fit: BoxFit.contain,
                              ),
                            ),
                            Positioned(
                              top: 0.0,
                              right: size.width * 0.025,
                              child: Container(
                                width: size.width * 0.18,
                                height: size.height * 0.08,
                                child: Align(
                                  alignment: Alignment.centerLeft,
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 15.0),
                                    child: Text(
                                      strain.icon!,
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: AppFontSizes.titleSize + (size.width * 0.05),
                                          fontFamily: "Poppins",
                                          fontWeight: FontWeight.w600),
                                      textAlign: TextAlign.left,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Positioned(
                              bottom: 5.0,
                              left: size.width * 0.01,
                              child: Container(
                                width: size.width * 0.18,
                                height: size.height * 0.03,
                                child: Text(
                                  strain.title!,
                                  style: TextStyle(color: Colors.white, fontSize: AppFontSizes.contentSize, fontWeight: FontWeight.w600),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    onTap: () {
                      setState(() {
                        if (strain.isSelected) {
                          strain.isSelected = false;
                          _currentSession.strainType = StrainType(title: "");
                        } else {
                          _dataStrainTypes.forEach((s) {
                            s.isSelected = false;
                          });
                          strain.isSelected = true;
                          _currentSession.strainType = strain;
                        }
                      });
                    },
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _initFoundProductField(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Column(
      children: [
        SizedBox(height: size.height * 0.01),
        TitleInternalSectionSession(context, "Find Product", false),
        Container(
          height: 50.0,
          margin: EdgeInsets.symmetric(vertical: 7.5),
          child: Row(
            children: [
              Expanded(
                child: Container(
                  child: TextField(
                    controller: _foundProductController,
                    autofocus: false,
                    keyboardType: TextInputType.text,
                    style: TextStyle(fontSize: 15.0, color: AppColor.content),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: AppColor.primaryColor.withOpacity(0.07),
                      hintText: "Find your Product...",
                      hintStyle: TextStyle(fontSize: AppFontSizes.contentSize - 1.0, color: Colors.grey[400]),
                      contentPadding: EdgeInsets.only(left: 25.0, right: 25.0, top: 10.0, bottom: 10.0),
                      border: OutlineInputBorder(borderSide: BorderSide.none, borderRadius: BorderRadius.circular(15.0)),
                      focusedBorder: OutlineInputBorder(borderSide: BorderSide.none, borderRadius: BorderRadius.circular(10.0)),
                      suffixIcon: _foundProductController.text.length > 0
                          ? Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.all(
                                  Radius.circular(15),
                                ),
                                color: Colors.black.withOpacity(0.1),
                              ),
                              child: IconButton(
                                onPressed: () {
                                  print('Clear');
                                  _foundProductController.text = '';
                                  _foundProductList = false;
                                  _productList = [];
                                  setState(() {});
                                },
                                icon: Icon(
                                  Icons.clear_rounded,
                                  color: AppColor.primaryColor,
                                ),
                              ),
                            )
                          : Container(
                              width: 0.0,
                            ),
                    ),
                  ),
                ),
              ),
              FloatingActionButton(
                elevation: 0.0,
                heroTag: "search",
                backgroundColor: Colors.transparent,
                child: Container(
                  width: 50,
                  height: 45,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(
                      Radius.circular(10),
                    ),
                    gradient: AppColor.secondaryGradient,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.7),
                        offset: Offset(0.0, 1.0), //(x,y)
                        blurRadius: 5.0,
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.search_rounded,
                    size: 27,
                    color: AppColor.background,
                  ),
                ),
                onPressed: () {
                  if (_foundProductController.text.isNotEmpty) {
                    if (!_prefs.demoVersion) {
                      print("Search");
                      loadProducts(context, _foundProductController.text);
                      // _foundProductList
                      //     ? _foundProductList = false
                      //     : _foundProductList = true;
                      // setState(() {});
                    } else {
                      showAlertMessage(context, 'Not available in demo version', () {
                        Navigator.pop(context);
                      });
                    }
                  }
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _initFoundProductList(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Container(
      height: size.height * 0.5,
      child: ListView.builder(
        itemCount: _productList.length,
        itemBuilder: (BuildContext context, int index) => buildProductCard(context, index),
      ),
    );
  }

  Widget buildProductCard(BuildContext context, int index) {
    final size = MediaQuery.of(context).size;
    return Material(
      child: InkWell(
          child: Container(
            color: AppColor.fourthColor.withOpacity(0.1),
            child: Padding(
              padding: EdgeInsets.only(left: 10.0, right: 10.0, top: 10.0),
              child: Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 1.0),
                        child: Image(
                          color: AppColor.secondaryColor,
                          width: AppFontSizes.contentSize - 2.0,
                          image: AssetImage('assets/img/icon_arrow.png'),
                          fit: BoxFit.contain,
                        ),
                      ),
                      SizedBox(width: size.width * 0.02),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: size.width * 0.65,
                            child: Text(
                              _productList[index].name![0].toUpperCase() + _productList[index].name!.substring(1).toLowerCase(),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 2,
                              softWrap: true,
                              style: TextStyle(
                                fontSize: AppFontSizes.contentSize,
                                color: AppColor.content,
                              ),
                              textScaler: TextScaler.linear(AppFontScales.adaptiveScale),
                            ),
                          ),
                          SizedBox(height: size.height * 0.005),
                          Text(
                            _productList[index].brandName![0].toUpperCase() + _productList[index].brandName!.substring(1).toLowerCase(),
                            softWrap: true,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: AppFontSizes.contentSize - 1.0,
                              color: AppColor.primaryColor,
                            ),
                            textScaler: TextScaler.linear(AppFontScales.adaptiveScale),
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: size.height * 0.005),
                  Divider(
                    color: AppColor.content.withOpacity(0.5),
                  )
                ],
              ),
            ),
          ),
          onTap: () {
            autoFillProduct(_productList[index]);
          }),
    );
  }

  autoFillProduct(Product product) {
    _clearSetupSession();

    if (product.brandName != '') {
      _currentSession.productBrand = product.brandName;
      _productBrandController.text = product.brandName![0].toUpperCase() + product.brandName!.substring(1).toLowerCase();
    }
    if (product.name != '') {
      _currentSession.productName = product.name;
      _productNameController.text = product.name![0].toUpperCase() + product.name!.substring(1).toLowerCase();
    }

    if (product.thc != '' && product.thc != 'null') {
      _currentSession.doseMeasurement!.isSelected = true;
      _dataMeasurements.forEach((m) {
        if (m.title == '%') {
          m.isSelected = true;
        }
      });
      _currentSession.activeIngredientsMeasurement = Measurement(title: "%");
      num thcValue = double.parse(product.thc!);
      String thc = isInteger(thcValue) ? product.thc! : product.thc!.substring(0, 5);
      _thcController.text = thc;

      _currentSession.cannabinoids!.add(Cannabinoid(title: "THC", value: thc));
    }

    if (product.cbd != '' && product.cbd != 'null') {
      _currentSession.doseMeasurement!.isSelected = true;
      _dataMeasurements.forEach((m) {
        if (m.title == '%') {
          m.isSelected = true;
        }
      });
      _currentSession.activeIngredientsMeasurement = Measurement(title: "%");
      num cbdValue = double.parse(product.cbd!);
      String cbd = isInteger(cbdValue) ? product.cbd! : product.cbd!.substring(0, 5);
      _cbdController.text = cbd;
      _currentSession.cannabinoids!.add(Cannabinoid(title: "CBD", value: cbd));
    }

    _foundProductList = false;
    setState(() {});
  }

  bool isInteger(num value) => value is int || value == value.roundToDouble();

  Widget _initProductBrand(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Column(
      children: [
        SizedBox(height: size.height * 0.01),
        TitleInternalSectionSession(context, "Brand", true),
        Container(
          padding: EdgeInsets.symmetric(vertical: 5.0),
          child: Material(
            elevation: 2.0,
            shadowColor: Colors.grey.withOpacity(0.5),
            borderRadius: BorderRadius.circular(size.width * 0.025),
            child: TextField(
              controller: _productBrandController,
              style: TextStyle(fontSize: AppFontSizes.contentSize, color: AppColor.content),
              keyboardType: TextInputType.text,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                hintText: "Brand",
                hintStyle: TextStyle(fontSize: AppFontSizes.contentSize - 1.0, color: Colors.grey[400]),
                contentPadding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 5.0),
                focusedBorder: OutlineInputBorder(borderSide: BorderSide.none, borderRadius: BorderRadius.circular(size.width * 0.025)),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide.none,
                  borderRadius: BorderRadius.circular(size.width * 0.025),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _initProductName(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Column(
      children: [
        SizedBox(height: size.height * 0.01),
        TitleInternalSectionSession(context, "Product Name", true),
        Container(
          padding: EdgeInsets.symmetric(vertical: 5.0),
          child: Material(
            elevation: 2.0,
            shadowColor: Colors.grey.withOpacity(0.5),
            borderRadius: BorderRadius.circular(size.width * 0.025),
            child: TextField(
              controller: _productNameController,
              style: TextStyle(fontSize: AppFontSizes.contentSize, color: AppColor.content),
              keyboardType: TextInputType.text,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                hintText: "Product Name",
                hintStyle: TextStyle(fontSize: AppFontSizes.contentSize - 1.0, color: Colors.grey[400]),
                contentPadding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 5.0),
                focusedBorder: OutlineInputBorder(borderSide: BorderSide.none, borderRadius: BorderRadius.circular(size.width * 0.025)),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide.none,
                  borderRadius: BorderRadius.circular(size.width * 0.025),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _initTemperature(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Column(
      children: [
        SizedBox(height: size.height * 0.01),
        TitleInternalSectionSession(context, "Temperature Setting", false),
        Container(
          padding: EdgeInsets.symmetric(vertical: 5.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                flex: 2,
                child: Container(
                  height: 45.0,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      InkWell(
                        child: Container(
                          width: size.width * 0.175,
                          decoration: BoxDecoration(
                            gradient: _tempF ? AppColor.secondaryGradient : null,
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(size.width * 0.025),
                              bottomLeft: Radius.circular(size.width * 0.025),
                            ),
                            border: Border.all(color: AppColor.secondaryColor),
                          ),
                          child: Center(
                            child: Text(
                              "°F",
                              style: TextStyle(
                                  color: _tempF ? Colors.white : AppColor.secondaryColor,
                                  fontSize: AppFontSizes.contentSize,
                                  fontWeight: FontWeight.w800),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                        onTap: () {
                          setState(() {
                            _tempF = true;
                            _tempC = false;
                            _temperatureController.clear();
                            _currentSession.temperatureMeasurement!.title = "°F";
                          });
                        },
                      ),
                      InkWell(
                        child: Container(
                          width: size.width * 0.175,
                          decoration: BoxDecoration(
                            gradient: _tempC ? AppColor.secondaryGradient : null,
                            borderRadius: BorderRadius.only(
                              topRight: Radius.circular(size.width * 0.025),
                              bottomRight: Radius.circular(size.width * 0.025),
                            ),
                            border: Border.all(color: AppColor.secondaryColor),
                          ),
                          child: Center(
                            child: Text(
                              "°C",
                              style: TextStyle(
                                  color: _tempC ? Colors.white : AppColor.secondaryColor,
                                  fontSize: AppFontSizes.contentSize,
                                  fontWeight: FontWeight.w800),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                        onTap: () {
                          setState(() {
                            _tempF = false;
                            _tempC = true;
                            _temperatureController.clear();
                            _currentSession.temperatureMeasurement!.title = "°C";
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                flex: 2,
                child: Container(
                  height: 45.0,
                  padding: EdgeInsets.only(left: 20.0),
                  child: Material(
                    elevation: 2.0,
                    shadowColor: Colors.grey.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(size.width * 0.025),
                    child: Stack(
                      children: [
                        TextField(
                          controller: _temperatureController,
                          keyboardType: TextInputType.numberWithOptions(signed: true, decimal: false),
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(3),
                          ],
                          // [
                          //   FilteringTextInputFormatter.digitsOnly,
                          //   _currentSession.temperatureMeasurement.title == "°C"
                          //       ? LengthLimitingTextInputFormatter(2)
                          //       : LengthLimitingTextInputFormatter(3),
                          // ],
                          style: TextStyle(fontSize: AppFontSizes.contentSize, color: AppColor.content),
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.white,
                            hintStyle: TextStyle(fontSize: AppFontSizes.contentSize - 1.0, color: Colors.grey[400]),
                            contentPadding: const EdgeInsets.only(top: 5.0, bottom: 5.0, left: 30.0, right: 50.0),
                            focusedBorder: OutlineInputBorder(borderSide: BorderSide.none, borderRadius: BorderRadius.circular(size.width * 0.025)),
                            enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide.none,
                              borderRadius: BorderRadius.circular(size.width * 0.025),
                            ),
                          ),
                        ),
                        Positioned(
                          right: 0.0,
                          child: Container(
                            height: 45.0,
                            width: 55.0,
                            padding: EdgeInsets.only(left: 10.0),
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                _currentSession.temperatureMeasurement!.title!,
                                style: TextStyle(
                                  color: AppColor.primaryColor,
                                  fontSize: AppFontSizes.contentSize,
                                ),
                                textAlign: TextAlign.left,
                              ),
                            ),
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
      ],
    );
  }

  Widget _initActiveIngredients(BuildContext context) {
    final size = MediaQuery.of(context).size;
    String _measurement = _currentSession.activeIngredientsMeasurement!.title!;
    return Column(
      children: [
        SizedBox(height: size.height * 0.01),
        TitleInternalSectionSession(context, "Active Ingredients", false),
        Container(
          margin: EdgeInsets.only(top: 5.0),
          height: 45.0,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            shrinkWrap: true,
            itemCount: _dataMeasurements.length,
            itemBuilder: (BuildContext context, int index) {
              final measurement = _dataMeasurements[index];
              return InkWell(
                child: Container(
                  width: size.width * 0.25,
                  decoration: BoxDecoration(
                    gradient: measurement.isSelected ? AppColor.secondaryGradient : null,
                    borderRadius: _initBorderMeasurement(index),
                    border: Border.all(color: AppColor.secondaryColor),
                  ),
                  child: Center(
                    child: Text(
                      measurement.title!,
                      style: TextStyle(
                          color: measurement.isSelected ? Colors.white : AppColor.secondaryColor,
                          fontSize: AppFontSizes.contentSize,
                          fontWeight: FontWeight.w800),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                onTap: () {
                  setState(() {
                    if (measurement.isSelected) {
                      measurement.isSelected = false;
                      _currentSession.activeIngredientsMeasurement = Measurement(title: "");
                    } else {
                      _dataMeasurements.forEach((m) {
                        m.isSelected = false;
                      });
                      measurement.isSelected = true;
                      _currentSession.activeIngredientsMeasurement = measurement;
                    }
                    print("> Measurement: ${_currentSession.activeIngredientsMeasurement!.title}");
                  });
                },
              );
            },
          ),
        ),
        Padding(
          padding: EdgeInsets.only(top: size.height * 0.015, bottom: size.height * 0.015),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Image(
                color: AppColor.fifthColor,
                width: AppFontSizes.contentSize,
                image: AssetImage('assets/img/icon_arrow.png'),
                fit: BoxFit.contain,
              ),
              SizedBox(width: size.width * 0.02),
              Text(
                "Cannabinoid",
                style: TextStyle(
                  fontSize: AppFontSizes.contentSize,
                  color: AppColor.content,
                ),
                textScaler: TextScaler.linear(AppFontScales.adaptiveScale),
              ),
            ],
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              flex: 2,
              child: Container(
                height: 45.0,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(
                    Radius.circular(size.width * 0.025),
                  ),
                  gradient: AppColor.secondaryGradient,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      offset: Offset(1.0, 1.0), //(x,y)
                      blurRadius: 1.0,
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    "THC",
                    style: TextStyle(
                      fontSize: AppFontSizes.contentSize + 1.0,
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: Container(
                height: 45.0,
                padding: EdgeInsets.only(left: 20.0),
                child: Material(
                  elevation: 2.0,
                  shadowColor: Colors.grey.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(size.width * 0.025),
                  child: Stack(
                    children: [
                      TextField(
                        controller: _thcController,
                        style: TextStyle(fontSize: AppFontSizes.contentSize, color: AppColor.content),
                        keyboardType: TextInputType.numberWithOptions(signed: true, decimal: true),
                        inputFormatters: [
                          // FilteringTextInputFormatter.digitsOnly,
                          FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*$')),
                          LengthLimitingTextInputFormatter(6),
                          DecimalTextInputFormatter(decimalRange: 2),
                        ],
                        textInputAction: TextInputAction.done,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          hintStyle: TextStyle(fontSize: AppFontSizes.contentSize - 1.0, color: Colors.grey[400]),
                          contentPadding: const EdgeInsets.only(top: 5.0, bottom: 5.0, left: 20.0, right: 50.0),
                          focusedBorder: OutlineInputBorder(borderSide: BorderSide.none, borderRadius: BorderRadius.circular(size.width * 0.025)),
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide.none,
                            borderRadius: BorderRadius.circular(size.width * 0.025),
                          ),
                        ),
                      ),
                      Positioned(
                        right: 0.0,
                        child: Container(
                          height: 45.0,
                          width: 55.0,
                          padding: EdgeInsets.only(left: 10.0),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              _measurement,
                              style: TextStyle(
                                color: AppColor.primaryColor,
                                fontSize: _currentSession.activeIngredientsMeasurement!.title!.length > 5
                                    ? AppFontSizes.contentSmallSize - 1.5
                                    : AppFontSizes.contentSize - 1.0,
                              ),
                              textAlign: TextAlign.left,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: size.height * 0.01),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              flex: 2,
              child: Container(
                height: 45.0,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(
                    Radius.circular(size.width * 0.025),
                  ),
                  gradient: AppColor.secondaryGradient,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      offset: Offset(1.0, 1.0), //(x,y)
                      blurRadius: 1.0,
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    "CBD",
                    style: TextStyle(
                      fontSize: AppFontSizes.contentSize + 1.0,
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: Container(
                height: 45.0,
                padding: EdgeInsets.only(left: 20.0),
                child: Material(
                  elevation: 2.0,
                  shadowColor: Colors.grey.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(size.width * 0.025),
                  child: Stack(
                    children: [
                      TextField(
                        controller: _cbdController,
                        style: TextStyle(fontSize: AppFontSizes.contentSize, color: AppColor.content),
                        keyboardType: TextInputType.numberWithOptions(signed: true, decimal: true),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*$')),
                          LengthLimitingTextInputFormatter(6),
                          DecimalTextInputFormatter(decimalRange: 2),
                        ],
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          hintStyle: TextStyle(fontSize: AppFontSizes.contentSize - 1.0, color: Colors.grey[400]),
                          contentPadding: const EdgeInsets.only(top: 5.0, bottom: 5.0, left: 20.0, right: 50.0),
                          focusedBorder: OutlineInputBorder(borderSide: BorderSide.none, borderRadius: BorderRadius.circular(size.width * 0.025)),
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide.none,
                            borderRadius: BorderRadius.circular(size.width * 0.025),
                          ),
                        ),
                      ),
                      Positioned(
                        right: 0.0,
                        child: Container(
                          height: 45.0,
                          width: 55.0,
                          padding: EdgeInsets.only(left: 10.0),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              _measurement,
                              style: TextStyle(
                                color: AppColor.primaryColor,
                                fontSize: _currentSession.activeIngredientsMeasurement!.title!.length > 5
                                    ? AppFontSizes.contentSmallSize - 1.5
                                    : AppFontSizes.contentSize - 1.0,
                              ),
                              textAlign: TextAlign.left,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: size.height * 0.01),
        Stack(
          children: [
            _addCannabinoid ? _showAddCannabinoid(context) : Container(),
          ],
        ),
        Material(
          elevation: 2.0,
          shadowColor: Colors.grey.withOpacity(0.5),
          borderRadius: BorderRadius.circular(size.width * 0.025),
          child: InkWell(
            child: Container(
              height: 50.0,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(
                  Radius.circular(size.width * 0.025),
                ),
                gradient: AppColor.secondaryGradient,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    offset: Offset(0.0, 1.0), //(x,y)
                    blurRadius: 2.0,
                  ),
                ],
              ),
              child: Center(
                child: Padding(
                  padding: EdgeInsets.only(left: size.width * 0.025, right: size.width * 0.02),
                  child: Stack(
                    children: [
                      Positioned(
                        top: 3.0,
                        left: size.width * 0.025,
                        child: Text(
                          "Add Cannabinoid",
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.1),
                            fontSize: AppFontSizes.buttonSize + 10.0,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                      Positioned(
                        top: 15.0,
                        left: size.width * 0.02,
                        child: Text(
                          "Add Cannabinoid",
                          style: TextStyle(
                            fontSize: AppFontSizes.buttonSize + 5.0,
                            color: AppColor.background,
                            fontWeight: FontWeight.w700,
                          ),
                          textScaler: TextScaler.linear(AppFontScales.adaptiveScale),
                        ),
                      ),
                      Positioned(
                        top: 7.5,
                        right: size.width * 0.01,
                        child: Icon(
                          Icons.add,
                          size: 35.0,
                          color: AppColor.background,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            onTap: () {
              _showAddCannabinoidDialog(context, (listCannabinoidsSelected) {
                _selectedCannabinoids = [];
                _selectedCannabinoids.addAll(listCannabinoidsSelected);
                _addCannabinoid = true;
                setState(() {
                  Navigator.pop(context);
                });
              });
            },
          ),
        ),
        SizedBox(height: size.height * 0.01),
      ],
    );
  }

  BorderRadiusGeometry _initBorderMeasurement(int index) {
    final size = MediaQuery.of(context).size;
    if (index == 0) {
      return BorderRadius.only(
        topLeft: Radius.circular(size.width * 0.025),
        bottomLeft: Radius.circular(size.width * 0.025),
      );
    } else if (_dataMeasurements.length - 1 == index) {
      return BorderRadius.only(
        topRight: Radius.circular(size.width * 0.025),
        bottomRight: Radius.circular(size.width * 0.025),
      );
    } else {
      return BorderRadius.circular(0.0);
    }
  }

  _showAddCannabinoid(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Container(
      height: _selectedCannabinoids.length * 55.0,
      child: ListView.builder(
        scrollDirection: Axis.vertical,
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        itemCount: _selectedCannabinoids.length,
        itemBuilder: (BuildContext context, int index) {
          _cannabinoidsController.add(new TextEditingController());
          final cannabinoid = _selectedCannabinoids[index];
          return Container(
            margin: EdgeInsets.only(bottom: size.height * 0.01),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  flex: 2,
                  child: Container(
                    height: 45.0,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(
                        Radius.circular(size.width * 0.025),
                      ),
                      gradient: AppColor.secondaryGradient,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.5),
                          offset: Offset(1.0, 1.0), //(x,y)
                          blurRadius: 1.0,
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        cannabinoid.title!,
                        style: TextStyle(
                          fontSize: AppFontSizes.contentSize + 1.0,
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Container(
                    height: 45.0,
                    padding: EdgeInsets.only(left: 20.0),
                    child: Material(
                      elevation: 2.0,
                      shadowColor: Colors.grey.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(size.width * 0.025),
                      child: Stack(
                        children: [
                          TextField(
                            controller: _cannabinoidsController[index],
                            style: TextStyle(fontSize: AppFontSizes.contentSize, color: AppColor.content),
                            keyboardType: TextInputType.numberWithOptions(signed: true, decimal: true),
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*$')),
                              LengthLimitingTextInputFormatter(6),
                              DecimalTextInputFormatter(decimalRange: 2),
                            ],
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: Colors.white,
                              hintStyle: TextStyle(fontSize: AppFontSizes.contentSize - 1.0, color: Colors.grey[400]),
                              contentPadding: const EdgeInsets.only(top: 5.0, bottom: 5.0, left: 20.0, right: 50.0),
                              focusedBorder: OutlineInputBorder(borderSide: BorderSide.none, borderRadius: BorderRadius.circular(size.width * 0.025)),
                              enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide.none,
                                borderRadius: BorderRadius.circular(size.width * 0.025),
                              ),
                            ),
                          ),
                          Positioned(
                            right: 0.0,
                            child: Container(
                              height: 45.0,
                              width: 55.0,
                              padding: EdgeInsets.only(left: 10.0),
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  _currentSession.activeIngredientsMeasurement!.title!,
                                  style: TextStyle(
                                    color: AppColor.primaryColor,
                                    fontSize: _currentSession.activeIngredientsMeasurement!.title!.length > 5
                                        ? AppFontSizes.contentSmallSize - 1.5
                                        : AppFontSizes.contentSize - 1.0,
                                  ),
                                  textAlign: TextAlign.left,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  //Add Cannabinoid
  void _showAddCannabinoidDialog(BuildContext context, Function(List<Cannabinoid>) callback) {
    final size = MediaQuery.of(context).size;
    _dataCannabinoids.forEach((cannabinoid) {
      cannabinoid.isSelected = false;
      _selectedCannabinoids.forEach((selected) {
        if (cannabinoid.title == selected.title) {
          cannabinoid.isSelected = true;
        }
      });
    });
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
                    padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(30),
                        topRight: Radius.circular(30),
                      ),
                    ),
                    height: 500,
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
                                    ),
                                    onPressed: () {
                                      Navigator.pop(context);
                                    }),
                                Expanded(child: SizedBox()),
                                TextButton(
                                  child: Text(
                                    "Save",
                                    style: TextStyle(color: Colors.white, fontSize: AppFontSizes.buttonSize + 5.0, fontWeight: FontWeight.w500),
                                  ),
                                  onPressed: () {
                                    List<Cannabinoid> _cannabinoidsSelected = [];
                                    _dataCannabinoids.forEach((cannabinoid) {
                                      if (cannabinoid.isSelected) {
                                        _cannabinoidsSelected.add(cannabinoid);
                                      }
                                    });
                                    callback(_cannabinoidsSelected);
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                        Align(
                          alignment: Alignment.center,
                          child: Container(
                            height: 360.0,
                            child: Column(
                              children: [
                                SizedBox(height: size.height * 0.01),
                                Align(
                                    alignment: Alignment.center,
                                    child: Text(
                                      "Select the cannabinoid you would like to add",
                                      style: TextStyle(fontSize: AppFontSizes.contentSize + 1.0, color: Colors.grey[600]),
                                    )),
                                SizedBox(height: size.height * 0.01),
                                Scrollbar(
                                  child: Container(
                                    height: 320.0,
                                    padding: EdgeInsets.symmetric(horizontal: size.width * 0.1),
                                    child: ListView.builder(
                                      scrollDirection: Axis.vertical,
                                      shrinkWrap: true,
                                      itemCount: _dataCannabinoids.length,
                                      itemBuilder: (BuildContext context, int index) {
                                        final cannabinoid = _dataCannabinoids[index];
                                        return Container(
                                          margin: EdgeInsets.only(bottom: size.height * 0.005),
                                          child: Card(
                                            elevation: 3.0,
                                            color: cannabinoid.isSelected ? AppColor.secondaryColor : Colors.white,
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(10.0),
                                            ),
                                            child: InkWell(
                                              child: Container(
                                                height: 40.0,
                                                child: Center(
                                                  child: Text(
                                                    cannabinoid.title!,
                                                    style: TextStyle(
                                                      fontSize: AppFontSizes.contentSize + 1.0,
                                                      color: cannabinoid.isSelected ? Colors.white : AppColor.content,
                                                      fontWeight: FontWeight.w700,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              onTap: () {
                                                setState(() {
                                                  if (cannabinoid.isSelected) {
                                                    cannabinoid.isSelected = false;
                                                  } else {
                                                    cannabinoid.isSelected = true;
                                                  }
                                                });
                                              },
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ),
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

  Widget _initTerpenes(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Column(
      children: [
        SizedBox(height: size.height * 0.01),
        TitleInternalSectionSession(context, "Terpenes", false),
        _addTerpenes
            ? _showAddTerpenes(context)
            : Padding(
                padding: const EdgeInsets.only(top: 10.0),
                child: Material(
                  elevation: 2.0,
                  shadowColor: Colors.grey.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(size.width * 0.025),
                  child: InkWell(
                    child: Container(
                      height: 50.0,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(
                          Radius.circular(size.width * 0.025),
                        ),
                        gradient: AppColor.secondaryGradient,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.5),
                            offset: Offset(0.0, 1.0), //(x,y)
                            blurRadius: 2.0,
                          ),
                        ],
                      ),
                      child: Center(
                        child: Padding(
                          padding: EdgeInsets.only(left: size.width * 0.025, right: size.width * 0.02),
                          child: Stack(
                            children: [
                              Positioned(
                                top: 3.0,
                                left: size.width * 0.025,
                                child: Text(
                                  "Add Terpenes",
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.1),
                                    fontSize: AppFontSizes.buttonSize + 10.0,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ),
                              Positioned(
                                top: 15.0,
                                left: size.width * 0.02,
                                child: Text(
                                  "Add Terpenes",
                                  style: TextStyle(
                                    fontSize: AppFontSizes.buttonSize + 5.0,
                                    color: AppColor.background,
                                    fontWeight: FontWeight.w700,
                                  ),
                                  textScaler: TextScaler.linear(AppFontScales.adaptiveScale),
                                ),
                              ),
                              Positioned(
                                top: 7.5,
                                right: size.width * 0.01,
                                child: Icon(
                                  Icons.add,
                                  size: 35.0,
                                  color: AppColor.background,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    onTap: () {
                      _showAddTerpenesDialog(context, (listTerpenesSelected) {
                        _selectedTerpenes = [];
                        _selectedTerpenes.addAll(listTerpenesSelected);
                        _addTerpenes = true;
                        setState(() {
                          Navigator.pop(context);
                        });
                      });
                    },
                  ),
                ),
              ),
      ],
    );
  }

  _showAddTerpenes(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.only(top: 10.0),
          height: _selectedTerpenes.length * 55.0,
          child: ListView.builder(
            scrollDirection: Axis.vertical,
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: _selectedTerpenes.length,
            itemBuilder: (BuildContext context, int index) {
              final terpene = _selectedTerpenes[index];
              return Container(
                margin: EdgeInsets.only(bottom: size.height * 0.01),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      flex: 2,
                      child: Container(
                        height: 45.0,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(
                            Radius.circular(size.width * 0.025),
                          ),
                          gradient: AppColor.secondaryGradient,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.5),
                              offset: Offset(1.0, 1.0), //(x,y)
                              blurRadius: 1.0,
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            terpene.title!,
                            style: TextStyle(
                              fontSize: AppFontSizes.contentSize,
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Container(
                        height: 45.0,
                        padding: EdgeInsets.only(left: 20.0),
                        child: Material(
                          elevation: 2.0,
                          shadowColor: Colors.grey.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(size.width * 0.025),
                          child: Stack(
                            children: [
                              TextField(
                                controller: terpene.value.isEmpty
                                    ? TextEditingController.fromValue(TextEditingValue())
                                    : TextEditingController.fromValue(TextEditingValue(text: terpene.value)),
                                style: TextStyle(fontSize: AppFontSizes.contentSize, color: AppColor.content),
                                keyboardType: TextInputType.numberWithOptions(signed: true, decimal: true),
                                inputFormatters: [
                                  FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*$')),
                                  LengthLimitingTextInputFormatter(6),
                                  DecimalTextInputFormatter(decimalRange: 2),
                                ],
                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor: Colors.white,
                                  hintStyle: TextStyle(fontSize: AppFontSizes.contentSize - 1.0, color: Colors.grey[400]),
                                  contentPadding: const EdgeInsets.only(top: 5.0, bottom: 5.0, left: 20.0, right: 50.0),
                                  focusedBorder:
                                      OutlineInputBorder(borderSide: BorderSide.none, borderRadius: BorderRadius.circular(size.width * 0.025)),
                                  enabledBorder: UnderlineInputBorder(
                                    borderSide: BorderSide.none,
                                    borderRadius: BorderRadius.circular(size.width * 0.025),
                                  ),
                                ),
                                onChanged: (value) {
                                  terpene.value = value;
                                },
                              ),
                              Positioned(
                                right: 0.0,
                                child: Container(
                                  height: 45.0,
                                  width: 55.0,
                                  padding: EdgeInsets.only(left: 10.0),
                                  child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      _currentSession.activeIngredientsMeasurement!.title!,
                                      style: TextStyle(
                                        color: AppColor.primaryColor,
                                        fontSize: _currentSession.activeIngredientsMeasurement!.title!.length > 5
                                            ? AppFontSizes.contentSmallSize - 1.5
                                            : AppFontSizes.contentSize - 1.0,
                                      ),
                                      textAlign: TextAlign.left,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 10.0),
          child: Material(
            elevation: 2.0,
            shadowColor: Colors.grey.withOpacity(0.5),
            borderRadius: BorderRadius.circular(size.width * 0.025),
            child: InkWell(
              child: Container(
                height: 50.0,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(
                    Radius.circular(size.width * 0.025),
                  ),
                  gradient: AppColor.secondaryGradient,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      offset: Offset(0.0, 1.0), //(x,y)
                      blurRadius: 2.0,
                    ),
                  ],
                ),
                child: Center(
                  child: Padding(
                    padding: EdgeInsets.only(left: size.width * 0.025, right: size.width * 0.02),
                    child: Stack(
                      children: [
                        Positioned(
                          top: 3.0,
                          left: size.width * 0.025,
                          child: Text(
                            "Add Terpenes",
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.1),
                              fontSize: AppFontSizes.buttonSize + 10.0,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                        Positioned(
                          top: 15.0,
                          left: size.width * 0.02,
                          child: Text(
                            "Add Terpenes",
                            style: TextStyle(
                              fontSize: AppFontSizes.buttonSize + 5.0,
                              color: AppColor.background,
                              fontWeight: FontWeight.w700,
                            ),
                            textScaler: TextScaler.linear(AppFontScales.adaptiveScale),
                          ),
                        ),
                        Positioned(
                          top: 7.5,
                          right: size.width * 0.01,
                          child: Icon(
                            Icons.add,
                            size: 35.0,
                            color: AppColor.background,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              onTap: () {
                _showAddTerpenesDialog(context, (listTerpenesSelected) {
                  _selectedTerpenes = [];
                  _selectedTerpenes.addAll(listTerpenesSelected);
                  _addTerpenes = true;
                  setState(() {
                    Navigator.pop(context);
                  });
                });
              },
            ),
          ),
        ),
      ],
    );
  }

  //Add Terpenes
  void _showAddTerpenesDialog(BuildContext context, Function(List<Terpene>) callback) {
    final size = MediaQuery.of(context).size;
    _dataTerpenes.forEach((terpene) {
      terpene.isSelected = false;
      _selectedTerpenes.forEach((selected) {
        if (terpene.title == selected.title) {
          terpene.isSelected = true;
        }
      });
    });
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
                    padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(30),
                        topRight: Radius.circular(30),
                      ),
                    ),
                    height: 500,
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
                                    ),
                                    onPressed: () {
                                      Navigator.pop(context);
                                    }),
                                Expanded(child: SizedBox()),
                                TextButton(
                                  child: Text(
                                    "Save",
                                    style: TextStyle(color: Colors.white, fontSize: AppFontSizes.buttonSize + 5.0, fontWeight: FontWeight.w500),
                                  ),
                                  onPressed: () {
                                    List<Terpene> _terpenesSelected = [];
                                    _dataTerpenes.forEach((terpene) {
                                      if (terpene.isSelected) {
                                        _terpenesSelected.add(terpene);
                                      }
                                    });
                                    callback(_terpenesSelected);
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                        Align(
                          alignment: Alignment.center,
                          child: Container(
                            height: 360.0,
                            child: Column(
                              children: [
                                SizedBox(height: size.height * 0.01),
                                Align(
                                    alignment: Alignment.center,
                                    child: Text(
                                      "Select the terpene you would like to add",
                                      style: TextStyle(fontSize: AppFontSizes.contentSize + 1.0, color: Colors.grey[600]),
                                    )),
                                SizedBox(height: size.height * 0.01),
                                Scrollbar(
                                  child: Container(
                                    height: 320.0,
                                    padding: EdgeInsets.symmetric(horizontal: size.width * 0.1),
                                    child: ListView.builder(
                                      scrollDirection: Axis.vertical,
                                      shrinkWrap: true,
                                      itemCount: _dataTerpenes.length,
                                      itemBuilder: (BuildContext context, int index) {
                                        final terpene = _dataTerpenes[index];
                                        return Container(
                                          margin: EdgeInsets.only(bottom: size.height * 0.005),
                                          child: Card(
                                            elevation: 3.0,
                                            color: terpene.isSelected ? AppColor.secondaryColor : Colors.white,
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(10.0),
                                            ),
                                            child: InkWell(
                                              child: Container(
                                                height: 40.0,
                                                child: Center(
                                                  child: Text(
                                                    terpene.title!,
                                                    style: TextStyle(
                                                      fontSize: AppFontSizes.contentSize + 1.0,
                                                      color: terpene.isSelected ? Colors.white : AppColor.content,
                                                      fontWeight: FontWeight.w700,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              onTap: () {
                                                setState(() {
                                                  if (terpene.isSelected) {
                                                    terpene.isSelected = false;
                                                    terpene.value = '';
                                                  } else {
                                                    terpene.isSelected = true;
                                                  }
                                                });
                                              },
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ),
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

  Card buildSessionCard(BuildContext context, Session currentSession) {
    final size = MediaQuery.of(context).size;
    return Card(
      elevation: 5.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(size.width * 0.05),
      ),
      child: Container(
        height: valueHeightCard(size, currentSession),
        decoration: BoxDecoration(gradient: AppColor.primaryGradient, borderRadius: BorderRadius.circular(size.width * 0.05)),
        child: Padding(
          padding: EdgeInsets.only(
            top: size.height * 0.012,
            left: size.width * 0.03,
            right: size.width * 0.03,
          ),
          child: Column(
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        "Session Info.",
                        style: TextStyle(
                          fontSize: AppFontSizes.subTitleSize,
                          color: AppColor.fifthColor,
                          fontFamily: AppFont.primaryFont,
                        ),
                        textScaler: TextScaler.linear(AppFontScales.adaptiveScale),
                      ),
                      Expanded(child: Container()),
                      Text(
                        DateFormat('MM/dd/yyyy').format(DateTime.now()),
                        style: TextStyle(
                          fontSize: AppFontSizes.contentSmallSize,
                          color: AppColor.background,
                          fontFamily: AppFont.primaryFont,
                        ),
                        textScaler: TextScaler.linear(AppFontScales.adaptiveScale),
                      ),
                    ],
                  ),
                  Divider(
                    height: size.width * 0.05,
                    thickness: 2,
                    color: AppColor.fifthColor.withOpacity(0.75),
                  ),
                ],
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  primaryConditionsCard(size, _sessionPrimaryConditions),
                  SizedBox(
                    height: size.height * 0.12,
                    child: VerticalDivider(
                      width: size.width * 0.05,
                      thickness: 2,
                      color: AppColor.thirdColor.withOpacity(0.5),
                      indent: size.height * 0.025,
                    ),
                  ),
                  infoConditionsCard(size, _sessionSecondaryConditions),
                ],
              ),
              SizedBox(height: size.height * 0.01),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  productTypeCard(size, currentSession.productType!),
                  SizedBox(
                    height: size.height * 0.12,
                    child: VerticalDivider(
                      width: size.width * 0.05,
                      thickness: 2,
                      color: AppColor.thirdColor.withOpacity(0.6),
                      indent: size.height * 0.025,
                    ),
                  ),
                  infoProductTypeCard(size, _currentSession.deliveryMethodType!.title, _currentSession.strainType!.title!),
                ],
              ),
              SizedBox(height: size.height * 0.01),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  strainCard(size, currentSession.strainType),
                  SizedBox(
                    height: size.height * 0.12,
                    child: VerticalDivider(
                      width: size.width * 0.05,
                      thickness: 2,
                      color: AppColor.thirdColor.withOpacity(0.8),
                      indent: size.height * 0.025,
                    ),
                  ),
                  infoProductCard(size, _currentSession.productBrand!, _currentSession.productName!, _currentSession.temperature!,
                      _currentSession.temperatureMeasurement!.title), //36-°C
                ],
              ),
              SizedBox(height: size.height * 0.01),
              currentSession.cannabinoids!.length > 0
                  ? activeIngredientsCard(size, currentSession.cannabinoids!, currentSession.activeIngredientsMeasurement!.title, false)
                  : Container(),
              currentSession.terpenes!.length > 0
                  ? terpenesCard(size, currentSession.terpenes!, currentSession.activeIngredientsMeasurement!.title, false)
                  : Container(),
              // currentSession.sessionNote.length > 0 ? noteCard(size, currentSession.sessionNote) : Container(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _initContinueButton(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return InkWell(
      child: Container(
        height: 60.0,
        margin: EdgeInsets.only(
          left: size.width * 0.01,
          right: size.width * 0.01,
          top: size.height * 0.02,
          bottom: size.height * 0.03,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(
            Radius.circular(15),
          ),
          gradient: AppColor.secondaryGradient,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.7),
              offset: Offset(0.0, 1.0),
              blurRadius: 5.0,
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: size.width * 0.05),
          child: Row(
            children: [
              Text(
                "Complete",
                style: TextStyle(
                  fontSize: AppFontSizes.buttonSize + 10.0,
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                ),
                textScaler: TextScaler.linear(AppFontScales.adaptiveScale),
              ),
              Expanded(child: Container()),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: AppFontSizes.buttonSize + 10.0,
                color: Colors.white,
              ),
            ],
          ),
        ),
      ),
      onTap: () {
        _continue(context);
      },
    );
  }

  _loadUserPreferences() {
    _prefs.primaryConditions.forEach((condition) {
      Map<String, dynamic> temp = jsonDecode(condition);
      Condition tempCondition = Condition.fromJson(temp);
      _sessionPrimaryConditions.add(tempCondition);
    });
    _prefs.secondaryConditions.forEach((condition) {
      Map<String, dynamic> temp = jsonDecode(condition);
      Condition tempCondition = Condition.fromJson(temp);
      _sessionSecondaryConditions.add(tempCondition);
    });
  }

  _loadLumirProducts(BuildContext context) async {
    ProgressDialog progressDialog = ProgressDialog(context);
    progressDialog.show();
    Map infoResponse = await inventoryServices.lumirProductList();
    if (infoResponse['ok']) {
      setState(() {
        _lumir_productList = [];
        final productsResult = infoResponse['products'] ?? [];
        productsResult.forEach((product) {
          LumirProduct tempProduct = LumirProduct.fromJson(product);
          _lumir_productList.add(tempProduct);
        });
      });
      progressDialog.dismiss();
    } else {
      _lumir_productList = [];
      progressDialog.dismiss();
      showAlertMessage(context, "Lumir Product not found", () {
        Navigator.pop(context);
      });
    }
  }

  Widget _initLumirProducts(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Column(
      children: [
        TitleInternalSectionSession(context, "Lumir Product", true),
        SizedBox(height: size.height * 0.01),
        Stack(
          children: [
            Container(
              height: size.height * 0.55,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                shrinkWrap: true,
                itemCount: _lumir_productList.length,
                itemBuilder: (BuildContext context, int index) {
                  final product = _lumir_productList[index];
                  return Stack(
                    children: [
                      InkWell(
                        child: Container(
                          width: size.width * 0.74,
                          margin: EdgeInsets.only(right: size.width * 0.015),
                          decoration: BoxDecoration(
                            gradient: product.isSelected ? AppColor.secondaryGradient : AppColor.primaryGradient,
                            borderRadius: BorderRadius.circular(size.width * 0.05),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.5),
                                offset: Offset(1.0, 1.0), //(x,y)
                                blurRadius: 1.0,
                              ),
                            ],
                          ),
                          child: Stack(
                            children: [
                              Positioned(
                                top: 0.0,
                                right: -10.0,
                                child: Image.network(
                                  AppLogos.iconImg,
                                  opacity: const AlwaysStoppedAnimation(0.2),
                                  // color: Colors.white.withOpacity(0.2),
                                  width: size.width * 0.45,
                                  fit: BoxFit.contain,
                                ),
                              ),
                              Container(
                                margin: EdgeInsets.symmetric(vertical: size.width * 0.025, horizontal: size.width * 0.02),
                                child: Column(children: [
                                  SizedBox(height: size.height * 0.005),
                                  lumirProductCardName(product.name!),
                                  SizedBox(height: size.height * 0.0025),
                                  lumirProductCardDescription(product.description!),
                                  SizedBox(height: size.height * 0.005),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: lumirProductCardProductType(product.productType!),
                                      ),
                                      Expanded(
                                          child: Container(
                                        height: size.height * 0.12,
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.start,
                                          children: [
                                            lumirProductDeliveryMethod(product.deliveryMethod!),
                                            SizedBox(height: size.height * 0.0075),
                                            lumirProductCardStrain(product.strain!),
                                          ],
                                        ),
                                      )),
                                      Expanded(child: lumirProductCardStrainType(product.specie!)),
                                    ],
                                  ),
                                  SizedBox(height: size.height * 0.005),
                                  Row(
                                    children: [
                                      Expanded(child: lumirProductCardOrigin(product.origin!)),
                                      Expanded(child: lumirProductCardSize(product.size!)),
                                      Expanded(child: lumirProductCardIngredientUnit(product.ingredientUnit!)),
                                    ],
                                  ),
                                  SizedBox(height: size.height * 0.005),
                                  lumirProductCardCannabinoid(product.cannabinoids!, product.ingredientUnit)
                                ]),
                              ),
                            ],
                          ),
                        ),
                        onTap: () {
                          setState(() {
                            if (product.isSelected) {
                              product.isSelected = false;
                              _currentSession.productBrand = '';
                              _currentSession.productName = '';
                              _currentSession.productType = ProductType(title: '');
                              _currentSession.deliveryMethodType = DeliveryMethod(title: '');
                              _currentSession.strainType = StrainType(title: '');
                              _currentSession.origin = '';
                              _currentSession.size = '';
                              _currentSession.activeIngredientsMeasurement = Measurement(title: '');
                              _currentSession.cannabinoids = [];
                            } else {
                              _lumir_productList.forEach((p) {
                                p.isSelected = false;
                              });
                              product.isSelected = true;
                              _currentSession.productBrand = "Lumir";
                              _currentSession.productName = product.name;
                              _currentSession.productType = ProductType(title: product.productType, icon: product.productType!.toLowerCase());
                              _currentSession.deliveryMethodType = DeliveryMethod(title: product.deliveryMethod);
                              _currentSession.strainType = StrainType(title: product.specie, icon: product.specie!.toUpperCase()[0]);
                              _currentSession.origin = product.origin;
                              _currentSession.size = product.size;
                              _currentSession.activeIngredientsMeasurement = AppData().lumirDoseMeasurement(product.ingredientUnit);
                              _currentSession.doseMeasurement = AppData().lumirDoseMeasurement(product.ingredientUnit);
                              _currentSession.cannabinoids = product.cannabinoids;
                            }
                          });
                        },
                      ),
                    ],
                  );
                },
              ),
            ),
            // Positioned(
            //   right: 0.0,
            //   child: Container(
            //     decoration: BoxDecoration(
            //       color: AppColor.primaryColor.withOpacity(0.3),
            //       borderRadius: BorderRadius.only(
            //         topLeft: Radius.circular(25.0),
            //         bottomLeft: Radius.circular(25.0),
            //       ),
            //     ),
            //     height: 130.0,
            //     width: size.width * 0.07,
            //     child: Center(
            //       child: Image(
            //         color: AppColor.background.withOpacity(0.8),
            //         width: 15.0,
            //         image: AssetImage('assets/img/icon_arrowButton.png'),
            //         fit: BoxFit.contain,
            //       ),
            //     ),
            //   ),
            // ),
          ],
        ),
      ],
    );
  }

  Column lumirProductCardName(String productName) {
    final size = MediaQuery.of(context).size;
    return Column(
      children: [
        Container(
          alignment: Alignment.centerLeft,
          padding: EdgeInsets.only(bottom: 2.0),
          child: Text(
            "Product",
            style: TextStyle(fontSize: AppFontSizes.contentSmallSize, color: AppColor.fourthColor, fontWeight: FontWeight.w600),
          ),
        ),
        Container(
          alignment: Alignment.center,
          height: size.height * 0.05,
          child: Stack(
            children: [
              Container(
                alignment: Alignment.center,
                margin: EdgeInsets.symmetric(horizontal: 5.0),
                padding: EdgeInsets.all(5.0),
                decoration: BoxDecoration(color: AppColor.thirdColor.withOpacity(0.3), borderRadius: BorderRadius.circular(12.0)),
                child: Center(
                  child: Text(
                    productName,
                    style: TextStyle(color: Colors.white, fontSize: AppFontSizes.contentSize + 1.0, fontWeight: FontWeight.w600),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              Positioned(
                top: size.height * 0.007,
                child: Image(
                  color: AppColor.fifthColor,
                  width: size.width * 0.03,
                  image: AssetImage('assets/img/icon_arrow.png'),
                  fit: BoxFit.contain,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Column lumirProductCardDescription(String productDescription) {
    final size = MediaQuery.of(context).size;
    return Column(
      children: [
        Container(
          alignment: Alignment.centerLeft,
          padding: EdgeInsets.symmetric(vertical: 2.0),
          child: Text(
            "Description",
            style: TextStyle(fontSize: AppFontSizes.contentSmallSize, color: AppColor.fourthColor, fontWeight: FontWeight.w600),
          ),
        ),
        Container(
          alignment: Alignment.center,
          height: size.height * 0.12,
          child: Stack(
            children: [
              Container(
                alignment: Alignment.center,
                margin: EdgeInsets.symmetric(horizontal: 5.0),
                padding: EdgeInsets.all(5.0),
                decoration: BoxDecoration(color: AppColor.thirdColor.withOpacity(0.3), borderRadius: BorderRadius.circular(12.0)),
                child: Center(
                  child: Text(
                    productDescription,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: AppFontSizes.contentSmallSize,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              Positioned(
                top: size.height * 0.007,
                child: Image(
                  color: AppColor.fifthColor,
                  width: size.width * 0.03,
                  image: AssetImage('assets/img/icon_arrow.png'),
                  fit: BoxFit.contain,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Column lumirProductCardProductType(String productType) {
    final size = MediaQuery.of(context).size;
    return Column(
      children: [
        Container(
          alignment: Alignment.centerLeft,
          padding: EdgeInsets.symmetric(vertical: 2.0),
          child: Text(
            "Product Type",
            style: TextStyle(fontSize: AppFontSizes.contentSmallSize, color: AppColor.fourthColor, fontWeight: FontWeight.w600),
          ),
        ),
        Container(
          alignment: Alignment.center,
          height: size.height * 0.1,
          child: Stack(
            children: [
              Container(
                width: size.width * 0.17,
                alignment: Alignment.center,
                margin: EdgeInsets.symmetric(horizontal: 5.0),
                padding: EdgeInsets.all(5.0),
                decoration: BoxDecoration(color: AppColor.thirdColor.withOpacity(0.3), borderRadius: BorderRadius.circular(12.0)),
                child: Center(
                  child: Column(
                    children: [
                      Image(
                        color: AppColor.background,
                        height: 45.0,
                        width: size.width * 0.1,
                        image: AssetImage('assets/img/medication/${AppData().iconProductType(productType)}'),
                        fit: BoxFit.contain,
                      ),
                      SizedBox(height: 5.0),
                      Text(
                        productType,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: AppFontSizes.contentSmallSize - 0.25,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                top: size.height * 0.007,
                child: Image(
                  color: AppColor.fifthColor,
                  width: size.width * 0.03,
                  image: AssetImage('assets/img/icon_arrow.png'),
                  fit: BoxFit.contain,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Column lumirProductCardStrainType(String productSpecie) {
    final size = MediaQuery.of(context).size;
    return Column(
      children: [
        Container(
          alignment: Alignment.centerLeft,
          padding: EdgeInsets.symmetric(vertical: 2.0),
          child: Text(
            "Strain Type",
            style: TextStyle(fontSize: AppFontSizes.contentSmallSize, color: AppColor.fourthColor, fontWeight: FontWeight.w600),
          ),
        ),
        Container(
          alignment: Alignment.center,
          height: size.height * 0.1,
          child: Stack(
            children: [
              Container(
                width: size.width * 0.17,
                alignment: Alignment.center,
                margin: EdgeInsets.symmetric(horizontal: 5.0),
                padding: EdgeInsets.all(5.0),
                decoration: BoxDecoration(color: AppColor.thirdColor.withOpacity(0.3), borderRadius: BorderRadius.circular(12.0)),
                child: Center(
                  child: Column(
                    children: [
                      Container(
                          child: Center(
                        child: Text(
                          productSpecie == 'unknown' ? '-' : productSpecie.toString().toUpperCase()[0],
                          style: TextStyle(color: AppColor.background, fontSize: 35.0, fontFamily: "Poppins", fontWeight: FontWeight.w700),
                        ),
                      )),
                      SizedBox(height: 5.0),
                      Text(
                        productSpecie,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: AppFontSizes.contentSmallSize,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                top: size.height * 0.007,
                child: Image(
                  color: AppColor.fifthColor,
                  width: size.width * 0.03,
                  image: AssetImage('assets/img/icon_arrow.png'),
                  fit: BoxFit.contain,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Column lumirProductCardStrain(String productStrain) {
    final size = MediaQuery.of(context).size;
    return Column(
      children: [
        Container(
          alignment: Alignment.centerLeft,
          padding: EdgeInsets.symmetric(vertical: 2.0),
          child: Text(
            "Strain",
            style: TextStyle(fontSize: AppFontSizes.contentSmallSize, color: AppColor.fourthColor, fontWeight: FontWeight.w600),
          ),
        ),
        Container(
          alignment: Alignment.center,
          child: Stack(
            children: [
              Container(
                alignment: Alignment.center,
                margin: EdgeInsets.symmetric(horizontal: 5.0),
                padding: EdgeInsets.all(5.0),
                decoration: BoxDecoration(color: AppColor.thirdColor.withOpacity(0.3), borderRadius: BorderRadius.circular(5.0)),
                child: Center(
                  child: Text(
                    productStrain,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: AppFontSizes.contentSmallSize,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              Positioned(
                top: size.height * 0.005,
                child: Image(
                  color: AppColor.fifthColor,
                  width: size.width * 0.03,
                  image: AssetImage('assets/img/icon_arrow.png'),
                  fit: BoxFit.contain,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Column lumirProductDeliveryMethod(String productDeliveryMethod) {
    final size = MediaQuery.of(context).size;
    return Column(
      children: [
        Container(
          alignment: Alignment.centerLeft,
          padding: EdgeInsets.symmetric(vertical: 2.0),
          child: Text(
            "Delivery Method",
            style: TextStyle(fontSize: AppFontSizes.contentSmallSize, color: AppColor.fourthColor, fontWeight: FontWeight.w600),
          ),
        ),
        Container(
          alignment: Alignment.center,
          child: Stack(
            children: [
              Container(
                alignment: Alignment.center,
                margin: EdgeInsets.symmetric(horizontal: 5.0),
                padding: EdgeInsets.all(5.0),
                decoration: BoxDecoration(color: AppColor.thirdColor.withOpacity(0.3), borderRadius: BorderRadius.circular(5.0)),
                child: Center(
                  child: Text(
                    productDeliveryMethod,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: AppFontSizes.contentSmallSize + 1.0,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              Positioned(
                top: size.height * 0.005,
                child: Image(
                  color: AppColor.fifthColor,
                  width: size.width * 0.03,
                  image: AssetImage('assets/img/icon_arrow.png'),
                  fit: BoxFit.contain,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Column lumirProductCardOrigin(String productOrigin) {
    final size = MediaQuery.of(context).size;
    return Column(
      children: [
        Container(
          alignment: Alignment.centerLeft,
          padding: EdgeInsets.symmetric(vertical: 2.0),
          child: Text(
            "Origin",
            style: TextStyle(fontSize: AppFontSizes.contentSmallSize, color: AppColor.fourthColor, fontWeight: FontWeight.w600),
          ),
        ),
        Container(
          alignment: Alignment.center,
          child: Stack(
            children: [
              Container(
                alignment: Alignment.center,
                margin: EdgeInsets.symmetric(horizontal: 5.0),
                padding: EdgeInsets.all(5.0),
                decoration: BoxDecoration(color: AppColor.thirdColor.withOpacity(0.3), borderRadius: BorderRadius.circular(5.0)),
                child: Center(
                  child: Text(
                    productOrigin,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: AppFontSizes.contentSmallSize + 1.0,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              Positioned(
                top: size.height * 0.005,
                child: Image(
                  color: AppColor.fifthColor,
                  width: size.width * 0.03,
                  image: AssetImage('assets/img/icon_arrow.png'),
                  fit: BoxFit.contain,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Column lumirProductCardSize(String productSize) {
    final size = MediaQuery.of(context).size;
    return Column(
      children: [
        Container(
          alignment: Alignment.centerLeft,
          padding: EdgeInsets.symmetric(vertical: 2.0),
          child: Text(
            "Size (ml/g)",
            style: TextStyle(fontSize: AppFontSizes.contentSmallSize, color: AppColor.fourthColor, fontWeight: FontWeight.w600),
          ),
        ),
        Container(
          alignment: Alignment.center,
          child: Stack(
            children: [
              Container(
                alignment: Alignment.center,
                margin: EdgeInsets.symmetric(horizontal: 5.0),
                padding: EdgeInsets.all(5.0),
                decoration: BoxDecoration(color: AppColor.thirdColor.withOpacity(0.3), borderRadius: BorderRadius.circular(5.0)),
                child: Center(
                  child: Text(
                    productSize,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: AppFontSizes.contentSmallSize + 1.0,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              Positioned(
                top: size.height * 0.007,
                child: Image(
                  color: AppColor.fifthColor,
                  width: size.width * 0.03,
                  image: AssetImage('assets/img/icon_arrow.png'),
                  fit: BoxFit.contain,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Column lumirProductCardIngredientUnit(String productUnit) {
    final size = MediaQuery.of(context).size;
    return Column(
      children: [
        Container(
          alignment: Alignment.centerLeft,
          padding: EdgeInsets.symmetric(vertical: 2.0),
          child: Text(
            "Ingredient Unit",
            style: TextStyle(fontSize: AppFontSizes.contentSmallSize, color: AppColor.fourthColor, fontWeight: FontWeight.w600),
          ),
        ),
        Container(
          alignment: Alignment.center,
          child: Stack(
            children: [
              Container(
                alignment: Alignment.center,
                margin: EdgeInsets.symmetric(horizontal: 5.0),
                padding: EdgeInsets.all(5.0),
                decoration: BoxDecoration(color: AppColor.thirdColor.withOpacity(0.3), borderRadius: BorderRadius.circular(5.0)),
                child: Center(
                  child: Text(
                    productUnit,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: AppFontSizes.contentSmallSize + 1.0,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              Positioned(
                top: size.height * 0.007,
                child: Image(
                  color: AppColor.fifthColor,
                  width: size.width * 0.03,
                  image: AssetImage('assets/img/icon_arrow.png'),
                  fit: BoxFit.contain,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Column lumirProductCardCannabinoid(List<Cannabinoid> cannabinoids, String? measurement) {
    final size = MediaQuery.of(context).size;
    return Column(
      children: [
        Container(
          alignment: Alignment.centerLeft,
          padding: EdgeInsets.symmetric(vertical: 2.0),
          child: Text(
            "Active Ingredients", //"Cannabinoid",
            style: TextStyle(fontSize: AppFontSizes.contentSmallSize, color: AppColor.fourthColor, fontWeight: FontWeight.w600),
          ),
        ),
        Container(
          height: size.height * 0.08,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            shrinkWrap: true,
            physics: cannabinoids.length >= 3 ? ScrollPhysics() : NeverScrollableScrollPhysics(),
            itemCount: cannabinoids.length,
            itemBuilder: (BuildContext context, int index) {
              final cannabinoid = cannabinoids[index];
              return Stack(
                children: [
                  Container(
                    width: cannabinoids.length >= 4 ? size.width * 0.18 : size.width * 0.191,
                    margin: EdgeInsets.symmetric(horizontal: 5.0),
                    padding: EdgeInsets.all(5.0),
                    decoration: BoxDecoration(
                      color: AppColor.thirdColor.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            cannabinoid.title!,
                            style: TextStyle(
                              color: AppColor.background,
                              fontSize: AppFontSizes.contentSize + 1.0,
                              fontWeight: FontWeight.w700,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 2.5),
                          Text(
                            cannabinoid.value == "-" ? "-" : "${cannabinoid.value}",
                            style: TextStyle(
                              fontSize: AppFontSizes.contentSize - 1.0,
                              color: AppColor.background,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          Text(
                            cannabinoid.value == "-" ? "" : "$measurement",
                            style: TextStyle(
                              fontSize: AppFontSizes.contentSmallSize,
                              color: AppColor.background,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    top: size.height * 0.007,
                    child: Image(
                      color: AppColor.fifthColor,
                      width: size.width * 0.03,
                      image: AssetImage('assets/img/icon_arrow.png'),
                      fit: BoxFit.contain,
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  loadProducts(BuildContext context, String product) async {
    ProgressDialog progressDialog = ProgressDialog(context);
    progressDialog.show();
    Map infoResponse = await inventoryServices.productList(product);
    if (infoResponse['ok']) {
      setState(() {
        _foundProductList = true;
        _productList = [];
        final productsResult = infoResponse['products'] ?? [];
        productsResult.forEach((product) {
          Product tempProduct = Product.fromJson(product);
          _productList.add(tempProduct);
        });
        progressDialog.dismiss();
      });
    } else {
      _foundProductList = false;
      _productList = [];
      progressDialog.dismiss();
      showAlertMessage(context, "Product not found", () {
        Navigator.pop(context);
      });
    }
  }

  bool _validateSession() {
    if (_sessionPrimaryConditions.length <= 0) {
      showAlertMessage(context, "Please select your conditions", () {
        Navigator.pop(context);
      });
      return false;
    }
    // else if (_sessionSecondaryConditions.length <= 0) {
    //   showAlertMessage(context, "Please select your secondary conditions", () {
    //     Navigator.pop(context);
    //   });
    //   return false;
    // }
    return true;
  }

  _continue(BuildContext context) {
    if (_validateSession()) {
      Navigator.pushNamed(context, 'session_start', arguments: _currentSession);
    }
  }

  _clearSetupSession() {
    this._sessionPrimaryConditions.forEach((condition) {
      condition.isSelected = false;
    });
    this._sessionSecondaryConditions.forEach((condition) {
      condition.isSelected = false;
    });

    _lumir_productList = [];

    _dataProductTypes.forEach((productType) {
      productType.isSelected = false;
    });

    _dataDeliveryMethods.forEach((deliveryMethod) {
      deliveryMethod.isSelected = false;
    });

    _dataStrainTypes.forEach((strain) {
      strain.isSelected = false;
    });

    _foundProductController.text = "";

    _currentSession.productBrand = "";
    _productBrandController.text = "";

    _currentSession.productName = "";
    _productNameController.text = "";

    _dataMeasurements.forEach((measurement) {
      measurement.isSelected = false;
    });

    _currentSession.temperatureMeasurement = Measurement(title: "");
    _temperatureController.text = "";
    _tempF = false;
    _tempC = false;

    _currentSession.activeIngredientsMeasurement = Measurement(title: "");

    _thcController.text = "";
    _cbdController.text = "";
    _cannabinoidsController = [];
    _selectedCannabinoids = [];
    _selectedTerpenes = [];
    _addCannabinoid = false;
    _addTerpenes = false;
  }
}

class DecimalTextInputFormatter extends TextInputFormatter {
  DecimalTextInputFormatter({this.decimalRange}) : assert(decimalRange == null || decimalRange > 0);

  final int? decimalRange;

  get math => null;

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue, // unused.
    TextEditingValue newValue,
  ) {
    TextSelection newSelection = newValue.selection;
    String truncated = newValue.text;

    if (decimalRange != null) {
      String value = newValue.text;

      if (value.contains(".") && value.substring(value.indexOf(".") + 1).length > decimalRange!) {
        truncated = oldValue.text;
        newSelection = oldValue.selection;
      } else if (value == ".") {
        truncated = "0.";

        newSelection = newValue.selection.copyWith(
          baseOffset: math.min(truncated.length, truncated.length + 1),
          extentOffset: math.min(truncated.length, truncated.length + 1),
        );
      }

      return TextEditingValue(
        text: truncated,
        selection: newSelection,
        composing: TextRange.empty,
      );
    }
    return newValue;
  }
}
