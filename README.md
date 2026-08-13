<!--
This README describes the package. If you publish this package to pub.dev,
this README's contents appear on the landing page for your package.

For information about how to write a good package README, see the guide for
[writing package pages](https://dart.dev/guides/libraries/writing-package-pages).

For general information about developing packages, see the Dart guide for
[creating packages](https://dart.dev/guides/libraries/create-library-packages)
and the Flutter guide for
[developing packages and plugins](https://flutter.dev/developing-packages).
-->

# flutter_session_jwt

This package allows you to store the JWT token in secure storage and can decode the json web token. Since the payload is base64 encoded you can easily know the payload data stored with no password required, there are other methods available to get expiry date, issued date, and can check whether token expired or not.

This package can help you to store the JWT token in secure storage and provide you different methods to access information from the token.

> Note: Make sure to save the token before accessing other methods.

## Getting started

In your `pubspec.yaml` file within your Flutter Project:

```yaml
dependencies:
  flutter_session_jwt: <latest_version>
```

## Example Screenshot

<img src="https://user-images.githubusercontent.com/79859147/233702283-a7dc7592-ca45-49a1-952f-0d8e3efdc3dd.png" alt="Example screenshot" width="300">

## Usage

Import the package

```dart
import 'package:flutter_session_jwt/flutter_session_jwt.dart';
```

Here is an exmaple to store the JWT token post login

```dart
Future<http.Response> login(String userName , String password) async{
  var response = await http.post(
    Uri.parse('https://jsonplaceholder.typicode.com/albums'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
    body: jsonEncode(<String, String>{
      'userName': userName,
      'password': password
    }),
  );

  if(response.statusCode == 200){
    var token = response.body.token;
    await FlutterSessionJwt.saveToken(token);
  }
}
```

Once token is saved, you can access the other methods as below.

- To get payload from JWT token

```dart
//This will return payload object/map
await FlutterSessionJwt.getPayload();
```

- To retrieve saved token

```dart
//This method will return saved token for further API calls
await FlutterSessionJwt.retrieveToken();
```

- To get expiration date and time

```dart
//Make sure pass `exp` key in the payload
//This method will return expiration ```DateTime```
await FlutterSessionJwt.getExpirationDateTime();
```

- To get issued date and time

```dart
//Make sure pass `iat` key in the payload
//This method will return issuedAt ```DateTime```
 await FlutterSessionJwt.getIssuedDateTime();
```

- To get whether token has expired or not

```dart
//This will return bool with true/false
//If token expired, it will return true else false
await FlutterSessionJwt.isTokenExpired();
```

- To get the time difference between issued time and current time

```dart
//This will return the token's age since issue
await FlutterSessionJwt.getDurationFromIssuedTime();
```

- To delete the token from storage

```dart
//This will delete the token
await FlutterSessionJwt.deleteToken();
```

## Decoding a token without saving it

Every method above operates on the token saved in storage. If you just want to
inspect a token — for example checking a freshly received token's `exp` claim
before deciding whether to keep it, or decoding a token that arrived via a deep
link — use the static `decode()` method, or pass `token:` to any of the getters
above. Neither of these touches secure storage:

```dart
// Pure decode, no storage involved
final payload = FlutterSessionJwt.decode(someToken);

// Same idea for the date/expiry helpers
final isExpired = await FlutterSessionJwt.isTokenExpired(token: someToken);
final expiry = await FlutterSessionJwt.getExpirationDateTime(token: someToken);
```

## Access + refresh tokens

Most real-world auth flows issue a short-lived access token alongside a
longer-lived refresh token. `saveToken`/`retrieveToken`/`deleteToken` continue
to manage the access token as before; use the following to manage the refresh
token alongside it:

```dart
// After login, save both tokens in one call
await FlutterSessionJwt.saveTokenPair(
  accessToken: accessToken,
  refreshToken: refreshToken,
);

// Or save/retrieve the refresh token on its own
await FlutterSessionJwt.saveRefreshToken(refreshToken);
final storedRefreshToken = await FlutterSessionJwt.retrieveRefreshToken();
final hasRefreshToken = await FlutterSessionJwt.hasRefreshToken();

// When your access token has expired, call your refresh endpoint with
// storedRefreshToken, then save the new pair the same way.

// On logout, clear both tokens
await FlutterSessionJwt.deleteTokens();
```

> Note: unlike `saveToken`, `saveRefreshToken` does not validate a three-part
> JWT structure, since many backends issue opaque (non-JWT) refresh tokens.

## License

MIT
