import 'package:flutter/material.dart';
import 'package:beanstalk_mobile/src/ui/app_skin.dart';

class ContestLeaderboardPage extends StatefulWidget {
  final String? contestId;

  const ContestLeaderboardPage({this.contestId});

  @override
  _ContestLeaderboardPageState createState() => _ContestLeaderboardPageState();
}

class _ContestLeaderboardPageState extends State<ContestLeaderboardPage> {
  bool _isLoading = true;
  String _selectedAgeGroup = 'all';

  List<Map<String, dynamic>> _rankings = [
    {
      'rank': 1,
      'username': 'InvestorPro',
      'ageGroup': 'high_school',
      'portfolioValue': 58500.0,
      'returnPercent': 17.0,
      'positionCount': 5,
      'bestPosition': 'TSLA',
    },
    {
      'rank': 2,
      'username': 'StockMaster',
      'ageGroup': 'high_school',
      'portfolioValue': 56200.0,
      'returnPercent': 12.4,
      'positionCount': 4,
      'bestPosition': 'MSFT',
    },
    {
      'rank': 3,
      'username': 'TradeKing',
      'ageGroup': 'high_school',
      'portfolioValue': 54800.0,
      'returnPercent': 9.6,
      'positionCount': 6,
      'bestPosition': 'GOOGL',
    },
    {
      'rank': 4,
      'username': 'MarketWatcher',
      'ageGroup': 'college',
      'portfolioValue': 52100.0,
      'returnPercent': 4.2,
      'positionCount': 3,
      'bestPosition': 'AAPL',
    },
    {
      'rank': 5,
      'username': 'FutureTrader',
      'ageGroup': 'college',
      'portfolioValue': 51500.0,
      'returnPercent': 3.0,
      'positionCount': 7,
      'bestPosition': 'NFLX',
    },
  ];

  @override
  void initState() {
    super.initState();
    _loadLeaderboard();
  }

  Future<void> _loadLeaderboard() async {
    // Simulate API call
    await Future.delayed(Duration(seconds: 1));
    setState(() {
      _isLoading = false;
    });
  }

  List<Map<String, dynamic>> _getFilteredRankings() {
    if (_selectedAgeGroup == 'all') {
      return _rankings;
    }
    return _rankings.where((r) => r['ageGroup'] == _selectedAgeGroup).toList();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        title: Text('Leaderboard'),
        backgroundColor: AppColor.primaryColor,
        elevation: 0,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildAgeGroupFilter(size),
                  SizedBox(height: 16),
                  _buildTopThree(size),
                  SizedBox(height: 20),
                  _buildRankingsList(size),
                  SizedBox(height: 20),
                ],
              ),
            ),
    );
  }

  Widget _buildAgeGroupFilter(Size size) {
    return Container(
      padding: EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Filter by Age Group',
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
              children: ['all', 'high_school', 'college', 'adults']
                  .map((ageGroup) {
                return Container(
                  margin: EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(ageGroup.replaceAll('_', ' ').toUpperCase()),
                    selected: _selectedAgeGroup == ageGroup,
                    onSelected: (selected) {
                      setState(() {
                        _selectedAgeGroup = ageGroup;
                      });
                    },
                    selectedColor: AppColor.secondaryColor,
                    labelStyle: TextStyle(
                      color: _selectedAgeGroup == ageGroup
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

  Widget _buildTopThree(Size size) {
    final rankings = _getFilteredRankings();
    if (rankings.isEmpty) return SizedBox.shrink();

    final top3 = rankings.take(3).toList();

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          // 2nd and 3rd place (bottom row)
          if (top3.length > 1)
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (top3.length > 1) _buildPodiumCard(top3[1], size, 2),
                SizedBox(width: 20),
                if (top3.isNotEmpty) _buildPodiumCard(top3[0], size, 1),
                SizedBox(width: 20),
                if (top3.length > 2) _buildPodiumCard(top3[2], size, 3),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildPodiumCard(Map<String, dynamic> ranking, Size size, int position) {
    final heightMultiplier = position == 1 ? 1.0 : position == 2 ? 0.85 : 0.7;
    final colors = [AppColor.primaryColor, Colors.amber, Colors.brown];

    return Expanded(
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: colors[position - 1],
              borderRadius: BorderRadius.circular(50),
            ),
            child: Text(
              '$position',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SizedBox(height: 8),
          Container(
            height: 100 * heightMultiplier,
            width: double.infinity,
            decoration: BoxDecoration(
              color: colors[position - 1].withOpacity(0.2),
              border: Border.all(color: colors[position - 1]),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Text(
                  ranking['username'],
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppColor.fourthColor,
                  ),
                ),
                Text(
                  '\$${ranking['portfolioValue'].toStringAsFixed(0)}',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: colors[position - 1],
                  ),
                ),
                Text(
                  '+${ranking['returnPercent'].toStringAsFixed(1)}%',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRankingsList(Size size) {
    final rankings = _getFilteredRankings();

    if (rankings.isEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(40),
          child: Text('No rankings available'),
        ),
      );
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Full Rankings',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColor.fourthColor,
            ),
          ),
          SizedBox(height: 12),
          ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: rankings.length,
            itemBuilder: (context, index) {
              return _buildRankingCard(rankings[index], index);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildRankingCard(Map<String, dynamic> ranking, int index) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Color(0xFFE0E0E0)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColor.primaryColor,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '${ranking['rank']}',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  ranking['username'],
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColor.fourthColor,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  '${ranking['positionCount']} positions • Best: ${ranking['bestPosition']}',
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColor.content.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '\$${ranking['portfolioValue'].toStringAsFixed(0)}',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColor.fourthColor,
                ),
              ),
              SizedBox(height: 4),
              Text(
                '+${ranking['returnPercent'].toStringAsFixed(1)}%',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
