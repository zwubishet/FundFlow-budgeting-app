class Transaction {
  final String id;
  final String userId;
  final double amount;
  final String category;
  final DateTime date;
  final String type;
  final String? notes;

  Transaction({
    required this.id,
    required this.userId,
    required this.amount,
    required this.category,
    required this.date,
    required this.type,
    this.notes,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) => Transaction(
    id: json['id'],
    userId: json['user_id'],
    amount: json['amount'].toDouble(),
    category: json['category'],
    date: DateTime.parse(json['date']),
    type: json['type'],
    notes: json['notes'],
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'user_id': userId,
    'amount': amount,
    'category': category,
    'date': date.toIso8601String(),
    'type': type,
    'notes': notes,
  };
}
