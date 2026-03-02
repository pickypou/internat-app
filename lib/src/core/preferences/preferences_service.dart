import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

@lazySingleton
class PreferencesService {
  SharedPreferences? _prefs;

  Future<void> _initPrefs() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  Future<void> saveColumnOrder(List<String> order) async {
    await _initPrefs();
    await _prefs!.setStringList('attendance_column_order', order);
  }

  Future<List<String>?> getColumnOrder() async {
    await _initPrefs();
    return _prefs!.getStringList('attendance_column_order');
  }
}
