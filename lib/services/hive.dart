import 'package:hive_flutter/hive_flutter.dart';

class _Hive {
  Box? _box;
  _Hive() {
    init();
  }

  Future<void> init() async {
    await Hive.initFlutter();

    _box ??= await Hive.openBox("easy_share_calc_debug_1");
  }

  bool containsKey(String key) {
    if (_box == null) return false;
    return _box!.containsKey(key);
  }

  Future setValue(String key, dynamic value) async {
    if (_box == null) return;
    await _box!.put(key, value);
  }

  getValue(String key, {dynamic defaultValue}) {
    if (_box == null) return;
    return _box!.get(key, defaultValue: defaultValue);
  }

  getDefaultValue(String key, {dynamic defaultValue}) {
    if (_box == null) return;
    return _box!.get(key, defaultValue: defaultValue);
  }

  bool getBool(String key, {bool defaultValue = false}) {
    return getDefaultValue(key, defaultValue: defaultValue) ?? defaultValue;
  }

  Future setBool(String key, bool value) async {
    if (_box == null) return;
    await _box!.put(key, value);
  }

  String getString(String key, {String defaultValue = ""}) {
    return getDefaultValue(key, defaultValue: defaultValue) ?? "";
  }

  Future<void> setString(String key, String value) async =>
      await _box!.put(key, value);

  clear() async {
    await _box!.clear();
  }
}

final hive = _Hive();
