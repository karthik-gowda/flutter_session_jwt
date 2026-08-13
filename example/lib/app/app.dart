import 'package:flutter/material.dart';
import 'package:flutter_session_jwt/flutter_session_jwt.dart';

class FlutterSessionJwtDemo extends StatefulWidget {
  const FlutterSessionJwtDemo({super.key});

  @override
  State<FlutterSessionJwtDemo> createState() => _FlutterSessionJwtDemoState();
}

class _FlutterSessionJwtDemoState extends State<FlutterSessionJwtDemo> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _tokenInputController = TextEditingController();
  final TextEditingController _refreshTokenInputController =
      TextEditingController();
  final TextEditingController _decodeInputController =
      TextEditingController();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text("Flutter Session using JWT")),
        body: SingleChildScrollView(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Form(
                    key: _formKey,
                    child: TextFormField(
                      maxLines: 7,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      validator: validateToken,
                      controller: _tokenInputController,
                      onChanged: (value) {},
                      style: const TextStyle(
                        fontSize: 16,
                      ),
                      textAlign: TextAlign.start,
                      decoration: _fieldDecoration("Enter access token here"),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 20),
                    child: SizedBox(
                      width: 150,
                      height: 45,
                      child: ElevatedButton(
                          onPressed: () async {
                            if (_formKey.currentState!.validate()) {
                              var token = _tokenInputController.text;
                              await FlutterSessionJwt.saveToken(token);
                            }
                          },
                          child: const Text(
                            "Save Token",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          )),
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  const Divider(
                    thickness: 2,
                  ),
                  const Text(
                    "Other useful methods",
                    style: TextStyle(fontSize: 20),
                  ),
                  const Text("[Save token before using other methods]"),
                  Padding(
                    padding: const EdgeInsets.only(top: 20),
                    child: SizedBox(
                      width: 180,
                      height: 45,
                      child: ElevatedButton(
                          onPressed: () async {
                            if (_formKey.currentState!.validate()) {
                              var payload =
                                  await FlutterSessionJwt.retrieveToken();
                              showAlert(payload.toString());
                            }
                          },
                          child: const Text(
                            "Retrieve token",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          )),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 20),
                    child: SizedBox(
                      width: 150,
                      height: 45,
                      child: ElevatedButton(
                          onPressed: () async {
                            if (_formKey.currentState!.validate()) {
                              var payload =
                                  await FlutterSessionJwt.getPayload();
                              showAlert(payload.toString());
                            }
                          },
                          child: const Text(
                            "Get payload",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          )),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 20),
                    child: SizedBox(
                      width: 250,
                      height: 45,
                      child: ElevatedButton(
                          onPressed: () async {
                            if (_formKey.currentState!.validate()) {
                              var expiry = await FlutterSessionJwt
                                  .getExpirationDateTime();
                              showAlert(expiry.toString());
                            }
                          },
                          child: const Text(
                            "Get expiration date time",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          )),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 20),
                    child: SizedBox(
                      width: 250,
                      height: 45,
                      child: ElevatedButton(
                          onPressed: () async {
                            if (_formKey.currentState!.validate()) {
                              var issued =
                                  await FlutterSessionJwt.getIssuedDateTime();
                              showAlert(issued.toString());
                            }
                          },
                          child: const Text(
                            "Get issued date time",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          )),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 20),
                    child: SizedBox(
                      width: 250,
                      height: 45,
                      child: ElevatedButton(
                          onPressed: () async {
                            if (_formKey.currentState!.validate()) {
                              var isExpired =
                                  await FlutterSessionJwt.isTokenExpired();
                              showAlert(isExpired.toString());
                            }
                          },
                          child: const Text(
                            "Has token expired?",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          )),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Divider(thickness: 2),
                  const Text(
                    "Decode without saving",
                    style: TextStyle(fontSize: 20),
                  ),
                  const Text(
                    "[Inspect any token's payload/expiry without touching storage]",
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 20),
                    child: TextField(
                      maxLines: 7,
                      controller: _decodeInputController,
                      style: const TextStyle(fontSize: 16),
                      decoration: _fieldDecoration("Paste any token here"),
                    ),
                  ),
                  Wrap(
                    alignment: WrapAlignment.center,
                    children: [
                      _actionButton(
                        label: "Decode payload",
                        onPressed: () => _runSafely(() {
                          final payload = FlutterSessionJwt.decode(
                            _decodeInputController.text,
                          );
                          showAlert(payload.toString());
                        }),
                      ),
                      _actionButton(
                        label: "Is this token expired?",
                        onPressed: () => _runSafely(() async {
                          final isExpired = await FlutterSessionJwt
                              .isTokenExpired(token: _decodeInputController.text);
                          showAlert(isExpired.toString());
                        }),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Divider(thickness: 2),
                  const Text(
                    "Access + refresh tokens",
                    style: TextStyle(fontSize: 20),
                  ),
                  const Text(
                    "[Manage a refresh token alongside the access token above]",
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 20),
                    child: TextField(
                      controller: _refreshTokenInputController,
                      style: const TextStyle(fontSize: 16),
                      decoration: _fieldDecoration("Enter refresh token here"),
                    ),
                  ),
                  Wrap(
                    alignment: WrapAlignment.center,
                    children: [
                      _actionButton(
                        label: "Save token pair",
                        onPressed: () => _runSafely(() async {
                          await FlutterSessionJwt.saveTokenPair(
                            accessToken: _tokenInputController.text,
                            refreshToken: _refreshTokenInputController.text,
                          );
                          showAlert("Saved access + refresh tokens");
                        }),
                      ),
                      _actionButton(
                        label: "Retrieve refresh token",
                        onPressed: () => _runSafely(() async {
                          final refreshToken =
                              await FlutterSessionJwt.retrieveRefreshToken();
                          showAlert(refreshToken.toString());
                        }),
                      ),
                      _actionButton(
                        label: "Has refresh token?",
                        onPressed: () => _runSafely(() async {
                          final hasRefreshToken =
                              await FlutterSessionJwt.hasRefreshToken();
                          showAlert(hasRefreshToken.toString());
                        }),
                      ),
                      _actionButton(
                        label: "Delete tokens (logout)",
                        onPressed: () => _runSafely(() async {
                          await FlutterSessionJwt.deleteTokens();
                          showAlert("Deleted access + refresh tokens");
                        }),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _fieldDecoration(String hintText) {
    return InputDecoration(
      hintStyle: const TextStyle(fontWeight: FontWeight.w400),
      hintText: hintText,
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
      fillColor: const Color.fromRGBO(237, 237, 237, 1),
      filled: true,
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(4),
        borderSide: const BorderSide(color: Color.fromRGBO(237, 237, 237, 1)),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(4),
        borderSide: const BorderSide(color: Color.fromRGBO(255, 255, 255, 1)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(4),
        borderSide: const BorderSide(color: Color.fromRGBO(237, 237, 237, 1)),
      ),
    );
  }

  Widget _actionButton({
    required String label,
    required VoidCallback onPressed,
  }) {
    return Padding(
      padding: const EdgeInsets.only(top: 20, left: 6, right: 6),
      child: SizedBox(
        width: 220,
        height: 45,
        child: ElevatedButton(
          onPressed: onPressed,
          child: Text(
            label,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }

  /// Runs [action] and surfaces any [JwtException]/[JwtStorageException] as
  /// an alert instead of letting the demo crash.
  void _runSafely(Function action) async {
    try {
      final result = action();
      if (result is Future) {
        await result;
      }
    } on JwtException catch (e) {
      showAlert(e.toString());
    } on JwtStorageException catch (e) {
      showAlert(e.toString());
    }
  }

  String? validateToken(String? value) {
    if (value!.isEmpty) {
      return 'Field cannot be empty';
    } else if (value.split(".").length != 3) {
      return 'Enter a valid token';
    } else {}
    return null;
  }

  void showAlert(String msg) {
    var alert = AlertDialog(
        title: const Text("Flutter session JWT"),
        content: Text(msg),
        actions: <Widget>[
          TextButton(
              child: const Text(
                "Ok",
              ),
              onPressed: () {
                Navigator.pop(context);
              })
        ]);
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) => alert);
  }
}
