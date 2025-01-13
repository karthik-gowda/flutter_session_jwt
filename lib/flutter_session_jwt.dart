library flutter_session_jwt;

import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Flutter session management using JWT token.
///
/// Note: Make sure to save token using ```FlutterSessionJwt.saveToken("token here")``` before using other methods
class FlutterSessionJwt {
  static const _storage = FlutterSecureStorage();

  static const _keyJwtToken = 'jwtToken';

  /// Internal methods
  static Future<String?> _getJwtToken() async =>
      await _storage.read(key: _keyJwtToken);
  static Future<DateTime?> _getTokenDate({required String param}) async {
    final decodedToken = await getPayload();
    final date = decodedToken[param] as int?;
    if (date == null) {
      return null;
    }
    // convert milliseconds to valid ```DateTime```
    return DateTime.fromMillisecondsSinceEpoch(date * 1000);
  }

  /// Public interface

  ///Saves a JWT token with encryption
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
    }
  }

  /// Retrieves the JWT token from storage.
  ///
  /// Returns token as ```String``` if token is saved in storage or ```null```, otherwise.
  ///
  ///```Note:```
  ///Make sure to save token using ```FlutterSessionJwt.saveToken("token here")``` method before using other methods
  static Future<String?> retrieveToken() async => await _getJwtToken();

  ///Gets the payload for the stored JWT token.
  ///
  ///Returns ```Map<String, dynamic>``` of the payload object which is encryped in jwt token
  ///
  //////Throws [FormatException] if no valid JWT token is stored, it's malformed or its payload cannot be decoded.
  ///```Note:```
  ///Make sure to save token using ```FlutterSessionJwt.saveToken("token here")``` method before using other methods
  static Future<Map<String, dynamic>> getPayload() async {
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

  ///Throws [FormatException] if no valid JWT token is stored.
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

  /// Returns the JWT token's ```DateTime``` of expiration (exp).
  ///
  /// Returns ```null``` if expiration date is not found in payload.
  ///
  /// Throws [FormatException] if no JWT token is stored.
  ///
  ///```Note:```
  ///Make sure to save token using ```FlutterSessionJwt.saveToken("token here")``` method before using other methods
  static Future<DateTime?> getExpirationDateTime() async =>
      await _getTokenDate(param: 'exp');

  /// Returns the JWT token's ```DateTime``` of issue (iat).
  ///
  /// Returns ```null``` if issue date is not found in payload.
  ///
  /// Throws [FormatException] if no JWT token is stored.
  ///
  ///```Note:```
  ///Make sure to save token using ```FlutterSessionJwt.saveToken("token here")``` method before using other methods
  static Future<DateTime?> getIssuedDateTime() async =>
      await _getTokenDate(param: 'iat');

  /// Returns the ```Duration``` since the JWT token's issue.
  ///
  ///Returns null if issued date is not found in payload.
  static Future<Duration?> getDurationFromIssuedTime() async {
    final issuedAtDate = await getIssuedDateTime();
    if (issuedAtDate == null) {
      return null;
    }
    return DateTime.now().difference(issuedAtDate);
  }

  /// Deletes the JWT token from storage.
  static Future<void> deleteToken() async {
    await _storage.delete(key: _keyJwtToken);
  }
}
