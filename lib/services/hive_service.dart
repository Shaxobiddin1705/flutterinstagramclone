import 'package:hive/hive.dart';

enum StorageKeys {
  UID,
  TOKEN,
}

class HiveDB{
  static String DB_NAME = "add_card_with_hive_database";
  static var box = Hive.box(DB_NAME);

  static Future<void> store(String data) async{
    await box.put('uid', data);
  }

  static Future<String?> load() async{
    var result = await box.get("uid");
    return result;
  }

  static Future<void> saveFCM(String fcmToken) async{
    await box.put('fcmToken', fcmToken);
  }

  static Future<String> loadFCM() async {
    String token = await box.get('fcmToken');
    return token;
  }

  static void remove() async{
    await box.delete('uid');
  }

}