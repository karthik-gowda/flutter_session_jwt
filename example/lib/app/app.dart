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
        body: Center(
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
                            log("Token saved");
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}
