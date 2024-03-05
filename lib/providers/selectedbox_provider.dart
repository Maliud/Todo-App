import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';

// ... other imports

class SelectedBoxProvider with ChangeNotifier {
  Map<String, dynamic> _selectedBox = {};

  Map<String, dynamic> get selectedBox => _selectedBox;

  String getFormattedDate() {
    if (_selectedBox.isNotEmpty) {
      DateTime date = DateTime(_selectedBox['year'],
          getMonthNumber(_selectedBox['month']), _selectedBox['date']);
      return DateFormat('d MMM y').format(date);
    } else {
      return '';
    }
  }

  void updateSelectedBox(Map<String, dynamic> newSelectedBox) {
    _selectedBox = newSelectedBox;
    notifyListeners();
  }

  int getMonthNumber(String monthName) {
    switch (monthName) {
      case 'Ocak':
        return 1;
      case 'Şubat':
        return 2;
      case 'Mart':
        return 3;
      case 'Nisan':
        return 4;
      case 'Mayıs':
        return 5;
      case 'Haziran':
        return 6;
      case 'Temmuz':
        return 7;
      case 'Ağustos':
        return 8;
      case 'Eylül':
        return 9;
      case 'Ekim':
        return 10;
      case 'Kasım':
        return 11;
      case 'Aralık':
        return 12;
      default:
        return 1;
    }
  }
}
