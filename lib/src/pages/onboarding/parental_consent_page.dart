import 'package:flutter/material.dart';
import 'package:beanstalk_mobile/src/blocs/provider.dart';
import 'package:beanstalk_mobile/src/ui/app_skin.dart';
import 'package:beanstalk_mobile/src/utils/utils.dart';

class ParentalConsentPage extends StatefulWidget {
  const ParentalConsentPage({Key? key}) : super(key: key);

  @override
  _ParentalConsentPageState createState() => _ParentalConsentPageState();
}

class _ParentalConsentPageState extends State<ParentalConsentPage> {
  final TextEditingController _parentEmailController = TextEditingController();
  final TextEditingController _parentNameController = TextEditingController();
  bool _isLoading = false;
  int _currentStep = 0;

  Future<void> _initParentalConsent() async {
    if (_parentEmailController.text.isEmpty || _parentNameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill in all fields')),
      );
      return;
    }

    // Validate email
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
    if (!emailRegex.hasMatch(_parentEmailController.text)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter a valid email address')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final bloc = Provider.onboardingOf(context);

      // Call API to initiate parental consent
      // TODO: Call ParentalConsentService.initParentalConsent()

      bloc.changeParentEmail(_parentEmailController.text);
      bloc.changeParentName(_parentNameController.text);

      setState(() => _currentStep = 1);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Verification email sent to ${_parentEmailController.text}',
          ),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to send consent email: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _skipParentalConsent() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Skip Parental Consent?'),
        content: Text(
          'Users under 18 require parental consent to use Beanstalk. '
          'You can continue once your parent/guardian verifies their consent.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Continue'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // Navigate to next step (demographics)
              Navigator.of(context).pushReplacementNamed('/onboarding/demographics');
            },
            child: Text('Skip For Now'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _parentEmailController.dispose();
    _parentNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Container(
        color: AppColor.background,
        child: SingleChildScrollView(
          child: Column(
            children: [
              SafeArea(
                child: Container(height: size.height * 0.05),
              ),
              _buildHeader(size),
              _currentStep == 0
                  ? _buildConsentForm(context, size)
                  : _buildPendingVerification(size),
            ],
          ),
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
          SizedBox(height: size.height * 0.03),
          Text(
            'Parental Consent',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: size.height * 0.02),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              'Since you\'re under 18, we need your parent or guardian to verify consent.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.white70,
              ),
            ),
          ),
          SizedBox(height: size.height * 0.03),
        ],
      ),
    );
  }

  Widget _buildConsentForm(BuildContext context, Size size) {
    return Container(
      color: AppColor.background,
      padding: EdgeInsets.symmetric(horizontal: 30, vertical: 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Parent/Guardian Information',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColor.text,
            ),
          ),
          SizedBox(height: 24),
          Text(
            'Parent/Guardian Name',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColor.text,
            ),
          ),
          SizedBox(height: 8),
          TextField(
            controller: _parentNameController,
            decoration: InputDecoration(
              hintText: 'e.g., John Doe',
              hintStyle: TextStyle(color: Colors.grey),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
          ),
          SizedBox(height: 24),
          Text(
            'Parent/Guardian Email',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColor.text,
            ),
          ),
          SizedBox(height: 8),
          TextField(
            controller: _parentEmailController,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              hintText: 'parent@example.com',
              hintStyle: TextStyle(color: Colors.grey),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
          ),
          SizedBox(height: 20),
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.orange.shade50,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.warning, color: Colors.orange, size: 20),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'We\'ll send a verification email to this address. '
                    'Your parent/guardian must click the link to activate your account.',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.orange.shade900,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 40),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _initParentalConsent,
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
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        strokeWidth: 2,
                      ),
                    )
                  : Text(
                      'Send Consent Email',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
            ),
          ),
          SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: OutlinedButton(
              onPressed: _skipParentalConsent,
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: AppColor.primary),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
              child: Text(
                'Skip For Now',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColor.primary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPendingVerification(Size size) {
    return Container(
      color: AppColor.background,
      padding: EdgeInsets.symmetric(horizontal: 30, vertical: 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(
            Icons.mail_outline,
            size: 80,
            color: AppColor.primary,
          ),
          SizedBox(height: 24),
          Text(
            'Check Your Parent\'s Email',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColor.text,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 12),
          Text(
            'We\'ve sent a verification email to ${_parentEmailController.text}',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 8),
          Text(
            'They need to click the link in the email to verify consent.',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 40),
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.blue.shade200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'What happens next?',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade900,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  '1. Parent/guardian receives email\n'
                  '2. They click verification link\n'
                  '3. Your account becomes active\n'
                  '4. You can start using Beanstalk',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.blue.shade900,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 40),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(context).pushReplacementNamed('/onboarding/demographics');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColor.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
              child: Text(
                'Continue to Next Step',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
