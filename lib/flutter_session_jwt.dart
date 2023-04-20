library flutter_session_jwt;

import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Flutter session management using JWT token.
///
/// Note: Make sure to save token using ```FlutterSessionJwt.saveToken("token here")``` before using other methods
class FlutterSessionJwt {
  static const _storage = FlutterSecureStorage();

  static const _keyJwtToken = 'jwtToken';

  ///Save JWT token with encryption
  ///
  ///It accepts ```String``` and saves the token with advanced encyption
  ///
  ///Keychain is used for iOS
  ///
  ///AES encryption is used for Android. AES secret key is encrypted with RSA and RSA key is stored in KeyStore
  static Future saveToken(String jwtToken) async {
    if (jwtToken.split(".").length != 3) {
      throw const FormatException("Invalid token");
    } else {
      await _storage.write(
        key: _keyJwtToken,
        value: jwtToken,
      );
      print("Token saved successfully");
    }
  }

  //To get jwt token from storage
  static _getJwtToken() async => await _storage.read(key: _keyJwtToken);

  ///Get payload from jwt token
  ///
  ///Returns Map<String, dynamic> of the payload object which is encryped in jwt token
  ///
  ///```Note:```
  ///Make sure to save token using ```FlutterSessionJwt.saveToken("token here")``` method before using other methods
  static getPayload() async {
    final token = await _getJwtToken();
    if (token == "" || token == null) {
      throw const FormatException(
          'Invalid token : Please save valid jwt token');
    } else {
      final splitTheToken =
          token.toString().split("."); // Split the token by '.'
      if (splitTheToken.length != 3) {
        //after splitting if array length is not equal to 3, thow invalid token
        throw const FormatException('Invalid token');
      }
      try {
        final payloadBase64 = splitTheToken[1]; // Payload will be at index 1

        // Normalize data to remove special characters, spaces and also validate that the length is correct (a multiple of four).
        final normalizedPayload = base64.normalize(payloadBase64);

        // Decode the normalized data to stringified object
        final payloadString = utf8.decode(base64.decode(normalizedPayload));

        // Parse the String to a Map<String, dynamic> using jsonDecode
        final decodedPayload = jsonDecode(payloadString);

        // Return the decoded payload as object/map
        return decodedPayload;
      } catch (error) {
        throw const FormatException('Invalid payload');
      }
    }
  }

  /// Throws Invalid token if parameter is not a valid JWT token.
  ///
  /// returns ```true``` if token has expired else returns ```false```
  ///
  ///```Note:```
  ///Make sure to save token using ```FlutterSessionJwt.saveToken("token here")``` method before using other methods
  static Future<bool> isTokenExpired() async {
    final expirationDate = await getExpirationDateTime();
    if (expirationDate == null) {
      return false;
    }
    // If current date is after the expiration date from token, then JWT token is expired
    return DateTime.now().isAfter(expirationDate);
  }

  static _getExpiryDate({required String param}) async {
    final decodedToken = await getPayload();
    final expiration = decodedToken[param] as int?;
    if (expiration == null) {
      return null;
    }
    return DateTime.fromMillisecondsSinceEpoch(expiration *
        1000); //to convert milliseconds to valid date time format based on parameter
  }

  /// Returns DateTime of token expiry
  ///
  ///```Note:```
  ///Make sure to save token using ```FlutterSessionJwt.saveToken("token here")``` method before using other methods
  static getExpirationDateTime() {
    return _getExpiryDate(param: 'exp');
  }

  /// Returns token issued DateTime (iat)
  ///
  /// Throws [FormatException] if parameter is not a valid JWT token.
  ///
  ///```Note:```
  ///Make sure to save token using ```FlutterSessionJwt.saveToken("token here")``` before using other methods
  static getIssuedDateTime() async {
    final issuedAtDate = await _getExpiryDate(param: 'iat');
    if (issuedAtDate == null) {
      return null;
    }
    return issuedAtDate;
  }

  /// Returns the duration from the issued date and time
  ///
  ///
  static getDurationFromIssuedTime() async {
    final issuedAtDate = await _getExpiryDate(param: 'iat');
    if (issuedAtDate == null) {
      return null;
    }
    return DateTime.now().difference(issuedAtDate); //return
  }
}
