class Credit {
  final int? id;
  final String creditType; // Subscriptions, Loan, Bill, Other
  final String name; // the "To" field
  final double amount;
  final DateTime dueDate;
  final String planType; // Monthly, One-Time, Yearly

  const Credit({
    this.id,
    required this.creditType,
    required this.name,
    required this.amount,
    required this.dueDate,
    required this.planType,
  });

  Map<String, Object?> toMap() => {
    'id': id,
    'credit_type': creditType,
    'name': name,
    'amount': amount,
    'due_date': dueDate.toIso8601String(),
    'plan_type': planType,
  };

  factory Credit.fromMap(Map<String, Object?> m) => Credit(
    id: m['id'] as int?,
    creditType: m['credit_type'] as String,
    name: m['name'] as String,
    amount: (m['amount'] as num).toDouble(),
    dueDate: DateTime.parse(m['due_date'] as String),
    planType: m['plan_type'] as String,
  );
}
