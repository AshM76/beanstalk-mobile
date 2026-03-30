import 'package:flutter/material.dart';
import 'package:beanstalk_mobile/src/preferences/user_preference.dart';
import 'package:beanstalk_mobile/src/ui/app_skin.dart';

import 'package:beanstalk_mobile/src/widgets/onboarding/backgroundPaint_widget.dart';

import 'package:app_tracking_transparency/app_tracking_transparency.dart';

class LumirOnboardingInformationPage extends StatefulWidget {
  @override
  _LumirOnboardingInformationPageState createState() => _LumirOnboardingInformationPageState();
}

class _LumirOnboardingInformationPageState extends State<LumirOnboardingInformationPage> {
  final _prefs = new UserPreference();
  // ignore: unused_field
  String _authStatus = 'Unknown';

  @override
  void initState() {
    super.initState();

    WidgetsFlutterBinding.ensureInitialized().addPostFrameCallback((_) => initPlugin());
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlugin() async {
    final TrackingStatus status = await AppTrackingTransparency.trackingAuthorizationStatus;
    setState(() => _authStatus = '$status');
    // If the system can show an authorization request dialog
    if (status == TrackingStatus.notDetermined) {
      // Request system's tracking authorization dialog
      final TrackingStatus status = await AppTrackingTransparency.requestTrackingAuthorization();
      setState(() => _authStatus = '$status');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Stack(
      children: <Widget>[
        initBackgroundPaint(context),
        _initProfileAgreeForm(context),
        // backButton(context),
      ],
    ));
  }

  Widget _initProfileAgreeForm(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: size.width * 0.06),
      child: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: size.height * 0.02),
              _initTitle(),
              _initProjectInformation(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _initTitle() {
    final size = MediaQuery.of(context).size;
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Image.network(
            AppLogos.iconImg,
            width: 40.0,
            height: 40.0,
            fit: BoxFit.cover,
          ),
          Container(
            height: 120.0,
            width: 350.0,
            child: Align(
              alignment: Alignment.topLeft,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Welcome",
                    style: TextStyle(
                      color: AppColor.fourthColor,
                      fontSize: AppFontSizes.titleSize + (size.width * 0.01),
                      fontFamily: AppFont.primaryFont,
                    ),
                    textAlign: TextAlign.left,
                    softWrap: true,
                  ),
                  Text(
                    "to the Lumir Mission Market Research Study",
                    style: TextStyle(
                      color: AppColor.fourthColor,
                      fontSize: AppFontSizes.titleSize,
                      fontFamily: AppFont.primaryFont,
                    ),
                    textAlign: TextAlign.left,
                    softWrap: true,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _initProjectInformation() {
    final size = MediaQuery.of(context).size;
    return Container(
      height: size.height * 0.65,
      width: size.width * 0.8,
      child: Scrollbar(
        thickness: 5.0,
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "The Lumir Mission is a market research project to better understand your health. \nLearn whether medicinal cannabis is effective for your condition as well as its effects on mood, sleep and energy. \nThe Lumir Mission App allows us to collect data for this study, and you to track your progress and share, if you choose, with your other healthcare providers.\n\nThis study is sponsored by Cannim Group Pty Ltd and Lumir Clinics.\n",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: AppFontSizes.contentSize,
                ),
              ),
              Text(
                "What I am Required to Do?\n",
                style: TextStyle(
                  color: AppColor.fifthColor.withOpacity(0.9),
                  fontSize: AppFontSizes.contentSize,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                "First Use\n",
                style: TextStyle(
                  color: AppColor.fifthColor.withOpacity(0.9),
                  fontSize: AppFontSizes.contentSize,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                "1. Register and identify your primary condition.\n2. Rate aspects of your overall health by answering 7 sliding scale questions.\n3. Record your regular treatments including therapies, medications and medicinal cannabis.\n\nThis creates your baseline data.\n",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: AppFontSizes.contentSize,
                ),
              ),
              Text(
                "Each Week\n",
                style: TextStyle(
                  color: AppColor.fifthColor.withOpacity(0.9),
                  fontSize: AppFontSizes.contentSize,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                "Answer the same 7 sliding scale questions plus one more on any change in pharmaceutical medications. Weekly answers will be compared to your baseline and previous weeks’ responses.\n",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: AppFontSizes.contentSize,
                ),
              ),
              Text(
                "Why participate?\n",
                style: TextStyle(
                  color: AppColor.fifthColor.withOpacity(0.9),
                  fontSize: AppFontSizes.contentSize,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                "- Enhance your awareness of your personal wellbeing.\n- Continuously track your health and, if you choose, share with your other healthcare professionals.\n- Add to the knowledge base around medicinal cannabis which may help a larger community of people.\n- Be rewarded for your active and ongoing participation with a range of offers.\n",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: AppFontSizes.contentSize,
                ),
              ),
              Text(
                "How will my data by used?\n",
                style: TextStyle(
                  color: AppColor.fifthColor.withOpacity(0.9),
                  fontSize: AppFontSizes.contentSize,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                "At all times your data will be managed with the strictest adherence to the data legislation relevant in your region. This includes (but is not limited to); HIPAA compliance (USA), UK GDPR compliance (UK) and The Privacy Act 1988 and Australian Privacy Principles (Australia).\n",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: AppFontSizes.contentSize,
                ),
              ),
              Text(
                "Aside from your own use and reports within your personal Lumir Mission account, all data collected is deidentified and added to the anonymous data from other study participants around the world. This deidentified global data set will then be analysed to inform future research directions in pursuit of furthering the understanding of applications of medical cannabis.\n",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: AppFontSizes.contentSize,
                ),
              ),
              Text(
                "Agreement to Participate\n",
                style: TextStyle(
                  color: AppColor.fifthColor.withOpacity(0.9),
                  fontSize: AppFontSizes.contentSize,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                "- I agree to participate in the Lumir Mission Market Research Study.",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: AppFontSizes.contentSize,
                ),
              ),
              SizedBox(height: 7.0),
              Text(
                "- I understand that I can drop out of the study at any time and it will have no impact on me.",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: AppFontSizes.contentSize,
                ),
              ),
              SizedBox(height: 7.0),
              Text(
                "- I agree to allow my de-identified data to also be used in future research studies.",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: AppFontSizes.contentSize,
                ),
              ),
              SizedBox(height: size.height * 0.03),
              _initContinueButton(context),
              SizedBox(height: size.height * 0.01),
            ],
          ),
        ),
      ),
    );
  }

  Widget _initContinueButton(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return SafeArea(
      child: Container(
        child: Material(
          elevation: 4.0,
          borderRadius: BorderRadius.circular(15.0),
          child: Container(
            width: size.width * 0.7,
            height: 50.0,
            child: Material(
              color: AppColor.secondaryColor,
              borderRadius: BorderRadius.circular(15.0),
              child: InkWell(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 20.0),
                      child: Text(
                        "Continue",
                        style: TextStyle(
                          fontSize: AppFontSizes.buttonSize + (size.width * 0.012),
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                        textScaler: TextScaler.linear(AppFontScales.adaptiveScale),
                      ),
                    ),
                    Expanded(child: SizedBox()),
                    Padding(
                      padding: const EdgeInsets.only(right: 10.0),
                      child: Icon(
                        Icons.navigate_next_rounded,
                        size: 30.0,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                onTap: () {
                  _prefs.agreementAccepted = true;
                  Navigator.pushNamed(context, 'onboarding_agree');
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
