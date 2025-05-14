import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/transaction.dart';

class TransactionProvider with ChangeNotifier {
  final supabase = Supabase.instance.client;
  List<Transaction> _transactions = [];
  List<String> _categories = ['Food', 'Rent', 'Salary', 'Utilities', 'Other'];

  List<Transaction> get transactions => _transactions;
  List<String> get categories => _categories;

  Future<void> fetchTransactions(
    String userId, {
    String? timeRange = 'Monthly',
  }) async {
    try {
      DateTime startDate;
      switch (timeRange) {
        case 'Weekly':
          startDate = DateTime.now().subtract(Duration(days: 7));
          break;
        case 'Yearly':
          startDate = DateTime.now().subtract(Duration(days: 365));
          break;
        default:
          startDate = DateTime.now().subtract(Duration(days: 30));
      }

      final response = await supabase
          .from('transactions')
          .select()
          .eq('user_id', userId)
          .gte('date', startDate.toIso8601String());

      _transactions =
          (response as List).map((json) => Transaction.fromJson(json)).toList();
      print('Fetched ${_transactions.length} transactions for user: $userId');
      notifyListeners();
    } catch (e) {
      print('Error fetching transactions: $e');
      throw e; // Rethrow to allow callers (e.g., HomePage) to handle errors
    }
  }

  Future<void> fetchCategories() async {
    try {
      final response = await supabase.from('categories').select('name');
      _categories = (response as List).map((c) => c['name'] as String).toList();
      if (_categories.isEmpty) {
        _categories = ['Food', 'Rent', 'Salary', 'Utilities', 'Other'];
        print('No categories found in database, using defaults');
      } else {
        print('Fetched ${_categories.length} categories');
      }
      notifyListeners();
    } catch (e) {
      print('Error fetching categories: $e');
      _categories = ['Food', 'Rent', 'Salary', 'Utilities', 'Other'];
      notifyListeners();
    }
  }

  Future<void> addTransaction(Transaction transaction) async {
    try {
      await supabase.from('transactions').insert(transaction.toJson());
      _transactions.add(transaction);
      print('Transaction added: ${transaction.id}');
      notifyListeners();
    } catch (e) {
      print('Error adding transaction: $e');
      throw e; // Rethrow to allow AddTransactionPage to display the error
    }
  }

  double getIncome() {
    return _transactions
        .where((tx) => tx.type == 'income')
        .fold(0.0, (sum, tx) => sum + tx.amount);
  }

  double getExpenses() {
    return _transactions
        .where((tx) => tx.type == 'expense')
        .fold(0.0, (sum, tx) => sum + tx.amount);
  }

  Map<String, double> getCategoryBreakdown() {
    Map<String, double> breakdown = {};
    for (var tx in _transactions.where((tx) => tx.type == 'expense')) {
      breakdown[tx.category] = (breakdown[tx.category] ?? 0) + tx.amount;
    }
    return breakdown;
  }
}
