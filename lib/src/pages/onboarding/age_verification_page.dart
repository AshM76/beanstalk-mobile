import 'package:flutter/material.dart';
import 'package:beanstalk_mobile/src/blocs/provider.dart';
import 'package:beanstalk_mobile/src/ui/app_skin.dart';
import 'package:beanstalk_mobile/src/utils/loading.dart';
import 'package:intl/intl.dart';

class AgeVerificationPage extends StatefulWidget {
  const AgeVerificationPage({Key? key}) : super(key: key);

  @override
  _AgeVerificationPageState createState() => _AgeVerificationPageState();
}

class _AgeVerificationPageState extends State<AgeVerificationPage> {
  final TextEditingController _dateController = TextEditingController();
  String? _selectedMethod = 'self_reported';
  bool _isLoading = false;

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1920),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColor.primary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _dateController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  Future<void> _verifyAge() async {
    if (_dateController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select your date of birth')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final bloc = Provider.onboardingOf(context);

      // Verify self-reported age via API
      // TODO: Call AgeVerificationService.verifySelfReported(_dateController.text)

      bloc.changeDateOfBirth(_dateController.text);
      bloc.changeAgeVerificationMethod(_selectedMethod!);

      // Navigate to next onboarding step
      Navigator.of(context).pushReplacementNamed('/onboarding/parental-consent');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Age verification failed: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _dateController.dispose();
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
                child: Container(
                  height: size.height * 0.05,
                ),
              ),
              _buildHeader(size),
              _buildContent(context, size),
              _buildButton(size),
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
            'Age Verification',
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
              'We need to verify your age to provide age-appropriate content and features.',
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

  Widget _buildContent(BuildContext context, Size size) {
    return Container(
      color: AppColor.background,
      padding: EdgeInsets.symmetric(horizontal: 30, vertical: 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Select Verification Method',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColor.text,
            ),
          ),
          SizedBox(height: 20),
          _buildMethodOption(
            'Self-Reported',
            'self_reported',
            'Enter your date of birth',
          ),
          SizedBox(height: 15),
          _buildMethodOption(
            'ID Verification',
            'id_verification',
            'Verify with government ID',
          ),
          SizedBox(height: 40),
          Text(
            'Date of Birth',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColor.text,
            ),
          ),
          SizedBox(height: 12),
          GestureDetector(
            onTap: () => _selectDate(context),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 15, vertical: 16),
              decoration: BoxDecoration(
                border: Border.all(color: AppColor.primary),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _dateController.text.isEmpty
                        ? 'Select date (YYYY-MM-DD)'
                        : _dateController.text,
                    style: TextStyle(
                      fontSize: 14,
                      color: _dateController.text.isEmpty
                          ? Colors.grey
                          : AppColor.text,
                    ),
                  ),
                  Icon(Icons.calendar_today, color: AppColor.primary),
                ],
              ),
            ),
          ),
          SizedBox(height: 15),
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(Icons.info, color: Colors.blue, size: 20),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'You must be at least 13 years old to use Beanstalk.',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.blue.shade900,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMethodOption(String title, String value, String subtitle) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: _selectedMethod == value ? AppColor.primary : Colors.grey.shade300,
          width: _selectedMethod == value ? 2 : 1,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: RadioListTile<String>(
        title: Text(
          title,
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(subtitle, style: TextStyle(fontSize: 12)),
        value: value,
        groupValue: _selectedMethod,
        onChanged: (newValue) {
          setState(() => _selectedMethod = newValue);
        },
        activeColor: AppColor.primary,
      ),
    );
  }

  Widget _buildButton(Size size) {
    return Container(
      color: AppColor.background,
      padding: EdgeInsets.only(
        left: 30,
        right: 30,
        bottom: 30,
      ),
      child: SizedBox(
        width: double.infinity,
        height: 50,
        child: ElevatedButton(
          onPressed: _isLoading ? null : _verifyAge,
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
                  'Continue',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
        ),
      ),
    );
  }
}
