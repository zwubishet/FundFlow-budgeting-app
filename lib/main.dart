import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:provider/provider.dart';
import 'pages/home_page.dart';
import 'pages/add_transaction_page.dart';
import 'pages/transaction_list_page.dart';
import 'pages/ai_analysis_page.dart';
import 'pages/login_page.dart';
import 'pages/register_page.dart';
import 'providers/transaction_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: 'https://hssawpkmmgkxcjlwkkvc.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imhzc2F3cGttbWdreGNqbHdra3ZjIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDA5ODk5MjksImV4cCI6MjA1NjU2NTkyOX0.tcRfw9rhSeibckEef9F-S1KDIU2s0V59j0yrZQndEcU',
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final supabase = Supabase.instance.client;
    final initialRoute =
        supabase.auth.currentSession != null ? '/home' : '/login';

    return ChangeNotifierProvider(
      create: (_) => TransactionProvider(),
      child: MaterialApp(
        title: 'Budget App',
        theme: ThemeData(primarySwatch: Colors.blue),
        initialRoute: initialRoute,
        routes: {
          '/login': (context) => LoginPage(),
          '/register': (context) => RegisterPage(),
          '/home': (context) => HomePage(),
          '/add-transaction': (context) => AddTransactionPage(),
          '/transaction-list': (context) => TransactionListPage(),
          '/ai-analysis': (context) => AIAnalysisPage(),
        },
      ),
    );
  }
}
