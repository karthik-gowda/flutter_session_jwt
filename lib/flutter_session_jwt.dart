library flutter_session_jwt;

import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Custom exception for JWT token related errors
class JwtException implements Exception {
  final String message;
  final dynamic originalError;

  const JwtException(this.message, [this.originalError]);

  @override
  String toString() =>
      'JwtException: $message${originalError != null ? ' ($originalError)' : ''}';
}

/// Custom exception for storage related errors
class JwtStorageException implements Exception {
  final String message;
  final dynamic originalError;

  const JwtStorageException(this.message, [this.originalError]);

  @override
  String toString() =>
      'JwtStorageException: $message${originalError != null ? ' ($originalError)' : ''}';
}

/// Flutter session management using JWT token.
///
/// Note: Make sure to save token using ```FlutterSessionJwt.saveToken("token here")``` before using other methods
class FlutterSessionJwt {
  static const _storage = FlutterSecureStorage();

  static const _keyJwtToken = 'jwtToken';

  /// Internal methods
  static Future<String?> _getJwtToken() async {
    try {
      return await _storage.read(key: _keyJwtToken);
    } catch (e) {
      throw JwtStorageException('Failed to read JWT token from storage', e);
    }
  }

  static Future<DateTime?> _getTokenDate({required String param}) async {
    try {
      final decodedToken = await getPayload();
      final date = decodedToken[param] as int?;
      if (date == null) {
        return null;
      }
      // convert milliseconds to valid ```DateTime```
      return DateTime.fromMillisecondsSinceEpoch(date * 1000);
    } catch (e) {
      if (e is JwtException) rethrow;
      throw JwtException('Failed to get token date for parameter: $param', e);
    }
  }

  /// Public interface

  ///Saves a JWT token with encryption
  ///
  ///It accepts ```String``` and saves the token with advanced encyption
  ///
  ///Keychain is used for iOS
  ///
  ///AES encryption is used for Android. AES secret key is encrypted with RSA and RSA key is stored in KeyStore
  static Future<void> saveToken(String jwtToken) async {
    if (jwtToken.isEmpty) {
      throw const JwtException('Token cannot be empty');
    }

    if (jwtToken.split(".").length != 3) {
      throw const JwtException(
          'Invalid token format: JWT must have three parts');
    }

    try {
      await _storage.write(
        key: _keyJwtToken,
        value: jwtToken,
      );
    } catch (e) {
      throw JwtStorageException('Failed to save JWT token', e);
    }
  }

  /// Retrieves the JWT token from storage.
  ///
  /// Returns token as ```String``` if token is saved in storage or ```null```, otherwise.
  ///
  ///```Note:```
  ///Make sure to save token using ```FlutterSessionJwt.saveToken("token here")``` method before using other methods
  static Future<String?> retrieveToken() async {
    try {
      return await _getJwtToken();
    } catch (e) {
      if (e is JwtStorageException) rethrow;
      throw JwtStorageException('Failed to retrieve token', e);
    }
  }

  ///Gets the payload for the stored JWT token.
  ///
  ///Returns ```Map<String, dynamic>``` of the payload object which is encryped in jwt token
  ///
  //////Throws [JwtException] if no valid JWT token is stored, it's malformed or its payload cannot be decoded.
  ///```Note:```
  ///Make sure to save token using ```FlutterSessionJwt.saveToken("token here")``` method before using other methods
  static Future<Map<String, dynamic>> getPayload() async {
    try {
      final token = await _getJwtToken();
      if (token == null || token.isEmpty) {
        throw const JwtException(
            'No token found: Please save a valid JWT token first');
      }

      final splitToken = token.split(".");
      if (splitToken.length != 3) {
        throw const JwtException(
            'Invalid token format: JWT must have three parts');
      }

      try {
        final payloadBase64 = splitToken[1];
        final normalizedPayload = base64.normalize(payloadBase64);
        final payloadString = utf8.decode(base64.decode(normalizedPayload));
        final decodedPayload = jsonDecode(payloadString);
        return decodedPayload;
      } on FormatException catch (e) {
        throw JwtException('Invalid payload format', e);
      } catch (e) {
        throw JwtException('Failed to decode payload', e);
      }
    } catch (e) {
      if (e is JwtException) rethrow;
      throw JwtException('Failed to get payload', e);
    }
  }

  ///Throws [JwtException] if no valid JWT token is stored.
  ///
  /// returns ```true``` if token has expired else returns ```false```
  ///
  ///```Note:```
  ///Make sure to save token using ```FlutterSessionJwt.saveToken("token here")``` method before using other methods
  static Future<bool> isTokenExpired() async {
    try {
      final expirationDate = await getExpirationDateTime();
      if (expirationDate == null) {
        throw const JwtException('No expiration date found in token');
      }
      // If current date is after the expiration date from token, then JWT token is expired
      return DateTime.now().isAfter(expirationDate);
    } catch (e) {
      if (e is JwtException) rethrow;
      throw JwtException('Failed to check token expiration', e);
    }
  }

  /// Returns the JWT token's ```DateTime``` of expiration (exp).
  ///
  /// Returns ```null``` if expiration date is not found in payload.
  ///
  /// Throws [JwtException] if no JWT token is stored.
  ///
  ///```Note:```
  ///Make sure to save token using ```FlutterSessionJwt.saveToken("token here")``` method before using other methods
  static Future<DateTime?> getExpirationDateTime() async {
    try {
      return await _getTokenDate(param: 'exp');
    } catch (e) {
      if (e is JwtException) rethrow;
      throw JwtException('Failed to get expiration date', e);
    }
  }

  /// Returns the JWT token's ```DateTime``` of issue (iat).
  ///
  /// Returns ```null``` if issue date is not found in payload.
  ///
  /// Throws [JwtException] if no JWT token is stored.
  ///
  ///```Note:```
  ///Make sure to save token using ```FlutterSessionJwt.saveToken("token here")``` method before using other methods
  static Future<DateTime?> getIssuedDateTime() async {
    try {
      return await _getTokenDate(param: 'iat');
    } catch (e) {
      if (e is JwtException) rethrow;
      throw JwtException('Failed to get issue date', e);
    }
  }

  /// Returns the ```Duration``` since the JWT token's issue.
  ///
  ///Returns null if issued date is not found in payload.
  static Future<Duration?> getDurationFromIssuedTime() async {
    try {
      final issuedAtDate = await getIssuedDateTime();
      if (issuedAtDate == null) {
        return null;
      }
      return DateTime.now().difference(issuedAtDate);
    } catch (e) {
      if (e is JwtException) rethrow;
      throw JwtException('Failed to calculate duration from issue time', e);
    }
  }

  /// Deletes the JWT token from storage.
  static Future<void> deleteToken() async {
    try {
      await _storage.delete(key: _keyJwtToken);
    } catch (e) {
      throw JwtStorageException('Failed to delete token', e);
    }
  }
}
