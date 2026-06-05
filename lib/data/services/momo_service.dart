import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;

class MomoService {
  // Sandbox API credentials - Provided by user
  static const String partnerCode = "MOMO4LG620250601_TEST";
  static const String accessKey = "e6g7W44vmy1rgT7K";
  static const String secretKey = "XAAT9fHRPeJD8zhjKsZnTTUSnYEHFISa";
  static const String endpoint = "https://test-payment.momo.vn/v2/gateway/api/create";
  
  // Creates a dynamic payment URL via MoMo Sandbox API
  Future<String?> createMomoPayment({
    required double amount,
    required String orderId,
    required String description,
  }) async {
    final String requestId = orderId;
    const String requestType = "captureWallet";
    const String ipnUrl = "https://momo.vn"; // Dummy URL for testing
    const String redirectUrl = "https://momo.vn"; // Dummy URL for testing
    const String extraData = "";

    // Build raw signature string in alphabetical order of key names
    final String rawSignature = 
        "accessKey=$accessKey"
        "&amount=${amount.toInt()}"
        "&extraData=$extraData"
        "&ipnUrl=$ipnUrl"
        "&orderId=$orderId"
        "&orderInfo=$description"
        "&partnerCode=$partnerCode"
        "&redirectUrl=$redirectUrl"
        "&requestId=$requestId"
        "&requestType=$requestType";

    // Hash with HMAC-SHA256
    final keyBytes = utf8.encode(secretKey);
    final messageBytes = utf8.encode(rawSignature);
    final hmacSha256 = Hmac(sha256, keyBytes);
    final digest = hmacSha256.convert(messageBytes);
    final signature = digest.toString();

    // Prepare Request Body
    final Map<String, dynamic> requestBody = {
      "partnerCode": partnerCode,
      "partnerName": "Kinetic Gym POS",
      "storeId": "KineticStore",
      "requestId": requestId,
      "amount": amount.toInt(),
      "orderId": orderId,
      "orderInfo": description,
      "redirectUrl": redirectUrl,
      "ipnUrl": ipnUrl,
      "extraData": extraData,
      "requestType": requestType,
      "signature": signature,
      "lang": "vi"
    };

    try {
      final response = await http.post(
        Uri.parse(endpoint),
        headers: {"Content-Type": "application/json; charset=UTF-8"},
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        if (responseData["resultCode"] == 0) {
          // Success: return payUrl
          return responseData["payUrl"] as String?;
        } else {
          throw Exception("MoMo Error ${responseData["resultCode"]}: ${responseData["message"]}");
        }
      } else {
        throw Exception("Server connection error: Code ${response.statusCode}");
      }
    } catch (e) {
      rethrow;
    }
  }

  // Queries MoMo API for transaction status (checks if paid)
  // Returns true if status is Success (resultCode == 0), false otherwise
  Future<bool> checkPaymentStatus(String orderId) async {
    final String requestId = orderId;
    const String queryEndpoint = "https://test-payment.momo.vn/v2/gateway/api/query";

    // Build raw signature string in alphabetical order of key names
    final String rawSignature = 
        "accessKey=$accessKey"
        "&orderId=$orderId"
        "&partnerCode=$partnerCode"
        "&requestId=$requestId";

    // Hash with HMAC-SHA256
    final keyBytes = utf8.encode(secretKey);
    final messageBytes = utf8.encode(rawSignature);
    final hmacSha256 = Hmac(sha256, keyBytes);
    final digest = hmacSha256.convert(messageBytes);
    final signature = digest.toString();

    // Prepare Request Body
    final Map<String, dynamic> requestBody = {
      "partnerCode": partnerCode,
      "requestId": requestId,
      "orderId": orderId,
      "signature": signature,
      "lang": "vi"
    };

    try {
      final response = await http.post(
        Uri.parse(queryEndpoint),
        headers: {"Content-Type": "application/json; charset=UTF-8"},
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        final int resultCode = responseData["resultCode"] ?? -1;
        // resultCode 0 is Success
        return resultCode == 0;
      }
      return false;
    } catch (e) {
      return false;
    }
  }
}
