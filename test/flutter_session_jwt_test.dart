import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_session_jwt/flutter_session_jwt.dart';
import 'package:flutter_test/flutter_test.dart';

String _encodeSegment(Object value) =>
    base64Url.encode(utf8.encode(jsonEncode(value))).replaceAll('=', '');

String _makeToken(
  Map<String, dynamic> payload, {
  Map<String, dynamic>? header,
}) {
  final headerSegment = _encodeSegment(header ?? {'alg': 'HS256', 'typ': 'JWT'});
  final payloadSegment = _encodeSegment(payload);
  return '$headerSegment.$payloadSegment.fakesignature';
}

int _epochSeconds(DateTime dateTime) =>
    dateTime.millisecondsSinceEpoch ~/ 1000;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    // Resets the secure storage backing FlutterSessionJwt to an empty,
    // in-memory implementation before every test.
    FlutterSecureStorage.setMockInitialValues({});
  });

  group('decode', () {
    test('decodes a well-formed token payload without storage', () {
      final token = _makeToken({'sub': '123', 'role': 'admin'});
      expect(FlutterSessionJwt.decode(token), {'sub': '123', 'role': 'admin'});
    });

    test('throws JwtException for an empty token', () {
      expect(() => FlutterSessionJwt.decode(''), throwsA(isA<JwtException>()));
    });

    test('throws JwtException for a token without three parts', () {
      expect(
        () => FlutterSessionJwt.decode('abc.def'),
        throwsA(isA<JwtException>()),
      );
    });

    test('throws JwtException for an invalid base64 payload segment', () {
      expect(
        () => FlutterSessionJwt.decode('a.###.c'),
        throwsA(isA<JwtException>()),
      );
    });

    test('throws JwtException when the payload is not a JSON object', () {
      final arraySegment = _encodeSegment([1, 2, 3]);
      expect(
        () => FlutterSessionJwt.decode('a.$arraySegment.c'),
        throwsA(isA<JwtException>()),
      );
    });
  });

  group('saveToken / retrieveToken / deleteToken', () {
    test('round-trips an access token through storage', () async {
      final token = _makeToken({'sub': '1'});
      await FlutterSessionJwt.saveToken(token);
      expect(await FlutterSessionJwt.retrieveToken(), token);
    });

    test('throws for an empty token', () {
      expect(
        () => FlutterSessionJwt.saveToken(''),
        throwsA(isA<JwtException>()),
      );
    });

    test('throws for a malformed token', () {
      expect(
        () => FlutterSessionJwt.saveToken('not-a-jwt'),
        throwsA(isA<JwtException>()),
      );
    });

    test('retrieveToken returns null when nothing is saved', () async {
      expect(await FlutterSessionJwt.retrieveToken(), isNull);
    });

    test('deleteToken removes the stored access token', () async {
      final token = _makeToken({'sub': '1'});
      await FlutterSessionJwt.saveToken(token);
      await FlutterSessionJwt.deleteToken();
      expect(await FlutterSessionJwt.retrieveToken(), isNull);
    });
  });

  group('getPayload', () {
    test('reads the payload from the stored access token', () async {
      final token = _makeToken({'sub': '42'});
      await FlutterSessionJwt.saveToken(token);
      expect(await FlutterSessionJwt.getPayload(), {'sub': '42'});
    });

    test('reads the payload from an explicit token without touching storage',
        () async {
      final token = _makeToken({'sub': 'explicit'});
      expect(
        await FlutterSessionJwt.getPayload(token: token),
        {'sub': 'explicit'},
      );
      expect(await FlutterSessionJwt.retrieveToken(), isNull);
    });

    test('throws when no token is stored and none is provided', () {
      expect(
        () => FlutterSessionJwt.getPayload(),
        throwsA(isA<JwtException>()),
      );
    });
  });

  group('expiration / issued helpers', () {
    test('getExpirationDateTime reads the exp claim', () async {
      final exp = DateTime.now().add(const Duration(hours: 1));
      final token = _makeToken({'exp': _epochSeconds(exp)});
      await FlutterSessionJwt.saveToken(token);

      final result = await FlutterSessionJwt.getExpirationDateTime();
      expect(result!.difference(exp).inSeconds.abs() < 2, isTrue);
    });

    test('getExpirationDateTime returns null when exp is missing', () async {
      await FlutterSessionJwt.saveToken(_makeToken({'sub': '1'}));
      expect(await FlutterSessionJwt.getExpirationDateTime(), isNull);
    });

    test('getIssuedDateTime reads the iat claim', () async {
      final iat = DateTime.now().subtract(const Duration(minutes: 5));
      final token = _makeToken({'iat': _epochSeconds(iat)});
      await FlutterSessionJwt.saveToken(token);

      final result = await FlutterSessionJwt.getIssuedDateTime();
      expect(result!.difference(iat).inSeconds.abs() < 2, isTrue);
    });

    test('isTokenExpired returns true for an expired token', () async {
      final token = _makeToken({
        'exp': _epochSeconds(DateTime.now().subtract(const Duration(hours: 1))),
      });
      await FlutterSessionJwt.saveToken(token);
      expect(await FlutterSessionJwt.isTokenExpired(), isTrue);
    });

    test('isTokenExpired returns false for a valid token', () async {
      final token = _makeToken({
        'exp': _epochSeconds(DateTime.now().add(const Duration(hours: 1))),
      });
      await FlutterSessionJwt.saveToken(token);
      expect(await FlutterSessionJwt.isTokenExpired(), isFalse);
    });

    test('isTokenExpired throws when exp is missing', () async {
      await FlutterSessionJwt.saveToken(_makeToken({'sub': '1'}));
      expect(
        () => FlutterSessionJwt.isTokenExpired(),
        throwsA(isA<JwtException>()),
      );
    });

    test('isTokenExpired accepts an explicit token without saving it',
        () async {
      final token = _makeToken({
        'exp': _epochSeconds(DateTime.now().subtract(const Duration(hours: 1))),
      });
      expect(await FlutterSessionJwt.isTokenExpired(token: token), isTrue);
      expect(await FlutterSessionJwt.retrieveToken(), isNull);
    });

    test('getDurationFromIssuedTime returns the age of an explicit token',
        () async {
      final iat = DateTime.now().subtract(const Duration(minutes: 10));
      final token = _makeToken({'iat': _epochSeconds(iat)});

      final duration =
          await FlutterSessionJwt.getDurationFromIssuedTime(token: token);
      expect(duration!.inMinutes, greaterThanOrEqualTo(9));
    });

    test('getDurationFromIssuedTime returns null when iat is missing',
        () async {
      final token = _makeToken({'sub': '1'});
      expect(
        await FlutterSessionJwt.getDurationFromIssuedTime(token: token),
        isNull,
      );
    });
  });

  group('refresh token', () {
    test('saveRefreshToken / retrieveRefreshToken round-trip', () async {
      await FlutterSessionJwt.saveRefreshToken('opaque-refresh-token');
      expect(
        await FlutterSessionJwt.retrieveRefreshToken(),
        'opaque-refresh-token',
      );
    });

    test('saveRefreshToken does not require a JWT-shaped value', () async {
      await FlutterSessionJwt.saveRefreshToken('not-a-jwt-but-thats-fine');
      expect(
        await FlutterSessionJwt.retrieveRefreshToken(),
        'not-a-jwt-but-thats-fine',
      );
    });

    test('saveRefreshToken throws for an empty string', () {
      expect(
        () => FlutterSessionJwt.saveRefreshToken(''),
        throwsA(isA<JwtException>()),
      );
    });

    test('retrieveRefreshToken returns null when nothing is saved', () async {
      expect(await FlutterSessionJwt.retrieveRefreshToken(), isNull);
    });

    test('hasRefreshToken reflects whether a refresh token is stored',
        () async {
      expect(await FlutterSessionJwt.hasRefreshToken(), isFalse);
      await FlutterSessionJwt.saveRefreshToken('r1');
      expect(await FlutterSessionJwt.hasRefreshToken(), isTrue);
    });

    test('deleteRefreshToken removes only the refresh token', () async {
      final token = _makeToken({'sub': '1'});
      await FlutterSessionJwt.saveToken(token);
      await FlutterSessionJwt.saveRefreshToken('r1');

      await FlutterSessionJwt.deleteRefreshToken();

      expect(await FlutterSessionJwt.retrieveRefreshToken(), isNull);
      expect(await FlutterSessionJwt.retrieveToken(), token);
    });

    test('saveTokenPair saves both the access and refresh tokens', () async {
      final token = _makeToken({'sub': '1'});
      await FlutterSessionJwt.saveTokenPair(
        accessToken: token,
        refreshToken: 'r1',
      );

      expect(await FlutterSessionJwt.retrieveToken(), token);
      expect(await FlutterSessionJwt.retrieveRefreshToken(), 'r1');
    });

    test('deleteTokens clears both the access and refresh tokens', () async {
      final token = _makeToken({'sub': '1'});
      await FlutterSessionJwt.saveTokenPair(
        accessToken: token,
        refreshToken: 'r1',
      );

      await FlutterSessionJwt.deleteTokens();

      expect(await FlutterSessionJwt.retrieveToken(), isNull);
      expect(await FlutterSessionJwt.retrieveRefreshToken(), isNull);
    });
  });
}
