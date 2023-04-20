import 'dart:developer';

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
                      validator: (value) =>
                          value!.isEmpty ? 'Field cannot be empty' : null,
                      controller: _tokenInputController,
                      onChanged: (value) {},
                      style: const TextStyle(
                        fontSize: 16,
                      ),
                      textAlign: TextAlign.start,
                      decoration: InputDecoration(
                        hintStyle: const TextStyle(fontWeight: FontWeight.w400),
                        hintText: "Enter token here",
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 11),
                        fillColor: const Color.fromRGBO(237, 237, 237, 1),
                        filled: true,
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(4),
                          borderSide: const BorderSide(
                              color: Color.fromRGBO(237, 237, 237, 1)),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(4),
                          borderSide: const BorderSide(
                              color: Color.fromRGBO(255, 255, 255, 1)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(4),
                          borderSide: const BorderSide(
                              color: Color.fromRGBO(237, 237, 237, 1)),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 20),
                    child: SizedBox(
                      width: 150,
                      height: 45,
                      child: ElevatedButton(
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              var token = _tokenInputController.text;
                              FlutterSessionJwt.saveToken(token);
                              print("Token saved");
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
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void showAlert(msg) {
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
