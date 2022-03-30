import 'dart:convert';

import 'package:http/http.dart';

class Network {

  static String baseApi = "fcm.googleapis.com";

  static Map<String, String> getHeaders() {
    Map<String, String> headers = {
      'Content-Type' : 'application/json',
      'Authorization':
      'key=AAAA1umoaT0:APA91bFIu3NlCAvD1tG5iO30-QMGN3TvnbDWzx1TFcsCXDSm5F2ejfmlJrGC5v92ZfRtdEosAwMSi8ZWzS-KPrdJMGDsEs1zTQIY7jTUzmLkPIRURERfFuQ2cHWoqF9LsvbInUvXrE3t'
    };
    return headers;
  }

  /* Http Requests */

  static Future<String?> POST(String api, Map<String, dynamic> body) async {
    var uri = Uri.https(baseApi, api); // http or https
    var response =
    await post(uri, headers: getHeaders(), body: jsonEncode(body));
    if (response.statusCode == 200 || response.statusCode == 201) {
      return response.body;
    }
    return null;
  }

  /* Http Apis */
  static String API_PUSH = "/fcm/send";

  /* Http Bodies */
  static Map<String, dynamic> bodyCreate(String token, String someone) {
    Map<String, dynamic> body = {};
    body.addAll({
      "notification": {
        "title":"Instagram Clone",
        "body":"$someone followed you"
      },
      "registration_ids":[token],
      "click_action":"FLUTTER_NOTIFICATION_CLICK"
    });
    return body;
  }
}