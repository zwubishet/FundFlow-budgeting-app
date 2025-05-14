import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import '../providers/transaction_provider.dart';
import '../models/transaction.dart';
import 'dart:io';

class AddTransactionPage extends StatefulWidget {
  const AddTransactionPage({super.key});

  @override
  _AddTransactionPageState createState() => _AddTransactionPageState();
}

class _AddTransactionPageState extends State<AddTransactionPage> {
  final _formKey = GlobalKey<FormState>();
  double? amount;
  String? category;
  DateTime date = DateTime.now();
  String type = 'expense';
  String? notes;
  File? receipt;
  final supabase = Supabase.instance.client;

  Future<void> _pickReceipt() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      setState(() {
        receipt = File(pickedFile.path);
      });
    }
  }

  Future<void> _saveTransaction(TransactionProvider provider) async {
    print("transaction save start....");
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      final userId = supabase.auth.currentUser!.id;
      final transaction = Transaction(
        id: Uuid().v4(),
        userId: userId,
        amount: amount!,
        category: category!,
        date: date,
        type: type,
        notes: notes,
      );
      print("transaction save proccessing....");
      // Upload receipt if present
      if (receipt != null) {
        await supabase.storage
            .from('receipts')
            .upload('$userId/${transaction.id}.jpg', receipt!);
      }
      print("transaction save procedd....");
      await provider.addTransaction(transaction);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<TransactionProvider>(context);
    final categories = provider.categories;

    return Scaffold(
      appBar: AppBar(title: Text('Add Transaction')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                decoration: InputDecoration(labelText: 'Amount'),
                keyboardType: TextInputType.number,
                validator: (value) => value!.isEmpty ? 'Enter an amount' : null,
                onSaved: (value) => amount = double.parse(value!),
              ),
              DropdownButtonFormField<String>(
                decoration: InputDecoration(labelText: 'Category'),
                value: category,
                items:
                    categories
                        .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                        .toList(),
                validator:
                    (value) => value == null ? 'Select a category' : null,
                onChanged: (value) => setState(() => category = value),
              ),
              ListTile(
                title: Text('Date: ${DateFormat('MMM dd, yyyy').format(date)}'),
                trailing: Icon(Icons.calendar_today),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: date,
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                  );
                  if (picked != null) setState(() => date = picked);
                },
              ),
              Row(
                children: [
                  Text('Type:'),
                  Radio<String>(
                    value: 'income',
                    groupValue: type,
                    onChanged: (value) => setState(() => type = value!),
                  ),
                  Text('Income'),
                  Radio<String>(
                    value: 'expense',
                    groupValue: type,
                    onChanged: (value) => setState(() => type = value!),
                  ),
                  Text('Expense'),
                ],
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Notes (Optional)'),
                onSaved: (value) => notes = value,
              ),
              ElevatedButton(
                onPressed: _pickReceipt,
                child: Text(
                  receipt == null ? 'Upload Receipt' : 'Receipt Uploaded',
                ),
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => _saveTransaction(provider),
                child: Text('Save Transaction'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
