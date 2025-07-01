import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'db_helper.dart';

class OrderFormPage extends StatefulWidget {
  final String namaRoti;
  final int harga;

  const OrderFormPage({super.key, required this.namaRoti, required this.harga});

  @override
  State<OrderFormPage> createState() => _OrderFormPageState();
}

class _OrderFormPageState extends State<OrderFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();

  double? _latitude;
  double? _longitude;
  String _address = "Lokasi belum diambil";
  bool _isLoadingLocation = false;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _fetchLocationAndAddress() async {
    setState(() {
      _isLoadingLocation = true;
      _address = "Meminta izin lokasi...";
    });

    final permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      setState(() {
        _address =
            "Izin lokasi ditolak. Harap aktifkan di pengaturan aplikasi.";
        _isLoadingLocation = false;
      });
      return;
    }

    try {
      setState(() {
        _address = "Sedang mengambil koordinat GPS...";
      });
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      ).timeout(const Duration(seconds: 15));

      setState(() {
        _latitude = position.latitude;
        _longitude = position.longitude;
        _address = "Koordinat didapat, mengubah menjadi alamat...";
      });

      final placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        final p = placemarks.first;
        _address =
            "${p.street}, ${p.subLocality}, ${p.locality}, ${p.subAdministrativeArea}";
      } else {
        _address = "Alamat tidak dapat ditemukan.";
      }
    } on TimeoutException {
      _address = "Gagal mendapatkan lokasi: Waktu habis (Timeout).";
    } catch (e) {
      _address = "Gagal mengambil alamat: Periksa koneksi internet.";
    } finally {
      setState(() {
        _isLoadingLocation = false;
      });
    }
  }

  Future<void> _saveOrder() async {
    if (_latitude == null || _longitude == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Harap ambil lokasi GPS Anda terlebih dahulu."),
        ),
      );
      return;
    }
    if (_formKey.currentState!.validate()) {
      await DatabaseHelper.insertPesanan({
        'nama_roti': widget.namaRoti,
        'harga': widget.harga,
        'latitude': _latitude,
        'longitude': _longitude,
        'nama_pemesan': _nameController.text,
        'no_hp': _phoneController.text,
        'alamat': _address,
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Pesanan berhasil disimpan!")),
        );
        Navigator.popUntil(context, (route) => route.isFirst);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Form Pemesanan")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: "Nama Pemesan",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
                validator:
                    (value) =>
                        (value == null || value.isEmpty)
                            ? 'Nama tidak boleh kosong'
                            : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(
                  labelText: "Nomor HP",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.phone),
                ),
                keyboardType: TextInputType.phone,
                validator:
                    (value) =>
                        (value == null || value.isEmpty)
                            ? 'Nomor HP tidak boleh kosong'
                            : null,
              ),
              const SizedBox(height: 24),
              const Text(
                "Alamat Pengantaran (dari GPS):",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(_address),
              ),
              const SizedBox(height: 8),
              _isLoadingLocation
                  ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(8.0),
                      child: CircularProgressIndicator(),
                    ),
                  )
                  : TextButton.icon(
                    icon: const Icon(Icons.location_on),
                    label: const Text("Ambil Alamat Saya Saat Ini"),
                    onPressed: _fetchLocationAndAddress,
                  ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: _saveOrder,
                icon: const Icon(Icons.save),
                label: const Text("Simpan Pesanan"),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  textStyle: const TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
