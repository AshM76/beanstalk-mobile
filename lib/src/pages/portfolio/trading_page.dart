import 'package:flutter/material.dart';
import 'package:beanstalk_mobile/src/ui/app_skin.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:beanstalk_mobile/src/preferences/user_preference.dart';

class TradingPage extends StatefulWidget {
  @override
  _TradingPageState createState() => _TradingPageState();
}

class _TradingPageState extends State<TradingPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final TextEditingController _symbolController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();

  String _selectedAction = 'buy';
  double _totalCost = 0.0;
  double _currentPrice = 0.0;
  bool _isLoadingPrice = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _symbolController.addListener(() {
      _fetchCurrentPrice(_symbolController.text.trim());
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _symbolController.dispose();
    _quantityController.dispose();
    super.dispose();
  }

  void _calculateTotal() {
    final quantity = double.tryParse(_quantityController.text) ?? 0;
    setState(() {
      _totalCost = quantity * _currentPrice;
    });
  }

  Future<void> _fetchCurrentPrice(String symbol) async {
    if (symbol.isEmpty) return;

    setState(() {
      _isLoadingPrice = true;
    });

    try {
      final prefs = UserPreference();
      await prefs.initPrefs();
      final token = prefs.token;

      final response = await http.get(
        Uri.parse('https://staging.beanstalk.app/api/market/price/$symbol'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _currentPrice = data['price'] ?? 0.0;
          _calculateTotal();
        });
      } else {
        // Handle error
        setState(() {
          _currentPrice = 0.0;
        });
      }
    } catch (e) {
      setState(() {
        _currentPrice = 0.0;
      });
    } finally {
      setState(() {
        _isLoadingPrice = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        title: Text('Trading'),
        backgroundColor: AppColor.primaryColor,
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: 'Buy'),
            Tab(text: 'Sell'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildTradeForm(context, size, 'buy'),
          _buildTradeForm(context, size, 'sell'),
        ],
      ),
    );
  }

  Widget _buildTradeForm(BuildContext context, Size size, String action) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Execute ${action.toUpperCase()} Trade',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColor.fourthColor,
            ),
          ),
          SizedBox(height: 24),
          _buildInputField('Symbol', 'e.g., AAPL', _symbolController),
          SizedBox(height: 16),
          _buildCurrentPriceDisplay(),
          SizedBox(height: 16),
          _buildInputField('Quantity', 'Number of shares', _quantityController, isNumeric: true),
          SizedBox(height: 24),
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Color(0xFFF8F9FA),
              border: Border.all(color: AppColor.primaryColor),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Order Summary',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColor.fourthColor,
                  ),
                ),
                SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Total Cost/Proceeds:'),
                    Text(
                      '\$${_totalCost.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColor.secondaryColor,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Est. Fee (0%):'),
                    Text('\$0.00'),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                _executeTrade(context, action);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: action == 'buy' ? Colors.green : Colors.red,
                padding: EdgeInsets.symmetric(vertical: 16),
              ),
              child: Text(
                'Confirm ${action.toUpperCase()}',
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
            child: OutlinedButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputField(
    String label,
    String hint,
    TextEditingController controller, {
    bool isNumeric = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: AppColor.fourthColor,
          ),
        ),
        SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: isNumeric ? TextInputType.number : TextInputType.text,
          onChanged: (_) => _calculateTotal(),
          decoration: InputDecoration(
            hintText: hint,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
      ],
    );
  }

  Widget _buildCurrentPriceDisplay() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Current Price',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: AppColor.fourthColor,
          ),
        ),
        SizedBox(height: 8),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Text(
                _isLoadingPrice ? 'Loading...' : '\$${_currentPrice.toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 16,
                  color: _isLoadingPrice ? Colors.grey : AppColor.fourthColor,
                ),
              ),
              if (_isLoadingPrice)
                SizedBox(width: 8),
              if (_isLoadingPrice)
                SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
            ],
          ),
        ),
      ],
    );
  }

  void _executeTrade(BuildContext context, String action) {
    final symbol = _symbolController.text.trim();
    final quantity = double.tryParse(_quantityController.text);

    if (symbol.isEmpty || quantity == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill in all fields')),
      );
      return;
    }

    if (_currentPrice == 0.0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Unable to get current price. Please check symbol')),
      );
      return;
    }

    // Show confirmation dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm ${action.toUpperCase()}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Symbol: $symbol'),
              Text('Quantity: ${quantity.toStringAsFixed(1)} shares'),
              Text('Price: \$${_currentPrice.toStringAsFixed(2)}'),
              SizedBox(height: 12),
              Text(
                'Total: \$${_totalCost.toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColor.secondaryColor,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(context);
                await _submitTrade(context, action, symbol, quantity);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: action == 'buy' ? Colors.green : Colors.red,
              ),
              child: Text('Confirm'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _submitTrade(BuildContext context, String action, String symbol, double quantity) async {
    try {
      final prefs = UserPreference();
      await prefs.initPrefs();
      final token = prefs.token;
      final userId = prefs.id;

      if (token.isEmpty || userId.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Authentication required. Please log in again.')),
        );
        return;
      }

      final response = await http.post(
        Uri.parse('https://staging.beanstalk.app/api/portfolio/$userId/trade'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'action': action,
          'symbol': symbol,
          'quantity': quantity,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${action.toUpperCase()} order executed successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        // Optionally refresh portfolio or navigate
        Future.delayed(Duration(seconds: 2), () {
          Navigator.pop(context);
        });
      } else {
        final error = json.decode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Trade failed: ${error['error'] ?? 'Unknown error'}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Network error. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
