import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart'
    as http;

class AddTransactionPage
    extends StatefulWidget {

  final String token;

  const AddTransactionPage({

    super.key,

    required this.token,
  });

  @override
  State<AddTransactionPage>
      createState() =>
          _AddTransactionPageState();
}

class _AddTransactionPageState
    extends State<
        AddTransactionPage> {

  final TextEditingController
      titleController =
          TextEditingController();

  final TextEditingController
      amountController =
          TextEditingController();

  String type = "expense";

  bool isLoading = false;

  String message = "";

  ////////////////////////////////////////////////////

  Future<void>
      addTransaction() async {

    ////////////////////////////////////////////////////
    /// VALIDATION
    ////////////////////////////////////////////////////

    if (titleController.text
            .trim()
            .isEmpty ||
        amountController.text
            .trim()
            .isEmpty) {

      setState(() {

        message =
            "Please fill all fields";
      });

      return;
    }

    ////////////////////////////////////////////////////

    setState(() {

      isLoading = true;

      message = "";
    });

    final url = Uri.parse(

      "http://192.168.162.85:8000/api/transactions/",
    );

    try {

      final response = await http.post(

        url,

        headers: {

          "Content-Type":
              "application/json",

          "Authorization":
              "Bearer ${widget.token}",
        },

        body: jsonEncode({

          "title":
              titleController.text
                  .trim(),

          "amount": double.parse(

            amountController.text
                .trim(),
          ),

          "type":
              type,
        }),
      );

      debugPrint(response.body);

      ////////////////////////////////////////////////////
      /// SUCCESS
      ////////////////////////////////////////////////////

      if (response.statusCode ==
              201 ||
          response.statusCode ==
              200) {

        Navigator.pop(context);
      }

      ////////////////////////////////////////////////////
      /// FAILED
      ////////////////////////////////////////////////////

      else {

        setState(() {

          message =
              "Failed to add transaction";
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
            "Server Error";
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

      appBar: AppBar(

        title: const Text(
          "Add Transaction",
        ),
      ),

      body: SingleChildScrollView(

        padding:
            const EdgeInsets.all(20),

        child: Column(

          children: [

            ////////////////////////////////////////////////////
            /// TITLE
            ////////////////////////////////////////////////////

            TextField(

              controller:
                  titleController,

              decoration:
                  InputDecoration(

                labelText:
                    "Title",

                border:
                    OutlineInputBorder(

                  borderRadius:
                      BorderRadius.circular(
                          12),
                ),
              ),
            ),

            const SizedBox(
                height: 20),

            ////////////////////////////////////////////////////
            /// AMOUNT
            ////////////////////////////////////////////////////

            TextField(

              controller:
                  amountController,

              keyboardType:
                  TextInputType.number,

              decoration:
                  InputDecoration(

                labelText:
                    "Amount",

                border:
                    OutlineInputBorder(

                  borderRadius:
                      BorderRadius.circular(
                          12),
                ),
              ),
            ),

            const SizedBox(
                height: 20),

            ////////////////////////////////////////////////////
            /// TYPE
            ////////////////////////////////////////////////////

            Container(

              padding:
                  const EdgeInsets.symmetric(
                horizontal: 12,
              ),

              decoration: BoxDecoration(

                border: Border.all(
                  color: Colors.grey,
                ),

                borderRadius:
                    BorderRadius.circular(
                        12),
              ),

              child: DropdownButton<String>(

                value: type,

                isExpanded: true,

                underline:
                    const SizedBox(),

                items: const [

                  DropdownMenuItem(

                    value: "income",

                    child:
                        Text("Income"),
                  ),

                  DropdownMenuItem(

                    value: "expense",

                    child:
                        Text("Expense"),
                  ),
                ],

                onChanged: (value) {

                  setState(() {

                    type = value!;
                  });
                },
              ),
            ),

            const SizedBox(
                height: 30),

            ////////////////////////////////////////////////////
            /// BUTTON
            ////////////////////////////////////////////////////

            SizedBox(

              width:
                  double.infinity,

              height: 55,

              child: ElevatedButton(

                onPressed:

                    isLoading

                        ? null

                        : addTransaction,

                child:

                    isLoading

                        ? const CircularProgressIndicator(
                            color:
                                Colors.white,
                          )

                        : const Text(

                            "Add Transaction",

                            style: TextStyle(
                              fontSize: 18,
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

              style: const TextStyle(

                color: Colors.red,

                fontWeight:
                    FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}