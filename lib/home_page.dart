// lib/home_page.dart

import 'package:flutter/material.dart';
import 'db_helper.dart';
import 'detail_page.dart';
import 'admin_login_page.dart'; // Import halaman login

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Future<List<Map<String, dynamic>>> _rotiListFuture;

  @override
  void initState() {
    super.initState();
    _rotiListFuture = _fetchData();
  }

  Future<List<Map<String, dynamic>>> _fetchData() async {
    await DatabaseHelper.getDb();
    return DatabaseHelper.getAllRoti();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rotiku'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_outline),
            tooltip: 'Login Admin',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AdminLoginPage()),
              );
            },
          ),
        ],
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _rotiListFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("Tidak ada data roti."));
          }

          final rotiList = snapshot.data!;
          return ListView.builder(
            itemCount: rotiList.length,
            itemBuilder: (context, index) {
              final item = rotiList[index];
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => DetailPage(roti: item)),
                  );
                },
                child: Card(
                  margin: const EdgeInsets.all(10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Image.asset(
                        item['path'] ?? 'assets/img/Roti.jpg',
                        height: 180,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                      Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item['nama'],
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(item['deskripsi']),
                            Text("Rp ${item['harga']}"),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
