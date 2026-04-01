import 'package:flutter/material.dart';
import 'package:beanstalk_mobile/src/blocs/provider.dart';
import 'package:beanstalk_mobile/src/ui/app_skin.dart';

class EulaDisplayPage extends StatefulWidget {
  const EulaDisplayPage({Key? key}) : super(key: key);

  @override
  _EulaDisplayPageState createState() => _EulaDisplayPageState();
}

class _EulaDisplayPageState extends State<EulaDisplayPage> {
  int _currentEulaIndex = 0;
  Map<String, bool> _acceptedEulas = {
    'terms_of_service': false,
    'privacy_policy': false,
    'contest_rules': false,
  };
  bool _isLoading = false;

  final List<EulaDocument> eulas = [
    EulaDocument(
      id: 'terms_of_service',
      title: 'Terms of Service',
      version: '1.0.0',
      content: '''
TERMS OF SERVICE

Last Updated: March 2026

1. ACCEPTANCE OF TERMS
By creating an account and using Beanstalk, you agree to these Terms of Service. If you do not accept these terms, please do not use our service.

2. USE LICENSE
Beanstalk grants you a limited, non-exclusive, non-transferable license to use Beanstalk for lawful purposes only.

3. DISCLAIMER OF WARRANTIES
Beanstalk is provided on an "as-is" basis. We make no warranties regarding the service.

4. LIMITATION OF LIABILITY
Beanstalk shall not be liable for any indirect, incidental, special, consequential, or punitive damages.

5. CHANGES TO TERMS
We reserve the right to modify these terms. Your continued use constitutes acceptance of changes.

6. TERMINATION
We may terminate your account if you violate these terms.

[Full terms continue...]
      ''',
      required: true,
    ),
    EulaDocument(
      id: 'privacy_policy',
      title: 'Privacy Policy',
      version: '1.0.0',
      content: '''
PRIVACY POLICY

Last Updated: March 2026

1. INFORMATION COLLECTION
We collect information you provide directly to us when you register, use our service, or contact us.

2. HOW WE USE YOUR INFO
We use your information to:
- Provide and improve our service
- Personalize your experience
- Communicate with you
- Comply with legal obligations

3. DATA SECURITY
We implement appropriate security measures to protect your information.

4. AGE VERIFICATION DATA
We collect date of birth to verify age and comply with COPPA.

5. DATA RETENTION
We retain your data as long as your account is active or as needed for legal compliance.

6. YOUR RIGHTS
You have the right to access, correct, or delete your personal data.

[Full policy continues...]
      ''',
      required: true,
    ),
    EulaDocument(
      id: 'contest_rules',
      title: 'Contest Rules',
      version: '1.0.0',
      content: '''
CONTEST RULES

1. ELIGIBILITY
- Must be 13 or older
- Must have verified age
- Must have accepted Terms and Privacy Policy
- Minors must have parental consent

2. CONTEST CATEGORIES
- Age-matched cohorts (middle school, high school, college, adults)
- Virtual portfolio trading competitions
- Performance-based leaderboards

3. SCORING
- Returns calculated based on portfolio performance
- Penalties for rule violations
- TBD: Prize distribution

4. CODE OF CONDUCT
- No manipulation of leaderboards
- No sharing of accounts
- Respectful communication required
- Violation results in disqualification

5. PRIZES
- TBD: Prize details and distribution

6. LIABILITY
- Users assume all trading risk
- Virtual trades do not reflect real market
- Results are for educational purposes only

[Full rules continue...]
      ''',
      required: false,
    ),
  ];

  Future<void> _acceptAllEulas() async {
    // Check required EULAs
    if (!_acceptedEulas['terms_of_service']! ||
        !_acceptedEulas['privacy_policy']!) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('You must accept Terms of Service and Privacy Policy'),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final bloc = Provider.onboardingOf(context);

      // Accept each EULA via API
      // TODO: Call ComplianceService.acceptEula() for each EULA

      bloc.changeAcceptedConsents(_acceptedEulas);

      // Navigate to next step (medical profile or completion)
      Navigator.of(context)
          .pushReplacementNamed('/onboarding/medical-profile');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to accept EULAs: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final eula = eulas[_currentEulaIndex];

    return Scaffold(
      body: Container(
        color: AppColor.background,
        child: Column(
          children: [
            SafeArea(
              child: Container(height: size.height * 0.02),
            ),
            _buildHeader(size),
            Expanded(
              child: _buildEulaContent(eula),
            ),
            _buildFooter(size),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(Size size) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(50.0),
          topRight: Radius.circular(50.0),
        ),
        gradient: AppColor.primaryGradient,
      ),
      child: Column(
        children: [
          SizedBox(height: size.height * 0.02),
          Text(
            'Legal Agreements',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 12),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              'Please review and accept the following agreements',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.white70,
              ),
            ),
          ),
          SizedBox(height: size.height * 0.02),
        ],
      ),
    );
  }

  Widget _buildEulaContent(EulaDocument eula) {
    return Container(
      color: Colors.white,
      child: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      eula.title,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'v${eula.version}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
                if (eula.required)
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.red.shade100,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      'Required',
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
            SizedBox(height: 20),
            Text(
              eula.content,
              style: TextStyle(
                fontSize: 13,
                height: 1.6,
                color: Colors.grey.shade800,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFooter(Size size) {
    final eula = eulas[_currentEulaIndex];

    return Container(
      color: Colors.white,
      padding: EdgeInsets.all(20),
      child: Column(
        children: [
          Row(
            children: [
              Checkbox(
                value: _acceptedEulas[eula.id] ?? false,
                onChanged: (value) {
                  setState(() {
                    _acceptedEulas[eula.id] = value ?? false;
                  });
                },
                activeColor: AppColor.primary,
              ),
              Expanded(
                child: Text(
                  'I accept the ${eula.title}',
                  style: TextStyle(fontSize: 14),
                ),
              ),
            ],
          ),
          SizedBox(height: 20),
          Row(
            children: [
              if (_currentEulaIndex > 0)
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      setState(() => _currentEulaIndex--);
                    },
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: AppColor.primary),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                    child: Text(
                      'Previous',
                      style: TextStyle(color: AppColor.primary),
                    ),
                  ),
                ),
              if (_currentEulaIndex > 0) SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: _currentEulaIndex < eulas.length - 1
                      ? () {
                          if (_acceptedEulas[eula.id] == false) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                    'Please accept ${eula.title} to continue'),
                              ),
                            );
                            return;
                          }
                          setState(() => _currentEulaIndex++);
                        }
                      : (_isLoading ? null : _acceptAllEulas),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColor.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                  child: _isLoading
                      ? SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                            strokeWidth: 2,
                          ),
                        )
                      : Text(
                          _currentEulaIndex < eulas.length - 1
                              ? 'Next'
                              : 'Accept & Continue',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          Text(
            'Step ${_currentEulaIndex + 1} of ${eulas.length}',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}

class EulaDocument {
  final String id;
  final String title;
  final String version;
  final String content;
  final bool required;

  EulaDocument({
    required this.id,
    required this.title,
    required this.version,
    required this.content,
    required this.required,
  });
}
