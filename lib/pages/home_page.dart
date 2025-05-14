import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../providers/transaction_provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String timeRange = 'Monthly';
  final _supabase = Supabase.instance.client;
  @override
  void initState() {
    super.initState();
    final provider = Provider.of<TransactionProvider>(context, listen: false);
    provider.fetchTransactions(
      _supabase.auth.currentUser!.id,
    ); // Replace with actual user ID
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<TransactionProvider>(context);
    final income = provider.getIncome();
    final expenses = provider.getExpenses();
    final net = income - expenses;
    final transactions = provider.transactions;
    final supabase = Supabase.instance.client;
    return Scaffold(
      appBar: AppBar(
        title: Text('Budget App'),
        actions: [
          DropdownButton<String>(
            value: timeRange,
            items:
                ['Weekly', 'Monthly', 'Yearly']
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
            onChanged: (value) {
              setState(() => timeRange = value!);
              provider.fetchTransactions(
                supabase.auth.currentUser!.id,
                timeRange: value,
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Summary Card
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Column(
                      children: [
                        Text('Income', style: TextStyle(color: Colors.green)),
                        Text(
                          '\$${income.toStringAsFixed(2)}',
                          style: TextStyle(fontSize: 18),
                        ),
                      ],
                    ),
                    Column(
                      children: [
                        Text('Expenses', style: TextStyle(color: Colors.red)),
                        Text(
                          '\$${expenses.toStringAsFixed(2)}',
                          style: TextStyle(fontSize: 18),
                        ),
                      ],
                    ),
                    Column(
                      children: [
                        Text('Net', style: TextStyle(color: Colors.blue)),
                        Text(
                          '\$${net.toStringAsFixed(2)}',
                          style: TextStyle(fontSize: 18),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 16),
            // Pie Chart
            SizedBox(
              height: 200,
              child: PieChart(
                PieChartData(
                  sections: [
                    PieChartSectionData(
                      value: expenses,
                      color: Colors.red,
                      title: 'Expenses',
                      titleStyle: TextStyle(color: Colors.white),
                    ),
                    PieChartSectionData(
                      value: income,
                      color: Colors.green,
                      title: 'Income',
                      titleStyle: TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 16),
            // Recent Transactions
            Text('Recent Transactions', style: TextStyle(fontSize: 18)),
            Expanded(
              child: ListView.builder(
                itemCount: transactions.length > 5 ? 5 : transactions.length,
                itemBuilder: (context, index) {
                  final tx = transactions[index];
                  return ListTile(
                    title: Text(tx.category),
                    subtitle: Text(DateFormat('MMM dd, yyyy').format(tx.date)),
                    trailing: Text('\$${tx.amount.toStringAsFixed(2)}'),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pushNamed(context, '/add-transaction'),
        child: Icon(Icons.add),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: 'Transactions',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.analytics),
            label: 'AI Analysis',
          ),
        ],
        onTap: (index) {
          if (index == 1) {
            Navigator.pushNamed(context, '/transaction-list');
          } else if (index == 2) {
            Navigator.pushNamed(context, '/ai-analysis');
          }
        },
      ),
    );
  }
}
