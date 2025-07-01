import 'package:flutter/material.dart';
import 'order_form_page.dart';

class DetailPage extends StatelessWidget {
  final Map<String, dynamic> roti;

  const DetailPage({super.key, required this.roti});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(roti['nama'])),
      body: Column(
        children: [
          Image.asset(
            roti['path'] ?? 'assets/img/Roti.jpg',
            width: double.infinity,
            height: 250,
            fit: BoxFit.cover,
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  roti['nama'],
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(roti['deskripsi']),
                Text("Rp ${roti['harga']}"),
              ],
            ),
          ),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.all(16),
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (_) => OrderFormPage(
                          namaRoti: roti['nama'],
                          harga: roti['harga'],
                        ),
                  ),
                );
              },
              child: const Text("Pesan Sekarang"),
            ),
          ),
          const Spacer(),
        ],
      ),
    );
  }
}
