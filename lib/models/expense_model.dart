class ExpenseModel {
  final String title;
  final double amount;
  final String category;

  ExpenseModel({
    required this.title,
    required this.amount,
    required this.category,
  });

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'amount': amount,
      'category': category,
    };
  }
}
