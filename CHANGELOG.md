## 0.0.1

Releasing initial build

## 0.0.2

Added screenshot to pub

## 0.0.3

Added screenshot to pub

## 0.0.4

Added screenshot to pub

## 0.0.5

Added screenshot to pub

## 0.0.6

Upgraded dependencies to latest version

## 0.0.7

Added method `retriveToken()` to get the saved token

## 0.0.8

Added method `deleteToken()` to delete the saved token

## 1.0.0

Cleanup code structure, namings and comments

## 1.1.0

Added comprehensive error handling:
- Introduced custom `JwtException` and `JwtStorageException` classes
- Added detailed error messages for all operations
- Improved token validation and format verification
- Enhanced error handling for payload decoding
- Added proper error catching for storage operations

## 1.2.0

- Added `FlutterSessionJwt.decode(token)`, a static method to decode any JWT
  string's payload without touching secure storage
- Added an optional `token` parameter to `getPayload`, `isTokenExpired`,
  `getExpirationDateTime`, `getIssuedDateTime`, and `getDurationFromIssuedTime`
  so they can inspect an arbitrary token instead of only the stored one
- Added refresh token support: `saveRefreshToken`, `saveTokenPair`,
  `retrieveRefreshToken`, `hasRefreshToken`, `deleteRefreshToken`, and
  `deleteTokens` (clears both access and refresh tokens)
- Upgraded `flutter_secure_storage` to `^11.0.0`
- Raised minimum SDK constraints to Dart `>=3.8.0` and Flutter `>=3.19.0`
