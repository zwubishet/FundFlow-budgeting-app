import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/transaction_provider.dart';

class AIAnalysisPage extends StatefulWidget {
  const AIAnalysisPage({Key? key}) : super(key: key);

  @override
  _AIAnalysisPageState createState() => _AIAnalysisPageState();
}

class _AIAnalysisPageState extends State<AIAnalysisPage> {
  final TextEditingController _chatController = TextEditingController();
  List<String> _insights = [];
  double savingsGoal = 500.0;
  double budgetAdjustment = 100.0;

  @override
  void initState() {
    super.initState();
    _generateInsights();
  }

  void _generateInsights() {
    final provider = Provider.of<TransactionProvider>(context, listen: false);
    final breakdown = provider.getCategoryBreakdown();
    final expenses = provider.getExpenses();

    // Basic rule-based insights (replace with AI models later)
    setState(() {
      _insights = [
        'You spent \$${breakdown['Food']?.toStringAsFixed(2) ?? '0.00'} on Food this month.',
        if (breakdown['Food'] != null && breakdown['Food']! > 300)
          'Consider reducing Food spending by 20%.',
        'Your total expenses are \$${expenses.toStringAsFixed(2)}.',
      ];
    });
  }

  void _handleChatQuery(String query) {
    final provider = Provider.of<TransactionProvider>(context, listen: false);
    final breakdown = provider.getCategoryBreakdown();
    // Basic rule-based chatbot (replace with Hugging Face API)
    String response = 'Sorry, I didn’t understand.';
    if (query.toLowerCase().contains('grocery') ||
        query.toLowerCase().contains('food')) {
      response =
          'You spent \$${breakdown['Food']?.toStringAsFixed(2) ?? '0.00'} on Food.';
    }
    setState(() {
      _insights.add('You: $query');
      _insights.add('AI: $response');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('AI Analysis & Planning')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Insights
            Text('Insights', style: TextStyle(fontSize: 18)),
            Expanded(
              flex: 2,
              child: ListView.builder(
                itemCount: _insights.length,
                itemBuilder: (context, index) {
                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(_insights[index]),
                    ),
                  );
                },
              ),
            ),
            // Savings Goal
            Text('Savings Goal: \$${savingsGoal.toStringAsFixed(2)}'),
            Slider(
              value: savingsGoal,
              min: 0,
              max: 1000,
              divisions: 100,
              onChanged: (value) => setState(() => savingsGoal = value),
            ),
            // Budget Adjustment
            Text(
              'Reduce Food Budget by: \$${budgetAdjustment.toStringAsFixed(2)}',
            ),
            Slider(
              value: budgetAdjustment,
              min: 0,
              max: 500,
              divisions: 50,
              onChanged: (value) => setState(() => budgetAdjustment = value),
            ),
            // Chatbot
            TextField(
              controller: _chatController,
              decoration: InputDecoration(
                labelText: 'Ask AI (e.g., "How much on groceries?")',
                suffixIcon: IconButton(
                  icon: Icon(Icons.send),
                  onPressed: () {
                    _handleChatQuery(_chatController.text);
                    _chatController.clear();
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
