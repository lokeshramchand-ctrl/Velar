class Transaction {
  final String description;
  final double amount;
  final String category;
  final DateTime date;

  Transaction({
    required this.description,
    required this.amount,
    required this.category,
    required this.date,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      description: json['description'],
      amount: (json['amount'] as num).toDouble(),
      category: json['category'],
      date: DateTime.parse(json['date']),
    );
  }
}
