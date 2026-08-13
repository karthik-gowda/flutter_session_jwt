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
  static const _keyRefreshToken = 'jwtRefreshToken';

  /// Internal methods
  static Future<String?> _getJwtToken() async {
    try {
      return await _storage.read(key: _keyJwtToken);
    } catch (e) {
      throw JwtStorageException('Failed to read JWT token from storage', e);
    }
  }

  static void _validateFormat(String token) {
    if (token.isEmpty) {
      throw const JwtException('Token cannot be empty');
    }

    if (token.split('.').length != 3) {
      throw const JwtException(
          'Invalid token format: JWT must have three parts');
    }
  }

  static Future<DateTime?> _getTokenDate({
    required String param,
    String? token,
  }) async {
    try {
      final decodedToken = await getPayload(token: token);
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

  ///Decodes any JWT string and returns its payload, without touching storage.
  ///
  ///Useful for inspecting a token before deciding to persist it, e.g. checking
  ///a freshly received token's `exp` claim, or decoding one pulled from a
  ///deep link.
  ///
  ///Throws [JwtException] if the token is empty, malformed, or its payload
  ///cannot be decoded.
  static Map<String, dynamic> decode(String token) {
    _validateFormat(token);

    try {
      final payloadBase64 = token.split('.')[1];
      final normalizedPayload = base64.normalize(payloadBase64);
      final payloadString = utf8.decode(base64.decode(normalizedPayload));
      final decodedPayload = jsonDecode(payloadString);
      if (decodedPayload is! Map<String, dynamic>) {
        throw const JwtException('Invalid payload: expected a JSON object');
      }
      return decodedPayload;
    } on JwtException {
      rethrow;
    } on FormatException catch (e) {
      throw JwtException('Invalid payload format', e);
    } catch (e) {
      throw JwtException('Failed to decode payload', e);
    }
  }

  ///Saves an access token with encryption.
  ///
  ///It accepts ```String``` and saves the token with advanced encyption
  ///
  ///Keychain is used for iOS
  ///
  ///AES encryption is used for Android. AES secret key is encrypted with RSA and RSA key is stored in KeyStore
  static Future<void> saveToken(String jwtToken) async {
    _validateFormat(jwtToken);

    try {
      await _storage.write(
        key: _keyJwtToken,
        value: jwtToken,
      );
    } catch (e) {
      throw JwtStorageException('Failed to save JWT token', e);
    }
  }

  ///Saves a refresh token in secure storage, alongside the access token.
  ///
  ///Unlike [saveToken], this does not validate the JWT three-part structure,
  ///since many backends issue opaque (non-JWT) refresh tokens.
  static Future<void> saveRefreshToken(String refreshToken) async {
    if (refreshToken.isEmpty) {
      throw const JwtException('Refresh token cannot be empty');
    }

    try {
      await _storage.write(
        key: _keyRefreshToken,
        value: refreshToken,
      );
    } catch (e) {
      throw JwtStorageException('Failed to save refresh token', e);
    }
  }

  ///Convenience method to save the access token and refresh token returned
  ///from a login or token-refresh call in a single step.
  static Future<void> saveTokenPair({
    required String accessToken,
    required String refreshToken,
  }) async {
    await saveToken(accessToken);
    await saveRefreshToken(refreshToken);
  }

  /// Retrieves the JWT access token from storage.
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

  /// Retrieves the stored refresh token, or ```null``` if none is saved.
  static Future<String?> retrieveRefreshToken() async {
    try {
      return await _storage.read(key: _keyRefreshToken);
    } catch (e) {
      throw JwtStorageException('Failed to retrieve refresh token', e);
    }
  }

  /// Returns ```true``` if a refresh token is currently stored.
  static Future<bool> hasRefreshToken() async {
    final token = await retrieveRefreshToken();
    return token != null && token.isNotEmpty;
  }

  ///Gets the payload for a JWT token.
  ///
  ///By default, decodes the stored access token. Pass [token] to decode an
  ///arbitrary token instead (e.g. the stored refresh token, or one that
  ///hasn't been saved yet) without needing to save it first.
  ///
  ///Returns ```Map<String, dynamic>``` of the payload object which is encryped in jwt token
  ///
  //////Throws [JwtException] if no valid JWT token is stored, it's malformed or its payload cannot be decoded.
  ///```Note:```
  ///Make sure to save token using ```FlutterSessionJwt.saveToken("token here")``` method before using other methods
  static Future<Map<String, dynamic>> getPayload({String? token}) async {
    try {
      final jwt = token ?? await _getJwtToken();
      if (jwt == null || jwt.isEmpty) {
        throw const JwtException(
            'No token found: Please save a valid JWT token first');
      }

      return decode(jwt);
    } catch (e) {
      if (e is JwtException) rethrow;
      throw JwtException('Failed to get payload', e);
    }
  }

  ///Throws [JwtException] if no valid JWT token is stored.
  ///
  /// returns ```true``` if token has expired else returns ```false```
  ///
  ///Pass [token] to check an arbitrary token instead of the stored access token.
  ///
  ///```Note:```
  ///Make sure to save token using ```FlutterSessionJwt.saveToken("token here")``` method before using other methods
  static Future<bool> isTokenExpired({String? token}) async {
    try {
      final expirationDate = await getExpirationDateTime(token: token);
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
  ///Pass [token] to inspect an arbitrary token instead of the stored access token.
  ///
  ///```Note:```
  ///Make sure to save token using ```FlutterSessionJwt.saveToken("token here")``` method before using other methods
  static Future<DateTime?> getExpirationDateTime({String? token}) async {
    try {
      return await _getTokenDate(param: 'exp', token: token);
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
  ///Pass [token] to inspect an arbitrary token instead of the stored access token.
  ///
  ///```Note:```
  ///Make sure to save token using ```FlutterSessionJwt.saveToken("token here")``` method before using other methods
  static Future<DateTime?> getIssuedDateTime({String? token}) async {
    try {
      return await _getTokenDate(param: 'iat', token: token);
    } catch (e) {
      if (e is JwtException) rethrow;
      throw JwtException('Failed to get issue date', e);
    }
  }

  /// Returns the ```Duration``` since the JWT token's issue.
  ///
  ///Returns null if issued date is not found in payload.
  ///
  ///Pass [token] to inspect an arbitrary token instead of the stored access token.
  static Future<Duration?> getDurationFromIssuedTime({String? token}) async {
    try {
      final issuedAtDate = await getIssuedDateTime(token: token);
      if (issuedAtDate == null) {
        return null;
      }
      return DateTime.now().difference(issuedAtDate);
    } catch (e) {
      if (e is JwtException) rethrow;
      throw JwtException('Failed to calculate duration from issue time', e);
    }
  }

  /// Deletes the access token from storage.
  ///
  /// Note: this does not remove the refresh token — use [deleteTokens] on
  /// logout if a refresh token is also stored.
  static Future<void> deleteToken() async {
    try {
      await _storage.delete(key: _keyJwtToken);
    } catch (e) {
      throw JwtStorageException('Failed to delete token', e);
    }
  }

  /// Deletes only the refresh token from storage.
  static Future<void> deleteRefreshToken() async {
    try {
      await _storage.delete(key: _keyRefreshToken);
    } catch (e) {
      throw JwtStorageException('Failed to delete refresh token', e);
    }
  }

  /// Deletes both the access token and refresh token from storage.
  ///
  /// Use this on logout instead of [deleteToken] when a refresh token is in use.
  static Future<void> deleteTokens() async {
    await deleteToken();
    await deleteRefreshToken();
  }
}
