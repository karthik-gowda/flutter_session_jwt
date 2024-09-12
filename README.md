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
//This method will return expiration date and time
await FlutterSessionJwt.getExpirationDateTime();
```

- To get issued date and time

```dart
//Make sure pass `iat` key in the payload
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
//This will return the token time
await FlutterSessionJwt.getDurationFromIssuedTime();
```

## License

MIT
