import 'package:flutter/material.dart';

class QuantityProvider extends ChangeNotifier {
  int _currentNumber = 1;
  List<double> _baseIngredientAmounts = [];

  int get currentNumber => _currentNumber;
  List<double> get baseIngredientAmounts => _baseIngredientAmounts;

  void setBaseIngredientAmounts(List<double> amounts) {
    _baseIngredientAmounts = amounts;
    notifyListeners();
  }

  // Silent setter for initialization - doesn't notify listeners
  void initializeBaseIngredientAmounts(List<double> amounts) {
    _baseIngredientAmounts = amounts;
  }

  void setCurrentNumber(int number) {
    _currentNumber = number;
    notifyListeners();
  }

  void increaseQuantity() {
    _currentNumber++;
    notifyListeners();
  }

  void decreaseQuantity() {
    if (_currentNumber > 1) {
      _currentNumber--;
      notifyListeners();
    }
  }

  // Calculate scaled ingredient amounts based on current number
  List<double> getScaledIngredientAmounts() {
    return _baseIngredientAmounts.map((amount) => amount * _currentNumber).toList();
  }
}