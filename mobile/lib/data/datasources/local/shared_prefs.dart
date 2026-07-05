import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

abstract class SharedPrefs {
  Future<bool> setString(String key, String value);
  Future<String?> getString(String key);
  Future<bool> remove(String key);
  Future<bool> clear();
}

class SharedPrefsImpl implements SharedPrefs {
  final SharedPreferences sharedPreferences;
  final FlutterSecureStorage secureStorage;

  SharedPrefsImpl({
    required this.sharedPreferences,
    required this.secureStorage,
  });

  @override
  Future<bool> setString(String key, String value) async {
    if (key == 'token' || key == 'refreshToken') {
      await secureStorage.write(key: key, value: value);
      return true;
    }
    return await sharedPreferences.setString(key, value);
  }

  @override
  Future<String?> getString(String key) async {
    if (key == 'token' || key == 'refreshToken') {
      return await secureStorage.read(key: key);
    }
    return sharedPreferences.getString(key);
  }

  @override
  Future<bool> remove(String key) async {
    if (key == 'token' || key == 'refreshToken') {
      await secureStorage.delete(key: key);
      return true;
    }
    return await sharedPreferences.remove(key);
  }

  @override
  Future<bool> clear() async {
    await secureStorage.deleteAll();
    return await sharedPreferences.clear();
  }
}
