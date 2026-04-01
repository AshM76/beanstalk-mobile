import 'package:flutter/material.dart';
import 'package:beanstalk_mobile/src/ui/app_skin.dart';

class TransactionHistoryPage extends StatefulWidget {
  @override
  _TransactionHistoryPageState createState() => _TransactionHistoryPageState();
}

class _TransactionHistoryPageState extends State<TransactionHistoryPage> {
  bool _isLoading = true;
  String _selectedType = 'all';

  List<Map<String, dynamic>> _transactions = [
    {
      'id': '1',
      'type': 'buy',
      'symbol': 'AAPL',
      'quantity': 10,
      'price': 150.0,
      'amount': 1500.0,
      'date': '2024-03-15',
      'time': '10:30 AM',
      'status': 'completed',
    },
    {
      'id': '2',
      'type': 'buy',
      'symbol': 'GOOGL',
      'quantity': 5,
      'price': 2800.0,
      'amount': 14000.0,
      'date': '2024-03-14',
      'time': '2:15 PM',
      'status': 'completed',
    },
    {
      'id': '3',
      'type': 'sell',
      'symbol': 'MSFT',
      'quantity': 3,
      'price': 310.0,
      'amount': 930.0,
      'date': '2024-03-13',
      'time': '11:45 AM',
      'status': 'completed',
    },
    {
      'id': '4',
      'type': 'buy',
      'symbol': 'TSLA',
      'quantity': 2,
      'price': 250.0,
      'amount': 500.0,
      'date': '2024-03-12',
      'time': '9:00 AM',
      'status': 'completed',
    },
    {
      'id': '5',
      'type': 'dividend',
      'symbol': 'AAPL',
      'quantity': 10,
      'price': 0.23,
      'amount': 2.30,
      'date': '2024-03-10',
      'time': '4:00 PM',
      'status': 'completed',
    },
    {
      'id': '6',
      'type': 'sell',
      'symbol': 'NFLX',
      'quantity': 5,
      'price': 450.0,
      'amount': 2250.0,
      'date': '2024-03-09',
      'time': '1:30 PM',
      'status': 'completed',
    },
  ];

  @override
  void initState() {
    super.initState();
    _loadTransactions();
  }

  Future<void> _loadTransactions() async {
    // Simulate API call
    await Future.delayed(Duration(seconds: 1));
    setState(() {
      _isLoading = false;
    });
  }

  List<Map<String, dynamic>> _getFilteredTransactions() {
    if (_selectedType == 'all') {
      return _transactions;
    }
    return _transactions.where((t) => t['type'] == _selectedType).toList();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        title: Text('Transaction History'),
        backgroundColor: AppColor.primaryColor,
        elevation: 0,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTypeFilter(size),
                  SizedBox(height: 16),
                  _buildTransactionsList(size),
                  SizedBox(height: 20),
                ],
              ),
            ),
    );
  }

  Widget _buildTypeFilter(Size size) {
    return Container(
      padding: EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Filter by Type',
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
              children: ['all', 'buy', 'sell', 'dividend']
                  .map((type) {
                return Container(
                  margin: EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(type.toUpperCase()),
                    selected: _selectedType == type,
                    onSelected: (selected) {
                      setState(() {
                        _selectedType = type;
                      });
                    },
                    selectedColor: AppColor.secondaryColor,
                    labelStyle: TextStyle(
                      color: _selectedType == type
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

  Widget _buildTransactionsList(Size size) {
    final transactions = _getFilteredTransactions();

    if (transactions.isEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(40),
          child: Text('No transactions found'),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      padding: EdgeInsets.symmetric(horizontal: 20),
      itemCount: transactions.length,
      itemBuilder: (context, index) {
        return _buildTransactionCard(transactions[index]);
      },
    );
  }

  Widget _buildTransactionCard(Map<String, dynamic> transaction) {
    final isBuy = transaction['type'] == 'buy';
    final isSell = transaction['type'] == 'sell';
    final isDividend = transaction['type'] == 'dividend';

    Color typeColor = Colors.grey;
    IconData typeIcon = Icons.swap_horiz;

    if (isBuy) {
      typeColor = Colors.green;
      typeIcon = Icons.arrow_downward;
    } else if (isSell) {
      typeColor = Colors.red;
      typeIcon = Icons.arrow_upward;
    } else if (isDividend) {
      typeColor = Colors.blue;
      typeIcon = Icons.trending_up;
    }

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
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: typeColor.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Icon(
                typeIcon,
                color: typeColor,
                size: 24,
              ),
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${transaction['type'].toUpperCase()} ${transaction['symbol']}',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColor.fourthColor,
                      ),
                    ),
                    if (isDividend)
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'Dividend',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                      ),
                  ],
                ),
                SizedBox(height: 4),
                Text(
                  '${transaction['quantity'].toStringAsFixed(0)} shares @ \$${transaction['price'].toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColor.content.withOpacity(0.7),
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  '${transaction['date']} at ${transaction['time']}',
                  style: TextStyle(
                    fontSize: 10,
                    color: AppColor.content.withOpacity(0.5),
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${isSell ? '+' : '-'}\$${transaction['amount'].toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: isSell ? Colors.green : Colors.red,
                ),
              ),
              SizedBox(height: 4),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  transaction['status'],
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
