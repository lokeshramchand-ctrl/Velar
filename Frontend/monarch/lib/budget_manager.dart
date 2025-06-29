import 'package:shared_preferences/shared_preferences.dart';

class BudgetManager {
  static const _budgetKey = 'user_budget';
  
  static Future<double> getBudget() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble(_budgetKey) ?? 10000.0; // Default value
  }
  static Future<void> setBudget(double amount) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_budgetKey, amount);
  }
}
