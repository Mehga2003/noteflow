import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:fl_chart/fl_chart.dart';

import 'add_transaction.dart';

class DashboardPage extends StatefulWidget {
  final String token;

  const DashboardPage({
    super.key,
    required this.token,
  });

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int currentIndex = 0;
  List transactions = [];
  double totalIncome = 0;
  double totalExpense = 0;
  double totalBalance = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      fetchTransactions();
    });
  }

  Future<void> fetchTransactions() async {
    final url = Uri.parse("http://192.168.162.85:8000/api/transactions/");

    try {
      final response = await http.get(
        url,
        headers: {
          "Authorization": "Bearer ${widget.token}",
        },
      );

      debugPrint(response.body);

      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);

        double income = 0;
        double expense = 0;

        for (var item in data) {
          double amount = double.tryParse(item['amount'].toString()) ?? 0.0;
          String type = item['type'].toString().toLowerCase().trim();

          if (type == "income") {
            income += amount;
          } else if (type == "expense") {
            expense += amount;
          }
        }

        if (mounted) {
          setState(() {
            transactions = data;
            totalIncome = income;
            totalExpense = expense;
            totalBalance = income - expense;
          });
        }
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    // Crucial Change: Recalculate pages dynamically inside build so they receive updated state variables
    final List<Widget> pages = [
      buildHomeScreen(),
      buildAnalyticsScreen(),
      buildProfileScreen(),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: pages[currentIndex],
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.cyanAccent,
        child: const Icon(
          Icons.add,
          color: Colors.black,
        ),
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddTransactionPage(
                token: widget.token,
              ),
            ),
          );

          // Refresh database on pop
          fetchTransactions();
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (index) {
          setState(() {
            currentIndex = index;
          });
        },
        backgroundColor: const Color(0xFF1E293B),
        selectedItemColor: Colors.cyanAccent,
        unselectedItemColor: Colors.white60,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: "Analytics",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: "Profile",
          ),
        ],
      ),
    );
  }

  /// HOME SCREEN
  Widget buildHomeScreen() {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Hello Mehga 👋",
              style: TextStyle(
                color: Colors.white,
                fontSize: 30,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 25),

            /// BALANCE CARD
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(25),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFF7F5AF0),
                    Color(0xFF2CB67D),
                  ],
                ),
                borderRadius: BorderRadius.circular(25),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Total Balance",
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "₹ ${totalBalance.toStringAsFixed(2)}",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 38,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),

            /// RECENT TRANSACTIONS
            const Text(
              "Recent Transactions",
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            transactions.isEmpty
                ? const Text(
                    "No Transactions Yet",
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  )
                : Column(
                    children: transactions.map(
                      (item) {
                        bool isIncome = item['type'].toString().toLowerCase().trim() == "income";

                        return Container(
                          margin: const EdgeInsets.only(bottom: 15),
                          padding: const EdgeInsets.all(15),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1E293B),
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: Row(
                            children: [
                              CircleAvatar(
                                backgroundColor: isIncome ? Colors.green : Colors.red,
                                child: Icon(
                                  isIncome ? Icons.arrow_downward : Icons.arrow_upward,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(width: 15),
                              Expanded(
                                child: Text(
                                  item['title'] ?? "",
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                  ),
                                ),
                              ),
                              Text(
                                "₹ ${item['amount']}",
                                style: TextStyle(
                                  color: isIncome ? Colors.green : Colors.red,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ).toList(),
                  ),
          ],
        ),
      ),
    );
  }

  /// ANALYTICS SCREEN
  Widget buildAnalyticsScreen() {
    double savings = totalIncome - totalExpense;
    bool hasData = totalIncome > 0 || totalExpense > 0;

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Analytics 📊",
              style: TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 30),

            /// CHART CONTAINER
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF1E293B),
                borderRadius: BorderRadius.circular(25),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    "Income vs Expense",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 25),
                  !hasData
                      ? const Column(
                          children: [
                            Icon(
                              Icons.pie_chart,
                              color: Colors.white54,
                              size: 100,
                            ),
                            const SizedBox(height: 20),
                            Text(
                              "No analytics available",
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 18,
                              ),
                            ),
                          ],
                        )
                      : Container(
                          height: 280,
                          width: MediaQuery.of(context).size.width,
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          child: PieChart(
                            PieChartData(
                              sectionsSpace: 4,
                              centerSpaceRadius: 45,
                              borderData: FlBorderData(show: false),
                              sections: [
                                PieChartSectionData(
                                  value: totalIncome <= 0 ? 0.01 : totalIncome,
                                  color: Colors.green,
                                  radius: 70,
                                  title: "Income\n₹${totalIncome.toStringAsFixed(0)}",
                                  titleStyle: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  ),
                                ),
                                PieChartSectionData(
                                  value: totalExpense <= 0 ? 0.01 : totalExpense,
                                  color: Colors.red,
                                  radius: 70,
                                  title: "Expense\n₹${totalExpense.toStringAsFixed(0)}",
                                  titleStyle: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                            swapAnimationDuration: const Duration(milliseconds: 150),
                            swapAnimationCurve: Curves.linear,
                          ),
                        ),
                  const SizedBox(height: 25),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      legendItem(Colors.green, "Income"),
                      legendItem(Colors.red, "Expense"),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            analyticsCard(
              "Income",
              "₹ ${totalIncome.toStringAsFixed(2)}",
              Colors.green,
            ),
            const SizedBox(height: 20),
            analyticsCard(
              "Expense",
              "₹ ${totalExpense.toStringAsFixed(2)}",
              Colors.red,
            ),
            const SizedBox(height: 20),
            analyticsCard(
              "Savings",
              "₹ ${savings.toStringAsFixed(2)}",
              Colors.cyanAccent,
            ),
          ],
        ),
      ),
    );
  }

  /// ANALYTICS CARD
  Widget analyticsCard(String title, String value, Color color) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 30,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  /// LEGEND ITEM
  Widget legendItem(Color color, String text) {
    return Row(
      children: [
        Container(
          width: 15,
          height: 15,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(5),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
          ),
        ),
      ],
    );
  }

  /// PROFILE SCREEN
  Widget buildProfileScreen() {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const CircleAvatar(
              radius: 60,
              backgroundColor: Colors.cyanAccent,
              child: Icon(
                Icons.person,
                size: 70,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              "Mehga Rani",
              style: TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              "Flutter Developer",
              style: TextStyle(
                color: Colors.white70,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                profileCard(
                  "Transactions",
                  transactions.length.toString(),
                  Icons.wallet,
                  Colors.orange,
                ),
                profileCard(
                  "Balance",
                  "₹ ${totalBalance.toStringAsFixed(0)}",
                  Icons.savings,
                  Colors.green,
                ),
              ],
            ),
            const SizedBox(height: 30),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF1E293B),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  profileTile(Icons.email, "Email", "mehga@gmail.com"),
                  const Divider(color: Colors.white24),
                  profileTile(Icons.phone, "Phone", "+91 XXXXX XXXXX"),
                  const Divider(color: Colors.white24),
                  profileTile(Icons.lock, "Security", "Password Protected"),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// PROFILE CARD
  Widget profileCard(String title, String value, IconData icon, Color color) {
    return Container(
      width: 150,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 40),
          const SizedBox(height: 15),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
          ),
          ),
          const SizedBox(height: 10),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }

  /// PROFILE TILE
  Widget profileTile(IconData icon, String title, String subtitle) {
    return ListTile(
      leading: Icon(icon, color: Colors.cyanAccent),
      title: Text(
        title,
        style: const TextStyle(color: Colors.white),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(color: Colors.white70),
      ),
    );
  }
}