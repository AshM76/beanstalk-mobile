import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:beanstalk_mobile/src/datas/app_data.dart';
import 'package:beanstalk_mobile/src/models/canna_medication_model.dart';
import 'package:beanstalk_mobile/src/preferences/user_preference.dart';
import 'package:beanstalk_mobile/src/ui/app_skin.dart';
import 'package:beanstalk_mobile/src/utils/utils.dart';

import 'package:beanstalk_mobile/src/widgets/onboarding/backButton_widget.dart';
import 'package:beanstalk_mobile/src/widgets/onboarding/nextButton_widget.dart';
import 'package:beanstalk_mobile/src/widgets/onboarding/titleForm_widget.dart';

import 'package:beanstalk_mobile/src/widgets/onboarding/backgroundPaint_widget.dart';
import 'package:beanstalk_mobile/src/widgets/onboarding/actionCardMedication_widget.dart';

class OnboardingMedicationPage extends StatefulWidget {
  @override
  _OnboardingMedicationPageState createState() => _OnboardingMedicationPageState();
}

class _OnboardingMedicationPageState extends State<OnboardingMedicationPage> {
  final _prefs = new UserPreference();

  Medication _smokeMedication = Medication(
      title: "Smoke",
      description: "Smoking the dried flower from the cannabis plant in a pipe, bong, or joint is a common method of consumption.",
      icon: "icon_smoke.png",
      preference: "",
      experience: "",
      isSelected: false);
  Medication _vapeMedication = Medication(
      title: "Vape",
      description: "Vaporizers heat cannabis plant matter (or its oil) to a temperature that creates a smokeless, efficient form of inhalation. ",
      icon: "icon_vape.png",
      preference: "",
      experience: "",
      isSelected: false);
  Medication _ediblesMedication = Medication(
      title: "Edibles",
      description:
          "Edibles are ingested through the digestive system, by way of the liver, and can come in many forms, including capsules, gummies, drinks, snacks, choclates or mints.",
      icon: "icon_edibles.png",
      preference: "",
      experience: "",
      isSelected: false);
  Medication _tincturesMedication = Medication(
      title: "Tinctures",
      description: "Tinctures are liquids, usually delivered via droppers, absorbed under the tongue, so the cannabinoids are absorbed more quickly.",
      icon: "icon_tinctures.png",
      preference: "",
      experience: "",
      isSelected: false);
  Medication _dabbingMedication = Medication(
      title: "Dabbing",
      description:
          "Heating a small amount of cannabis concentrate (called a ‘dab’) on the head of a titanium nail with a blowtorch, causing combustion.",
      icon: "icon_dab.png",
      preference: "",
      experience: "",
      isSelected: false);
  Medication _topicalMedication = Medication(
      title: "Topical",
      description: "Lotions, balms or salves that are absorbed into the skin for more focused therapeutic effects.",
      icon: "icon_topical.png",
      preference: "",
      experience: "",
      isSelected: false);

  bool _selectedPreferenceLoveIt = false;
  bool _selectedPreferenceLikeIt = false;
  bool _selectedPreferenceItsOk = false;

  bool _selectedExperienceBeginner = false;
  bool _selectedExperienceAlot = false;
  bool _selectedExperienceAlittle = false;
  bool _selectedExperienceExpert = false;

  List<Medication> medications = [];

  @override
  void initState() {
    super.initState();
    () async {
      await Future.delayed(Duration.zero);
      _updateMedications();
    }();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Stack(
      children: <Widget>[
        initBackgroundPaint(context),
        _initProfileDataForm(context),
        backButton(context),
      ],
    ));
  }

  Widget _initProfileDataForm(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 30.0),
      child: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: size.height * 0.04),
              initTitle("About You"),
              _initMedication(),
              SizedBox(height: size.height * 0.02),
              initNextButton(context, () {
                _next(context);
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _initMedication() {
    final size = MediaQuery.of(context).size;
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 250,
                child: Text(
                  "Which consumption method have you tried?",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: AppFontSizes.subTitleSize + 2.5,
                  ),
                  textAlign: TextAlign.left,
                  textScaler: TextScaler.linear(AppFontScales.adaptiveScale),
                ),
              ),
              SizedBox(height: 7.5),
              Container(
                width: 250,
                child: Text(
                  "(Select at least one)",
                  style: TextStyle(color: Colors.white, fontSize: AppFontSizes.contentSmallSize, fontWeight: FontWeight.w300),
                  textAlign: TextAlign.left,
                  textScaler: TextScaler.linear(AppFontScales.adaptiveScale),
                ),
              ),
            ],
          ),
          Container(
            padding: EdgeInsets.symmetric(vertical: size.width * 0.05, horizontal: size.width * 0.05),
            child: Column(
              children: [
                Row(
                  children: [
                    ActionCardMedication(_smokeMedication, () {
                      setState(() {
                        if (_smokeMedication.isSelected) {
                          _smokeMedication.isSelected = false;
                          _smokeMedication.preference = '';
                          _smokeMedication.experience = '';
                          medications.removeWhere((medication) => medication.title == _smokeMedication.title);
                        } else {
                          _showMedicationSheet(_smokeMedication);
                        }
                      });
                    }),
                    SizedBox(width: size.width * 0.025),
                    ActionCardMedication(_vapeMedication, () {
                      setState(() {
                        if (_vapeMedication.isSelected) {
                          _vapeMedication.isSelected = false;
                          _vapeMedication.preference = '';
                          _vapeMedication.experience = '';
                          medications.removeWhere((medication) => medication.title == _vapeMedication.title);
                        } else {
                          _showMedicationSheet(_vapeMedication);
                        }
                      });
                    })
                  ],
                ),
                SizedBox(height: size.height * 0.01),
                Row(
                  children: [
                    ActionCardMedication(_ediblesMedication, () {
                      setState(() {
                        if (_ediblesMedication.isSelected) {
                          _ediblesMedication.isSelected = false;
                          _ediblesMedication.preference = '';
                          _ediblesMedication.experience = '';
                          medications.removeWhere((medication) => medication.title == _ediblesMedication.title);
                        } else {
                          _showMedicationSheet(_ediblesMedication);
                        }
                      });
                    }),
                    SizedBox(width: size.width * 0.025),
                    ActionCardMedication(_tincturesMedication, () {
                      setState(() {
                        if (_tincturesMedication.isSelected) {
                          _tincturesMedication.isSelected = false;
                          _tincturesMedication.preference = '';
                          _tincturesMedication.experience = '';
                          medications.removeWhere((medication) => medication.title == _tincturesMedication.title);
                        } else {
                          _showMedicationSheet(_tincturesMedication);
                        }
                      });
                    }),
                  ],
                ),
                SizedBox(height: size.height * 0.01),
                Row(
                  children: [
                    ActionCardMedication(_dabbingMedication, () {
                      setState(() {
                        if (_dabbingMedication.isSelected) {
                          _dabbingMedication.isSelected = false;
                          _dabbingMedication.preference = '';
                          _dabbingMedication.experience = '';
                          medications.removeWhere((medication) => medication.title == _dabbingMedication.title);
                        } else {
                          _showMedicationSheet(_dabbingMedication);
                        }
                      });
                    }),
                    SizedBox(width: size.width * 0.025),
                    ActionCardMedication(_topicalMedication, () {
                      setState(() {
                        if (_topicalMedication.isSelected) {
                          _topicalMedication.isSelected = false;
                          _topicalMedication.preference = '';
                          _topicalMedication.experience = '';
                          medications.removeWhere((medication) => medication.title == _topicalMedication.title);
                        } else {
                          _showMedicationSheet(_topicalMedication);
                        }
                      });
                    }),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  _showMedicationSheet(Medication medication) {
    final size = MediaQuery.of(context).size;
    _clearCard();
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
                    height: 550.0,
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
                                Expanded(child: SizedBox()),
                                TextButton(
                                    child: Text(
                                      "Save",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: AppFontSizes.buttonSize + 5.0,
                                        fontWeight: FontWeight.w800,
                                      ),
                                      textScaler: TextScaler.linear(AppFontScales.adaptiveScale),
                                    ),
                                    onPressed: () {
                                      _saveCard(medication);
                                    }),
                              ],
                            ),
                          ),
                        ),
                        Align(
                          alignment: Alignment.bottomCenter,
                          child: Container(
                            height: 480.0,
                            padding: EdgeInsets.symmetric(horizontal: size.width * 0.1),
                            child: Column(
                              children: [
                                Container(
                                  margin: EdgeInsets.only(bottom: 5.0, top: 10.0),
                                  alignment: Alignment.centerLeft,
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Image(
                                        height: size.height * 0.05,
                                        width: size.width * 0.15,
                                        image: AssetImage('assets/img/medication/${AppData().iconMedication(medication.title!)}'),
                                        fit: BoxFit.contain,
                                        color: AppColor.primaryColor,
                                      ),
                                      SizedBox(width: 10.0),
                                      Padding(
                                        padding: const EdgeInsets.only(bottom: 5.0),
                                        child: Text(
                                          "${medication.title}",
                                          style: TextStyle(
                                            color: AppColor.primaryColor,
                                            fontSize: AppFontSizes.subTitleSize + 5.0,
                                            fontWeight: FontWeight.w700,
                                          ),
                                          textScaler: TextScaler.linear(AppFontScales.adaptiveScale),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(height: 10.0),
                                Text(
                                  "${medication.description}",
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: AppFontSizes.contentSize - 1.0,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                SizedBox(height: 15.0),
                                _initPreference(medication, setState),
                                SizedBox(height: 15.0),
                                _initExperience(medication, setState),
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

  Widget _initPreference(Medication medication, Function(void Function()) setState) {
    final size = MediaQuery.of(context).size;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          child: Text(
            "How do you feel about this method?",
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: AppFontSizes.contentSize + 1.0,
            ),
            textAlign: TextAlign.left,
          ),
        ),
        SizedBox(height: 20.0),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            InkWell(
              child: Row(
                children: [
                  Text(
                    "Love it",
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: AppFontSizes.contentSize,
                    ),
                  ),
                  SizedBox(width: size.width * 0.02),
                  Icon(Icons.check_circle_rounded, color: _selectedPreferenceLoveIt ? AppColor.secondaryColor : AppColor.content.withOpacity(0.3)),
                ],
              ),
              onTap: () {
                setState(() {
                  if (_selectedPreferenceLoveIt) {
                    _selectedPreferenceLoveIt = false;
                    medication.preference = "";
                  } else {
                    _selectedPreferenceLoveIt = true;
                    _selectedPreferenceLikeIt = false;
                    _selectedPreferenceItsOk = false;
                    medication.preference = "Love it";
                  }
                });
              },
            ),
            SizedBox(width: size.width * 0.06),
            InkWell(
              child: Row(
                children: [
                  Text(
                    "Like it",
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: AppFontSizes.contentSize,
                    ),
                  ),
                  SizedBox(width: size.width * 0.02),
                  Icon(Icons.check_circle_rounded, color: _selectedPreferenceLikeIt ? AppColor.secondaryColor : AppColor.content.withOpacity(0.3)),
                ],
              ),
              onTap: () {
                setState(() {
                  if (_selectedPreferenceLikeIt) {
                    _selectedPreferenceLikeIt = false;
                    medication.preference = "";
                  } else {
                    _selectedPreferenceLoveIt = false;
                    _selectedPreferenceLikeIt = true;
                    _selectedPreferenceItsOk = false;
                    medication.preference = "Like it";
                  }
                });
              },
            ),
            SizedBox(width: size.width * 0.06),
            InkWell(
              child: Row(
                children: [
                  Text(
                    "Dislike it",
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: AppFontSizes.contentSize,
                    ),
                  ),
                  SizedBox(width: size.width * 0.02),
                  Icon(Icons.check_circle_rounded, color: _selectedPreferenceItsOk ? AppColor.secondaryColor : AppColor.content.withOpacity(0.3)),
                ],
              ),
              onTap: () {
                setState(() {
                  if (_selectedPreferenceItsOk) {
                    _selectedPreferenceItsOk = false;
                    medication.preference = "";
                  } else {
                    _selectedPreferenceLoveIt = false;
                    _selectedPreferenceLikeIt = false;
                    _selectedPreferenceItsOk = true;
                    medication.preference = "Dislike it";
                  }
                });
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _initExperience(Medication medication, Function(void Function()) setState) {
    final size = MediaQuery.of(context).size;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          child: Text(
            "How much experience do you have?",
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: AppFontSizes.contentSize + 1.0,
            ),
            textAlign: TextAlign.left,
          ),
        ),
        SizedBox(height: size.height * 0.01),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _cardExperience("Novice", _selectedExperienceBeginner, () {
              setState(() {
                if (_selectedExperienceBeginner) {
                  _selectedExperienceBeginner = false;
                  medication.experience = "";
                } else {
                  _selectedExperienceBeginner = true;
                  _selectedExperienceAlittle = false;
                  _selectedExperienceAlot = false;
                  _selectedExperienceExpert = false;
                  medication.experience = "Novice";
                }
              });
            }),
            SizedBox(width: size.width * 0.03),
            _cardExperience("Intermediate", _selectedExperienceAlittle, () {
              setState(() {
                if (_selectedExperienceAlittle) {
                  _selectedExperienceAlittle = false;
                  medication.experience = "";
                } else {
                  _selectedExperienceBeginner = false;
                  _selectedExperienceAlittle = true;
                  _selectedExperienceAlot = false;
                  _selectedExperienceExpert = false;
                  medication.experience = "Intermediate";
                }
              });
            }),
          ],
        ),
        SizedBox(height: size.height * 0.01),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _cardExperience("Proficient", _selectedExperienceAlot, () {
              setState(() {
                if (_selectedExperienceAlot) {
                  _selectedExperienceAlot = false;
                  medication.experience = "";
                } else {
                  _selectedExperienceBeginner = false;
                  _selectedExperienceAlittle = false;
                  _selectedExperienceAlot = true;
                  _selectedExperienceExpert = false;
                  medication.experience = "Proficient";
                }
              });
            }),
            SizedBox(width: size.width * 0.03),
            _cardExperience("Expert", _selectedExperienceExpert, () {
              setState(() {
                if (_selectedExperienceExpert) {
                  _selectedExperienceExpert = false;
                  medication.experience = "";
                } else {
                  _selectedExperienceBeginner = false;
                  _selectedExperienceAlittle = false;
                  _selectedExperienceAlot = false;
                  _selectedExperienceExpert = true;
                  medication.experience = "Expert";
                }
              });
            }),
          ],
        ),
        SizedBox(height: size.height * 0.05),
      ],
    );
  }

  Widget _cardExperience(String text, bool isSelected, VoidCallback callback) {
    final size = MediaQuery.of(context).size;
    return Card(
      elevation: 3.0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
        side: BorderSide(
          width: 2.0,
          color: isSelected ? AppColor.secondaryColor : Colors.transparent,
        ),
      ),
      child: InkWell(
        child: SizedBox(
          width: size.width * 0.35,
          height: 40.0,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '$text',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w300,
                  fontSize: AppFontSizes.contentSize,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        onTap: callback,
      ),
    );
  }

  void _updateCard() {
    setState(() {});
  }

  void _updateMedications() {
    // medications = [];
    _prefs.medications.forEach((medication) {
      Map<String, dynamic> temp = jsonDecode(medication);
      Medication tempMedication = Medication.fromJson(temp);
      // medications.add(tempMedication);
      switch (tempMedication.title) {
        case "Smoke":
          _smokeMedication.isSelected = true;
          _smokeMedication.preference = tempMedication.preference;
          _smokeMedication.experience = tempMedication.experience;
          medications.add(_smokeMedication);
          _updateCard();
          break;
        case "Vape":
          _vapeMedication.isSelected = true;
          _vapeMedication.preference = tempMedication.preference;
          _vapeMedication.experience = tempMedication.experience;
          medications.add(_vapeMedication);
          _updateCard();
          break;
        case "Topical":
          _topicalMedication.isSelected = true;
          _topicalMedication.preference = tempMedication.preference;
          _topicalMedication.experience = tempMedication.experience;
          medications.add(_topicalMedication);
          _updateCard();
          break;
        case "Edibles":
          _ediblesMedication.isSelected = true;
          _ediblesMedication.preference = tempMedication.preference;
          _ediblesMedication.experience = tempMedication.experience;
          medications.add(_ediblesMedication);
          _updateCard();
          break;
        case "Tinctures":
          _tincturesMedication.isSelected = true;
          _tincturesMedication.preference = tempMedication.preference;
          _tincturesMedication.experience = tempMedication.experience;
          medications.add(_tincturesMedication);
          _updateCard();
          break;
        case "Dabbing":
          _dabbingMedication.isSelected = true;
          _dabbingMedication.preference = tempMedication.preference;
          _dabbingMedication.experience = tempMedication.experience;
          medications.add(_dabbingMedication);
          _updateCard();
          break;
      }
    });
  }

  void _saveCard(Medication medication) {
    switch (medication.title) {
      case "Smoke":
        if (_emptyCard(_smokeMedication)) {
          _smokeMedication.isSelected = true;
          medications.add(_smokeMedication);
          Navigator.pop(context);
          _updateCard();
        }
        break;
      case "Vape":
        if (_emptyCard(_vapeMedication)) {
          _vapeMedication.isSelected = true;
          medications.add(_vapeMedication);
          Navigator.pop(context);
          _updateCard();
        }
        break;
      case "Topical":
        if (_emptyCard(_topicalMedication)) {
          _topicalMedication.isSelected = true;
          medications.add(_topicalMedication);
          Navigator.pop(context);
          _updateCard();
        }
        break;
      case "Edibles":
        if (_emptyCard(_ediblesMedication)) {
          _ediblesMedication.isSelected = true;
          medications.add(_ediblesMedication);
          Navigator.pop(context);
          _updateCard();
        }
        break;
      case "Tinctures":
        if (_emptyCard(_tincturesMedication)) {
          _tincturesMedication.isSelected = true;
          medications.add(_tincturesMedication);
          Navigator.pop(context);
          _updateCard();
        }
        break;
      case "Dabbing":
        if (_emptyCard(_dabbingMedication)) {
          _dabbingMedication.isSelected = true;
          medications.add(_dabbingMedication);
          Navigator.pop(context);
          _updateCard();
        }
        break;
    }
  }

  bool _emptyCard(Medication modication) {
    if (modication.preference.isEmpty) {
      showAlertMessage(context, "Select how you feel about this method", () {
        Navigator.pop(context);
      });
      return false;
    } else {
      if (modication.experience.isEmpty) {
        showAlertMessage(context, "Select your experience level", () {
          Navigator.pop(context);
        });
        return false;
      } else {
        return true;
      }
    }
  }

  void _clearCard() {
    _selectedPreferenceLoveIt = false;
    _selectedPreferenceLikeIt = false;
    _selectedPreferenceItsOk = false;
    _selectedExperienceBeginner = false;
    _selectedExperienceAlittle = false;
    _selectedExperienceAlot = false;
    _selectedExperienceExpert = false;
  }

  bool _validateMedications() {
    List<String> medicationsEncoded = medications.map((medication) => jsonEncode(medication.toJson())).toList();
    if (medicationsEncoded.length == 0) {
      showAlertMessage(context, "Please select at least one method", () {
        Navigator.pop(context);
      });
      return false;
    }
    _prefs.medications = medicationsEncoded;
    return true;
  }

  _next(BuildContext context) {
    if (_validateMedications()) {
      print('medications: ${_prefs.medications}');
      Navigator.pushNamed(context, 'onboarding_agree');
    }
  }
}
