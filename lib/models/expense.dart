class Expense {
  final int? id;
  final String title;
  final double amount;
  final String category;
  final String type; // 'expense' or 'income'
  final DateTime date;
  final String? description;

  const Expense({
    this.id,
    required this.title,
    required this.amount,
    required this.category,
    required this.type,
    required this.date,
    this.description,
  });

  bool get isIncome => type == 'income';

  Map<String, Object?> toMap() => {
    'id': id,
    'title': title,
    'amount': amount,
    'category': category,
    'type': type,
    'date': date.toIso8601String(),
    'description': description,
  };

  factory Expense.fromMap(Map<String, Object?> m) => Expense(
    id: m['id'] as int?,
    title: m['title'] as String,
    amount: (m['amount'] as num).toDouble(),
    category: m['category'] as String,
    type: m['type'] as String,
    date: DateTime.parse(m['date'] as String),
    description: m['description'] as String?,
  );
}
