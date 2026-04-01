import 'package:flutter/material.dart';
import 'package:beanstalk_mobile/src/ui/app_skin.dart';

class PortfolioDashboardPage extends StatefulWidget {
  @override
  _PortfolioDashboardPageState createState() => _PortfolioDashboardPageState();
}

class _PortfolioDashboardPageState extends State<PortfolioDashboardPage> {
  bool _isLoading = true;

  // Portfolio data
  double _totalBalance = 10000.0;
  double _currentValue = 108500.0;
  double _totalReturn = 8500.0;
  double _returnPercent = 8.5;

  List<Map<String, dynamic>> _positions = [
    {
      'symbol': 'AAPL',
      'quantity': 10.0,
      'purchasePrice': 150.0,
      'currentPrice': 165.5,
      'currentValue': 1655.0,
      'gainLoss': 155.0,
      'gainLossPercent': 10.33,
    },
    {
      'symbol': 'GOOGL',
      'quantity': 5.0,
      'purchasePrice': 2800.0,
      'currentPrice': 2920.0,
      'currentValue': 14600.0,
      'gainLoss': 600.0,
      'gainLossPercent': 4.29,
    },
    {
      'symbol': 'MSFT',
      'quantity': 8.0,
      'purchasePrice': 280.0,
      'currentPrice': 310.0,
      'currentValue': 2480.0,
      'gainLoss': 240.0,
      'gainLossPercent': 10.71,
    },
  ];

  @override
  void initState() {
    super.initState();
    _loadPortfolioData();
  }

  Future<void> _loadPortfolioData() async {
    // Simulate API call
    await Future.delayed(Duration(seconds: 2));
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        title: Text('Portfolio Dashboard'),
        backgroundColor: AppColor.primaryColor,
        elevation: 0,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildPortfolioSummary(size),
                  SizedBox(height: 20),
                  _buildPerformanceChart(size),
                  SizedBox(height: 20),
                  _buildPositionsSection(size),
                  SizedBox(height: 20),
                  _buildActionButtons(context, size),
                  SizedBox(height: 20),
                ],
              ),
            ),
    );
  }

  Widget _buildPortfolioSummary(Size size) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColor.primaryColor, AppColor.secondaryColor],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Portfolio Value',
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 14,
            ),
          ),
          SizedBox(height: 8),
          Text(
            '\$${_currentValue.toStringAsFixed(2)}',
            style: TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildSummaryItem('Starting Balance', '\$${_totalBalance.toStringAsFixed(0)}'),
              _buildSummaryItem(
                'Total Return',
                '\$${_totalReturn.toStringAsFixed(2)}',
                color: _totalReturn >= 0 ? Colors.greenAccent : Colors.redAccent,
              ),
              _buildSummaryItem(
                'Return %',
                '${_returnPercent.toStringAsFixed(2)}%',
                color: _returnPercent >= 0 ? Colors.greenAccent : Colors.redAccent,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value, {Color? color}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.7),
            fontSize: 11,
          ),
        ),
        SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            color: color ?? Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildPerformanceChart(Size size) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Color(0xFFE0E0E0)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Performance Overview',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColor.fourthColor,
            ),
          ),
          SizedBox(height: 20),
          Container(
            height: 150,
            decoration: BoxDecoration(
              color: Color(0xFFF8F9FA),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                'Chart Placeholder',
                style: TextStyle(color: AppColor.content),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPositionsSection(Size size) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Current Positions (${_positions.length})',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColor.fourthColor,
            ),
          ),
          SizedBox(height: 12),
          Column(
            children: _positions.map((position) {
              return _buildPositionCard(position);
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildPositionCard(Map<String, dynamic> position) {
    bool isGain = position['gainLoss'] >= 0;

    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Color(0xFFE0E0E0)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  position['symbol'],
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColor.fourthColor,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  '${position['quantity'].toStringAsFixed(1)} shares @ \$${position['currentPrice'].toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 12,
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
                '\$${position['currentValue'].toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColor.fourthColor,
                ),
              ),
              SizedBox(height: 4),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: isGain ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  '${isGain ? '+' : ''}\$${position['gainLoss'].toStringAsFixed(2)} (${position['gainLossPercent'].toStringAsFixed(2)}%)',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: isGain ? Colors.green : Colors.red,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, Size size) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () {
                // Navigate to trading page
                Navigator.pushNamed(context, 'trading');
              },
              icon: Icon(Icons.shopping_cart),
              label: Text('Trade'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColor.secondaryColor,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () {
                // Navigate to history page
                Navigator.pushNamed(context, 'transaction_history');
              },
              icon: Icon(Icons.history),
              label: Text('History'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColor.primaryColor,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
