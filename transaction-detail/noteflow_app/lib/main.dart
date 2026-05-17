import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'dashboard.dart';

void main() {

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {

  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {

    return MaterialApp(

      debugShowCheckedModeBanner: false,

      home: const LoginPage(),
    );
  }
}

class LoginPage extends StatefulWidget {

  const LoginPage({super.key});

  @override
  State<LoginPage> createState() =>
      _LoginPageState();
}

class _LoginPageState
    extends State<LoginPage> {

  final TextEditingController
      usernameController =
          TextEditingController();

  final TextEditingController
      passwordController =
          TextEditingController();

  String message = "";

  bool isLoading = false;

  ////////////////////////////////////////////////////

  Future<void> loginUser() async {

    final url = Uri.parse(

      "http://192.168.162.85:8000/api/token/",
    );

    setState(() {

      isLoading = true;
    });

    try {

      final response = await http.post(

        url,

        headers: {

          "Content-Type":
              "application/json",
        },

        body: jsonEncode({

          "username":
              usernameController.text
                  .trim(),

          "password":
              passwordController.text
                  .trim(),
        }),
      );

      debugPrint(
        response.statusCode.toString(),
      );

      debugPrint(response.body);

      ////////////////////////////////////////////////////
      /// SUCCESS
      ////////////////////////////////////////////////////

      if (response.statusCode == 200) {

        final data =
            jsonDecode(response.body);

        String accessToken =
            data['access'];

        setState(() {

          message =
              "Login Successful ✅";
        });

        Navigator.push(

          context,

          MaterialPageRoute(

            builder: (context) =>

                DashboardPage(
                  token:
                      accessToken,
                ),
          ),
        );
      }

      ////////////////////////////////////////////////////
      /// INVALID LOGIN
      ////////////////////////////////////////////////////

      else {

        setState(() {

          message =
              "Invalid Username or Password ❌";
        });
      }
    }

    ////////////////////////////////////////////////////
    /// ERROR
    ////////////////////////////////////////////////////

    catch (e) {

      debugPrint(e.toString());

      setState(() {

        message =
            "Server Connection Failed ❌";
      });
    }

    setState(() {

      isLoading = false;
    });
  }

  ////////////////////////////////////////////////////

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      backgroundColor:
          Colors.blueGrey[900],

      body: Center(

        child: SingleChildScrollView(

          child: Container(

            width: 350,

            padding:
                const EdgeInsets.all(20),

            margin:
                const EdgeInsets.all(20),

            decoration: BoxDecoration(

              color: Colors.white,

              borderRadius:
                  BorderRadius.circular(
                      20),
            ),

            child: Column(

              mainAxisSize:
                  MainAxisSize.min,

              children: [

                const Icon(

                  Icons.account_balance_wallet,

                  size: 80,

                  color: Colors.blue,
                ),

                const SizedBox(
                    height: 20),

                const Text(

                  "Finova Login",

                  style: TextStyle(

                    fontSize: 30,

                    fontWeight:
                        FontWeight.bold,
                  ),
                ),

                const SizedBox(
                    height: 10),

                const Text(

                  "Welcome Back 👋",

                  style: TextStyle(

                    color: Colors.grey,

                    fontSize: 16,
                  ),
                ),

                const SizedBox(
                    height: 30),

                ////////////////////////////////////////////////////
                /// USERNAME
                ////////////////////////////////////////////////////

                TextField(

                  controller:
                      usernameController,

                  decoration:
                      InputDecoration(

                    labelText:
                        "Username",

                    border:
                        OutlineInputBorder(

                      borderRadius:
                          BorderRadius.circular(
                              12),
                    ),

                    prefixIcon:
                        const Icon(
                      Icons.person,
                    ),
                  ),
                ),

                const SizedBox(
                    height: 20),

                ////////////////////////////////////////////////////
                /// PASSWORD
                ////////////////////////////////////////////////////

                TextField(

                  controller:
                      passwordController,

                  obscureText: true,

                  decoration:
                      InputDecoration(

                    labelText:
                        "Password",

                    border:
                        OutlineInputBorder(

                      borderRadius:
                          BorderRadius.circular(
                              12),
                    ),

                    prefixIcon:
                        const Icon(
                      Icons.lock,
                    ),
                  ),
                ),

                const SizedBox(
                    height: 30),

                ////////////////////////////////////////////////////
                /// LOGIN BUTTON
                ////////////////////////////////////////////////////

                SizedBox(

                  width: double.infinity,

                  height: 55,

                  child: ElevatedButton(

                    onPressed:

                        isLoading

                            ? null

                            : loginUser,

                    style:
                        ElevatedButton.styleFrom(

                      backgroundColor:
                          Colors.blue,

                      shape:
                          RoundedRectangleBorder(

                        borderRadius:
                            BorderRadius.circular(
                                12),
                      ),
                    ),

                    child:

                        isLoading

                            ? const CircularProgressIndicator(
                                color:
                                    Colors.white,
                              )

                            : const Text(

                                "Login",

                                style:
                                    TextStyle(

                                  fontSize: 18,

                                  color:
                                      Colors.white,
                                ),
                              ),
                  ),
                ),

                const SizedBox(
                    height: 20),

                ////////////////////////////////////////////////////
                /// MESSAGE
                ////////////////////////////////////////////////////

                Text(

                  message,

                  textAlign:
                      TextAlign.center,

                  style:
                      const TextStyle(

                    color: Colors.red,

                    fontWeight:
                        FontWeight.bold,
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