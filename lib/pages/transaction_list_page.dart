import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import '../providers/transaction_provider.dart';
import '../models/transaction.dart';

class TransactionListPage extends StatefulWidget {
  const TransactionListPage({super.key});

  @override
  _TransactionListPageState createState() => _TransactionListPageState();
}

class _TransactionListPageState extends State<TransactionListPage> {
  String? filterCategory;
  String searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<TransactionProvider>(context);
    final transactions =
        provider.transactions
            .where(
              (tx) =>
                  (filterCategory == null || tx.category == filterCategory) &&
                  (searchQuery.isEmpty ||
                      tx.category.toLowerCase().contains(
                        searchQuery.toLowerCase(),
                      ) ||
                      tx.notes?.toLowerCase().contains(
                            searchQuery.toLowerCase(),
                          ) ==
                          true),
            )
            .toList();
    final breakdown = provider.getCategoryBreakdown();

    return Scaffold(
      appBar: AppBar(title: Text('Transactions')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search and Filter
            TextField(
              decoration: InputDecoration(
                labelText: 'Search',
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (value) => setState(() => searchQuery = value),
            ),
            DropdownButton<String>(
              hint: Text('Filter by Category'),
              value: filterCategory,
              items:
                  provider.categories
                      .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                      .toList()
                    ..add(DropdownMenuItem(value: null, child: Text('All'))),
              onChanged: (value) => setState(() => filterCategory = value),
            ),
            SizedBox(height: 16),
            // Pie Chart
            SizedBox(
              height: 200,
              child: PieChart(
                PieChartData(
                  sections:
                      breakdown.entries
                          .map(
                            (e) => PieChartSectionData(
                              value: e.value,
                              title: e.key,
                              color:
                                  Colors.primaries[breakdown.keys
                                          .toList()
                                          .indexOf(e.key) %
                                      Colors.primaries.length],
                              titleStyle: TextStyle(color: Colors.white),
                            ),
                          )
                          .toList(),
                ),
              ),
            ),
            SizedBox(height: 16),
            // Transaction List
            Expanded(
              child: ListView.builder(
                itemCount: transactions.length,
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
            // Export Button
            ElevatedButton(
              onPressed: () {
                final csv = [
                  'Date,Category,Amount,Type,Notes',
                  ...transactions.map(
                    (tx) =>
                        '${tx.date.toIso8601String()},${tx.category},${tx.amount},${tx.type},${tx.notes ?? ''}',
                  ),
                ].join('\n');
                Share.share(csv, subject: 'Transactions Export');
              },
              child: Text('Export as CSV'),
            ),
          ],
        ),
      ),
    );
  }
}
