import 'package:flutter/material.dart';
import 'package:beanstalk_mobile/src/blocs/provider.dart';
import 'package:beanstalk_mobile/src/ui/app_skin.dart';

class DemographicsPage extends StatefulWidget {
  const DemographicsPage({Key? key}) : super(key: key);

  @override
  _DemographicsPageState createState() => _DemographicsPageState();
}

class _DemographicsPageState extends State<DemographicsPage> {
  String? _educationLevel;
  String? _incomeBracket;
  String? _primaryInterest;
  String? _riskTolerance;
  bool _isLoading = false;

  final List<String> educationLevels = [
    'Middle School',
    'High School',
    'Some College',
    'College',
    'Graduate Degree',
    'Other'
  ];

  final List<String> incomeBrackets = [
    'Under $25k',
    '$25k - $50k',
    '$50k - $100k',
    '$100k - $250k',
    'Over $250k',
    'Prefer not to say'
  ];

  final List<String> primaryInterests = [
    'Trading',
    'Investing',
    'Learning',
    'Competing',
    'Other'
  ];

  final List<String> riskTolerances = [
    'Conservative',
    'Moderate',
    'Aggressive'
  ];

  Future<void> _saveDemographics() async {
    if (_educationLevel == null ||
        _incomeBracket == null ||
        _primaryInterest == null ||
        _riskTolerance == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill in all demographic fields')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final bloc = Provider.onboardingOf(context);

      // Save demographics via API
      // TODO: Call ComplianceService.updateUserDemographics()

      bloc.changeEducationLevel(_educationLevel!);
      bloc.changeIncomeBracket(_incomeBracket!);
      bloc.changePrimaryInterest(_primaryInterest!);
      bloc.changeRiskTolerance(_riskTolerance!);

      Navigator.of(context).pushReplacementNamed('/onboarding/eula');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to save demographics: ${e.toString()}'),
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
              _buildContent(size),
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
            'Tell Us About Yourself',
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
              'Help us personalize your Beanstalk experience with demographic information.',
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

  Widget _buildContent(Size size) {
    return Container(
      color: AppColor.background,
      padding: EdgeInsets.symmetric(horizontal: 30, vertical: 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDropdownField('Education Level', _educationLevel, educationLevels,
              (value) {
            setState(() => _educationLevel = value);
          }),
          SizedBox(height: 24),
          _buildDropdownField('Annual Income', _incomeBracket, incomeBrackets,
              (value) {
            setState(() => _incomeBracket = value);
          }),
          SizedBox(height: 24),
          _buildDropdownField('Primary Interest', _primaryInterest, primaryInterests,
              (value) {
            setState(() => _primaryInterest = value);
          }),
          SizedBox(height: 24),
          _buildDropdownField(
              'Risk Tolerance', _riskTolerance, riskTolerances, (value) {
            setState(() => _riskTolerance = value);
          }),
          SizedBox(height: 40),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _saveDemographics,
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
        ],
      ),
    );
  }

  Widget _buildDropdownField(String label, String? value, List<String> items,
      Function(String?) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColor.text,
          ),
        ),
        SizedBox(height: 8),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            border: Border.all(color: AppColor.primary),
            borderRadius: BorderRadius.circular(8),
          ),
          child: DropdownButton<String>(
            isExpanded: true,
            underline: SizedBox(),
            hint: Text('Select $label'),
            value: value,
            items: items.map((String item) {
              return DropdownMenuItem<String>(
                value: item,
                child: Text(item),
              );
            }).toList(),
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }
}
