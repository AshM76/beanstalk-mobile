import 'package:flutter/material.dart';
import 'package:beanstalk_mobile/src/ui/app_skin.dart';

class ContestDiscoveryPage extends StatefulWidget {
  @override
  _ContestDiscoveryPageState createState() => _ContestDiscoveryPageState();
}

class _ContestDiscoveryPageState extends State<ContestDiscoveryPage> {
  bool _isLoading = true;
  String _selectedDifficulty = 'all';

  List<Map<String, dynamic>> _contests = [
    {
      'id': '1',
      'name': 'High School Trading Challenge',
      'description': 'A competitive trading contest for high school students',
      'ageGroups': ['high_school'],
      'difficulty': 'beginner',
      'startDate': '2024-04-01',
      'endDate': '2024-05-01',
      'participants': 45,
      'maxParticipants': 100,
      'startingBalance': 50000,
      'status': 'active',
      'prizePool': 5000,
    },
    {
      'id': '2',
      'name': 'College Investor League',
      'description': 'Advanced trading strategies for college students',
      'ageGroups': ['college'],
      'difficulty': 'intermediate',
      'startDate': '2024-04-15',
      'endDate': '2024-06-15',
      'participants': 120,
      'maxParticipants': 200,
      'startingBalance': 100000,
      'status': 'active',
      'prizePool': 15000,
    },
    {
      'id': '3',
      'name': 'Wall Street Elite',
      'description': 'Premium contest for experienced traders',
      'ageGroups': ['adults'],
      'difficulty': 'advanced',
      'startDate': '2024-05-01',
      'endDate': '2024-07-01',
      'participants': 75,
      'maxParticipants': 150,
      'startingBalance': 250000,
      'status': 'active',
      'prizePool': 50000,
    },
  ];

  @override
  void initState() {
    super.initState();
    _loadContests();
  }

  Future<void> _loadContests() async {
    // Simulate API call
    await Future.delayed(Duration(seconds: 1));
    setState(() {
      _isLoading = false;
    });
  }

  List<Map<String, dynamic>> _getFilteredContests() {
    if (_selectedDifficulty == 'all') {
      return _contests;
    }
    return _contests.where((c) => c['difficulty'] == _selectedDifficulty).toList();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        title: Text('Contests'),
        backgroundColor: AppColor.primaryColor,
        elevation: 0,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDifficultyFilter(size),
                  SizedBox(height: 16),
                  _buildContestsList(size),
                  SizedBox(height: 20),
                ],
              ),
            ),
    );
  }

  Widget _buildDifficultyFilter(Size size) {
    return Container(
      padding: EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Filter by Difficulty',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppColor.fourthColor,
            ),
          ),
          SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: ['all', 'beginner', 'intermediate', 'advanced']
                  .map((difficulty) {
                return Container(
                  margin: EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(difficulty.toUpperCase()),
                    selected: _selectedDifficulty == difficulty,
                    onSelected: (selected) {
                      setState(() {
                        _selectedDifficulty = difficulty;
                      });
                    },
                    selectedColor: AppColor.secondaryColor,
                    labelStyle: TextStyle(
                      color: _selectedDifficulty == difficulty
                          ? Colors.white
                          : AppColor.content,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContestsList(Size size) {
    final contests = _getFilteredContests();

    if (contests.isEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(40),
          child: Text('No contests found'),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      padding: EdgeInsets.symmetric(horizontal: 20),
      itemCount: contests.length,
      itemBuilder: (context, index) {
        return _buildContestCard(contests[index], context);
      },
    );
  }

  Widget _buildContestCard(Map<String, dynamic> contest, BuildContext context) {
    final participationPercent =
        (contest['participants'] / contest['maxParticipants'] * 100).toStringAsFixed(0);

    return Container(
      margin: EdgeInsets.only(bottom: 16),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Color(0xFFE0E0E0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                contest['name'],
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColor.fourthColor,
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColor.primaryColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  contest['difficulty'].toUpperCase(),
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Text(
            contest['description'],
            style: TextStyle(
              fontSize: 13,
              color: AppColor.content.withOpacity(0.7),
            ),
          ),
          SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildContestInfo('Starting Balance', '\$${contest['startingBalance']}'),
              _buildContestInfo('Prize Pool', '\$${contest['prizePool']}'),
              _buildContestInfo('Duration', '${DateTime.parse(contest['endDate']).difference(DateTime.parse(contest['startDate'])).inDays} days'),
            ],
          ),
          SizedBox(height: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Participants: ${contest['participants']}/${contest['maxParticipants']}',
                    style: TextStyle(fontSize: 12, color: AppColor.content),
                  ),
                  Text(
                    '$participationPercent%',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppColor.secondaryColor,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: contest['participants'] / contest['maxParticipants'],
                  minHeight: 6,
                  valueColor: AlwaysStoppedAnimation(AppColor.secondaryColor),
                  backgroundColor: Color(0xFFE0E0E0),
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                _joinContest(context, contest);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColor.secondaryColor,
                padding: EdgeInsets.symmetric(vertical: 12),
              ),
              child: Text(
                'Join Contest',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContestInfo(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 11, color: AppColor.content.withOpacity(0.6)),
        ),
        SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: AppColor.fourthColor,
          ),
        ),
      ],
    );
  }

  void _joinContest(BuildContext context, Map<String, dynamic> contest) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Join ${contest['name']}?'),
          content: Text(
            'You will receive a starting balance of \$${contest['startingBalance']} for this contest.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Successfully joined contest!'),
                    backgroundColor: Colors.green,
                  ),
                );
                Future.delayed(Duration(seconds: 1), () {
                  Navigator.pushNamed(
                    context,
                    'contest_leaderboard',
                    arguments: contest['id'],
                  );
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColor.secondaryColor,
              ),
              child: Text('Join Now'),
            ),
          ],
        );
      },
    );
  }
}
